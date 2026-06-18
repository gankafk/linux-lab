# Módulo 0 — Fundamentos del laboratorio y control de versiones

> Estado: 🟦 **En curso**
> Documento de seguimiento del módulo. Registra decisiones, trabajo realizado y verificaciones.
> Última actualización: 2026-06-18.

---

## Objetivo del módulo

Establecer los **cimientos de reproducibilidad y versionado** del laboratorio antes de
construir infraestructura. Al cerrar el módulo debe existir: (1) un repositorio Git que es
la fuente de verdad del proyecto, con protección de secretos activa, y (2) una VM base limpia
y con snapshot, lista para clonar las cuatro máquinas del laboratorio.

---

## Decisiones tomadas

| Decisión | Elección | Justificación |
|---|---|---|
| Visibilidad del repo | **Privado** (de momento) | Permite organizar el proyecto antes de exponerlo. Disparador para hacerlo público: cierre del capstone (Módulo 11). |
| Estructura de directorios | **Incremental** (carpeta por módulo según se necesita) | Evita estructura prematura; deja que la organización emerja del uso real. Condición: el README raíz refleja la estructura a medida que crece. |
| Protección de secretos | **`.gitignore` en la raíz + secretos fuera del repo por ubicación** | Defensa en profundidad: lo sensible vive fuera del repo (credenciales AWS, claves SSH en sus rutas de sistema); el `.gitignore` actúa como red de seguridad. |
| Sistema operativo de las VMs | **Ubuntu Server 24.04 LTS** | LTS madura y soportada hasta 2029 (2034 con ESM). Se descarta 26.04 LTS (abril 2026) por ser muy reciente: criterio de no desplegar una `.04` LTS hasta su primer point release. |
| Nombres de las VMs | `bastion`, `web-server`, `db-server`, `monitor-server` | Convención válida como hostname y DNS (minúsculas, sin espacios ni acentos, con guiones). El nombre de la VM coincide con el hostname interno. |
| Dimensionado de recursos | **Right-sizing por rol** (no uniforme) | Imagen base idéntica; recursos ajustados por VM tras el clonado, según la carga de cada servicio. |
| Diseño de red | **Red interna (host aislado) + NAT** | Mínima exposición: el host NO está en la red del lab. Acceso solo por SSH al bastión y salto a las internas. Réplica fiel de una topología cloud real. |
| Diseño de disco | **Base: 1 disco 30 GB dinámico (SO). `db`/`monitor`: + disco de datos dedicado tras clonar** | Separar SO y datos (patrón de producción / volumen de datos tipo EBS). El disco de datos va solo donde aporta. |
| Estrategia de snapshots | **Practicar AMBAS capas: hipervisor (VirtualBox) + LVM (dentro del SO)** | Son capas distintas y complementarias, las dos reales en producción (VBox ≈ snapshots de EBS; LVM = backup consistente de un volumen). Se reserva espacio libre en el VG para los snapshots de LVM. |
| Reserva para snapshots LVM (disco SO) | **Raíz 20 GB, 8 GB libres en el VG** | El snapshot solo guarda los bloques que cambian (copy-on-write); se dimensiona al churn esperado, no al tamaño del volumen. 8 GB sobra para practicar en el disco de SO. |

### Dimensionado previsto por VM

| VM | Rol | RAM | vCPU | Disco | Motivo |
|---|---|---|---|---|---|
| `bastion` | Jump host SSH | 1 GB | 1 | 30 GB SO (dinámico) | Solo reenvía conexiones; carga mínima. |
| `web-server` | Nginx (capa web) | 1–2 GB | 1 | 30 GB SO (dinámico) | Nginx es muy ligero. |
| `db-server` | PostgreSQL (capa de datos) | 2 GB | 1–2 | 30 GB SO + disco de datos dedicado | La DB cachea en RAM; los datos crecen y se aíslan en su propio disco. |
| `monitor-server` | Prometheus + Grafana | 2–4 GB | 2 | 30 GB SO + disco de datos dedicado | Base de datos de series temporales + retención: el componente más pesado. |

