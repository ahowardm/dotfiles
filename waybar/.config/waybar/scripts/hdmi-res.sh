#!/usr/bin/env bash
# Modulo custom/hdmi de waybar: muestra la resolucion actual de HDMI-A-1.
# Si el monitor no esta conectado devuelve texto vacio (waybar oculta el modulo).
# Devuelve JSON para return-type: json.

MONITOR="HDMI-A-1"

info=$(hyprctl monitors -j | jq -r --arg m "$MONITOR" \
    '.[] | select(.name==$m) | "\(.width)x\(.height)@\(.refreshRate | floor)"')

if [ -z "$info" ]; then
    echo '{"text": "", "tooltip": ""}'
    exit 0
fi

height=${info#*x}; height=${height%%@*}
case "$height" in
    720)  short="720p";  class="proyector" ;;
    1080) short="1080p"; class="normal" ;;
    *)    short="$height""p"; class="normal" ;;
esac

printf '{"text": "󰍹 %s", "tooltip": "%s: %s", "class": "%s"}\n' \
    "$short" "$MONITOR" "$info" "$class"
