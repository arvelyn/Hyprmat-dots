#!/bin/bash

set -e

echo "🌌 Hyprland Required Dependencies Installer"
echo "======================================="

# Check Arch Linux

if ! command -v pacman >/dev/null 2>&1; then
echo "❌ This script is for Arch Linux only."
exit 1
fi

# ------------------------

# Install base-devel (needed for AUR)

# ------------------------

echo "🔧 Installing build tools..."
sudo pacman -S --needed base-devel git

# ------------------------

# Install AUR helper (yay or paru)

# ------------------------

install_yay() {
echo "📦 Installing yay (AUR helper)..."
cd /tmp
git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git)
cd yay
makepkg -si --noconfirm
}

install_paru() {
echo "📦 Installing paru (AUR helper)..."
cd /tmp
git clone [https://aur.archlinux.org/paru.git](https://aur.archlinux.org/paru.git)
cd paru
makepkg -si --noconfirm
}

if command -v yay >/dev/null 2>&1; then
AUR_HELPER="yay"
echo "✔ yay found"
elif command -v paru >/dev/null 2>&1; then
AUR_HELPER="paru"
echo "✔ paru found"
else
echo "⚠️ No AUR helper found."
echo "Choose one:"
echo "1) yay (recommended)"
echo "2) paru"
read -p "Enter choice [1/2]: " choice
if [ "$choice" = "2" ]; then
install_paru
AUR_HELPER="paru"
else
install_yay
AUR_HELPER="yay"
fi
fi

# ------------------------

# Core Hyprland + Wayland stack

# ------------------------

echo "📦 Installing core packages..."

PKGS=(
# Hyprland / Wayland
hypridle
hyprlock
xdg-desktop-portal-hyprland
wayland
wl-clipboard
libinput
mesa

```
# Audio / media
pipewire
pipewire-pulse
wireplumber
playerctl
pamixer
pavucontrol

# System
polkit-gnome
networkmanager
bluez
bluez-utils
blueman
brightnessctl
power-profiles-daemon

# Terminal / UI
kitty
swaync
cava
nwg-look
swww

# File manager + portals
nautilus
gvfs
gvfs-mtp
gvfs-smb
gnome-keyring
xdg-user-dirs
adwaita-icon-theme 
gnome-themes-extra

# Theming / utils
imagemagick
jq
bc
curl
unzip
```

)

sudo pacman -S --needed "${PKGS[@]}"

# ------------------------

# Fonts (everything we discussed)

# ------------------------

echo "🔤 Installing fonts..."

FONTS=(
ttf-dejavu
noto-fonts
noto-fonts-emoji
noto-fonts-cjk
ttf-jetbrains-mono
ttf-jetbrains-mono-nerd
ttf-fira-code
ttf-firacode-nerd
ttf-nerd-fonts-symbols
)

sudo pacman -S --needed "${FONTS[@]}"

# ------------------------

# Rofi (pinned, manual install – EXACT method you use)

echo "🎯 Installing Rofi 1.7.5 (manual archive install)..."
cd /tmp
wget [https://archive.archlinux.org/packages/r/rofi/rofi-1.7.5-1-x86_64.pkg.tar.zst](https://archive.archlinux.org/packages/r/rofi/rofi-1.7.5-1-x86_64.pkg.tar.zst)
sudo pacman -U --noconfirm rofi-1.7.5-1-x86_64.pkg.tar.zst

# ------------------------

# AUR packages we used

# ------------------------

echo "🎨 Installing AUR packages..."

$AUR_HELPER -S --needed 
matugen 
python-fabric-git

# ------------------------

# Enable services

# ------------------------

echo "⚙️ Enabling system services..."

sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service
sudo systemctl enable power-profiles-daemon.service

# ------------------------

# User directories

# ------------------------

echo "📁 Creating user directories..."
xdg-user-dirs-update

echo ""
echo "✅ All required dependencies installed successfully"
echo "You can now continue with your Hyprland setup"
