#!/bin/bash

# Defining port range and mac addresses
MAC_ADDRESS='AA:BB:CC:DD:EE:FF'
PORT_RANGE='32768-65535'

# Parsing command line arguments
while getopts ":p:" opt; do
  case $opt in
    p) previous_ip_file="$OPTARG";;
    \?) echo "Invalid option: -$OPTARG"; exit 1;;
  esac
done

shift $((OPTIND-1))

# Checking for the existence of the file with credentials
if [ -n "$previous_ip_file" ]; then
  # Check if file path contains suspicious characters
  if [[ $previous_ip_file =~ [^a-zA-Z0-9_/\.\-] ]]; then
    echo "Error: File path contains suspicious characters"
    exit 1
  fi

  # Check if file exists and has only one line with IP:PORT format
  if [ -f "$previous_ip_file" ]; then
    lines=$(wc -l < "$previous_ip_file")
    if [ $lines -ne 1 ]; then
      echo "Error: File should have only one line"
      exit 1
    fi

    ip_port=$(cat "$previous_ip_file")
    IFS=: read -r IP PORT <<< "$ip_port"
    echo "Using previous credentials from file: $previous_ip_file"
    echo "IP: $IP"
    echo "PORT: $PORT"
  else
    echo "Error: File does not exist"
    exit 1
  fi
else
  # If the file was not provided, we should do the scan again
  echo "No previous IP file specified"

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
fi
  
# If SIGINT, do adb disconnect
trap "adb disconnect $IP:$PORT; echo $IP:$PORT > ~/.previous_phone_connect" INT

# Connecting to device
adb connect $IP:$PORT

# Open scrcpy with h265, with keyboard, 60 fps and without active screen
scrcpy -s "$IP:$PORT" --video-codec=h265 --keyboard=uhid --max-fps=60 -S --power-off-on-close