> Criterio: empezar conservador y ajustar al alza si la monitorización (Módulo 7) revela un servicio ahogado.
> **VM base (`base-ubuntu-2404`):** durante la instalación se asignan **2 GB RAM / 1 vCPU**. Con 1 GB el instalador se bloqueaba al crear el usuario (RAM insuficiente para esa fase). Tras clonar, cada VM se ajusta según la tabla; 2 GB queda como suelo seguro si alguna da inestabilidad.

### Diseño de red (detalle)

Cada VM lleva **dos adaptadores**:

- **Adaptador 1 — NAT:** salida a internet de cada VM (instalación, actualizaciones). Aísla la entrada: nadie de fuera inicia conexión hacia la VM por aquí.
- **Adaptador 2 — Red interna (Internal Network):** red privada **solo entre las VMs**; el host queda **fuera**, por mínima exposición. Aquí viven las IPs estáticas y la comunicación entre máquinas (se configura en el Módulo 3).

**Acceso desde el host:** como el host no está en la red interna, se entra **únicamente al `bastion`** mediante una regla de **reenvío de puertos** sobre su NAT (p. ej. `host:2222 → bastion:22`). Desde el bastión se salta por SSH a las VMs internas. Para abrir interfaces web internas (Grafana, etc.) se usarán **túneles SSH a través del bastión**, igual que en un entorno cloud real.

> La VM **base** arranca solo con el Adaptador 1 (NAT), suficiente para instalar y actualizar. El Adaptador 2 y las IPs estáticas se trabajan al clonar / en el Módulo 3.

### Diseño de disco (detalle)

- **Asignación dinámica** (no fija): el disco solo ocupa en el host lo que se use de verdad.
- **VM base (`base-ubuntu-2404`):** un único disco de **30 GB** para el SO, heredado por los cuatro clones. Particionado guiado con **LVM** (sin cifrado LUKS). Reparto: **raíz (`/`) 20 GB y 8 GB libres en el grupo de volúmenes** para practicar snapshots de LVM.
- **Snapshots — dos capas que se practican a propósito:**
  - *Hipervisor (VirtualBox):* foto de la VM/volumen entero. Equivalente local de un **snapshot de EBS**. Red de seguridad para revertir toda la máquina.
  - *LVM (dentro del SO):* foto de un volumen lógico vía **copy-on-write** (solo guarda los bloques que cambian). Sirve para **backups consistentes en caliente**. Necesita espacio libre en el VG → de ahí los ~7 GB reservados.
  - Dimensionado de un snapshot LVM: al **churn** esperado durante su vida (regla práctica ~10–20 % del volumen), no al tamaño total. Si se llena, se invalida.
- **`db-server` y `monitor-server`:** se les añade, al aprovisionarlas tras el clonado, un **segundo disco virtual dedicado a datos**, montado en la ruta de datos del servicio (carpeta de PostgreSQL / almacenamiento de Prometheus). Separa SO y datos: si el disco de datos se llena, no tumba el sistema, y permite backup/restore del volumen por separado. Ahí es donde el snapshot de LVM tiene su uso "de verdad" (backup en caliente de la DB), así que se dejará holgura también en **su** VG.
- Posible mejora futura: gestionar el disco de datos con **LVM** para ampliarlo en caliente.

---

## Trabajo realizado

1. **Repositorio creado** en GitHub e inicializado en local (visibilidad privada).
2. **README raíz** creado (pendiente: añadir enlace al roadmap y apartado de estructura).
3. **`.gitignore` creado y commiteado** en la raíz, con protección de secretos. Patrones incluidos:
   - `*.pem`, `*.key` — claves y certificados.
   - `*.env` — ficheros de variables/credenciales (cubre también el fichero oculto `.env`).
   - `Secretos/` — carpeta local de borradores sensibles.
   - Comentarios explicativos en cada bloque.
