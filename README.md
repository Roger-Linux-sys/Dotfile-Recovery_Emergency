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

  
## Instalação

```bash
sudo pacman -S git
git clone https://github.com/Roger-Linux-sys/Dotfile-Recovery_Emergency.git ~/dotfiles
cd ~/dotfiles
./install.sh
sudo reboot
```

Feito para que eu possa voltar ao meu setup rapidamente caso eu reinstale o sistema
