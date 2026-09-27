# Dotfile-Recovery_Emergency

Meus dotfiles e configurações pessoais do Arch, feitos para **restaurar o ricing inteiro depois de uma instalação limpa**. O tema geral é inspirado em OneShot, com wallpapers e temas personalizados de SDDM e GRUB.

## Restaurar depois de formatar

```bash
sudo pacman -S git
git clone https://github.com/Roger-Linux-sys/Dotfile-Recovery_Emergency.git ~/dotfiles
cd ~/dotfiles
./install.sh
sudo reboot
```

Rode como **usuário normal** (o script chama `sudo` quando precisa — como root ele se recusa a rodar).

Depois de instalar:

```bash
./install.sh --check    # só verifica o estado do sistema, não altera nada
./backup.sh             # joga o setup em uso de volta para o repositório
```

## O que o `install.sh` faz

| Etapa | O que acontece |
|---|---|
| 1 | Pacotes dos repositórios oficiais (o script valida cada nome antes; se algum não existir ele **avisa e para**, em vez de instalar nada silenciosamente) |
| 2 | Pacotes do AUR: `wlogout` e `vscodium-bin` — se você não tiver `yay`/`paru`, o script instala `base-devel` e compila o `yay` |
| 3 | Copia `worldmachine/` para `~/.config/worldmachine` e linka `hypr`, `waybar`, `rofi`, `fastfetch`, `kitty` em `~/.config` (com backup do que já existir) |
| 4 | Linka `fish`, `foot` e `wlogout` a partir de `config/` |
| 5 | Linka `autoclicker.sh` (F1) e `holdkey.sh` (F2) em `~/.local/bin` |
| 6 | Habilita `ydotool.service` (daemon `ydotoold`) e adiciona o usuário ao grupo `input` |
| 7 | Instala o tema `caelestia` no SDDM (`/usr/share/sddm/themes/caelestia` + `/etc/sddm.conf.d/caelestia.conf`) e habilita o `sddm` |
| 8 | Instala o tema `niko-theme` no GRUB, aplica `/etc/default/grub` + `grub-mkconfig` e copia os wallpapers para `~/Pictures/Wallpapers` |

No fim ele roda a verificação e mostra exatamente o que faltou (pacotes, comandos, symlinks, wallpaper, tema do SDDM/GRUB, `ydotoold`).

## O que tem no repositório

