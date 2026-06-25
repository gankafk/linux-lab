#!/bin/bash
#
# red-interna.sh — Asigna una IP estática en la red interna (netplan).
#
# Qué hace:
#   - Detecta la interfaz interna (la ethernet que NO tiene la ruta por defecto).
#   - Escribe /etc/netplan/99-internal.yaml con esa interfaz e IP fija (sin DHCP/gateway).
#   - Aplica la configuración.
#
# Uso:        sudo ./red-interna.sh   (interactivo: pide la IP en formato CIDR)
# Requisitos: ejecutar como root; segundo adaptador en "Red interna".
# Idempotente: sobrescribe el YAML con el estado deseado; re-ejecutable sin problema.
#
set -euo pipefail

# --- Configuración -----------------------------------------------------------
NETPLAN_FILE="/etc/netplan/99-internal.yaml"

# --- Comprobaciones previas --------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script debe ejecutarse como root (usa sudo)." >&2
    exit 1
fi

# --- Entrada y validación ----------------------------------------------------
read -r -p "[INFO] IP interna a asignar (formato CIDR, p.ej. 10.10.10.20/24): " ip_interna

if [[ ! "$ip_interna" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]]; then
    echo "[ERROR] Formato inválido. Debe ser IP/CIDR, p.ej. 10.10.10.20/24." >&2
    exit 1
fi

# --- Detección de la interfaz interna ----------------------------------------
# La interna es la ethernet que NO tiene la ruta por defecto (esa es la del NAT).
nat_dev=$(ip route show default | awk '{print $5}')
device=""
for iface in /sys/class/net/en*; do
    name=$(basename "$iface")
    if [[ "$name" != "$nat_dev" ]]; then
        device="$name"
        break
    fi
done

if [[ -z "$device" ]]; then
    echo "[ERROR] No se encontró interfaz interna (distinta de la del NAT: ${nat_dev})." >&2
    exit 1
fi
echo "[INFO] Interfaz interna detectada: $device"

# --- Escritura de la configuración netplan -----------------------------------
cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  ethernets:
    $device:
      dhcp4: false
      addresses:
        - $ip_interna
EOF
chmod 600 "$NETPLAN_FILE"
echo "[OK] $NETPLAN_FILE escrito"

# --- Aplicación --------------------------------------------------------------
netplan apply
echo "[OK] IP $ip_interna asignada en $device"
