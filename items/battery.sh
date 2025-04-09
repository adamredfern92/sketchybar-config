#!/bin/bash

sketchybar --add item battery right \
           --set battery update_freq=120 \
                         script="$PLUGIN_DIR/battery.sh" \
                         background.drawing=off \
                         padding_left=0 \
                         click_script="$SCRIPT_DIR/toggle_battery.sh" \
           --subscribe battery system_woke power_source_change