| Caminho | Conteúdo |
|---|---|
| `worldmachine/` | Rice principal (base: [hyprland-worldmachine](https://github.com/maxobur0001/hyprland-worldmachine), **modificado**): `hypr/` (`hyprland.conf`, `hyprlock.conf`, `wallpaper.png`, `scripts/`), `waybar/`, `rofi/` (inclui `bin/powermenu`), `fastfetch/`, `kitty/`, e ainda `dunst/`, `qutebrowser/` e `niri/` (não linkados por padrão) |
| `config/` | Configs independentes: `fish/`, `foot/`, `wlogout/` |
| `local/bin/` | `autoclicker.sh` (F1, ydotool) e `holdkey.sh` (F2, xdotool) |
| `sddm-caelestia/` | Tema Caelestia (locklike) do SDDM |
| `grub-niko-theme/` | Tema da Niko para o GRUB |
| `grub-default.conf` | Linhas aplicadas em `/etc/default/grub` |
| `sddm.conf` | Vai para `/etc/sddm.conf.d/caelestia.conf` |
| `wallpapers/` | Wallpapers extras (OneShot) → `~/Pictures/Wallpapers` |
| `keybinds-backup/` | Backup dos `keybinds.lua`/`variables.lua` do Caelestia Shell (não usado pelo install) |
| `install.sh` / `backup.sh` | Instalador / sincronizador de backup |

## Dependências

### Repositórios oficiais
* **Sistema:** hyprland, waybar, rofi, dunst, swaybg, hyprlock, hyprpicker
* **Terminais/shell:** fish, foot, kitty
* **Utilitários:** wlogout¹, wl-clipboard, cliphist, grim, slurp, ydotool, xdotool, brightnessctl, github-cli, imagemagick
* **Áudio/mídia:** pipewire, pipewire-pulse, wireplumber (`wpctl`), playerctl
* **Apps dos keybinds:** firefox, thunar, codium¹
* **Fontes:** ttf-jetbrains-mono-nerd (kitty), ttf-terminus-nerd (waybar/rofi)
* **SDDM:** sddm, qt6-declarative, qt6-5compat, qt6-svg, xorg-server, xorg-xauth
* **GRUB/build:** grub, rsync, base-devel

¹ `wlogout` e `codium` (`vscodium-bin`) estão **no AUR** — por isso o `pacman -S` antigo falhava inteiro: um pacote inexistente nos repositórios faz o pacman abortar e não instalar nada.

## Detalhes que importam

* **Wallpaper ativo:** `~/.config/worldmachine/hypr/wallpaper.png` — é o que o `swaybg -i $background` e o `hyprlock` usam.
* **Autoclicker:** `F1` = `autoclicker.sh` (ydotool, precisa do `ydotoold` rodando) e `F2` = `holdkey.sh` (xdotool, portanto só segura o clique em janelas X/XWayland).
* **Cursor OneShot (`oneshot-niko`) não está no repositório:** o `hyprland.conf` define `XCURSOR_THEME,oneshot-niko`, então se o tema não estiver instalado o cursor cai no padrão.
* O shell de login **continua bash** (o setup não troca com `chsh`).
* `dunst/`, `qutebrowser/` e `niri/` ficam no repositório mas não são linkados (não são usados hoje).
* GRUB é aplicado com `GRUB_GFXMODE=1280x1024x32,auto` (máquina BIOS + GRUB).
* O greeter do SDDM roda com `QT_QPA_PLATFORM=xcb` (por isso xorg-server/xorg-auth nos pacotes).
* Fontes do tema Caelestia (Material Symbols, Rubik, Roboto, CaskaydiaCove) são opcionais: sem elas o tema funciona, mas ícones podem cair em fonte substituta.

## Keybindings

| Tecla | Ação |
|---|---|
| `SUPER + Enter` | Terminal (foot) |
| `CTRL + SUPER + Enter` | App Launcher (rofi) |
| `SUPER + B` | Firefox |
| `SUPER + C` | Codium |
| `SUPER + E` | Thunar |
| `SUPER + Q` | Fechar Janela |
| `SUPER + F` | Tela Cheia |
| `SUPER + ALT + F` | Tela cheia com borda |
| `SUPER + ALT + Espaço` | Alternar janela flutuante |
| `SUPER + P` | Pin (fixar janela) |
| `SUPER + setas` | Mover Foco |
| `SUPER + SHIFT + setas` | Mover Janela |
| `SUPER + ALT + setas` / `SUPER ±` | Redimensionar janela |
| `SUPER + 1-0` | Alternar Workspace |
| `SUPER + ALT + 1-0` | Mover janela para Workspace |
| `CTRL + SUPER + esquerda/direita` | Workspace anterior/próximo |
| `SUPER + roda do mouse` | Workspace anterior/próximo |
| `SUPER + PageUp/PageDown` | Workspace anterior/próximo |
| `SUPER + S` | Workspace especial |
| `ALT + Tab` / `SHIFT + ALT + Tab` | Ciclar janelas |
| `SUPER + U` / `SUPER + ,` | Agrupar janela (togglegroup) |
| `SUPER + L` | Lockscreen (hyprlock) |
| `SUPER + SHIFT + L` | Suspender |
| `CTRL + ALT + Delete` | Menu de Energia (wlogout) |
| `SUPER + SHIFT + E` | Sair da Sessão |
| `Print` / `SUPER + SHIFT + 3` | Capturar tela |
| `SUPER + SHIFT + 4` | Capturar seleção |
| `SUPER + V` | Área de Transferência (cliphist + rofi) |
| `SUPER + SHIFT + C` | Seletor de Cor (hyprpicker) |
| `F1` | Alternar Autoclicker (ydotool) |
| `F2` | Segurar clique esquerdo (holdkey) |
| `XF86Audio*` / `XF86MonBrightness*` | Volume / brilho |

## Nota sobre a recuperação

Duas coisas faziam o clone **não** restaurar o setup:

1. `worldmachine/` era gravado como submódulo (`gitlink`) sem `.gitmodules` — o `git clone` trazia a pasta **vazia**, o `install.sh` imprimia `Warning: worldmachine not found, skipping...` e nenhum config do rice era instalado. Agora o `worldmachine/` está versionado como arquivos normais.
2. O `pacman -S` incluía `wlogout` (que é do AUR): o pacman abortava o lote inteiro e, como o erro era jogado em `2>/dev/null`, parecia que tinha dado certo.

Também foi removido o `config/hypr/` (era uma cópia desatualizada do `worldmachine/hypr/`, que agora é a única fonte de verdade) e o `install.sh` passou a linkar tudo, habilitar o `ydotoold`, ser idempotente (não aninha mais cópias de tema em re-execuções) e ter verificação final com `--check`.

Usa [hyprland-worldmachine](https://github.com/maxobur0001/hyprland-worldmachine) como base (modificado) e [caelestia-sddm](https://github.com/ItsABigIgloo/caelestia-sddm) para o tema do SDDM.

