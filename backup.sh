#!/usr/bin/env bash
# =============================================================================
#  backup.sh - joga o setup que esta EM USO de volta para este repositorio.
#  Serve para o repositorio nunca mais ficar desatualizado em relacao ao que
#  voce realmente roda (foi assim que a versao antiga "perdeu" o worldmachine).
#
#  Fluxo: ./backup.sh  ->  confira o 'git diff --cached --stat'  ->  push
# =============================================================================
set -uo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONF="$HOME/.config"
BIN="$HOME/.local/bin"

c_head(){ printf '\n\033[1;35m==> %s\033[0m\n' "$*"; }
c_ok(){   printf '    \033[32mok\033[0m  %s\n' "$*"; }
c_warn(){ printf '    \033[33maviso\033[0m  %s\n' "$*" >&2; }

command -v rsync >/dev/null 2>&1 || { echo "instale o rsync"; exit 1; }

c_head "worldmachine (~/.config/worldmachine -> worldmachine/)"
if [ -d "$CONF/worldmachine" ]; then
  rsync -a --delete --exclude '.git' --exclude '*.bak.*' "$CONF/worldmachine/" "$DIR/worldmachine/" \
    && c_ok "worldmachine sincronizado"
else
  c_warn "$CONF/worldmachine nao existe (rode ./install.sh antes)"
fi

c_head "configs independentes (fish, foot, wlogout)"
for d in fish foot wlogout; do
  if [ -d "$CONF/$d" ]; then
    rsync -a --delete --exclude '*.bak.*' "$CONF/$d/" "$DIR/config/$d/" && c_ok "$d"
  else
    c_warn "$CONF/$d nao existe"
  fi
done

c_head "scripts locais"
mkdir -p "$DIR/local/bin"
for f in autoclicker.sh holdkey.sh; do
  if [ -f "$BIN/$f" ]; then
    cp -a "$BIN/$f" "$DIR/local/bin/$f" && c_ok "local/bin/$f"
  else
    c_warn "$BIN/$f nao existe"
  fi
done

c_head "git"
cd "$DIR" || exit 1
git add -A
if git diff --cached --quiet; then
  c_ok "nada mudou - o repositorio ja esta igual ao setup em uso"
  exit 0
fi
git --no-pager diff --cached --stat
msg="backup: sincroniza setup em uso ($(date '+%Y-%m-%d %H:%M'))"
git commit -q -m "$msg" && c_ok "commit: $msg"
if git push; then
  c_ok "push feito"
else
  c_warn "push falhou - rode 'git push' manualmente"
fi
