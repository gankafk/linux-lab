# Módulo 0 — Fundamentos y control de versiones

> Estado: ✅ Completado

## Objetivo

Establecer los cimientos del laboratorio antes de construir infraestructura: repositorio Git
con protección de secretos, y una VM base reproducible de la que clonar las 4 máquinas.

## Qué se construyó

- Repositorio Git con `.gitignore` para excluir secretos (`*.pem`, `*.key`, `*.env`).
- VM base `base-ubuntu-2404`: Ubuntu Server 24.04 LTS, disco 30 GB con LVM, SSH como servicio persistente.
- Snapshot de la base limpia + 4 clones (`bastion`, `web-server`, `db-server`, `monitor-server`).
- Cada clon "generalizado" (hostname, `machine-id` y claves de host SSH únicas) mediante el script `hostname-changer.sh`.

## Decisiones clave

| Tema | Elección | Motivo |
|---|---|---|
| SO | Ubuntu Server 24.04 LTS | LTS madura, soporte largo. |
| Red | Red interna (host aislado) + NAT | Mínima exposición; acceso solo por SSH al bastión. |
| Disco | 30 GB con LVM (raíz 20 GB + 8 GB libres) | Espacio reservado para snapshots LVM; datos en disco aparte (db/monitor). |
| Recursos | Right-sizing por rol | Imagen base común; recursos ajustados por VM. |
| Snapshots | Hipervisor + LVM | Dos capas complementarias. |

## Cómo reproducir

1. Crear VM Ubuntu Server 24.04 (instalación manual, LVM, OpenSSH).
2. Actualizar, dejar SSH como servicio persistente y tomar snapshot limpio.
3. Clonar (clon completo, MAC nuevas) y ejecutar `hostname-changer.sh` en cada clon para darle identidad única.

## Artefactos

- [`hostname-changer.sh`](hostname-changer.sh) — generaliza un clon (hostname + machine-id + claves SSH).
