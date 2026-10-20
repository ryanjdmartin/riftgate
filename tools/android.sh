#!/bin/sh
# The real thing on the phone: a debug APK, installed over USB and launched.
#
#   tools/android.sh            export, install, launch
#   tools/android.sh install    install and launch the last export
#   tools/android.sh log        the game's output from the phone (ctrl-c to stop)
#
# Once, on the phone: Settings > About > tap Build number seven times, then Developer
# options > USB debugging on; plug in and accept the computer's key. The desk machine has
# the 4.7.2 export templates, the Android SDK (platform-tools, build-tools 35, platform 35;
# ~/Library/Android/sdk on a Mac, %LOCALAPPDATA%\Android\Sdk on Windows), a JDK, and the
# debug keystore Godot expects; the README says how they were put there. On Windows this
# runs from Git Bash.
set -e
cd "$(dirname "$0")/.."
SDK=${ANDROID_HOME:-$HOME/Library/Android/sdk}
[ -d "$SDK" ] || [ -z "$LOCALAPPDATA" ] || SDK="$(cygpath -u "$LOCALAPPDATA")/Android/Sdk"
ADB=${ADB:-$SDK/platform-tools/adb}
case "$1" in
	log)
		exec "$ADB" logcat -s godot:V GodotApp:V
		;;
	install)
		;;
	*)
		mkdir -p build
		perl -e 'alarm 600; exec @ARGV' godot --headless --path . --export-debug Android build/riftgate.apk 2>&1 | grep -i 'error' || true
		[ -f build/riftgate.apk ] || { echo "export failed: no build/riftgate.apk" >&2; exit 1; }
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
