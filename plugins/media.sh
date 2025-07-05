#!/bin/bash

# Function to get media info from Music app
get_music_info() {
  osascript -e '
    try
      tell application "Music"
        if player state is playing then
          return (name of current track) & " - " & (artist of current track)
        else
          return ""
        end if
      end tell
    on error
      return ""
    end try
  ' 2>/dev/null
}

# Function to get media info from Spotify
get_spotify_info() {
  osascript -e '
    try
      tell application "Spotify"
        if player state is playing then
          return (name of current track) & " - " & (artist of current track)
        else
          return ""
        end if
      end tell
    on error
      return ""
    end try
  ' 2>/dev/null
}

# Try to get media info from various sources
MEDIA=""

# First try the built-in SketchyBar media info
if [ -n "$INFO" ]; then
  STATE="$(echo "$INFO" | jq -r '.state' 2>/dev/null)"
  if [ "$STATE" = "playing" ]; then
    MEDIA="$(echo "$INFO" | jq -r '.title + " - " + .artist' 2>/dev/null)"
  fi
fi

# If no media from SketchyBar, try Music app
if [ -z "$MEDIA" ]; then
  MEDIA="$(get_music_info)"
fi

# If no media from Music, try Spotify
if [ -z "$MEDIA" ]; then
  MEDIA="$(get_spotify_info)"
fi

# Update the display
if [ -n "$MEDIA" ] && [ "$MEDIA" != " - " ]; then
  sketchybar --set $NAME label="$MEDIA" drawing=on
else
  sketchybar --set $NAME drawing=off
fi
