# Laboratorio Linux + AWS — Hoja de Ruta

> Proyecto de portfolio orientado a **Cloud / DevOps Junior**. Documento vivo.

---

## 1. Contexto y decisiones de arquitectura

Laboratorio que simula una pequeña infraestructura real para demostrar competencias en
administración Linux, redes, seguridad, monitorización, automatización e integración con AWS.

### Decisiones de diseño

| Decisión | Elección | Razón |
|---|---|---|
| Hipervisor | VirtualBox (local) | Coste 0, snapshots, hardware sobrado. |
| Nube | AWS (no OCI) | Foco de portfolio en AWS. |
| Modelo | Híbrido (local + AWS gestionado) | Escenario empresarial real: infra propia que integra cloud. |
| Topología | 4 VMs (bastión + web + db + monitor) | Arquitectura por capas, segmentación de red y jump host. |
| Red | Red interna (host aislado) + NAT | Mínima exposición; acceso solo por SSH al bastión. |
| Versionado | Git + GitHub desde el día 0 | En DevOps, lo que no está en Git no existe. |
| Coste | 0 € (Free Tier + billing alarms) | Disciplina de coste. |

### Topología

```
  [ Host · VirtualBox ]
   ├── bastion         → jump host SSH + nodo de control (AWS CLI, backups)
   ├── web-server      → Nginx (capa web) + node_exporter
   ├── db-server       → PostgreSQL (capa de datos, segmentada) + node_exporter
   └── monitor-server  → Prometheus + Grafana (raspa métricas de las 3)
               └──(AWS CLI)──► AWS: IAM · S3 · (CloudWatch · Route53)
```

- **Segmentación:** `db-server` solo accesible desde `web-server` (y bastión para admin).
- **Bastión:** único punto de entrada SSH; las internas no aceptan SSH desde fuera de la red interna.
- **Descartado (fase 2):** balanceador + segundo web-server (alta disponibilidad).

---

## 2. Estado de la cuenta AWS

Línea base de seguridad ya configurada: MFA en root, operación con usuario IAM, billing alarms.
Pendiente (módulo AWS): mínimo privilegio por servicio, roles vs. usuarios, rotación de claves.

---

## 3. Principios transversales

Todo se documenta y se versiona · Snapshot antes de tocar · Nada se da por funcionando sin
verificarlo · Coste bajo control en cada sesión que toque AWS.

---

## 4. Módulos (de menor a mayor dificultad)

> Estado: ⬜ pendiente · 🟦 en curso · ✅ hecho

### Módulo 0 — Fundamentos del lab y control de versiones  ✅
- **Aprendes:** VM base Ubuntu Server, snapshots, repositorio Git, generalización de clones.
- **Valor:** orden, reproducibilidad y manejo de Git desde el inicio.

### Módulo 1 — Administración Linux: usuarios, grupos y permisos  ⬜
- **Aprendes:** usuarios/grupos, modelo de permisos, `sudo`/sudoers, umask, ACLs.
- **Valor:** competencia núcleo de SysAdmin/DevOps.

### Módulo 2 — SSH, hardening y bastión (jump host)  ⬜
- **Aprendes:** autenticación por clave, hardening de SSH, anti-fuerza bruta, patrón bastión/jump host.
- **Valor:** seguridad práctica tangible.

### Módulo 3 — Redes Linux y segmentación entre VMs  ⬜
- **Aprendes:** red interna entre las 4 VMs, IP estática, firewall, segmentación, diagnóstico de red.
- **Valor:** networking, el punto débil de la mayoría de juniors.

### Módulo 4 — Servicios por capas: Nginx (web) + PostgreSQL (datos)  ⬜
- **Aprendes:** systemd, Nginx, PostgreSQL en VM separada, conexión a DB remota, reverse proxy.
- **Valor:** desplegar y operar un stack web + datos separados y comunicados de forma segura.

### Módulo 5 — Bash scripting y automatización con cron  ⬜
- **Aprendes:** scripting de tareas, cron, idempotencia, manejo de errores.
- **Valor:** scripts propios en el repo = evidencia de automatización.

### Módulo 6 — Logs y troubleshooting  ⬜
- **Aprendes:** journald/rsyslog, correlación de logs, metodología de diagnóstico.
- **Valor:** diagnosticar problemas es el grueso del trabajo real.

### Módulo 7 — Monitorización: Prometheus + Grafana  ⬜
- **Aprendes:** exporters, recolección con Prometheus, dashboards en Grafana, alertas.
- **Valor:** observabilidad; un dashboard real impresiona.

### Módulo 8 — Backups y recuperación  ⬜
- **Aprendes:** estrategia de backup, copias automatizadas, probar la restauración, RTO/RPO.
- **Valor:** pensamiento de fiabilidad/continuidad, raro en juniors.

### Módulo 9 — Integración AWS: IAM + S3  ⬜
- **Aprendes:** AWS CLI desde las VMs, IAM con mínimo privilegio, S3, backups offsite a S3.
- **Valor:** el puente Linux↔Cloud; el núcleo del relato híbrido.

### Módulo 10 — AWS extra (opcional): CloudWatch · Route53 · HTTPS  ⬜
- **Aprendes:** métricas/logs a CloudWatch, DNS con Route53, certificados TLS.
- **Valor:** lleva el lab a "expuesto y profesional" con DNS y HTTPS reales.

### Módulo 11 — Capstone: documentación, diagrama y post-mortem  ⬜
- **Aprendes:** diagrama de arquitectura, README final, post-mortem de un incidente.
- **Valor:** convierte las configs en un proyecto de portfolio coherente.

---

## 5. Cómo cada módulo alimenta el CV

| Competencia | Módulos |
|---|---|
| Linux Administration | 1, 2, 4 |
| Networking | 3 |
| Security | 1, 2, 9 |
| Automation | 5, 8 |
| Monitoring | 7 |
| Troubleshooting | 6 |
| Backups / Reliability | 8 |
| AWS / Cloud Integration | 9, 10 |
| Documentation | 0, 11 (transversal) |

---

## 6. Estado

| Módulo | Estado |
|---|---|
| 0 — Fundamentos | ✅ |
| 1–11 | ⬜ |
