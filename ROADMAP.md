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
Repositorio Git con protección de secretos, VM base Ubuntu Server con LVM, snapshots y clonado generalizado de las 4 VMs.

### Módulo 1 — Administración Linux: usuarios, grupos y permisos  ✅
Crear usuarios y grupos, aplicar el modelo de permisos, configurar `sudo`/sudoers, umask y ACLs.

### Módulo 2 — SSH, hardening y bastión (jump host)  ✅
Configurar autenticación SSH por clave, endurecer el servicio y montar el bastión como único punto de entrada.

### Módulo 3 — Redes Linux y segmentación entre VMs  ✅
Red interna entre las 4 VMs, IPs estáticas, firewall y segmentación de la capa de datos.

### Módulo 4 — Servicios por capas: Nginx (web) + PostgreSQL (datos)  ⬜
Desplegar Nginx en la capa web y PostgreSQL en una VM separada, conectados de forma segura.

### Módulo 5 — Bash scripting y automatización con cron  ⬜
Escribir scripts de administración con Bash y programar tareas con cron.

### Módulo 6 — Logs y troubleshooting  ⬜
Gestionar logs (journald/rsyslog) y aplicar una metodología sistemática de diagnóstico.

### Módulo 7 — Monitorización: Prometheus + Grafana  ⬜
Recolectar métricas con Prometheus y node_exporter, y construir dashboards y alertas en Grafana.

### Módulo 8 — Backups y recuperación  ⬜
Automatizar backups, probar la restauración y definir RTO/RPO.

### Módulo 9 — Integración AWS: IAM + S3  ⬜
Configurar AWS CLI, IAM con mínimo privilegio y enviar backups offsite a S3.

### Módulo 10 — Exposición segura: dominio + Cloudflare + HTTPS (y CloudWatch)  ⬜
Exponer el web con **dominio propio vía Cloudflare**, usando **Cloudflare Tunnel** (sin abrir puertos,
sin IP pública — coherente con el aislamiento), **HTTPS** y seguridad de borde (WAF, DDoS, rate limiting).
Opcional: métricas/logs a CloudWatch. (Sustituye el Route53 inicialmente previsto.)

### Módulo 11 — Capstone: documentación, diagrama y post-mortem  ⬜
Elaborar la documentación final, el diagrama de arquitectura y un post-mortem de un incidente.

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
| 1 — Usuarios, grupos y permisos | ✅ |
| 2 — SSH, hardening y bastión | ✅ |
| 3 — Redes y segmentación | ✅ (segmentación de la DB en Módulo 4) |
| 4–11 | ⬜ |
