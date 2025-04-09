#!/bin/bash

sketchybar --add item ram right \
           --set ram update_freq=15 \
                 icon=􀫦 \
                 script="$PLUGIN_DIR/ram.sh" \
                 background.drawing=off \
                 padding_left=0 \
                 label.font="SF Mono:Semibold:13.0"
