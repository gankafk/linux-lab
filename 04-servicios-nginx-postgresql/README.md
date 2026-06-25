# Módulo 4 — Servicios por capas: Nginx (web) + PostgreSQL (datos)

> Estado: ⬜ Pendiente

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

## Decisiones pendientes

- Tipo de aplicación que sirve `web-server`: sitio estático + demo de conectividad, o app dinámica que lee de la DB con Nginx como reverse proxy (y, en ese caso, el stack).

## Notas de seguridad

- Credenciales de la DB **fuera del repo** (gitignored / variables), nunca hardcodeadas.
- Provisionar (instalar) = admin (`juanma`); operar el servicio = operador (`webops`/`dbops`).
