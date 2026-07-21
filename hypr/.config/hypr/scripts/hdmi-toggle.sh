#!/usr/bin/env bash
# Alterna la resolucion de HDMI-A-1 entre modo normal y modo proyector,
# sin tener que editar hyprland.conf.
#
#   Normal:    1920x1080@60  (default de la config)
#   Proyector: 1280x720@60   (proyectores viejos que no soportan 1080p)
#
# Uso:
#   hdmi-toggle.sh            -> alterna entre ambos modos
#   hdmi-toggle.sh normal     -> fuerza modo normal
#   hdmi-toggle.sh proyector  -> fuerza modo proyector

set -euo pipefail

MONITOR="HDMI-A-1"
NORMAL="1920x1080@60"
PROYECTOR="1280x720@60"
POS="auto-right"
SCALE="1"

apply() {
    local mode="$1" label="$2"
    hyprctl keyword monitor "${MONITOR},${mode},${POS},${SCALE}"
    notify-send -i video-display "${MONITOR}" "${label}: ${mode}"
    # Refresca de inmediato el modulo de waybar (custom/hdmi, signal 8).
    pkill -RTMIN+8 waybar 2>/dev/null || true
}

# Verifica que el monitor este conectado antes de hacer nada.
if ! hyprctl monitors -j | jq -e --arg m "$MONITOR" 'any(.[]; .name == $m)' >/dev/null; then
    notify-send -i dialog-warning "${MONITOR}" "No esta conectado"
    exit 1
fi

current=$(hyprctl monitors -j | jq -r --arg m "$MONITOR" \
    '.[] | select(.name==$m) | "\(.width)x\(.height)"')

case "${1:-toggle}" in
    normal)    apply "$NORMAL"    "Modo normal" ;;
    proyector) apply "$PROYECTOR" "Modo proyector" ;;
    *)
        if [ "$current" = "1280x720" ]; then
            apply "$NORMAL" "Modo normal"
        else
            apply "$PROYECTOR" "Modo proyector"
        fi
        ;;
esac
