#!/bin/bash

sketchybar --add item claude_usage right \
           --set claude_usage update_freq=300 \
                              icon="" \
                              icon.font="SF Pro:Semibold:13.0" \
                              script="$PLUGIN_DIR/claude_usage.sh" \
                              background.drawing=off \
                              label.font="SF Mono:Semibold:11.0" \
                              padding_left=0
