#!/bin/sh

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

if [ "$SENDER" = "brightness_change" ]; then
  BRIGHTNESS="$INFO"

  case "$BRIGHTNESS" in
    100) ICON="􀆮"
    ;;
    [5-9][0-9]) ICON="􀆭"
    ;;
    *) ICON="􀆫"
  esac

  sketchybar --set "$NAME" icon="$ICON" label="$BRIGHTNESS%"
fi
