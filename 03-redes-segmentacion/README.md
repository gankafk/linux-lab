# Módulo 3 — Redes Linux y segmentación

> Estado: ✅ Completado (la segmentación del puerto de la DB se aplica en el Módulo 4, con PostgreSQL)

## Objetivo

Levantar la red interna privada entre las 4 VMs con IPs estáticas, aplicar firewall y segmentar
la capa de datos (la `db-server` solo accesible desde `web-server` y bastión). Habilita el salto
SSH (ProxyJump) y el hardening de las internas que quedó pendiente del Módulo 2.

## Direccionamiento

Subred interna: **`10.10.10.0/24`** (VirtualBox "Red interna"). Sin puerta de enlace ni DNS en
esta red: el acceso a internet va por el NAT (Adaptador 1).

| VM | IP interna (`enp0s8`) |
|---|---|
| `bastion` | `10.10.10.10` |
| `web-server` | `10.10.10.20` |
| `db-server` | `10.10.10.30` |
| `monitor-server` | `10.10.10.40` |

## Notas de diseño

- Cada VM tiene **dos interfaces**: `enp0s3` (NAT, DHCP → internet) y `enp0s8` (red interna, IP estática).
- IP estática configurada con **netplan**, solo en `enp0s8` (sin gateway/DNS).
- **Segmentación con firewall (ufw):** `db-server` acepta su puerto solo desde `web-server` (y bastión para admin); resto denegado.
- Diagnóstico: `ip a`, `ip r`, `ss`, `ping`, captura básica.

## Progreso

- [x] Red interna en VirtualBox (misma red en las 4 VMs) + IPs estáticas con **netplan**.
- [x] Conectividad entre las 4 VMs verificada (ping).
- [x] (Cierra Módulo 2) ProxyJump a internas + hardening SSH de web/db/monitor.
- [x] Firewall (ufw): por defecto denegar entrante / permitir saliente en las 4 VMs.
- [x] Segmentación SSH: a las internas solo se entra **desde el bastión** (`allow from 10.10.10.10`), verificado.
- [ ] Segmentación del puerto de la DB (`5432` solo desde `web-server`) → **Módulo 4** (requiere PostgreSQL instalado).

## Artefactos

- [`red-interna.sh`](red-interna.sh) — IP estática interna con netplan (detecta la interfaz automáticamente, valida el CIDR, idempotente).
- [`ufw-rules.sh`](ufw-rules.sh) — firewall de las internas: deny por defecto + SSH solo desde el bastión (idempotente, guarda de host).
