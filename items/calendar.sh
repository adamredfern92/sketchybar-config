#!/bin/bash

sketchybar --add item calendar right \
           --set calendar update_freq=120 \
                       icon=􀉉 \
                       script="$PLUGIN_DIR/calendar.sh" \
                       background.drawing=off \
                       padding_right=0


