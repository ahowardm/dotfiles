#!/bin/bash

# Detiene el script si algo falla
set -e

# Instalar yay
if !command -v yay &>/dev/null; then
  echo "Instalando yay"
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --no-confirm
  cd -
fi

echo "Instalando paquetes pacman"
sudo pacman -S --needed --noconfirm - <pacman-pkgs.txt
yay -S --needed --noconfirm - <aur-pkgs.txt

echo "Configurando dotfiles"
