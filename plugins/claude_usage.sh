#!/bin/bash

set_auth_needed() {
  sketchybar --set claude_5h     icon="auth" label="░░░░░░░░"
  sketchybar --set claude_5h_pct icon="↻"
  sketchybar --set claude_7d     icon="needed" label="░░░░░░░░"
  sketchybar --set claude_7d_pct icon="↻"
}

# Get the short-lived OAuth token from Claude Code, if not expired
CREDENTIALS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
if [ -n "$CREDENTIALS" ]; then
  ACCESS_TOKEN=$(echo "$CREDENTIALS" | python3 -c "
import sys, json, time
try:
  d = json.loads(sys.stdin.read())
  oauth = d['claudeAiOauth']
  expires_ms = oauth.get('expiresAt', 0)
  if expires_ms > int(time.time() * 1000):
    print(oauth['accessToken'])
except Exception:
  pass
" 2>/dev/null)
fi

# Nothing usable — show auth prompt (run 'claude' once to refresh the token)
if [ -z "$ACCESS_TOKEN" ]; then
  set_auth_needed
  exit 0
fi

# Fetch usage from Anthropic API — capture body and HTTP status separately
HTTP_RESPONSE=$(curl -s --max-time 10 \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -H "User-Agent: claude-code/2.0.32" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -w "\n__HTTP_STATUS__%{http_code}" \
  "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

HTTP_STATUS=$(echo "$HTTP_RESPONSE" | grep -o '__HTTP_STATUS__[0-9]*' | grep -o '[0-9]*')
RESPONSE=$(echo "$HTTP_RESPONSE" | sed 's/__HTTP_STATUS__[0-9]*$//')

if [ -z "$RESPONSE" ] || [ "$HTTP_STATUS" != "200" ]; then
  set_auth_needed
  exit 0
fi

# Parse utilization %, resets_at timestamps, and compute time-elapsed % per cycle
# Outputs: five_pct seven_pct five_secs_remaining seven_secs_remaining five_elapsed_pct seven_elapsed_pct
read FIVE_HOUR SEVEN_DAY FIVE_SECS SEVEN_SECS FIVE_ELAPSED SEVEN_ELAPSED <<< $(echo "$RESPONSE" | python3 -c "
import sys, json
from datetime import datetime, timezone

FIVE_CYCLE  = 5 * 3600    # 18 000 s
SEVEN_CYCLE = 7 * 86400   # 604 800 s

def parse(obj, cycle):
    if not obj:
        return 0, cycle, 0
    pct  = int(obj.get('utilization') or 0)
    ra   = obj.get('resets_at')
    if ra:
        resets = datetime.fromisoformat(ra.replace('Z', '+00:00'))
        secs   = max(0, int((resets - datetime.now(timezone.utc)).total_seconds()))
    else:
        secs   = cycle
    elapsed_pct = max(0, min(100, int((cycle - secs) * 100 / cycle)))
    return pct, secs, elapsed_pct

try:
    d  = json.load(sys.stdin)
    fp, fs, fe = parse(d.get('five_hour'),  FIVE_CYCLE)
    sp, ss, se = parse(d.get('seven_day'),  SEVEN_CYCLE)
    print(fp, sp, fs, ss, fe, se)
except Exception:
    print(0, 0, 18000, 604800, 0, 0)
" 2>/dev/null)

FIVE_PCT=${FIVE_HOUR:-0};      SEVEN_PCT=${SEVEN_DAY:-0}
FIVE_SECS=${FIVE_SECS:-18000}; SEVEN_SECS=${SEVEN_SECS:-604800}
FIVE_ELAPSED=${FIVE_ELAPSED:-0}; SEVEN_ELAPSED=${SEVEN_ELAPSED:-0}

# 8-block usage bar using █ / ░
build_bar() {
  local filled=$(( $1 * 8 / 100 )) bar=""
  for i in 1 2 3 4 5 6 7 8; do
    [ "$i" -le "$filled" ] && bar="${bar}█" || bar="${bar}░"
  done
  echo "$bar"
}

# Time-remaining label for the 5h window: show hours, or minutes if under 1h
if   [ "$FIVE_SECS" -ge 3600 ]; then FIVE_LABEL="$(( FIVE_SECS / 3600 ))h"
else                                  FIVE_LABEL="$(( FIVE_SECS / 60 ))m"
fi

# Time-remaining label for the 7d window: ceil to days, or hours if under 1 day
if   [ "$SEVEN_SECS" -ge 86400 ]; then SEVEN_LABEL="$(( (SEVEN_SECS + 86399) / 86400 ))d"
else                                    SEVEN_LABEL="$(( SEVEN_SECS / 3600 ))h"
fi

FIVE_BAR=$(build_bar "$FIVE_PCT")
SEVEN_BAR=$(build_bar "$SEVEN_PCT")

# Pacing color per bar — red when utilization outrunning time elapsed, green otherwise
source "$CONFIG_DIR/colors.sh"

FIVE_COLOR=$GREEN;  [ "$FIVE_PCT"  -gt "$FIVE_ELAPSED"  ] && FIVE_COLOR=$RED
SEVEN_COLOR=$GREEN; [ "$SEVEN_PCT" -gt "$SEVEN_ELAPSED" ] && SEVEN_COLOR=$RED

# icon = time (white), label = bar (pacing color), _pct item = "XX%" (white)
sketchybar --set claude_5h     icon="$FIVE_LABEL"   label="$FIVE_BAR"   label.color="$FIVE_COLOR"
sketchybar --set claude_5h_pct icon="${FIVE_PCT}%"
sketchybar --set claude_7d     icon="$SEVEN_LABEL"  label="$SEVEN_BAR"  label.color="$SEVEN_COLOR"
sketchybar --set claude_7d_pct icon="${SEVEN_PCT}%"
