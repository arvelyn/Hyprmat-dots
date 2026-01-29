#!/bin/bash

WALL="$1"

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
    echo "❌ Wallpaper not found"
    exit 1
fi

# Set wallpaper
if command -v swww >/dev/null 2>&1; then
    swww img "$WALL" --transition-type fade
fi

echo "🎨 Generating Matugen palette..."

# Generate Hyprland colors
matugen image "$WALL" -t hyprland.conf -o ~/.config/hypr/colors.conf

# Generate Kitty colors
matugen image "$WALL" -t kitty.conf -o ~/.config/kitty/colors.conf

# Generate Rofi colors
matugen image "$WALL" -t rofi.rasi -o ~/.config/rofi/colors.rasi

# Generate GTK colors
matugen image "$WALL" -t gtk.css -o ~/.config/gtk-3.0/colors.css

# Brightness detection (dark/light)
BRIGHT=$(magick "$WALL" -colorspace Gray -format "%[fx:mean*255]" info:)
BRIGHT=${BRIGHT%.*}

if [ "$BRIGHT" -gt 150 ]; then
    MODE="light"
else
    MODE="dark"
fi

echo "🌗 Mode: $MODE"

# ============================
# AMOLED Black Mode (dark wallpapers)
# ============================

if [ "$MODE" = "dark" ]; then
    cat >> ~/.config/hypr/colors.conf <<EOF

# ===== AMOLED Black Mode =====
$bg = rgba(000000ff)
$surface = rgba(080808ff)
EOF
fi

# ============================
# Soft Light Mode (light wallpapers)
# ============================

if [ "$MODE" = "light" ]; then
    cat >> ~/.config/hypr/colors.conf <<EOF

# ===== Soft Light Mode =====
$bg = rgba(245,245,245,1.0)
$surface = rgba(230,230,230,1.0)
$color_inactive_border = rgba(00000044)
EOF
fi

# ============================
# Matugen → Dunst integration 🔔
# ============================

# Extract colors from Matugen-generated Hyprland colors.conf
BG=$(grep '^\$bg =' ~/.config/hypr/colors.conf | tail -1 | awk '{print $3}')
FG=$(grep '^\$fg =' ~/.config/hypr/colors.conf | tail -1 | awk '{print $3}')
ACCENT=$(grep '^\$accent =' ~/.config/hypr/colors.conf | tail -1 | awk '{print $3}')
MUTED=$(grep '^\$muted =' ~/.config/hypr/colors.conf | tail -1 | awk '{print $3}')

# fallback if muted is missing
[ -z "$MUTED" ] && MUTED="$ACCENT"

# Convert rgba(r,g,b,a) → hex #RRGGBB
rgba_to_hex() {
    local rgba="$1"
    local rgb=$(echo "$rgba" | sed 's/rgba(//' | sed 's/).*//')
    local r=$(echo "$rgb" | cut -d',' -f1)
    local g=$(echo "$rgb" | cut -d',' -f2)
    local b=$(echo "$rgb" | cut -d',' -f3)
    printf "#%02x%02x%02x" "$r" "$g" "$b"
}

BG_HEX=$(rgba_to_hex "$BG")
FG_HEX=$(rgba_to_hex "$FG")
ACCENT_HEX=$(rgba_to_hex "$ACCENT")
MUTED_HEX=$(rgba_to_hex "$MUTED")

# simple error color (from Matugen accent if available)
ERROR_HEX="#ff5555"

DUNST_FILE="$HOME/.config/dunst/dunstrc"

sed -i \
    -e "s/__BG__/$BG_HEX/g" \
    -e "s/__FG__/$FG_HEX/g" \
    -e "s/__ACCENT__/$ACCENT_HEX/g" \
    -e "s/__MUTED__/$MUTED_HEX/g" \
    -e "s/__ERROR__/$ERROR_HEX/g" \
    "$DUNST_FILE"

# Restart dunst
pkill dunst && dunst &



# Reload Hyprland
hyprctl reload

# Reload Kitty
pkill -USR1 kitty 2>/dev/null || true

echo "✅ Theme applied successfully"
