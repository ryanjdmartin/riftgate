#!/bin/sh
# The real thing on the phone: a debug APK, installed over USB and launched.
#
#   tools/android.sh            export, install, launch
#   tools/android.sh install    install and launch the last export
#   tools/android.sh log        the game's output from the phone (ctrl-c to stop)
#
# Once, on the phone: Settings > About > tap Build number seven times, then Developer
# options > USB debugging on; plug in and accept the computer's key. The desk machine has
# the 4.8-beta2 export templates, the Android SDK (platform-tools, build-tools 36.1, platform 36;
# ~/Library/Android/sdk on the Mac, ~/Android/Sdk on the Windows PC), a JDK, and the debug
# keystore Godot expects; the README says how they were put there. On Windows this runs from
# Git Bash, or from PowerShell as tools\android.
set -e
cd "$(dirname "$0")/.."
# The SDK: $ANDROID_HOME, or where Android Studio puts it (~/Library/Android/sdk on a Mac,
# ~/Android/Sdk on Linux and on the Windows desk machine, %LOCALAPPDATA%\Android\Sdk on Windows).
WINSDK=
[ -z "$LOCALAPPDATA" ] || WINSDK="$(cygpath -u "$LOCALAPPDATA")/Android/Sdk"
SDK=
for d in "${ANDROID_HOME:-}" "$HOME/Library/Android/sdk" "$HOME/Android/Sdk" "$WINSDK"; do
	if [ -n "$d" ] && [ -d "$d" ]; then SDK=$d; break; fi
done
[ -n "$SDK" ] || [ -n "$ADB" ] || { echo "no Android SDK found: set ANDROID_HOME" >&2; exit 1; }
ADB=${ADB:-$SDK/platform-tools/adb}
case "$1" in
	log)
		exec "$ADB" logcat -s godot:V GodotApp:V
		;;
	install)
		;;
	*)
		mkdir -p build
		# Gone first, so a failed export cannot fall through to installing the last APK.
		rm -f build/riftgate.apk
		perl -e 'alarm 600; exec @ARGV' godot --headless --path . --export-debug Android build/riftgate.apk > build/export.log 2>&1 || true
		if [ ! -f build/riftgate.apk ]; then
			# Godot gives the reasons on the lines after its ERROR line.
			grep -i -A 4 'error' build/export.log >&2 || tail -n 20 build/export.log >&2
			echo "export failed: no build/riftgate.apk (the whole log is build/export.log)" >&2
			exit 1
		fi
		grep -i 'error' build/export.log || true
		;;
esac
# tr: adb on Windows ends its lines with a carriage return.
"$ADB" devices | tr -d '\r' | grep -q 'device$' || { echo "no phone: plug it in with USB debugging on" >&2; "$ADB" devices; exit 1; }
"$ADB" install -r build/riftgate.apk || {
	echo "install failed. INSTALL_FAILED_UPDATE_INCOMPATIBLE means the copy on the phone was signed with another" >&2
	echo "machine's debug key: uninstall it once (\"$ADB\" uninstall com.publabs.riftgate; its saves go with it), then rerun." >&2
	exit 1
}
"$ADB" shell monkey -p com.publabs.riftgate -c android.intent.category.LAUNCHER 1 > /dev/null
echo "launched; tools/android.sh log for its output"
