#!/bin/bash

sketchybar --add item clock right \
           --set clock update_freq=10 \
                       icon=􀐫 \
                       script="$PLUGIN_DIR/clock.sh" \
                       background.drawing=off \
                       padding_left=0


