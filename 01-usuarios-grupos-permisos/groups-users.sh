#!/bin/bash
# Nos aseguramos de que si algo falla, avise y no siga a ciegas
set -euo pipefail

# Comprobar quien ejecuta el script y si tiene privilegios o no
if [[ $EUID -ne 0 ]]; then # Si EUID es distinto de 0 saca ERROR (El 0 es el ID asignado a root)
    echo "[ERROR] Ejecuta el script con sudo"
    exit 1
fi

# En primer lugar modificamos el umask por defecto
sed -i "s/^UMASK.*/UMASK\t027/" /etc/login.defs
echo "[OK] umask cambiada correctamente a 027"

# Creamos nuevo grupo
read -r -p "[INFO] Introduce el nombre del nuevo grupo a crear: " newgroup
groupadd "$newgroup"
echo "[OK] Grupo creado correctamente"

# Creamos nuevo usuario
read -r -p "[INFO] Introduce el nombre del nuevo usuario a crear: " newuser
useradd -m -s /bin/bash "$newuser"

# Creamos contraseña para el nuevo usuario
read -r -s -p "[INFO] Introduce la contraseña para $newuser: " newpass
echo
echo "$newuser:$newpass"| chpasswd
echo "[OK] Usuario creado correctamente"

# Lo añadimos al grupo creado
usermod -aG "$newgroup" "$newuser"
echo "[OK] $newuser añadido al grupo $newgroup correctamente"

# Grupo para carpeta compartida
read -r -p "[INFO] Introduce el nombre del nuevo grupo para administrar la carpeta compartida (este nombre será el asignado tanto al grupo como a la carpeta): " sharedgroup
groupadd "$sharedgroup"
echo "[OK] Grupo $sharedgroup creado correctamente"
usermod -aG "$sharedgroup" "$newuser"
echo "[OK] $newuser añadido al grupo $sharedgroup correctamente"
mkdir /srv/"$sharedgroup"
echo "[OK] Carpeta $sharedgroup creada correctamente"
chgrp "$sharedgroup" /srv/"$sharedgroup"
chmod 3770 /srv/"$sharedgroup"
echo "[OK] Permisos y asignaciones de grupo de la carpeta $sharedgroup asignados con éxito"

#Gestionar ACLs
apt-get update && apt-get install -y acl
setfacl -m g:"$sharedgroup":rwx /srv/"$sharedgroup"
setfacl -d -m g:"$sharedgroup":rwx /srv/"$sharedgroup"
echo "[OK] ACLs asignados con éxito"
getfacl /srv/"$sharedgroup"