#!/bin/bash

# Get OAuth token from macOS Keychain
CREDENTIALS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)

if [ -z "$CREDENTIALS" ]; then
  sketchybar --set "$NAME" icon="" label="N/A"
  exit 0
fi

# Extract access token using python3
ACCESS_TOKEN=$(echo "$CREDENTIALS" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  print(d['claudeAiOauth']['accessToken'])
except Exception:
  pass
" 2>/dev/null)

if [ -z "$ACCESS_TOKEN" ]; then
  sketchybar --set "$NAME" icon="" label="N/A"
  exit 0
fi

# Fetch usage from Anthropic API
RESPONSE=$(curl -s --max-time 10 \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "User-Agent: claude-code/2.0.32" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

if [ -z "$RESPONSE" ]; then
  sketchybar --set "$NAME" icon="" label="offline"
  exit 0
fi

# Parse utilization values (may be floats like 6.0, 35.0)
read FIVE_HOUR SEVEN_DAY <<< $(echo "$RESPONSE" | python3 -c "
import sys, json
try:
  d = json.load(sys.stdin)
  fh = d.get('five_hour')
  sd = d.get('seven_day')
  five = int(fh['utilization']) if fh else 0
  seven = int(sd['utilization']) if sd else 0
  print(five, seven)
except Exception:
  print(0, 0)
" 2>/dev/null)

FIVE_HOUR=${FIVE_HOUR:-0}
SEVEN_DAY=${SEVEN_DAY:-0}

# Build an 8-block progress bar from a percentage value
build_bar() {
  local pct=$1
  local filled=$(( pct * 8 / 100 ))
  local bar=""
  for i in 1 2 3 4 5 6 7 8; do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
  done
  echo "$bar"
}

FIVE_BAR=$(build_bar "$FIVE_HOUR")
SEVEN_BAR=$(build_bar "$SEVEN_DAY")

LABEL="5h ${FIVE_BAR} ${FIVE_HOUR}%  7d ${SEVEN_BAR} ${SEVEN_DAY}%"

# Color-code the icon based on highest utilization
MAX=$FIVE_HOUR
[ "$SEVEN_DAY" -gt "$MAX" ] && MAX=$SEVEN_DAY

source "$CONFIG_DIR/colors.sh"

if [ "$MAX" -ge 80 ]; then
  ICON_COLOR=$RED
elif [ "$MAX" -ge 50 ]; then
  ICON_COLOR=$YELLOW
else
  ICON_COLOR=$GREEN
fi

sketchybar --set "$NAME" icon="" icon.color="$ICON_COLOR" label="$LABEL"
