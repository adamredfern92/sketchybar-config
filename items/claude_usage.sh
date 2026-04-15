#!/bin/bash

# Brain icon — static, no script
sketchybar --add item claude_icon center \
           --set claude_icon icon="􀙚" \
                             icon.font="SF Pro:Semibold:13.0" \
                             icon.color=$WHITE \
                             label.drawing=off \
                             background.drawing=off \
                             padding_right=2

# 5-hour window — drives the API fetch; sets both claude_5h and claude_7d
sketchybar --add item claude_5h center \
           --set claude_5h update_freq=300 \
                           icon.font="SF Mono:Semibold:11.0" \
                           icon.color=$WHITE \
                           label.font="SF Mono:Semibold:11.0" \
                           script="$PLUGIN_DIR/claude_usage.sh" \
                           background.drawing=off \
                           padding_left=2 \
                           padding_right=0

sketchybar --add item claude_5h_pct center \
           --set claude_5h_pct icon.font="SF Mono:Semibold:11.0" \
                               icon.color=$WHITE \
                               label.drawing=off \
                               background.drawing=off \
                               padding_left=0 \
                               padding_right=4

# 7-day window — updated by claude_5h's script, no independent fetch
sketchybar --add item claude_7d center \
           --set claude_7d icon.font="SF Mono:Semibold:11.0" \
                           icon.color=$WHITE \
                           label.font="SF Mono:Semibold:11.0" \
                           background.drawing=off \
                           padding_left=0 \
                           padding_right=0

sketchybar --add item claude_7d_pct center \
           --set claude_7d_pct icon.font="SF Mono:Semibold:11.0" \
                               icon.color=$WHITE \
                               label.drawing=off \
                               background.drawing=off \
                               padding_left=0
