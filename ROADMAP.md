# Laboratorio Linux + AWS — Hoja de Ruta

> Proyecto de portfolio orientado a **Cloud / DevOps Junior**.
> Documento vivo: se actualiza a medida que evolucionan los objetivos.
> Autor: Juanma · Inicio: junio 2026

---

## 1. Contexto y decisiones de arquitectura

Este laboratorio simula una pequeña infraestructura real para demostrar competencias prácticas
en administración Linux, redes, seguridad, monitorización, automatización e integración con AWS.

**Perfil objetivo:** Cloud / DevOps Junior (con solape hacia AWS Cloud Support y SysAdmin Linux).

### Decisiones de diseño tomadas (y por qué)

| Decisión | Elección | Razón |
|---|---|---|
| Hipervisor | VirtualBox (local) | Coste 0, snapshots, dominio previo de la herramienta. El hipervisor es invisible en un CV. |
| Hosting cómputo | VMs Linux en local | Hardware sobrado (64 GB / Ryzen 9). Mejor máquina que cualquier capa gratuita cloud. |
| Nube | AWS (no Oracle/OCI) | Foco de portfolio en AWS. Meter OCI diluiría el relato para puestos AWS. |
| Modelo | Híbrido (local + AWS gestionado) | Refleja el escenario empresarial real: infra propia que integra servicios cloud. |
| Topología | 2 VMs (app + monitorización) | Simula infra distribuida. Más vendible que "todo en una VM". |
| Versionado | Git + GitHub desde el día 0 | En DevOps, lo que no está en Git no existe. |
| Coste | 0 € (Free Tier + billing alarms) | Disciplina de coste = señal de seniority. |

### Topología prevista

```
  [ Host Windows · Ryzen 9 / 64 GB ]
        │  VirtualBox
        ├── VM1  "app-server"      → Nginx + PostgreSQL + node_exporter
        └── VM2  "monitor-server"  → Prometheus + Grafana
                    │
                    └──(AWS CLI)──►  AWS: IAM · S3 · (CloudWatch · Route53)
```

> Nota: las VMs corren localmente; AWS aporta los servicios gestionados (almacenamiento de
> backups en S3, identidad con IAM, y opcionalmente métricas/DNS/TLS).

---

## 2. Estado de la cuenta AWS (línea base de seguridad)

Ya configurado (✓) — punto de partida por encima de la media de un junior:

- ✓ MFA en el usuario root
- ✓ Operación con usuario IAM (no root)
- ✓ Billing alarms / Budgets activos

Pendiente de revisar en el módulo de AWS: política de mínimo privilegio por servicio,
roles vs. usuarios, claves de acceso y su rotación.

---

## 3. Principios transversales (aplican a TODOS los módulos)

1. **Todo se documenta.** Cada módulo deja un `README` propio explicando qué, por qué y cómo se verificó.
2. **Todo se versiona.** Commits pequeños y descriptivos. El historial de Git es parte del portfolio.
3. **Snapshot antes de tocar.** Foto de la VM antes de cambios arriesgados.
4. **Nada se da por funcionando sin verificarlo.** Cada módulo termina con una comprobación explícita.
5. **Aprender el porqué, no solo el comando.** Si no puedo defenderlo en una entrevista, no está terminado.
6. **Coste bajo control.** Revisar el panel de billing al cerrar cada sesión que toque AWS.

---

## 4. Módulos (de menor a mayor dificultad)

> Cada módulo indica: **Aprendes / Por qué existe / Valor de portfolio / Pregunta de recruiter /
> Pregunta de entrevistador técnico / Error típico de junior / Buena práctica.**
> Estado: ⬜ pendiente · 🟦 en curso · ✅ hecho

---

### Módulo 0 — Fundamentos del lab y control de versiones  ⬜
- **Aprendes:** crear la VM base Ubuntu Server, snapshots, estructura del repositorio Git, disciplina de documentación.
- **Por qué existe:** sienta las bases reproducibles. Sin versionado ni documentación, nada de lo demás es portfolio.
- **Valor de portfolio:** demuestra orden, reproducibilidad y manejo de Git desde el inicio.
- **Pregunta recruiter:** "¿Cómo organizas y documentas tus proyectos?"
- **Pregunta técnica:** "¿Por qué snapshots y no clones? ¿Cuándo cada uno?"
- **Error típico junior:** empezar a configurar sin estructura ni commits; documentar al final (o nunca).
- **Buena práctica:** repo inicializado, README raíz y primer snapshot ANTES de instalar nada.

### Módulo 1 — Administración Linux: usuarios, grupos y permisos  ⬜
- **Aprendes:** gestión de usuarios/grupos, modelo de permisos, `sudo`/sudoers, umask, ACLs.
- **Por qué existe:** es la base de la seguridad y la operación diaria de cualquier servidor.
- **Valor de portfolio:** competencia núcleo de SysAdmin/DevOps; imprescindible y muy preguntada.
- **Pregunta recruiter:** "¿Tienes experiencia administrando usuarios en Linux?"
- **Pregunta técnica:** "Diferencia entre permisos de directorio y de fichero; ¿qué hace el bit de ejecución en un directorio?"
- **Error típico junior:** dar permisos amplios (777) para 'que funcione'; trabajar siempre como root.
- **Buena práctica:** mínimo privilegio; un grupo por función; sudoers granular.

