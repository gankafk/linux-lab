# Módulo 5 — Bash scripting y automatización con cron

> Estado: 🟦 En curso

## Objetivo

Formalizar las buenas prácticas de scripting en Bash y automatizar tareas con cron: scripts
robustos (manejo de errores, idempotencia), programados, con logging para ejecución desatendida.

## Qué aporta de nuevo (respecto a los scripts previos)

- **cron**: ejecutar tareas automáticamente según un horario (no a mano).
- **Logging**: salida con marca de tiempo a un fichero de log, para auditar lo que pasó cuando nadie miraba.
- Consolidación de buenas prácticas ya aplicadas: `set -euo pipefail`, validaciones, errores a stderr, idempotencia.

## Entregable central

Un script **`health-check.sh`** que:
- Recoge estado del sistema: uso de disco, memoria y estado de servicios clave (ssh, nginx, postgresql según VM).
- Registra el resultado con **timestamp** en un fichero de log.
- Se ejecuta **periódicamente con cron**.

> Es la versión artesanal (bash+cron) de la monitorización; en el Módulo 7 se hará la versión profesional con Prometheus/Grafana.

## Entregable adicional

Un script **`limpieza-logs.sh`** que elimina/rota logs antiguos (más de N días) de forma
controlada, programado con cron. Tarea clásica de sysadmin para evitar que el disco se llene.

## Progreso

- [x] **`health-check-web.sh` / `health-check-db.sh`**: chequean disco, memoria y los servicios de cada VM; registran en `/var/log/health-check.log` con timestamp; if/else con estado OK/WARNING.
- [x] **cron**: programado en la crontab de root (`*/15 * * * *`), verificado que se ejecuta solo.
- [ ] **`limpieza-logs.sh`**: borrar logs antiguos con `find -mtime` (con dry-run de seguridad). *(Siguiente)*

## Artefactos

- [`health-check-web.sh`](health-check-web.sh) / [`health-check-db.sh`](health-check-db.sh) — un script por VM (con sus servicios), desplegados en `/usr/local/sbin/` (root:root, 755), ejecutados por cron de root.

## Conceptos del módulo

- Sintaxis de **cron** (5 campos), `crontab -e` (usuario) vs `/etc/cron.d`, `/etc/cron.daily`.
- **Logging**: redirección de salida, timestamps, ubicación del log, permisos, rotación (logrotate).
- Buenas prácticas de scripting (recap) e idempotencia.

## Scripts previos del lab (ya escritos)

`hostname-changer.sh` (M0), `groups-users.sh` (M1), `red-interna.sh` y `ufw-rules.sh` (M3) — todos
con preámbulo seguro, validaciones e idempotencia.
