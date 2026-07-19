# Dotfile-Recovery_Emergency

Meus dotfiles e configurações pessoais do Arch para restaurar de forma rápida meu ricing após uma instalação limpa

O tema geral é inspirado em OneShot com wallpapers, cursor e temas personalizados para SDDM e GRUB

## Inclui

* Worldmachine Dotfiles (modificados)
* Hyprland, Waybar, Rofi, Dunst e Fastfetch
* Fish Shell
* Foot Terminal(Terminal principal)
* Wlogout
* Autoclicker (F1)
* Tema do Caelestia para SDDM
* Tema da Niko para GRUB
* Cursor e wallpapers do OneShot

## Dependências

### Sistema
* hyprland, waybar, rofi, dunst, swaybg
* fish, foot, kitty

### Utilitários
* wlogout, fastfetch, ydotool, brightnessctl
* github-cli

### Fontes
* ttf-jetbrains-mono-nerd

### Gerenciamento de Sessão
* sddm (habilitado automaticamente pelo script)

## Keybindings

| Tecla | Ação |
|---|---|
| `SUPER + Enter` | Terminal (foot) |
| `CTRL + SUPER + Enter` | Lançador de apps (rofi) |
| `SUPER + B` | Firefox |
| `SUPER + C` | Codium |
| `SUPER + E` | Thunar |
| `SUPER + Q` | Fechar janela |
| `SUPER + F` | Tela cheia |
| `SUPER + ALT + F` | Tela cheia com borda |
| `SUPER + ALT + Espaço` | Alternar janela flutuante |
| `SUPER + setas` | Mover foco |
| `SUPER + SHIFT + setas` | Mover janela |
| `SUPER + 1-0` | Alternar workspace |
| `SUPER + ALT + 1-0` | Mover janela para workspace |
| `CTRL + SUPER + esquerda/direita` | Workspace anterior/próximo |
| `SUPER + L` | Travar tela |
| `SUPER + SHIFT + L` | Suspender |
| `CTRL + ALT + Delete` | Menu de energia (wlogout) |
| `SUPER + SHIFT + E` | Sair da sessão |
| `Print` | Capturar tela |
| `SUPER + SHIFT + 3` | Capturar tela |
| `SUPER + SHIFT + 4` | Capturar seleção |
| `SUPER + V` | Área de transferência (cliphist + rofi) |
| `SUPER + SHIFT + C` | Seletor de cor (hyprpicker) |
| `F1` | Alternar autoclicker (50 CPS) |
| `SUPER + roda do mouse` | Workspace anterior/próximo |
| `SUPER + PageUp/PageDown` | Workspace anterior/próximo |

  
## Instalação

```bash
sudo pacman -S git
git clone https://github.com/Roger-Linux-sys/Dotfile-Recovery_Emergency.git ~/dotfiles
cd ~/dotfiles
./install.sh
sudo reboot
```

Feito para que eu possa voltar ao meu setup rapidamente caso eu reinstale o sistema
