#!/bin/bash
#
# limpieza-logs.sh - Se encarga de realizar una limpieza de los logs innecesarios
#
# Qué hace:
#    - El script busca los ficheros correspondientes a los logs.
#    - Que coincidan con un determinado patrón.
#    - Con una antigüedad determinada.
#    - Los borra.
#
# --- CONTROL DE ERRORES --------------------------------------------------------
set -euo pipefail

# --- CONFIGURACIÓN -------------------------------------------------------------
DIR_LOGS="/tmp/test-logs"
DIAS=14
LOG="/tmp/limpieza.log"

# --- FUNCION DEL LOG -----------------------------------------------------------
log () {
    echo "$(date '+%F %T') | $1" >> "$LOG"
}

# --- LIMPIEZA DE LOGS ----------------------------------------------------------
find_logs=$(find "$DIR_LOGS" -type f -name "*.log" -mtime +"$DIAS")
num=$(echo "$find_logs" | wc -l)
log "Limpieza: $num ficheros de más de $DIAS días en $DIR_LOGS"

for fichero in $find_logs; do
    rm "$fichero"
    log "Eliminado: $fichero ha sido eliminado"
done