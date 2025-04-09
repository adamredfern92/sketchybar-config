#!/bin/bash

sketchybar --add item volume right \
           --set volume script="$PLUGIN_DIR/volume.sh" \
                        background.drawing=off \
                        padding_left=0 \
                        padding_right=0 \
                        click_script="$SCRIPT_DIR/toggle_volume.sh" \
           --subscribe volume volume_change
