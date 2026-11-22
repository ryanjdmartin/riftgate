#!/bin/sh
# Put the game on a phone without an Android export: a Web build served over the LAN.
#
#   tools/phone.sh            export, then serve
#   tools/phone.sh serve      serve the last export
#
# Open the printed address in the phone's browser (same Wi-Fi). It is https with a
# certificate made here, since Godot's web build refuses a plain http origin that is not
# localhost: the browser warns once ("not private"); open Advanced and proceed. The
# canvas fills the screen at the phone's own pixels, so sizes and touch are real; the
# browser bar takes a strip off the height until the first button press goes full screen,
# and the frame rate is the browser's, not the game's. First load pulls about 40 MB over
# the LAN, later loads come from the browser cache.
#
# Needs the 4.8-beta4 export templates in ~/Library/Application Support/Godot/export_templates
# on the Mac, editor_data\export_templates beside the Godot executable on the Windows PC (the
# README says where to fetch them). On Windows it runs from Git Bash, or from PowerShell as
# tools\phone, and the first serve asks Windows Firewall to let Python take connections on
# private networks.
set -e
cd "$(dirname "$0")/.."
PORT=${PORT:-8060}
# Windows' own python3 is a Microsoft Store stub that runs nothing; fall back to python.
PYTHON=python3
"$PYTHON" -c '' 2>/dev/null || PYTHON=python
if [ "$1" != "serve" ]; then
	mkdir -p build/web
	# Gone first, so a failed export cannot fall through to serving the last build.
	rm -f build/web/index.wasm
	perl -e 'alarm 600; exec @ARGV' godot --headless --path . --export-debug Web build/web/index.html > build/export.log 2>&1 || true
	if [ ! -f build/web/index.wasm ]; then
		# Godot gives the reasons on the lines after its ERROR line.
		grep -i -A 4 'error' build/export.log >&2 || tail -n 20 build/export.log >&2
		echo "export failed: no build/web/index.wasm (the whole log is build/export.log)" >&2
		exit 1
	fi
	grep -i 'error' build/export.log || true
fi
case "$(uname -s)" in
	Darwin) IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo 127.0.0.1) ;;
	# Elsewhere, the address of the interface the default route leaves by (a UDP connect sends nothing).
	*) IP=$("$PYTHON" -c 'import socket; s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(("192.0.2.1", 9)); print(s.getsockname()[0])' 2>/dev/null || echo 127.0.0.1) ;;
esac
CERT=build/phone-cert
if [ ! -f "$CERT/cert.pem" ]; then
	mkdir -p "$CERT"
	# MSYS_NO_PATHCONV: Git Bash would otherwise rewrite "/CN=riftgate" as a Windows path.
	MSYS_NO_PATHCONV=1 openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -keyout "$CERT/key.pem" -out "$CERT/cert.pem" \
		-subj "/CN=riftgate" -addext "subjectAltName=IP:$IP,DNS:localhost" 2>/dev/null
fi
echo
echo "  On the phone:  https://$IP:$PORT/   (accept the certificate warning once)"
echo
exec "$PYTHON" - "$PORT" "$CERT" <<'PY'
import functools, http.server, ssl, sys
class H(http.server.SimpleHTTPRequestHandler):
	extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map,
		".wasm": "application/wasm", ".js": "application/javascript", ".pck": "application/octet-stream"}
	def end_headers(self):
		# Cross-origin isolation, so a build with threads on would also run.
		self.send_header("Cross-Origin-Opener-Policy", "same-origin")
		self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
		self.send_header("Cache-Control", "no-cache")
		super().end_headers()
	def log_message(self, fmt, *args):
		if not str(args[0]).startswith("GET /index.wasm"):
			return
		sys.stderr.write("phone connected: %s\n" % self.client_address[0])
http.server.ThreadingHTTPServer.allow_reuse_address = True
srv = http.server.ThreadingHTTPServer(("0.0.0.0", int(sys.argv[1])), functools.partial(H, directory="build/web"))
ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(sys.argv[2] + "/cert.pem", sys.argv[2] + "/key.pem")
srv.socket = ctx.wrap_socket(srv.socket, server_side=True)
srv.serve_forever()
PY
