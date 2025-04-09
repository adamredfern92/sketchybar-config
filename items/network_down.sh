#!/bin/bash

sketchybar --add item network.down right \
	       --set network.down update_freq=1 \
	       		              icon=􀄩 \
	       		              script="$PLUGIN_DIR/network.sh" \
                              background.drawing=off \
                              padding_right=0 \
                              padding_left=0 \
                              label.font="SF Mono:Semibold:13.0"

