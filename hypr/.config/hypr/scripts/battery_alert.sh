#!/bin/bash

# Battery paths
BAT0="/sys/class/power_supply/BAT0"
BAT1="/sys/class/power_supply/BAT1"

# Function to compute total percentage like TLP does
calc_total_percentage() {
  EN0=$(cat "$BAT0/energy_now")
  EN1=$(cat "$BAT1/energy_now")
  FULL0=$(cat "$BAT0/energy_full")
  FULL1=$(cat "$BAT1/energy_full")

  TOTAL_NOW=$((EN0 + EN1))
  TOTAL_FULL=$((FULL0 + FULL1))

  # Avoid division by zero
  if [[ $TOTAL_FULL -eq 0 ]]; then
    echo 0
  else
    echo $((100 * TOTAL_NOW / TOTAL_FULL))
  fi
}

# Calculate combined percentage
LEVEL=$(calc_total_percentage)

# Check if either battery is discharging
STATE0=$(cat "$BAT0/status")
STATE1=$(cat "$BAT1/status")

# Combined state = "Discharging" only if any is discharging
if [[ "$STATE0" == "Discharging" || "$STATE1" == "Discharging" ]]; then
  STATE="Discharging"
else
  STATE="Charging"
fi

# Thresholds
LOW=20
CRIT=10
CRIT_HARD=5

# Flags for anti-spam
RUNTIME="/run/user/$UID"
F_LOW="$RUNTIME/batt_low"
F_CRIT="$RUNTIME/batt_crit"

# Logic
if [[ "$STATE" == "Discharging" ]]; then

  if ((LEVEL <= LOW)) && [[ ! -f "$F_LOW" ]]; then
    notify-send -u normal "🔋 Batería baja" "Queda $LEVEL%"
    touch "$F_LOW"
  fi

  if ((LEVEL <= CRIT)) && [[ ! -f "$F_CRIT" ]]; then
    notify-send -u critical "⚠️ Batería crítica" "Queda $LEVEL%"
    touch "$F_CRIT"
  fi

  if ((LEVEL <= CRIT_HARD)); then
    notify-send -u critical "💀 Nivel crítico" "Suspendiendo..."
    sleep 2
    systemctl suspend
  fi

else
  rm -f "$F_LOW" "$F_CRIT"
fi
