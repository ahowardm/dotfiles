#!/bin/bash

set -e

# Desactivar WiFi power save para evitar cortes intermitentes
sudo install -d /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF

sudo systemctl stop iwd
sudo systemctl disable iwd
sudo systemctl enable --now NetworkManager
sudo systemctl restart NetworkManager

# Configurar dominio regulatorio de Chile para desbloquear txpower a 20 dBm
sudo iw reg set CL
