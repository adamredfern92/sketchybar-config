#!/bin/bash

drawing=`sketchybar --query wifi | jq -r '.label .drawing'`

if [[ $drawing == "on" ]]; then
    sketchybar --set wifi label.drawing=off
else
    sketchybar --set wifi label.drawing=on
fi

