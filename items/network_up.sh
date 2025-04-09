#!/bin/bash

sketchybar --add item network.up right \
	       --set network.up update_freq=1 \
	   		                icon=􀄨 \
			                script="$PLUGIN_DIR/network.sh" \
                            background.drawing=off \
                            padding_left=0 \
                            label.font="SF Mono:Semibold:13.0"
