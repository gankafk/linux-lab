#!/bin/bash
set -euo pipefail # Nos aseguramos de que si algo falla, avise y no siga a ciegas

# Script con el que realizaremos el cambio de HOSTNAME, MACHINE-id y claves SSH

# Comprobar quien ejecuta el script y si tiene privilegios o no

if [[ $EUID -ne 0 ]]; then # Si EUID es distinto de 0 saca ERROR (El 0 es el ID asignado a root)
    echo "[ERROR] Ejecuta el script con sudo"
    exit 1
fi

# Solicitamos el nuevo nombre, lo almacenamos en new-hostname y lo asignamos con hostnamectl
read -r -p "[INFO] Introduce el nuevo hostname: " new_hostname

if [[ -z "$new_hostname" ]]; then # -z indica que la cadena esta vacía con lo que si se cumple salta exit 1
    echo "[ERROR] El hostname no puede estar vacío"
    exit 1
fi

hostnamectl set-hostname "$new_hostname"

# Modificamos el fichero /etc/hosts mediante sed con las siguientes expresiones regulares
sed -i "s/^127\.0\.1\.1.*/127.0.1.1 $new_hostname/" /etc/hosts

# Machine-id
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
systemd-machine-id-setup
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Claves SSH
rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

echo "[OK] Hostname, machine-id y SSH modificados con éxito."

#Reiniciamos el sistema

while true; do
    read -r -p "Desea reiniciar el sistema ahora? (y/n): "
    case "$REPLY" in
    y|Y) reboot
    ;;
    n|N) echo "[INFO] Recuerda reiniciar manualmente más tarde" 
    exit
    ;;
    *) echo "[INFO] Responde (y/n)"
    ;;
    esac
done
