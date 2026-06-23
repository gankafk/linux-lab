# Módulo 1 — Usuarios, grupos y permisos

> Estado: 🟦 En curso

## Objetivo

Diseñar y aplicar un modelo de usuarios, grupos y permisos en las VMs: grupo de administración,
operadores con `sudo` restringido, directorio compartido de equipo, umask y ACLs.

## Enfoque de identidad (progresivo)

1. **Local (este módulo):** usuarios y grupos locales en cada VM.
2. **Claves SSH (Módulo 2):** autenticación por clave en lugar de contraseña.
3. **Futuro (posible lab aparte):** identidad centralizada (LDAP/AD + SSSD + Kerberos) para gestión a escala.

> Las cuentas locales sirven para admin *break-glass* y cuentas de servicio; a escala, la identidad se centraliza.

## Estructura de usuarios y grupos

### Línea base (en las 4 VMs)

| Elemento | Nombre | Rol |
|---|---|---|
| Usuario | `labadmin` | Break-glass: cuenta local de emergencia, uso excepcional. |
| Usuario | `juanma` | Admin nominal del día a día (trazabilidad en logs). |
| Grupo | `admins` | `sudo` completo (se concede al grupo, no por usuario). |
| Grupo | `team` | Acceso al directorio compartido del equipo. |

### Operador por VM (`sudo` restringido)

Principio: **los humanos usan cuentas nominales** (trazabilidad en logs); el privilegio de
"operador" se concede **por pertenencia a un grupo**, no con una cuenta compartida. Los nombres
funcionales solo valen para cuentas de servicio (sin login humano).

| VM | Grupo operador | Persona nominal (ejemplo) | `sudo` permitido |
|---|---|---|---|
| `bastion` | — | — | Nodo de control; sin operador. |
| `web-server` | `webops` | `pedro` | Gestionar Nginx. |
| `db-server` | `dbops` | `ana` | Gestionar PostgreSQL. |
| `monitor-server` | `monops` | `luis` | Gestionar Prometheus / Grafana. |

> El `sudo` de los operadores apunta a servicios que se instalan en el Módulo 4; se prepara aquí y se afina/prueba cuando exista el servicio.

### Usuarios de servicio (los crea cada paquete, no nosotros)

- `web-server`: `www-data` · `db-server`: `postgres` · `monitor-server`: `prometheus`, `grafana`.

## Conceptos clave del módulo

Modelo usuario/grupo (primario vs suplementario) · permisos `rwx` en ficheros y directorios ·
octal · propiedad (`chown`/`chgrp`) · `umask` · bits especiales (setgid para carpetas de equipo,
sticky bit) · `sudoers` granular · ACLs · **autenticación ≠ autorización**.
