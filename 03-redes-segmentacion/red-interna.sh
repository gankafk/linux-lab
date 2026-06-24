#!/bin/bash

# Script para automatizar la configuracion de la IP interna estática de las VMS

# Nos aseguramos de que si algo falla, avise y no siga a ciegas
set -euo pipefail

# Comprobar quien ejecuta el script y si tiene privilegios o no
if [[ $EUID -ne 0 ]]; then # Si EUID es distinto de 0 saca ERROR (El 0 es el ID asignado a root)
    echo "[ERROR] Ejecuta el script con sudo"
    exit 1
fi

read -r -p "[INFO] Introduce la direccion ip a asignar en la presente maquina (ESPECIFICAR CIDR): " ip_interna

nat_dev=$(ip route show default | awk '{print $5}')
for iface in /sys/class/net/en*; do
    name=$(basename "$iface")
    if [ "$name" != "$nat_dev" ]; then
        device="$name"
        break
    fi
done

cat <<EOF > /etc/netplan/99-internal.yaml
network:
  version: 2
  ethernets:
    $device:
      dhcp4: false
      addresses:
        - $ip_interna
EOF

echo "[INFO] Fichero 99-internal.yaml creado con éxito."

chmod 600 /etc/netplan/99-internal.yaml
netplan apply

echo "[INFO] IP asignada con éxito"