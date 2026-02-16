# Fix: Bluetooth HSP/HFP sin audio de salida

## Problema

Al conectar audífonos Bluetooth (Lenovo Wireless VoIP Headset) en una videollamada de Google Meet, el micrófono funcionaba pero no se escuchaba nada por los parlantes de los audífonos. Con el perfil A2DP (solo audio, sin micrófono) sí funcionaba.

## Diagnóstico

### Logs de WirePlumber
```bash
journalctl --user -u wireplumber --since "5 min ago" --no-pager
```
Mostraba: `spa.audioconvert: out of buffers on port 0`

### Logs del kernel
```bash
sudo dmesg | grep -i bluetooth | tail -30
```
Mostraba:
- `Bluetooth: hci1: corrupted SCO packet`
- `Bluetooth: hci1: SCO packet for unknown connection handle`

### Información del adaptador
- Adaptador: MediaTek (0e8d:e025) - Bluetooth interno del laptop
- Stack de audio: PipeWire + WirePlumber + pipewire-pulse

## Solución

### 1. Instalar rtkit
PipeWire necesita prioridad de tiempo real para manejar correctamente el audio Bluetooth. Sin `rtkit`, PipeWire no puede obtener esa prioridad y los buffers de audio se vacían antes de llegar al hardware.

```bash
sudo pacman -S rtkit
```

### 2. Habilitar MultiProfile en BlueZ
Editar `/etc/bluetooth/main.conf` y cambiar:
```
#MultiProfile = off
```
por:
```
MultiProfile = multiple
```

### 3. Instalar pavucontrol
Útil para diagnosticar problemas de audio. Permite ver perfiles, sinks, volumen por canal y ruteo de aplicaciones.

```bash
sudo pacman -S pavucontrol
```

### 4. Reiniciar el sistema
Un reboot completo es necesario para que todos los cambios tomen efecto (especialmente rtkit y el adaptador Bluetooth).

## Diagnóstico útil con pavucontrol

- **Playback**: verificar que el navegador esté ruteando al headset Bluetooth
- **Output Devices**: verificar volumen, mute y balance de canales
- **Configuration**: verificar qué perfil está activo (HSP/HFP vs A2DP)

## Comandos útiles

```bash
# Ver sinks disponibles
pactl list sinks short

# Ver perfil activo del dispositivo Bluetooth
pactl list cards | grep -A 5 "Active Profile"

# Ver conexiones de nodos de audio
pw-link -l | grep bluez

# Ver logs de PipeWire en tiempo real
journalctl --user -u wireplumber -f

# Ver errores del kernel Bluetooth
sudo dmesg | grep -i bluetooth
```

## Nota sobre ALSA

Durante la investigación se hizo downgrade de ALSA de 1.2.15.3 a 1.2.15.2 (reportado como causa de "corrupted SCO packet" en Arch Forums). Si después de un `pacman -Syu` el problema vuelve, verificar si ALSA fue actualizado:

```bash
pacman -Q alsa-ucm-conf alsa-lib
grep "upgraded alsa" /var/log/pacman.log | tail -5
```

Downgrade desde cache:
```bash
sudo pacman -U /var/cache/pacman/pkg/alsa-ucm-conf-1.2.15.2-1-any.pkg.tar.zst /var/cache/pacman/pkg/alsa-lib-1.2.15.2-1-x86_64.pkg.tar.zst
```
