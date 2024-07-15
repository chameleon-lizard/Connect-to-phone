#!/bin/bash

# Defining port range and mac addresses
MAC_ADDRESS='AA:BB:CC:DD:EE:FF'
PORT_RANGE='32768-65535'

# Scanning for IP
echo "Scanning for IP..."
while true; do
  result=$(sudo nmap -sn 192.168.1.1-254)
  # If a device with defined mac address is found, saving the IP
  if echo "$result" | grep $MAC_ADDRESS -q; then 
    IP=$(echo "$result" | grep "$MAC_ADDRESS" -B 2 | head -n 1 | awk '{ print $5 }')
    break 
  fi

  echo "IP not found, retrying scan..."
  sleep 0.2
done

echo "Ip found: $IP"

# Scanning ports of found device
echo "Scanning for port..."
while true; do
  result=$(nmap -Pn -p $PORT_RANGE $IP)
  # If an open port is found, saving this port
  if echo "$result" | grep open -q; then
    PORT=$(echo "$result" | grep open | awk '{ print $1 }' | cut -d "/" -f1)
    echo "Port found: $PORT"
    break
  fi
  echo "Port not found, retrying scan..."
  sleep 0.2
done

# If SIGINT, do adb disconnect
trap "adb disconnect $IP:$PORT" INT

# Connecting to device
adb connect $IP:$PORT

# Open scrcpy with h265, with keyboard, 60 fps and without active screen
scrcpy -s "$IP:$PORT" --video-codec=h265 --keyboard=uhid --max-fps=60 -S --power-off-on-close
