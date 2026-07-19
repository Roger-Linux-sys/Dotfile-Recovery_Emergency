#!/usr/bin/env bash

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Installing SDDM (if missing) ==="
pacman -Q sddm &>/dev/null || sudo pacman -S --noconfirm sddm

echo "=== Installing packages (single batch) ==="
sudo pacman -S --noconfirm hyprland waybar kitty rofi dunst swaybg fastfetch \
  fish foot wlogout ydotool github-cli brightnessctl \
  ttf-jetbrains-mono-nerd ttf-terminus-nerd 2>/dev/null || \
  echo "Some packages not found, continuing..."

echo "=== Setting up worldmachine configs ==="
if [ -f "$DIR/worldmachine/install.sh" ]; then
  chmod +x "$DIR/worldmachine/install.sh"
  "$DIR/worldmachine/install.sh"
else
  echo "Warning: worldmachine not found, skipping..."
fi

echo "=== Linking independent configs ==="
mkdir -p "$HOME/.config"
for dir in fish foot wlogout; do
  bak="$HOME/.config/$dir.bak.$(date +%s)"
  [ -e "$HOME/.config/$dir" ] && mv "$HOME/.config/$dir" "$bak"
  ln -sf "$DIR/config/$dir" "$HOME/.config/$dir"
done

mkdir -p "$HOME/.local/bin"
[ -e "$HOME/.local/bin/autoclicker.sh" ] && \
  mv "$HOME/.local/bin/autoclicker.sh" "$HOME/.local/bin/autoclicker.sh.bak.$(date +%s)"
ln -sf "$DIR/local/bin/autoclicker.sh" "$HOME/.local/bin/autoclicker.sh"

echo "=== Copying SDDM theme ==="
if [ -d "$DIR/sddm-caelestia" ]; then
  sudo cp -r "$DIR/sddm-caelestia" /usr/share/sddm/themes/caelestia
  sudo mkdir -p /etc/sddm.conf.d
  [ -f "$DIR/sddm.conf" ] && sudo cp "$DIR/sddm.conf" /etc/sddm.conf.d/caelestia.conf
  sudo systemctl enable sddm
else
  echo "Warning: SDDM theme not found, skipping..."
fi

echo "=== Copying GRUB theme ==="
if [ -d "$DIR/grub-niko-theme" ]; then
  sudo mkdir -p /usr/share/grub/themes
  sudo cp -r "$DIR/grub-niko-theme" /usr/share/grub/themes/niko-theme
fi

echo "=== Applying GRUB config ==="
if [ -f "$DIR/grub-default.conf" ] && command -v grub-mkconfig &>/dev/null; then
  sudo sed -i '/^GRUB_THEME=/d; /^GRUB_GFXMODE=/d; /^GRUB_TERMINAL=/d' /etc/default/grub
  cat "$DIR/grub-default.conf" | sudo tee -a /etc/default/grub > /dev/null
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "=== Copying wallpapers ==="
if ls "$DIR/wallpapers/"*.{png,jpg,jpeg,webp} &>/dev/null 2>&1; then
  mkdir -p "$HOME/Pictures/Wallpapers"
  cp -r "$DIR/wallpapers/"* "$HOME/Pictures/Wallpapers/"
fi

echo "=== Done! Log out and back in. ==="