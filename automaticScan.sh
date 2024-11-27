#!/bin/bash

green='\033[0;32m'
yellow='\033[0;33m'
clear='\033[0m'

# Verifica si se ha pasado la IP como argumento
if [ -z "$1" ]; then
    echo "Uso: $0 <IP de máquina objetivo>"
    exit 1
fi

# Guarda la IP objetivo
IP="$1"

# Crear directorio de salida
mkdir -p scan

echo "[*] Identificando puertos abiertos de $IP"
nmap -p- --open -sS -n -Pn --min-rate 5000 "$IP" -oG initial_scan.txt > /dev/null 2>&1

PORTS=$(grep -oP '\d+/open' initial_scan.txt | awk -F'/' '{print $1}' | tr '\n' ',' | sed 's/,$//')
echo "$PORTS" > scan/ports.txt

rm initial_scan.txt

# Verifica si se encontraron puertos
if [ -z "$PORTS" ]; then
    echo "No se encontraron puertos abiertos."
    exit 1
fi

echo -e "Puertos abiertos de ${yellow}$IP${clear}: ${green}$PORTS${clear}"

echo "[*] Identificando versión y servicios en los puertos abiertos de $IP"
nmap -p"$PORTS" -sCV -vvv "$IP" -oN scan/detailed_scan.txt > /dev/null 2>&1

echo "[*] Resumen de puertos abiertos, servicios y versiones:"
grep -E "^[0-9]+/tcp|Service Info" scan/detailed_scan.txt
