#!/usr/bin/env bash

# Get CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')

# Get RAM usage
ram_usage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')

# Get CPU temperature (may need adjustment based on your system)
cpu_temp=$(sensors | awk '/Package id 0/{print $4}' | sed 's/+//;s/°C//')
# Alternative if above doesn't work:
# cpu_temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1 | awk '{print $1/1000}')

# Get current battery watt usage (Arch Linux / sysfs)
battery_path=$(ls /sys/class/power_supply/BAT*/power_now 2>/dev/null | head -n1)
if [[ -n "$battery_path" ]]; then
  watt_usage=$(awk '{print $1/1000000}' "$battery_path" 2>/dev/null)
  watt_usage=$(printf "%.1fW" "$watt_usage")
else
  watt_usage="N/A"
fi

# Output the information
echo "{\"text\":\" $cpu_usage\n $ram_usage\n ${cpu_temp}°C\n󱐋 ${watt_usage}\"}"
