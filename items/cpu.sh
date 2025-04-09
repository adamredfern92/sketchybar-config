#!/bin/bash

sketchybar --add item cpu right \
	       --set cpu update_freq=2 \
	                 icon=􀧓 \
		             script="$PLUGIN_DIR/cpu.sh" \
                     background.drawing=off \
                     padding_right=0 \
                     label.font="SF Mono:Semibold:13.0"

