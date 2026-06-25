#!/bin/bash
#
# ufw-rules.sh — Firewall de las VMs internas (web / db / monitor).
#
# Qué hace:
#   - Política por defecto: denegar entrante, permitir saliente.
#   - Permite SSH ÚNICAMENTE desde el bastión (segmentación: a las internas
#     solo se entra a través del bastión).
#
# Uso:        sudo ./ufw-rules.sh
# Requisitos: ejecutar como root, en una VM interna (NO en el bastión),
#             con la red interna ya configurada.
# Resultado:  ufw activo con el estado descrito (idempotente: deja siempre
#             el mismo estado final).
#
set -euo pipefail

# --- Configuración -----------------------------------------------------------
BASTION_IP="10.10.10.10"
SSH_PORT="22"

# --- Comprobaciones previas --------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "[ERROR] Este script debe ejecutarse como root (usa sudo)." >&2
    exit 1
fi

if [[ "$(hostname)" == "bastion" ]]; then
    echo "[ERROR] No ejecutar en el bastión: lo dejaría sin acceso SSH desde el host." >&2
    exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
    echo "[ERROR] ufw no está instalado." >&2
    exit 1
fi

# --- Aplicación de reglas ----------------------------------------------------
echo "[INFO] Reiniciando ufw a un estado limpio..."
ufw --force reset

echo "[INFO] Aplicando políticas por defecto (deny incoming / allow outgoing)..."
ufw default deny incoming
ufw default allow outgoing

echo "[INFO] Permitiendo SSH (${SSH_PORT}/tcp) solo desde el bastión (${BASTION_IP})..."
ufw allow from "$BASTION_IP" to any port "$SSH_PORT" proto tcp

echo "[INFO] Activando el firewall..."
ufw --force enable

echo "[INFO] Estado final:"
ufw status verbose

echo "[OK] Firewall aplicado correctamente."
