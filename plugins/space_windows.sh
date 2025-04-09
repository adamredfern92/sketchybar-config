#!/bin/bash
date '+%y-%m-%d %H:%M:%S' >> $CONFIG_DIR/logs/plugins-space_windows.txt
echo "  $NAME" >> $CONFIG_DIR/logs/plugins-space_windows.txt
echo "  $SENDER" >> $CONFIG_DIR/logs/plugins-space_windows.txt
echo "  $INFO" >> $CONFIG_DIR/logs/plugins-space_windows.txt


if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  apps="$(echo "$INFO" | jq -r '.apps | keys[]')"

  icon_strip=""
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      if [ "${app}" != "LaunchBar" ]; then
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map_fn.sh "$app")"
      fi
    done <<< "${apps}"
  fi

  if [ "${icon_strip}" != "" ]; then
    sketchybar --set space.$space label="$icon_strip"
  else
    sketchybar --set space.$space label.drawing=off \
                                  icon.padding_right=6
  fi
fi
