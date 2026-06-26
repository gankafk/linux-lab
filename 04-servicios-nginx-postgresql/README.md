# Módulo 4 — Servicios por capas: Nginx (web) + PostgreSQL (datos)

> Estado: 🟦 En curso (falta Nginx)

## Objetivo

Desplegar una arquitectura de dos capas en VMs separadas: Nginx en `web-server` (capa web) y
PostgreSQL en `db-server` (capa de datos), comunicadas de forma segura, y completar la
segmentación de la base de datos.

## Alcance previsto

1. **`db-server`:** instalar PostgreSQL, crear base de datos + usuario de aplicación con mínimo privilegio.
2. **`web-server`:** instalar Nginx, servir el sitio y conectar a la DB remota (reverse proxy si la app es dinámica).
3. **systemd:** gestionar y verificar ambos servicios (status/enable/logs).
4. **Verificación** de la comunicación web↔db y de la segmentación.

## Segmentación de la DB (3 capas, defensa en profundidad)

- **PostgreSQL `listen_addresses`** → escucha en la IP interna de `db-server`, no solo en localhost.
- **`pg_hba.conf`** → solo acepta conexiones desde la IP de `web-server`.
- **ufw** → `allow 5432/tcp from web-server` (cierra lo pendiente del Módulo 3).

> Resultado: la DB es accesible **solo desde `web-server`**; el resto de VMs, denegado en las 3 capas.

## Decisión de aplicación

App dinámica en **Python / Flask** (con **gunicorn** y **Nginx** como reverse proxy). Sirve los
mensajes almacenados en PostgreSQL.

## Progreso

- [x] `db-server`: PostgreSQL instalado; base de datos `labapp` + rol `appuser` (mínimo privilegio); tabla con datos.
- [x] **Segmentación 3 capas** (`listen_addresses` + `pg_hba.conf` + `ufw`), verificada (web sí, otras VMs no).
- [x] `web-server`: venv + app Flask + driver postgres; credenciales en `EnvironmentFile` fuera del repo.
- [x] **gunicorn** como servicio systemd (`labapp.service`), usuario de servicio dedicado, escuchando en `127.0.0.1:8000`. Verificado con `curl`.
- [ ] **Nginx como reverse proxy** (80 → 127.0.0.1:8000) + estáticos. *(Siguiente)*

## Artefactos

- [`app/`](app/) — app Flask de demostración (`app.py`, `templates/`, `static/`, `requirements.txt`).
- [`deploy/labapp.service`](deploy/labapp.service) — unit file de systemd para gunicorn.
- [`deploy/labapp.env.example`](deploy/labapp.env.example) — plantilla de credenciales (sin el secreto real).

## Notas de seguridad

- Credenciales de la DB **fuera del repo** (`/etc/labapp/labapp.env`, 600 root), nunca hardcodeadas; la app las lee por variables de entorno.
- Provisionar (instalar) = admin (`juanma`); la app corre como usuario de servicio sin login (`labapp`).
