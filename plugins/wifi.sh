#!/bin/sh

IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')
SERVICES=$(networksetup -listnetworkserviceorder)
SSID=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' | xargs networksetup -getairportnetwork | sed -n "s/Current Wi-Fi Network: \(.*\)/\1/p")

if [[ $IS_VPN != "" ]]; then
	ICON="􁅏"
	LABEL="VPN"
elif [[ $IP_ADDRESS != "" ]]; then
    case $SSID in
      *iPhone*) ICON="􀉤";;
      *)        ICON="􀙇";;
    esac
	LABEL=$IP_ADDRESS
elif [[ $SERVICES == "iPhone USB" ]]; then
	ICON="􁈩"
	LABEL="iPhone USB"
elif [[ $SERVICES == "Thunderbolt Bridge" ]]; then
	ICON="􀒘"
	LABEL="Thunderbolt Bridge"
else
	ICON="􀙈"
	LABEL="Not Connected"
fi

sketchybar --set $NAME \
	icon=$ICON \
	label="$LABEL"
