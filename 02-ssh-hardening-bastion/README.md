# Módulo 2 — SSH, hardening y bastión

> Estado: ✅ Completado

## Objetivo

Asegurar el acceso remoto: autenticación SSH por clave, endurecimiento del servicio y montaje
del bastión como único punto de entrada hacia las VMs internas.

## Qué se hizo (en `bastion`)

- **Par de claves ed25519** generado en el host (WSL2); privada en el host, pública instalada en `bastion`.
- **Acceso host → bastion** vía reenvío de puertos NAT (host `2222` → bastion `22`). Equivale a la "cara pública" de un bastión en cloud.
- **Hardening de `sshd`** (drop-in en `/etc/ssh/sshd_config.d/`): `PasswordAuthentication no`, `PermitRootLogin no`. Verificado con `sshd -T` y forzando login por contraseña (rechazado).
- **`fail2ban`** activo (jail `sshd`) con `ignoreip` de la IP de gestión.
- **`~/.ssh/config`** en el host con alias `bastion-juanma` (HostName/Port/User/IdentityFile).

## Decisiones clave

| Tema | Elección | Motivo |
|---|---|---|
| Una clave por **identidad**, no por servidor | `lab_ed25519` para todo el lab | La clave te representa a ti; su pública se instala en todos los servidores. |
| Clave privada **nunca sale del host** | — | Se salta a internas con ProxyJump, no se copia la clave. |
| Drop-in de hardening con número bajo (`00-`) | Antes que `50-cloud-init.conf` | En `sshd_config` gana el **primer** valor; cloud-init pone `PasswordAuthentication yes`. |

## Acceso a las internas (vía red interna del Módulo 3)

- **ProxyJump** configurado en `~/.ssh/config`: host → bastión → interna, autenticación de extremo a extremo (la clave privada nunca toca el bastión).
- Clave de `juanma` (admin) instalada en las 3 internas; alias `web-juanma`/`db-juanma`/`monitor-juanma`.
- Hardening SSH (clave, sin contraseña/root) aplicado a `web-server`, `db-server`, `monitor-server`.
- `labadmin` queda **solo por consola** (break-glass); `PasswordAuthentication no` no afecta al login por consola.
