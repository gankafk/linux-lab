# Linux-lab

Laboratorio Linux + AWS que simula una pequeña infraestructura real, construido de forma
progresiva como proyecto de portfolio para perfiles **Cloud / DevOps Junior** (con solape
hacia AWS Cloud Support y SysAdmin Linux).

No es un laboratorio académico: el objetivo es demostrar competencias prácticas en
administración Linux, redes, seguridad, monitorización, automatización, troubleshooting e
integración con AWS, y poder defender cada decisión técnica en una entrevista.

## Arquitectura

Topología de 4 VMs (VirtualBox local) integradas con servicios gestionados de AWS:

```
  [ Host · VirtualBox ]
   ├── bastion         → jump host SSH + nodo de control
   ├── web-server      → Nginx (capa web)
   ├── db-server       → PostgreSQL (capa de datos, segmentada)
   └── monitor-server  → Prometheus + Grafana
                 └──(AWS CLI)──► AWS: IAM · S3 · (CloudWatch · Route53)
```

- **Red:** red interna privada (host aislado) + NAT para salida a internet. Acceso solo por SSH al bastión.
- **Híbrido:** las VMs corren en local; AWS aporta identidad (IAM), almacenamiento de backups (S3) y, opcionalmente, métricas y DNS/TLS.

## Stack tecnológico

Ubuntu Server 24.04 LTS · SSH · Bash · Cron · Nginx · PostgreSQL · Prometheus · Grafana ·
AWS (IAM, S3, CloudWatch, Route53) · Git.

## Documentación

- **[ROADMAP.md](ROADMAP.md)** — hoja de ruta: módulos, objetivos y estado.
- Cada módulo tiene su propio `README.md` con lo que se construyó, las decisiones clave y cómo reproducirlo.

## Estructura del repositorio

```
linux-lab/
├── README.md          ← este archivo
├── ROADMAP.md         ← hoja de ruta
├── GUIA_PASOS.md      ← guía de pasos por módulo
├── .gitignore         ← protección de secretos (claves, .env, etc.)
├── 00-fundamentos/    ← Módulo 0: repositorio, versionado y VM base
│   └── README.md
└── ...                ← módulos siguientes (se crean a medida que se necesitan)
```

> Las carpetas de cada módulo se crean de forma incremental, no todas de golpe.
> Los secretos (credenciales AWS, claves SSH privadas) viven **fuera del repo** por ubicación;
> el `.gitignore` actúa como red de seguridad adicional.

## Estado actual

| Módulo | Estado |
|---|---|
| 0 — Fundamentos y versionado | ✅ |
| 1 — Usuarios, grupos y permisos | ✅ |
| 2 — SSH, hardening y bastión | ✅ |
| 3 — Redes y segmentación | ✅ |
| 4 — Servicios (Nginx + PostgreSQL) | 🟦 (DB + app + gunicorn; falta Nginx) |
| 5–11 | ⬜ |

Infraestructura levantada: 4 VMs con red interna privada (`10.10.10.0/24`), acceso SSH por clave
vía bastión (ProxyJump), hardening, firewall (ufw) con SSH segmentado, y una arquitectura de dos
capas (Flask+gunicorn en web ↔ PostgreSQL segmentada en db). Siguiente: Nginx como reverse proxy.