### Módulo 2 — SSH y hardening de acceso  ⬜
- **Aprendes:** autenticación por clave, deshabilitar login de root y por contraseña, endurecimiento del servicio, protección anti-fuerza bruta.
- **Por qué existe:** SSH es la puerta de entrada; mal configurado es el riesgo nº1 de un servidor expuesto.
- **Valor de portfolio:** seguridad práctica tangible; historia muy concreta para contar.
- **Pregunta recruiter:** "¿Cómo aseguras el acceso remoto a un servidor?"
- **Pregunta técnica:** "¿Por qué clave en vez de contraseña? ¿Qué es un known_hosts y de qué protege?"
- **Error típico junior:** dejar login de root por SSH y contraseña habilitada; clave privada sin passphrase compartida.
- **Buena práctica:** solo clave, root deshabilitado, puerto/acceso restringido, fail2ban o similar.

### Módulo 3 — Redes Linux  ⬜
- **Aprendes:** modos de red de VM (NAT/host-only/bridged), IP estática, configuración de red moderna, firewall, diagnóstico (puertos, rutas, captura básica).
- **Por qué existe:** sin entender la red, no puedes conectar servicios ni diagnosticar fallos.
- **Valor de portfolio:** networking es el talón de Aquiles de la mayoría de juniors; dominarlo te diferencia.
- **Pregunta recruiter:** "¿Cómo de cómodo estás con redes?"
- **Pregunta técnica:** "Un servicio no responde en su puerto: ¿cómo lo diagnosticas paso a paso?"
- **Error típico junior:** confundir los modos de red de la VM; abrir el firewall entero en vez de puertos concretos.
- **Buena práctica:** IP estática para servidores, firewall por defecto denegar, abrir solo lo necesario.

### Módulo 4 — Servicios: Nginx + PostgreSQL  ⬜
- **Aprendes:** gestión de servicios con systemd, servir un sitio/app con Nginx, instalar y configurar PostgreSQL, conceptos de reverse proxy.
- **Por qué existe:** son los servicios reales que sostienen aplicaciones; el corazón del servidor.
- **Valor de portfolio:** demuestra que sabes desplegar y operar stack web + base de datos.
- **Pregunta recruiter:** "¿Has desplegado servicios web o bases de datos en Linux?"
- **Pregunta técnica:** "¿Qué hace systemd cuando un servicio falla? ¿Qué es un reverse proxy y para qué sirve?"
- **Error típico junior:** editar configs sin entenderlas; no comprobar el estado/logs del servicio tras un cambio.
- **Buena práctica:** un cambio → recargar → verificar estado y logs; configs versionadas.

### Módulo 5 — Bash scripting y automatización con cron  ⬜
- **Aprendes:** scripting de tareas administrativas, programación con cron, idempotencia, manejo de errores en scripts.
- **Por qué existe:** automatizar lo repetitivo es la esencia de DevOps.
- **Valor de portfolio:** scripts propios en el repo = evidencia directa de capacidad de automatización.
- **Pregunta recruiter:** "¿Automatizas tareas? ¿Con qué?"
- **Pregunta técnica:** "¿Cómo haces un script seguro y repetible? ¿Qué pasa si cron lo ejecuta dos veces?"
- **Error típico junior:** scripts sin control de errores ni logs; cron 'a ciegas' sin registrar resultado.
- **Buena práctica:** scripts con set de seguridad, salida registrada, idempotentes y comentados.

### Módulo 6 — Logs y troubleshooting  ⬜
- **Aprendes:** journald/rsyslog, lectura y correlación de logs, metodología sistemática de diagnóstico.
- **Por qué existe:** el 80% del trabajo real (sobre todo en Cloud Support) es diagnosticar problemas.
- **Valor de portfolio:** poder narrar un troubleshooting estructurado vale oro en entrevista.
- **Pregunta recruiter:** "Cuéntame una vez que resolviste un problema difícil."
- **Pregunta técnica:** "Servidor lento: ¿cuál es tu proceso de diagnóstico?"
- **Error típico junior:** tocar cosas al azar; no mirar logs; no aislar la causa antes de actuar.
- **Buena práctica:** método (síntoma → hipótesis → evidencia en logs → causa → fix → verificación).

### Módulo 7 — Monitorización: Prometheus + Grafana  ⬜
- **Aprendes:** exporters, recolección de métricas con Prometheus, dashboards en Grafana, alertas básicas. (Corre en la VM2.)
- **Por qué existe:** observabilidad = saber qué pasa antes de que el usuario lo note. Base de SRE/DevOps.
- **Valor de portfolio:** un dashboard real con métricas es de los entregables que más impresiona visualmente.
- **Pregunta recruiter:** "¿Tienes experiencia con monitorización?"
- **Pregunta técnica:** "¿Diferencia entre métricas, logs y trazas? ¿Modelo pull de Prometheus?"
- **Error típico junior:** monitorizar todo sin criterio; alertas que nadie atiende (alert fatigue).
- **Buena práctica:** monitorizar lo que importa (los 'four golden signals'), alertas accionables.