4. **Verificación del `.gitignore`** con `git check-ignore`: confirmado que los patrones sensibles se ignoran y que la documentación legítima sí se versiona.
5. **VirtualBox** instalado y actualizado; **imagen de Ubuntu Server 24.04 LTS** descargada.
6. **VM base `base-ubuntu-2404`** creada y arrancando: disco 30 GB dinámico (raíz 20 GB + 8 GB libres en VG), hostname `ubuntu-base`, usuario `labadmin`, Adaptador 1 = NAT, instalación manual (sin desatendida), Ubuntu Server estándar, OpenSSH instalado.
7. **Incidencia resuelta:** con **1 GB RAM / 1 vCPU** el instalador se bloqueaba al crear el usuario. Diagnóstico: RAM insuficiente para esa fase. Acción: subir la base a **2 GB RAM / 1 vCPU** y reiniciar la instalación.
8. **Verificación de la base:** salida a internet OK (`ping` a 8.8.8.8 con respuesta) y **sistema actualizado** (`apt update && upgrade`).
9. **SSH pasado a demonio clásico persistente:** se detectó que venía en **activación por socket** (`ssh.service` inactivo, `ssh.socket` a la escucha). Se deshabilitó el socket y se habilitó/arrancó `ssh.service` (`disable --now ssh.socket` / `enable --now ssh.service`). Verificado **active + enabled**, escuchando en el 22, y **persistente tras reboot**.
10. **README raíz completado:** enlaces a `ROADMAP.md` y `GUIA_PASOS.md`, arquitectura, stack y estructura del repositorio.
11. **Snapshot `base-limpia-actualizada`** tomado con la VM apagada (plantilla prístina).
12. **Adaptadores de red en la base antes de clonar:** Adaptador 1 = NAT, Adaptador 2 = Red interna (Internal Network). Heredados por los clones.
13. **4 clones completos** creados desde el estado actual, con **MAC nuevas**. Base `base-ubuntu-2404` se conserva **intacta** como plantilla.
14. **`bastion` generalizado:** identidad propia → hostname (`bastion` + `/etc/hosts`), `machine-id` regenerado, claves de host SSH regeneradas. Verificado tras reboot.

---

## Pendiente en este módulo

- [x] Completar el README raíz: enlaces a `ROADMAP.md`/`GUIA_PASOS.md`, arquitectura y estructura.
- [x] Renombrar carpetas a formato sin espacios ni acentos (hecho: `00-fundamentos`, ...).
- [x] Crear la **VM base `base-ubuntu-2404`** (Ubuntu Server 24.04 estándar, disco 30 GB con LVM, 2 GB RAM / 1 vCPU, Adaptador 1 = NAT).
- [x] Configuración común mínima de la VM base (actualizaciones, SSH como demonio persistente).
- [x] **Snapshot "base limpia"** de la VM base.
- [x] Clonar la VM base (4 clones completos, MAC nuevas, base intacta).
- [x] Generalizar `bastion` (hostname, machine-id, claves de host SSH).
- [ ] **Generalizar `web-server`, `db-server`, `monitor-server`** (mismos 3 bloques). → idea: hacerlo con un **script parametrizado** (enlaza con Módulo 5). Pendiente para mañana.
- [ ] Ajustar recursos de cada clon según la tabla de dimensionado.
- [ ] (Módulo 3) Adaptador 2 / IPs estáticas en la red interna.

---

## Verificación de cierre del módulo

- [x] El repo existe en GitHub con README, roadmap y `.gitignore` commiteados.
- [x] La VM base arranca, tiene red y se actualiza correctamente.
- [x] SSH activo, habilitado y persistente tras reboot.
- [ ] Existe un snapshot de la base limpia.

---

## Conceptos aprendidos (para defender en entrevista)

