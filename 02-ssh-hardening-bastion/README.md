# Módulo 2 — SSH, hardening y bastión

> Estado: ⬜ Pendiente

## Objetivo

Asegurar el acceso remoto: autenticación SSH por clave, endurecimiento del servicio y montaje
del bastión como único punto de entrada hacia las VMs internas.

## Alcance previsto

- Autenticación por **clave** (par pública/privada); deshabilitar contraseña y login de root.
- Hardening de `sshd` (opciones de configuración, anti-fuerza bruta).
- **Bastión / jump host:** acceso a las VMs internas solo a través de él.
- Acceso desde el host (reenvío de puertos / túnel) para trabajar desde la terminal con copy/paste.

> Diseño pendiente de definir al arrancar el módulo.
