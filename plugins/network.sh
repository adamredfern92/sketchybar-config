#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

UPDOWN=$(ifstat -i "en0" -b 0.1 1 | tail -n1)
DOWN=$(echo "$UPDOWN" | awk "{ print \$1 }" | cut -f1 -d ".")
UP=$(echo "$UPDOWN" | awk "{ print \$2 }" | cut -f1 -d ".")

DOWN_FORMAT=$(echo "$DOWN" | awk '{ printf "%.2f Mb", $1 / 1000}')
UP_FORMAT=$(echo "$UP" | awk '{ printf "%.2f Mb", $1 / 1000}')

if [[ $DOWN >0 ]]; then
    DOWN_COLOR=$GREEN
else
    DOWN_COLOR=$WHITE
fi

if [[ $UP >0 ]]; then
    UP_COLOR=$RED
else
    UP_COLOR=$WHITE
fi

sketchybar -m --set network.down label="$DOWN_FORMAT" \
                                 icon.color="$DOWN_COLOR"
sketchybar -m --set network.up label="$UP_FORMAT" \
                                 icon.color="$UP_COLOR"