- Por qué el repositorio y la protección de secretos se crean **antes** que la infraestructura.
- El historial de Git es **permanente**: ante una credencial filtrada, lo correcto es **rotar/revocar**, no solo borrar el fichero.
- Modelo de claves SSH: **privada = secreta y no sale de la máquina; pública = se comparte**.
- Sintaxis de `.gitignore` y verificación con `git check-ignore`.
- **Right-sizing / capacity planning**: dimensionar recursos según la carga, separando imagen base de recursos de VM.
- Criterio de versiones: por qué se prefiere una LTS madura frente a una `.04` recién publicada.
- **Aislamiento de red por mínima exposición**: por qué el host se deja fuera de la red del lab (red interna) en lugar de host-only, y cómo eso replica una topología cloud real (subred privada + acceso por bastión).
- **Reenvío de puertos y túneles SSH** como vía de acceso controlado a un entorno aislado.
- **Separación SO / datos** mediante disco dedicado: por qué no meter los datos en el disco raíz.
- Modos de red de VirtualBox: NAT, red interna, host-only, bridged, NAT network — qué hace cada uno y cuándo usarlo.
- **LVM**: jerarquía PV → VG → LV, y por qué aporta (redimensionar sin reparticionar, snapshots).
- **Snapshots de LVM (copy-on-write)**: cómo funcionan, para qué (backup consistente en caliente), por qué necesitan espacio libre en el VG y cómo se dimensionan (al churn, no al tamaño).
- **Dos capas de snapshot** (hipervisor vs LVM) y su mapeo a la nube (VBox ≈ EBS).
- Particionado: instalación guiada vs custom; **LVM sí / LUKS no** y cuándo se usaría el cifrado en reposo (mapea a cifrado de EBS).
- **Troubleshooting de instalación:** síntoma (cuelgue al crear usuario) → hipótesis (RAM insuficiente) → acción (subir a 2 GB) → verificación (reinstalar). Caso real de diagnóstico.
- **Activación por socket de SSH** en Ubuntu 24.04: por qué `ssh.service` aparece inactivo pero SSH responde (lo escucha `ssh.socket`), y cómo pasar a demonio clásico persistente.
- **systemd — `start`/`stop` vs `enable`/`disable`:** estado actual vs comportamiento en el arranque. El flag `--now` combina ambos. Verificación real = comprobar persistencia tras reboot.
- **Clon completo vs enlazado** y política de **MAC nueva** al clonar (evitar conflictos de red).
- **Generalizar un clon:** por qué `machine-id`, claves de host SSH y hostname deben ser únicos por máquina (DHCP, identidad criptográfica del servidor, trazabilidad). Equivale a lo que hace cloud-init/sysprep.

---

## Registro de cambios

- 2026-06-18 — Creación del documento de seguimiento del Módulo 0.
- 2026-06-18 — Cierre del diseño de red (red interna + NAT, host aislado) y de disco (base 25 GB + disco de datos dedicado para db/monitor). Carpetas renombradas a formato sin espacios.
- 2026-06-18 — VM base `base-ubuntu-2404` en creación. Ajustes: disco 30 GB (raíz 20 GB + 8 GB libres en VG para snapshots LVM), RAM subida a 2 GB tras incidencia de cuelgue con 1 GB. Decisión de practicar las dos capas de snapshot (hipervisor + LVM).
- 2026-06-18 — VM base operativa: red OK, sistema actualizado, SSH pasado a demonio clásico persistente (verificado tras reboot). README raíz completado. Pendiente: snapshot de base limpia y clonado.
- 2026-06-18 — Snapshot `base-limpia-actualizada` hecho. Adaptadores en la base (NAT + Red interna). 4 clones completos con MAC nuevas (base intacta). `bastion` generalizado (hostname/machine-id/claves SSH). Pendiente mañana: generalizar web/db/monitor (vía script) y ajustar recursos.
