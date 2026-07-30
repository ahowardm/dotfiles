#!/bin/bash

set -e

# Desactivar WiFi power save para evitar cortes intermitentes
sudo install -d /etc/NetworkManager/conf.d
sudo tee /etc/NetworkManager/conf.d/wifi-powersave.conf >/dev/null <<'EOF'
[connection]
wifi.powersave = 2
EOF

# Evitar falsos conflictos de IP cuando wifi y ethernet quedan en la misma subred (ARP flux).
# Con el default arp_ignore=0, wlan0 responde el ARP probe de la IP del cable y NetworkManager
# desmonta IPv4 del cable en cada renovacion DHCP, botando la ruta default al wifi.
sudo tee /etc/sysctl.d/99-arp-flux.conf >/dev/null <<'EOF'
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
EOF
sudo sysctl --system

sudo systemctl stop iwd
sudo systemctl disable iwd
sudo systemctl enable --now NetworkManager
sudo systemctl restart NetworkManager

# Configurar dominio regulatorio de Chile para desbloquear txpower a 20 dBm
sudo iw reg set CL
