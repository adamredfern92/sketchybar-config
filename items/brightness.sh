#!/bin/bash

sketchybar --add item brightness right \
           --set brightness script="$PLUGIN_DIR/brightness.sh" \
                        background.drawing=off \
                        padding_right=0 \
                        click_script="$SCRIPT_DIR/toggle_brightness.sh" \
           --subscribe brightness brightness_change
