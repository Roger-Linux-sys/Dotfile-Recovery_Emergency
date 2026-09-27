#!/usr/bin/env bash
# =============================================================================
#  Dotfile-Recovery_Emergency
#  Restaura o setup completo (Hyprland + SDDM + GRUB + shell/terminal) a partir
#  deste repositorio recem-clonado.
#
#  Uso:
#    ./install.sh            instala tudo
#    ./install.sh --check    apenas verifica o estado atual (nao altera nada)
#    ./install.sh --help     ajuda
#
#  Rode como usuario normal (o script chama sudo quando precisa).
# =============================================================================
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REAL_USER="${SUDO_USER:-$(id -un)}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
[ -n "$REAL_HOME" ] || REAL_HOME="$HOME"
CONF="$REAL_HOME/.config"

# Pacotes dos repositorios oficiais (validados antes de instalar)
PKGS=(
  hyprland waybar kitty rofi dunst swaybg fastfetch
  fish foot ydotool xdotool
  hyprlock hyprpicker cliphist wl-clipboard grim slurp
  thunar firefox playerctl imagemagick
  pipewire pipewire-pulse wireplumber
  brightnessctl github-cli
  ttf-jetbrains-mono-nerd ttf-terminus-nerd
  qt6-declarative qt6-5compat qt6-svg
  xorg-server xorg-xauth grub rsync
)
# Pacotes que NAO existem nos repositorios oficiais (AUR)
AUR_PKGS=(wlogout vscodium-bin)
# Configs do worldmachine que o setup usa (linkados em ~/.config)
WM_LINKS=(hypr waybar rofi fastfetch kitty)
# Disponiveis no repositorio mas nao usados hoje
WM_OPTIONAL=(dunst qutebrowser niri)
# Comandos que o rice chama nos keybinds
BINS=(
  hyprland hyprctl waybar rofi foot fish wlogout
  hyprlock hyprpicker cliphist wl-copy grim slurp
  thunar codium firefox ydotool xdotool notify-send
)
FAIL=0

