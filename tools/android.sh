#!/bin/sh
# The real thing on the phone: a debug APK, installed over USB and launched.
#
#   tools/android.sh            export, install, launch
#   tools/android.sh install    install and launch the last export
#   tools/android.sh log        the game's output from the phone (ctrl-c to stop)
#
# Once, on the phone: Settings > About > tap Build number seven times, then Developer
# options > USB debugging on; plug in and accept the computer's key. This Mac has the
# 4.7.2 export templates, the Android SDK (~/Library/Android/sdk: platform-tools,
# build-tools 35, platform 35), a JDK, and the debug keystore Godot expects; the README
# says how they were put there.
set -e
cd "$(dirname "$0")/.."
ADB=${ADB:-$HOME/Library/Android/sdk/platform-tools/adb}
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
"$ADB" devices | grep -q 'device$' || { echo "no phone: plug it in with USB debugging on" >&2; "$ADB" devices; exit 1; }
"$ADB" install -r build/riftgate.apk
"$ADB" shell monkey -p com.publabs.riftgate -c android.intent.category.LAUNCHER 1 > /dev/null
echo "launched; tools/android.sh log for its output"
