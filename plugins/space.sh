#!/bin/sh
date '+%y-%m-%d %H:%M:%S' >> $CONFIG_DIR/logs/plugins-space.txt
echo "  $NAME" >> $CONFIG_DIR/logs/plugins-space.txt
echo "  $SENDER" >> $CONFIG_DIR/logs/plugins-space.txt
echo "  $SELECTED" >> $CONFIG_DIR/logs/plugins-space.txt

source "${CONFIG_DIR}/colors.sh" # Loads all defined colors

if [ $SELECTED = true ]; then
  sketchybar --set $NAME background.drawing=on \
                         background.color=$WHITE \
                         label.color=$BLACK \
                         icon.color=$BLACK
else
  sketchybar --set $NAME background.drawing=on \
                         background.color=$ITEM_BG_COLOR \
                         label.color=$WHITE \
                         icon.color=$WHITE
fi

