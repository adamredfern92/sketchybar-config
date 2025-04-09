#!/bin/bash

drawing=`sketchybar --query battery | jq -r '.label .drawing'`

if [[ $drawing == "on" ]]; then
    sketchybar --set battery label.drawing=off
else
    sketchybar --set battery label.drawing=on
fi
