#!/bin/bash

sketchybar --add item  wifi right \
           --set       wifi script="$PLUGIN_DIR/wifi.sh" \
                            update_freq=30 \
                            background.drawing=off \
                            padding_left=0 \
                            click_script="$SCRIPT_DIR/toggle_ip_address.sh" \
           --subscribe wifi wifi_change
