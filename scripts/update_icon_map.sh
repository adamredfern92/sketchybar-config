#!/bin/bash
# Updates plugins/icon_map_fn.sh and ~/Library/Fonts/sketchybar-app-font.ttf
# from the latest kvndrsslr/sketchybar-app-font GitHub release.

set -euo pipefail

REPO="kvndrsslr/sketchybar-app-font"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
ICON_MAP_DEST="${CONFIG_DIR:-$HOME/.config/sketchybar}/plugins/icon_map_fn.sh"
FONT_DEST="$HOME/Library/Fonts/sketchybar-app-font.ttf"

echo "Fetching latest release info from ${REPO}..."
release_json=$(curl -fsSL "$API_URL")

# Extract download URLs for the two assets we need
icon_map_url=$(echo "$release_json" | grep -o '"browser_download_url": *"[^"]*icon_map\.sh"' | grep -o 'https://[^"]*')
font_url=$(echo "$release_json" | grep -o '"browser_download_url": *"[^"]*\.ttf"' | grep -o 'https://[^"]*')
release_tag=$(echo "$release_json" | grep -o '"tag_name": *"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"')

if [ -z "$icon_map_url" ] || [ -z "$font_url" ]; then
  echo "Error: could not find release assets. Response snippet:"
  echo "$release_json" | head -20
  exit 1
fi

echo "Found release: ${release_tag}"

# ── 1. Update icon_map_fn.sh ────────────────────────────────────────────────

echo "Downloading icon_map.sh..."
upstream=$(curl -fsSL "$icon_map_url")

# Extract just the block between the markers (inclusive)
map_block=$(echo "$upstream" | awk '/^### START-OF-ICON-MAP$/,/^### END-OF-ICON-MAP$/')

if [ -z "$map_block" ]; then
  echo "Error: could not find START-OF-ICON-MAP / END-OF-ICON-MAP markers in downloaded file."
  exit 1
fi

# The upstream function is named __icon_map(); rename to icon_map() to match
# our existing usage in front_app.sh and space_windows.sh.
map_block=$(echo "$map_block" | sed 's/function __icon_map()/function icon_map()/')

# Write the new file: the map block, then the two lines that make it work as
# a standalone executable script (called as plugins/icon_map_fn.sh "App Name").
cat > "$ICON_MAP_DEST" <<EOF
${map_block}

icon_map "\$1"
echo "\$icon_result"
EOF

echo "Updated: ${ICON_MAP_DEST}"

# ── 2. Update the font ───────────────────────────────────────────────────────

echo "Downloading sketchybar-app-font.ttf..."
curl -fsSL "$font_url" -o "$FONT_DEST"
echo "Updated: ${FONT_DEST}"

# ── 3. Done ──────────────────────────────────────────────────────────────────

echo ""
echo "Done! Run 'sketchybar --reload' to apply the changes."
