#!/bin/bash

drawing=`sketchybar --query volume | jq -r '.label .drawing'`

if [[ $drawing == "on" ]]; then
    sketchybar --set volume label.drawing=off
else
    sketchybar --set volume label.drawing=on
fi

