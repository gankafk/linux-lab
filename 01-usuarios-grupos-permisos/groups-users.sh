#!/bin/bash
#
# groups-users.sh — Línea base de usuarios, grupos y permisos de una VM.
#
# Qué hace:
#   - Fija el umask por defecto a 027 en /etc/login.defs.
#   - Crea un grupo y un usuario (con contraseña) y añade el usuario al grupo.
#   - Crea un grupo + directorio compartido en /srv con setgid + sticky y ACLs.
#
# Uso:        sudo ./groups-users.sh   (interactivo: pide nombres y contraseña)
# Requisitos: ejecutar como root.
# Idempotente: se puede re-ejecutar sin error; no recrea lo que ya existe.
#
set -euo pipefail

# --- Comprobaciones previas --------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script debe ejecutarse como root (usa sudo)." >&2
    exit 1
fi

# --- umask por defecto -------------------------------------------------------
sed -i "s/^UMASK.*/UMASK\t027/" /etc/login.defs
echo "[OK] umask por defecto fijada a 027"

# --- Grupo y usuario ---------------------------------------------------------
read -r -p "[INFO] Nombre del nuevo grupo a crear: " newgroup
groupadd -f "$newgroup"                     # -f = no falla si el grupo ya existe
echo "[OK] Grupo '$newgroup' disponible"

read -r -p "[INFO] Nombre del nuevo usuario a crear: " newuser
if id "$newuser" &>/dev/null; then
    echo "[INFO] El usuario '$newuser' ya existe; se omiten creación y contraseña."
else
    useradd -m -s /bin/bash "$newuser"
    read -r -s -p "[INFO] Contraseña para $newuser: " newpass
    echo
    echo "$newuser:$newpass" | chpasswd
    unset newpass                           # no dejar la contraseña en memoria más de lo necesario
    echo "[OK] Usuario '$newuser' creado"
fi

usermod -aG "$newgroup" "$newuser"          # idempotente: re-añadir a un grupo no falla
echo "[OK] '$newuser' pertenece al grupo '$newgroup'"

# --- Grupo y directorio compartido -------------------------------------------
read -r -p "[INFO] Nombre del grupo/carpeta compartida (mismo nombre para ambos): " sharedgroup
groupadd -f "$sharedgroup"
usermod -aG "$sharedgroup" "$newuser"
echo "[OK] Grupo compartido '$sharedgroup' listo y '$newuser' añadido"

shared_dir="/srv/$sharedgroup"
mkdir -p "$shared_dir"                       # -p = no falla si ya existe
chgrp "$sharedgroup" "$shared_dir"
chmod 3770 "$shared_dir"                     # setgid + sticky + rwxrwx---
echo "[OK] Directorio '$shared_dir' con setgid+sticky y grupo asignado"

# --- ACLs (colaboración pese a umask 027) ------------------------------------
if ! command -v setfacl &>/dev/null; then
    apt-get update && apt-get install -y acl
fi
setfacl -m  g:"$sharedgroup":rwx "$shared_dir"   # acceso actual
setfacl -d -m g:"$sharedgroup":rwx "$shared_dir"  # por defecto para lo nuevo
echo "[OK] ACLs aplicadas"

echo "[OK] Línea base completada. Estado del directorio compartido:"
getfacl "$shared_dir"
