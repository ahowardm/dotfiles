#!/bin/bash

# Detiene el script si algo falla
set -e

# Instalar yay
if !command -v yay &>/dev/null; then
  echo "Instalando yay"
  rm -rf /tmp/yay
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
fi

echo "Actualizando mirrorlist"
sudo pacman -S --needed --noconfirm reflector

sudo install -d /etc/xdg/reflector
sudo tee /etc/xdg/reflector/reflector.conf >/dev/null <<'EOF'
--verbose
--country Chile,Brazil
--protocol https
--latest 20
--sort rate
--save /etc/pacman.d/mirrorlist
EOF

# Genera la mirrorlist ahora usando la misma config que usará el timer
sudo systemctl start reflector.service

# Ahora sí, actualiza con mirrors nuevos
sudo pacman -Syyu --noconfirm

echo "Instalando paquetes pacman"
sudo pacman -S --needed --noconfirm - <pacman-pkgs.txt
yay -S --needed --noconfirm - <aur-pkgs.txt

if ! command -v sentry-cli &>/dev/null; then
  echo "Instalando sentry-cli"
  curl -fsS https://cli.sentry.dev/install | sh
fi

echo "Configurando dotfiles"
stow hypr
stow mise
stow waybar
stow wofi
stow systemd
stow starship
stow nvim

systemctl --user enable --now battery-alert.timer:wofi
sudo systemctl enable --now bluetooth.service
./network.sh
sudo systemctl enable --now tlp.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

# Timer semanal (usa reflector.conf)
sudo systemctl enable --now reflector.timer

# Permitir cerrar la tapa del laptop con dock/monitor externo sin suspender
sudo sed -i 's/#HandleLidSwitchDocked=ignore/HandleLidSwitchDocked=ignore/' /etc/systemd/logind.conf
