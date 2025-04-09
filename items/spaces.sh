#!/bin/bash
echo "items/spaces.sh" >> ~/temp.txt

IFS=$'\n' SPACE_SIDS=($(yabai -m query --spaces | jq '.[].index'))
SPACE_ICONS=(􀃊 􀃌 􀃎 􀃐 􀃒 􀃔 􀃖 􀃘 􀃚)

for sid in "${SPACE_SIDS[@]}"
do
  sketchybar --add space space.$sid left                                 \
             --set space.$sid space=$sid                                 \
                              icon=${SPACE_ICONS[$sid-1]}                  \
                              label.font="sketchybar-app-font:Regular:16.0" \
                              label.padding_right=10                     \
                              label.y_offset=-1                          \
                              script="$PLUGIN_DIR/space.sh"              \
                              click_script="yabai -m space --focus $sid" \
             --subscribe space.$sid space_change
done

sketchybar --add item space_separator left                             \
           --set space_separator icon="􀆊"                                \
                                 icon.color=$WHITE \
                                 icon.padding_left=4                   \
                                 label.drawing=off                     \
                                 background.drawing=off                \
                                 script="$PLUGIN_DIR/space_windows.sh" \
                                 click_script="yabai -m space --create" \
           --subscribe space_separator space_windows_change
