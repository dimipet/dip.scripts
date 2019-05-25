#!/bin/bash

#echo "=== $0 ==="
#for p; do printf "(%s)" "$p"; done; echo " [$#]"

if (( $# < 2 )); then
	echo "Call with two arguments like this:"
	echo ""
	echo "to set a device's touchpad natural scrolling to 0"
	echo "# natural_scrolling Microsoft 0" 
	echo ""
	echo "to set a device's touchpad (with a big name) natural scrolling to 1"
        echo "# natural_scrolling 'Microsoft all in one' 1" 
	echo ""
	echo "Showing your devices : '# xinput --list' "
	xinput list
	exit 1
fi

deviceName=$1
value=$2

deviceIds=$(xinput --list | grep "$deviceName" | grep 'pointer' |sed 's/^.*id=\([0-9]*\)[ \t].*$/\1/')
#echo "$deviceIds"

for deviceId in $deviceIds
do
	echo "showing current values for device ID : " $deviceId
	xinput --list-props $deviceId | grep "libinput Natural Scrolling Enabled"
	
	echo "setting for device ID " $deviceId " new value " $value 
	xinput set-prop $deviceId "libinput Natural Scrolling Enabled" $value
	
	echo "showing current values for device ID : " $deviceId
        xinput --list-props $deviceId | grep "libinput Natural Scrolling Enabled"
done

