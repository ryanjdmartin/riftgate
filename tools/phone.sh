#!/bin/sh
# Put the game on a phone without an Android export: a Web build served over the LAN.
#
#   tools/phone.sh            export, then serve
#   tools/phone.sh serve      serve the last export
#
# Open the printed address in the phone's browser (same Wi-Fi). The canvas fills the
# screen at the phone's own pixels, so sizes and touch are real; the browser bar takes a
# strip off the height, and the frame rate is the browser's, not the game's. First load
# pulls about 40 MB over the LAN, later loads come from the browser cache.
#
# Needs the 4.7.2 export templates in ~/Library/Application Support/Godot/export_templates
# (the README says where to fetch them).
set -e
cd "$(dirname "$0")/.."
PORT=${PORT:-8060}
if [ "$1" != "serve" ]; then
	mkdir -p build/web
	perl -e 'alarm 600; exec @ARGV' godot --headless --path . --export-debug Web build/web/index.html 2>&1 | grep -i 'error' || true
	[ -f build/web/index.wasm ] || { echo "export failed: no build/web/index.wasm" >&2; exit 1; }
fi
IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo 127.0.0.1)
echo
echo "  On the phone:  http://$IP:$PORT/"
echo
exec python3 - "$PORT" <<'PY'
import functools, http.server, sys
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
srv.serve_forever()
PY
