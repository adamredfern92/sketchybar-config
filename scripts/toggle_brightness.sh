#!/bin/bash

drawing=`sketchybar --query brightness | jq -r '.label .drawing'`

if [[ $drawing == "on" ]]; then
    sketchybar --set brightness label.drawing=off
else
    sketchybar --set brightness label.drawing=on
fi

