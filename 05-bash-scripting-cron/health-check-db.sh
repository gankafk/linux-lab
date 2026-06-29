#!/bin/bash
#
# health-check.sh - Se encarga de realizar un chequeo de disco, memoria, etc.
#
# Qué hace:
#    - Define una variable con la ruta del log y los umbrales (P.E.: >80% disco).
#    - Una función escribe el log con el timestamp.
#    - Recoge y registra el uso del disco, memoria y estado de servicios.
#    - Si algún parámetro supera el umbral, registra un aviso.
#
# Uso:        sudo ./health-check.sh   (escribe en /var/log, requiere root)
# Programado: vía cron de root (p.ej. "*/15 * * * * /usr/local/sbin/health-check.sh")
#
# --- CONTROL DE ERRORES --------------------------------------------------------
set -euo pipefail

# --- CONFIGURACIÓN -------------------------------------------------------------
LOG=/var/log/health-check.log
UMBRAL_DISCO=80
UMBRAL_MEM_PORC=20

# --- FUNCION DEL LOG -----------------------------------------------------------
log () {
    echo "$(date '+%F %T') | $1" >> "$LOG"
}

# --- USO DEL DISCO -------------------------------------------------------------
uso_disco=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$uso_disco" -gt "$UMBRAL_DISCO" ]; then
    log "[WARNING] Disco al ${uso_disco}%"
else
    log "[OK] Disco al ${uso_disco}%"
fi

# --- USO DE MEMORIA ------------------------------------------------------------
mem_disp=$(free -m | awk 'NR==2 {print $7}')
memoria_total=$(free -m | awk 'NR==2 {print $2}')
porcentaje_memoria=$(( mem_disp*100/memoria_total ))

if [ "$porcentaje_memoria" -lt "$UMBRAL_MEM_PORC" ]; then
    log "[WARNING] Memoria disponible al ${porcentaje_memoria}%"
else
    log "[OK] Porcentaje de memoria al ${porcentaje_memoria}%"
fi

# --- CHEQUEO DE SERVICIOS ------------------------------------------------------
SERVICIOS="ssh postgresql"

for servicio in $SERVICIOS; do

    estado=$(systemctl is-active "$servicio" || true)

    if [ "$estado" = "active" ]; then
        log "[OK] El estado del servicio ${servicio} es ${estado}"
    else
        log "[ERROR] El estado del servicio ${servicio} es ${estado}"
    fi
done
