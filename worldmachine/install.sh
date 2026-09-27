#!/usr/bin/env bash
# =============================================================================
#  worldmachine - linka os configs desta pasta em ~/.config
#  Chamado pelo ./install.sh da raiz do repositorio, mas roda sozinho tambem.
# =============================================================================
set -uo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cfg="$HOME/.config"

# diretorios usados pelo setup atual
LINK_DIRS=(hypr waybar rofi fastfetch kitty)

c_ok(){   printf '    \033[32mok\033[0m  %s\n' "$*"; }
c_warn(){ printf '    \033[33maviso\033[0m  %s\n' "$*" >&2; }

mkdir -p "$cfg"

link_dir(){
  local name="$1" src="$dir/$1" dest="$cfg/$1" bak
  [ -d "$src" ] || { c_warn "nao existe: $src"; return 1; }
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    bak="$dest.bak.$(date +%s)"
    mv "$dest" "$bak" && c_warn "backup: $dest -> $bak"
  fi
  ln -sfn "$src" "$dest" && c_ok "$dest -> $src"
}

for d in "${LINK_DIRS[@]}"; do link_dir "$d"; done

# recarrega o hyprland se estivermos dentro de uma sessao
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
  hyprctl reload >/dev/null 2>&1 && c_ok "hyprctl reload"
fi

echo
echo "Linkado em $cfg: ${LINK_DIRS[*]}"
echo "Tambem incluidas no repositorio, mas nao linkadas por padrao: dunst, qutebrowser, niri"
