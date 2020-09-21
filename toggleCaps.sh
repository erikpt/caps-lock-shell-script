#!/bin/bash
declare -a appBundleList

if [ -f "~/capsLockBundles.txt" ]; then
	echo "File exists!"
	readFile
else
	echo "File doesn't exist.  Creating..."
	touch ~/capsLockBundles.txt
fi

readFile() {
	apps=$(awk '{print $1}' ~/capsLockBundles.txt)
	appBundleList=${apps[@]}
}

capsOn() {
	osascript -l JavaScript -e 'ObjC.import("IOKit"); ObjC.import("CoreServices"); (() => { var ioConnect = Ref(); var state = Ref(); $.IOServiceOpen( $.IOServiceGetMatchingService( $.kIOMasterPortDefault, $.IOServiceMatching( $.kIOHIDSystemClass ) ), $.mach_task_self_, $.kIOHIDParamConnectType, ioConnect ); $.IOHIDGetModifierLockState(ioConnect, $.kIOHIDCapsLockState, state); $.IOHIDSetModifierLockState(ioConnect, $.kIOHIDCapsLockState, 1); $.IOServiceClose(ioConnect); })();'
}
capsOff() {
	osascript -l JavaScript -e 'ObjC.import("IOKit"); ObjC.import("CoreServices"); (() => { var ioConnect = Ref(); var state = Ref(); $.IOServiceOpen( $.IOServiceGetMatchingService( $.kIOMasterPortDefault, $.IOServiceMatching( $.kIOHIDSystemClass ) ), $.mach_task_self_, $.kIOHIDParamConnectType, ioConnect ); $.IOHIDGetModifierLockState(ioConnect, $.kIOHIDCapsLockState, state); $.IOHIDSetModifierLockState(ioConnect, $.kIOHIDCapsLockState, 0); $.IOServiceClose(ioConnect); })();'
}
while true; do
	readFile
	currentApp=$(lsappinfo info `lsappinfo front` | grep bundleID | awk -F'=' '{gsub(/"/,"",$2);print $2}')
	appCount=0
	echo "Current App: $currentApp"
	for item in ${appBundleList[*]}
	do
		echo "Checking for app: $item"
		if [ "$item" = "$currentApp" ]; then
			#echo "$currentApp is front, enabling caps lock"
			let "appCount++"
			break
		fi
	done
	if [ $appCount -gt 0 ]; then
		capsOn
	else
		capsOff
	fi
	sleep 1
done