c_head(){ printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
c_ok(){   printf '    \033[32mok\033[0m  %s\n' "$*"; }
c_bad(){  printf '    \033[31mFALHOU\033[0m  %s\n' "$*"; FAIL=$((FAIL + 1)); }
c_warn(){ printf '    \033[33maviso\033[0m  %s\n' "$*" >&2; }
die(){    printf '\n\033[31mERRO:\033[0m %s\n' "$*" >&2; exit 1; }

usage(){ sed -n '3,12p' "$DIR/install.sh" | sed 's/^# \{0,1\}//'; }

# -----------------------------------------------------------------------------
# helpers
# -----------------------------------------------------------------------------
link_with_backup(){ # <src> <dest>
  local src="$1" dest="$2" bak
  [ -e "$src" ] || { c_warn "origem ausente: $src"; return 1; }
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    bak="$dest.bak.$(date +%s)"
    mv "$dest" "$bak" || { c_warn "nao consegui mover $dest"; return 1; }
    c_warn "backup: $dest -> $bak"
  fi
  ln -sfn "$src" "$dest" && c_ok "$dest -> $src"
}

# -----------------------------------------------------------------------------
# etapas de instalacao
# -----------------------------------------------------------------------------
install_official(){
  local missing=() p
  for p in "${PKGS[@]}"; do
    pacman -Si "$p" >/dev/null 2>&1 || missing+=("$p")
  done
  if ((${#missing[@]})); then
    die "pacote(s) inexistente(s) nos repositorios oficiais: ${missing[*]}
     Isso e o que fazia o 'pacman -S' antigo abortar inteiro e instalar nada."
  fi
  sudo pacman -S --needed --noconfirm "${PKGS[@]}" || die "pacman -S falhou"
}

install_aur(){
  local helper tmp
  helper="$(command -v yay || command -v paru || true)"
  if [ -z "$helper" ]; then
    c_warn "sem yay/paru - compilando o yay para instalar ${AUR_PKGS[*]}"
    sudo pacman -S --needed --noconfirm base-devel git || { c_warn "base-devel/git falhou"; return 1; }
    tmp="$(mktemp -d)"
    if git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay" &&
       ( cd "$tmp/yay" && makepkg -si --needed --noconfirm ); then
      rm -rf "$tmp"
      helper="$(command -v yay || true)"
    else
      rm -rf "$tmp"
      c_warn "build do yay falhou"
      return 1
    fi
  fi
  [ -n "$helper" ] || return 1
  "$helper" -S --needed --noconfirm "${AUR_PKGS[@]}" || { c_warn "falhou: ${AUR_PKGS[*]}"; return 1; }
}

install_worldmachine(){
  local dst="$CONF/worldmachine"
  mkdir -p "$CONF"
  # sem --delete: nunca apaga nada que ja exista no destino
  rsync -a --exclude '*.bak.*' "$DIR/worldmachine/" "$dst/" || die "rsync para $dst falhou"
  chmod +x "$dst/install.sh" 2>/dev/null
  chmod +x "$dst"/hypr/scripts/* "$dst"/niri/scripts/* 2>/dev/null
  "$dst/install.sh" || c_warn "worldmachine/install.sh retornou erro"
}

install_independent(){
  link_with_backup "$DIR/config/fish"    "$CONF/fish"
  link_with_backup "$DIR/config/foot"    "$CONF/foot"
  link_with_backup "$DIR/config/wlogout" "$CONF/wlogout"
}

install_bins(){
  link_with_backup "$DIR/local/bin/autoclicker.sh" "$REAL_HOME/.local/bin/autoclicker.sh"
  link_with_backup "$DIR/local/bin/holdkey.sh"     "$REAL_HOME/.local/bin/holdkey.sh"
}

configure_ydotool(){
  # ydotool precisa do daemon (ydotoold) rodando + acesso a /dev/uinput
  if id -nG "$REAL_USER" | tr ' ' '\n' | grep -qx input; then
    c_ok "usuario $REAL_USER ja esta no grupo input"
  else
    sudo usermod -aG input "$REAL_USER" && c_warn "usuario $REAL_USER entrou no grupo input (faca logout/login)"
  fi
  if [ -f /usr/lib/systemd/user/ydotool.service ]; then
    if sudo systemctl --global enable ydotool.service >/dev/null 2>&1; then
      c_ok "ydotool.service habilitado (ydotoold sobe junto com a sessao)"
    else
      sudo install -d /etc/systemd/user/default.target.wants &&
        sudo ln -sfn /usr/lib/systemd/user/ydotool.service \
          /etc/systemd/user/default.target.wants/ydotool.service &&
        c_ok "ydotool.service habilitado via link manual"
    fi
  else
    c_warn "ydotool.service nao encontrado - o pacote ydotool esta instalado?"
  fi
}

install_sddm(){
  [ -d "$DIR/sddm-caelestia" ] || { c_warn "sddm-caelestia ausente"; return 1; }
  sudo rm -rf /usr/share/sddm/themes/caelestia
  sudo cp -r "$DIR/sddm-caelestia" /usr/share/sddm/themes/caelestia || die "copia do tema SDDM falhou"
  sudo mkdir -p /etc/sddm.conf.d
  [ -f "$DIR/sddm.conf" ] && sudo cp "$DIR/sddm.conf" /etc/sddm.conf.d/caelestia.conf
  sudo systemctl enable sddm && c_ok "sddm habilitado"
}

install_grub(){
  [ -d "$DIR/grub-niko-theme" ] || { c_warn "grub-niko-theme ausente"; return 1; }
  sudo mkdir -p /usr/share/grub/themes
  sudo rm -rf /usr/share/grub/themes/niko-theme
  sudo cp -r "$DIR/grub-niko-theme" /usr/share/grub/themes/niko-theme
  if command -v grub-mkconfig >/dev/null 2>&1 && [ -f /etc/default/grub ]; then
    sudo sed -i '/^GRUB_THEME=/d; /^GRUB_GFXMODE=/d; /^GRUB_TERMINAL=/d' /etc/default/grub
    sudo tee -a /etc/default/grub < "$DIR/grub-default.conf" >/dev/null
    sudo grub-mkconfig -o /boot/grub/grub.cfg >/dev/null && c_ok "tema niko aplicado no GRUB"
  else
    c_warn "grub-mkconfig ausente - tema copiado, mas nao aplicado"
  fi
}

install_wallpapers(){
  shopt -s nullglob
  local w=("$DIR/wallpapers/"*.png "$DIR/wallpapers/"*.jpg "$DIR/wallpapers/"*.jpeg "$DIR/wallpapers/"*.webp)
  shopt -u nullglob
  ((${#w[@]})) || { c_warn "nenhum wallpaper no repositorio"; return 0; }
  mkdir -p "$REAL_HOME/Pictures/Wallpapers"
  cp -r "${w[@]}" "$REAL_HOME/Pictures/Wallpapers/" && c_ok "${#w[@]} wallpaper(s) em ~/Pictures/Wallpapers"
}


# -----------------------------------------------------------------------------
# verificacao (--check nao altera nada)
# -----------------------------------------------------------------------------
same_file(){ # <a> <b>
  [ -f "$1" ] && cmp -s "$1" "$2"
}

check(){
  FAIL=0
  local p b d f wp

  c_head "pacotes oficiais"
  for p in "${PKGS[@]}"; do
    if pacman -Qq "$p" >/dev/null 2>&1; then c_ok "$p"; else c_bad "pacote ausente: $p"; fi
  done

  c_head "pacotes do AUR"
  for p in "${AUR_PKGS[@]}"; do
    if pacman -Qq "$p" >/dev/null 2>&1; then c_ok "$p"; else c_bad "pacote AUR ausente: $p"; fi
  done

  c_head "comandos usados pelos keybinds"
  for b in "${BINS[@]}"; do
    if command -v "$b" >/dev/null 2>&1; then c_ok "$b"; else c_bad "comando ausente: $b"; fi
  done

  c_head "configs do worldmachine"
  for d in "${WM_LINKS[@]}"; do
    if [ -L "$CONF/$d" ] && [ -e "$CONF/$d" ]; then
      c_ok "~/.config/$d -> $(readlink "$CONF/$d")"
    elif [ -d "$CONF/$d" ]; then
      c_ok "~/.config/$d (diretorio local, nao linkado)"
    else
      c_bad "~/.config/$d ausente (esperado link para ~/.config/worldmachine/$d)"
    fi
  done
  for d in "${WM_OPTIONAL[@]}"; do
    [ -d "$DIR/worldmachine/$d" ] && c_ok "opcional disponivel: worldmachine/$d"
  done

  c_head "configs independentes"
  if [ -L "$CONF/fish" ] || same_file "$DIR/config/fish/config.fish" "$CONF/fish/config.fish"; then c_ok "fish"; else c_bad "~/.config/fish sem config.fish identico"; fi
  if [ -L "$CONF/foot" ] || same_file "$DIR/config/foot/foot.ini" "$CONF/foot/foot.ini"; then c_ok "foot"; else c_bad "~/.config/foot/foot.ini diferente"; fi
  if [ -L "$CONF/wlogout" ] || same_file "$DIR/config/wlogout/layout" "$CONF/wlogout/layout"; then c_ok "wlogout"; else c_bad "~/.config/wlogout/layout diferente"; fi

  c_head "scripts locais"
  for f in autoclicker.sh holdkey.sh; do
    if [ -x "$REAL_HOME/.local/bin/$f" ]; then c_ok "~/.local/bin/$f"; else c_bad "~/.local/bin/$f ausente/nao executavel"; fi
  done

  c_head "hyprland / wallpaper"
  if [ -f "$CONF/hypr/hyprland.conf" ]; then c_ok "hyprland.conf"; else c_bad "~/.config/hypr/hyprland.conf ausente"; fi
  if [ -f "$CONF/hypr/hyprlock.conf" ]; then c_ok "hyprlock.conf"; else c_bad "~/.config/hypr/hyprlock.conf ausente"; fi
  wp="$CONF/hypr/wallpaper.png"
  if [ -s "$wp" ]; then c_ok "wallpaper.png ($(stat -c %s "$wp") bytes)"; else c_bad "wallpaper ausente: $wp"; fi

  c_head "sddm / grub"
  if [ -d /usr/share/sddm/themes/caelestia ]; then c_ok "tema SDDM caelestia"; else c_bad "tema SDDM caelestia ausente"; fi
  if [ -f /etc/sddm.conf.d/caelestia.conf ]; then c_ok "/etc/sddm.conf.d/caelestia.conf"; else c_bad "config do SDDM ausente"; fi
  if [ "$(systemctl is-enabled sddm 2>/dev/null)" = "enabled" ]; then c_ok "sddm habilitado"; else c_bad "sddm nao esta habilitado"; fi
  if [ -d /usr/share/grub/themes/niko-theme ]; then c_ok "tema GRUB niko-theme"; else c_bad "tema GRUB ausente"; fi
  if grep -q '^GRUB_THEME=.*niko-theme' /etc/default/grub 2>/dev/null; then c_ok "GRUB_THEME aplicado"; else c_bad "GRUB_THEME nao aplicado em /etc/default/grub"; fi

  c_head "ydotool (autoclicker F1 / holdkey F2)"
  if id -nG "$REAL_USER" | tr ' ' '\n' | grep -qx input; then c_ok "usuario no grupo input"; else c_bad "usuario fora do grupo input"; fi
  if systemctl --user is-active ydotool >/dev/null 2>&1; then
    c_ok "ydotoold rodando"
  else
    c_warn "ydotoold nao esta rodando nesta sessao (relogue depois de instalar)"
  fi

  printf '\n'
  if ((FAIL)); then
    printf '\033[31m%d verificacao(oes) falharam\033[0m\n' "$FAIL"
    return 1
  fi
  printf '\033[32mtudo certo: o setup esta completo\033[0m\n'
  return 0
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
case "${1:-}" in
  --check|-c) check; exit $? ;;
  --help|-h) usage; exit 0 ;;
  "") ;;
  *) die "opcao desconhecida: $1 (use --check ou --help)" ;;
esac

[ "$(id -u)" -eq 0 ] && die "nao rode como root. Use seu usuario normal; o script chama sudo quando precisa."
command -v sudo >/dev/null 2>&1 || die "sudo nao encontrado"
command -v pacman >/dev/null 2>&1 || die "este setup e para Arch Linux (pacman nao encontrado)"

c_head "1/8 pacotes oficiais";        install_official
c_head "2/8 pacotes do AUR";          install_aur || c_warn "instale manualmente: ${AUR_PKGS[*]}"
c_head "3/8 configs do worldmachine"; install_worldmachine
c_head "4/8 configs independentes";   install_independent
c_head "5/8 scripts locais";          install_bins
c_head "6/8 ydotool";                 configure_ydotool
c_head "7/8 tema do SDDM";            install_sddm
c_head "8/8 GRUB + wallpapers";       install_grub; install_wallpapers

c_head "verificacao final"
check || true

printf '\n\033[1mFaca logout/login (ou reboot) para a sessao Hyprland e o SDDM valerem.\033[0m\n'