### Módulo 8 — Backups y recuperación  ⬜
- **Aprendes:** estrategia de backup, copias automatizadas, y — lo más importante — **probar la restauración**. Conceptos RTO/RPO.
- **Por qué existe:** un backup que no se ha restaurado nunca no es un backup.
- **Valor de portfolio:** demuestra pensamiento de fiabilidad/continuidad, raro en juniors.
- **Pregunta recruiter:** "¿Has gestionado backups?"
- **Pregunta técnica:** "¿Qué es RTO y RPO? ¿Cómo validas que un backup sirve?"
- **Error típico junior:** configurar backups y no probar nunca la restauración.
- **Buena práctica:** backups automatizados + prueba de restore documentada + regla 3-2-1.

### Módulo 9 — Integración AWS: IAM + S3  ⬜
- **Aprendes:** AWS CLI desde las VMs, IAM con mínimo privilegio (usuarios/roles/políticas), S3, y enviar los backups del Módulo 8 a S3 (backup offsite).
- **Por qué existe:** es el puente Linux↔Cloud; el núcleo del relato híbrido del portfolio.
- **Valor de portfolio:** "integración Linux + AWS" es exactamente lo que pide el mercado.
- **Pregunta recruiter:** "¿Has trabajado con AWS? ¿Qué servicios?"
- **Pregunta técnica:** "¿Usuario IAM vs rol? ¿Cómo darías a una VM acceso a S3 con mínimo privilegio?"
- **Error típico junior:** claves con permisos de administrador; credenciales hardcodeadas o subidas a Git.
- **Buena práctica:** mínimo privilegio, políticas específicas por tarea, credenciales fuera del repo.

### Módulo 10 — AWS extra (opcional, prioridad media): CloudWatch · Route53 · HTTPS  ⬜
- **Aprendes:** enviar métricas/logs a CloudWatch, DNS real con Route53 (usando tu dominio), certificados TLS válidos.
- **Por qué existe:** lleva el lab de "interno" a "expuesto y profesional", con DNS y HTTPS reales.
- **Valor de portfolio:** un endpoint con tu dominio y candado HTTPS es un remate muy vistoso.
- **Pregunta recruiter:** "¿Has gestionado dominios/DNS o certificados?"
- **Pregunta técnica:** "¿Cómo funciona la resolución DNS? ¿Qué valida un certificado TLS?"
- **Error típico junior:** mezclar registros DNS sin entenderlos; certificados caducados sin renovación.
- **Buena práctica:** DNS documentado, renovación automática de certificados, coste vigilado.

### Módulo 11 — Capstone: documentación, diagrama y post-mortem  ⬜
- **Aprendes:** diagrama de arquitectura, README profesional del proyecto completo, redacción de un post-mortem de un incidente simulado.
- **Por qué existe:** convierte un montón de configs en un **proyecto de portfolio** coherente y narrable.
- **Valor de portfolio:** es la pieza que el recruiter realmente lee/mira; cierra el relato.
- **Pregunta recruiter:** "Enséñame un proyecto del que estés orgulloso."
- **Pregunta técnica:** "Explícame la arquitectura y por qué tomaste cada decisión."
- **Error típico junior:** dejar el proyecto sin documentar ni narrar; README pobre.
- **Buena práctica:** diagrama claro, decisiones justificadas, un incidente resuelto y documentado.

---

## 5. Cómo cada módulo alimenta las competencias del CV

| Competencia CV | Módulos que la demuestran |
|---|---|
| Linux Administration | 1, 2, 4 |
| Networking | 3 |
| Security | 1, 2, 9 |
| Automation | 5, 8 |
| Monitoring / Observability | 7 |
| Troubleshooting | 6 |
| Backups / Reliability | 8 |
| AWS / Cloud Integration | 9, 10 |
| Documentation / Communication | 0, 11 (transversal en todos) |

---

## 6. Estimación orientativa de tiempo

A 5-8 h/semana, ritmo cómodo y sin prisa (la calidad manda):

- Módulos 0-3 (fundamentos): ~3-4 semanas
- Módulos 4-6 (servicios, automatización, troubleshooting): ~4-5 semanas
- Módulos 7-8 (monitorización, backups): ~3-4 semanas
- Módulos 9-10 (AWS): ~3-4 semanas
- Módulo 11 (capstone): ~1-2 semanas

> Total aproximado: 3-4 meses. Es una guía, no un examen. Cada módulo se cierra cuando se entiende y se sabe defender.

---

## 7. Registro de cambios de la hoja de ruta

- 2026-06-17 — v1: creación tras fase de descubrimiento (perfil, hardware, hosting híbrido, objetivos).
