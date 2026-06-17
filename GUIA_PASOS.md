# Guía de pasos por módulo — Laboratorio Linux + AWS

> Complemento del `ROADMAP.md`. Aquí está el **orden de operaciones** de cada módulo:
> qué hacer, en qué secuencia, qué decidir y cómo verificar.
> **No contiene comandos ni configuraciones** — es la guía de pasos; el detalle lo trabajamos juntos.
> Documento vivo. Última actualización: 2026-06-17.

---

## Cómo usar esta guía

- Cada módulo sigue el mismo patrón: **Preparación → Pasos → Verificación → Documentar y commit → Checklist de cierre.**
- Un módulo NO está terminado hasta que: (1) funciona, (2) lo has verificado, (3) está documentado y commiteado, y (4) sabrías defenderlo en una entrevista.
- Snapshot de la VM afectada **antes** de cambios arriesgados.
- Convención sugerida de ramas/commits: un commit pequeño por paso lógico, mensaje claro en imperativo.

---

## Módulo 0 — Fundamentos del lab y control de versiones

**Preparación**
- Decidir nombres de las 4 VMs y de la red interna.
- Decidir estructura de carpetas del repositorio (una por módulo + carpeta de documentación/diagramas).

**Pasos**
1. Crear el repositorio en GitHub e inicializarlo en local.
2. Definir la estructura de directorios del proyecto y el `README` raíz (propósito, índice de módulos, enlace al roadmap).
3. Añadir un fichero de exclusiones para que nunca entren credenciales ni datos sensibles al repo.
4. Instalar/confirmar VirtualBox y descargar la imagen de Ubuntu Server.
5. Crear la **VM base** (una sola, que luego clonarás): instalación mínima, sin entorno gráfico.
6. Aplicar configuración común mínima a la VM base (actualizaciones, usuario de trabajo).
7. Tomar un **snapshot "base limpia"** de esa VM.
8. Clonar la VM base las veces necesarias para obtener bastion / web / db / monitor (o clonar a medida que cada módulo lo requiera).

**Verificación**
- La VM base arranca, tiene red y se actualiza correctamente.
- El repo existe en GitHub con README y estructura inicial.

**Documentar y commit**
- README raíz, decisiones de nombres/estructura, y nota de cómo se creó la VM base.

**Checklist de cierre**
- [ ] Repo creado y con primer commit · [ ] VM base con snapshot · [ ] README raíz redactado

---

## Módulo 1 — Administración Linux: usuarios, grupos y permisos

**Preparación**
- Definir qué usuarios y grupos tendrá sentido en el lab (administración, servicio, etc.).

**Pasos**
1. Repasar el modelo de usuarios/grupos y el de permisos (lectura/escritura/ejecución, propietario/grupo/otros).
2. Crear los grupos por función y los usuarios del laboratorio.
3. Configurar privilegios de administración (quién puede elevar y para qué) de forma granular.
4. Practicar asignación de permisos y propiedad sobre directorios de ejemplo.
5. Revisar permisos por defecto al crear ficheros y ajustarlos si procede.
6. (Opcional) Explorar permisos avanzados para casos que el modelo básico no cubre.

**Verificación**
- Cada usuario puede hacer exactamente lo que debe y nada más (probar un caso permitido y uno denegado).

**Documentar y commit**
- Tabla de usuarios/grupos y su propósito; criterio de permisos aplicado.

**Checklist de cierre**
- [ ] Usuarios/grupos creados con criterio · [ ] Privilegios mínimos verificados · [ ] Documentado

---

## Módulo 2 — SSH, hardening y bastión (jump host)

**Preparación**
- Decidir qué VM hará de bastión y cómo se accederá a las internas a través de ella.

**Pasos**
1. Repasar cómo funciona la autenticación por clave frente a contraseña.
2. Generar el par de claves y configurar el acceso por clave a la primera VM.
3. Endurecer el servicio SSH: desactivar acceso de root y de contraseña.
4. Configurar el **bastión** como único punto de entrada SSH desde fuera de la red interna.
5. Configurar el salto desde el bastión hacia web / db / monitor.
6. Restringir que las VMs internas no acepten SSH salvo desde la red interna/bastión.
7. Añadir protección anti-fuerza bruta.

**Verificación**
- Acceso directo por SSH a una VM interna desde fuera **falla**; vía bastión **funciona**.
- Login por contraseña y por root **rechazados**.

**Documentar y commit**
- Esquema de acceso (quién entra por dónde) y decisiones de hardening.

**Checklist de cierre**
- [ ] Solo clave · [ ] Root deshabilitado · [ ] Bastión operativo · [ ] Internas no expuestas

---

## Módulo 3 — Redes Linux y segmentación entre VMs

**Preparación**
- Decidir el esquema de red interna entre las 4 VMs y el direccionamiento.

**Pasos**
1. Repasar los modos de red de VirtualBox y elegir la combinación adecuada (acceso a internet + red interna entre VMs).
2. Asignar IP estática a cada servidor.
3. Verificar conectividad entre las VMs que deben hablarse.
4. Definir el firewall de cada VM con política "denegar por defecto".
5. Abrir únicamente los puertos necesarios por cada rol (web, db, monitorización).
6. Aplicar la **segmentación**: la base de datos solo accesible desde el servidor web (y bastión para admin).
7. Practicar diagnóstico de red (puertos a la escucha, rutas, conectividad).

**Verificación**
- El web-server alcanza la db-server; un tercer host **no** alcanza la db-server.
- Cada firewall solo permite lo previsto.

**Documentar y commit**
- Diagrama/tabla de direccionamiento y matriz de "quién puede hablar con quién".

**Checklist de cierre**
- [ ] IPs estáticas · [ ] Firewalls restrictivos · [ ] Segmentación db verificada

---

## Módulo 4 — Servicios por capas: Nginx (web) + PostgreSQL (datos)

**Preparación**
- Decidir qué servirá el web (sitio estático o app sencilla) y qué datos guardará la DB.

**Pasos**
1. Repasar systemd y el ciclo de vida de un servicio.
2. Instalar y arrancar Nginx en la web-server; servir contenido de prueba.
3. Instalar PostgreSQL en la db-server.
4. Configurar PostgreSQL para aceptar conexiones **solo** desde el web-server.
5. Crear base de datos y usuario de aplicación con permisos mínimos.
6. Conectar la capa web a la base de datos remota.
7. (Opcional) Configurar Nginx como reverse proxy si hay una app detrás.

**Verificación**
- La web responde; la app/consulta lee/escribe en la DB remota correctamente.
- La DB rechaza conexiones desde fuera del web-server.

**Documentar y commit**
- Configs versionadas (sin credenciales), esquema de la arquitectura de dos capas.

**Checklist de cierre**
- [ ] Nginx sirviendo · [ ] PostgreSQL restringido · [ ] Web↔DB funcionando

---

## Módulo 5 — Bash scripting y automatización con cron

**Preparación**
- Identificar 2-3 tareas repetitivas reales del lab que merezca automatizar.

**Pasos**
1. Repasar buenas prácticas de scripting (manejo de errores, salida registrada, idempotencia).
2. Escribir un primer script administrativo sencillo y probarlo manualmente.
3. Añadir registro de su ejecución (log) y control de errores.
4. Programar su ejecución periódica con cron.
5. Verificar que cron lo ejecuta y deja rastro.
6. Versionar los scripts en el repo.

**Verificación**
- El script se ejecuta solo a la hora prevista y su resultado queda registrado.
- Ejecutarlo dos veces no rompe nada (idempotencia).

**Documentar y commit**
- Qué hace cada script, cuándo se ejecuta y cómo se comprueba.

**Checklist de cierre**
- [ ] Script con logs y control de errores · [ ] Programado en cron · [ ] Versionado

---

## Módulo 6 — Logs y troubleshooting

**Preparación**
- Familiarizarte con dónde viven los logs del sistema y de los servicios.

**Pasos**
1. Repasar el sistema de logging (journald / ficheros de log) y cómo consultarlo.
2. Provocar un fallo controlado en un servicio (parar, mala config) para tener un caso real.
3. Aplicar una **metodología de diagnóstico**: síntoma → hipótesis → evidencia en logs → causa → solución → verificación.
4. Documentar el caso como mini post-mortem.
5. Repetir con un fallo de red o de permisos para practicar otro tipo de problema.

**Verificación**
- Has identificado la causa real (no un parche) y el servicio queda sano.

**Documentar y commit**
- 1-2 casos de troubleshooting con el proceso seguido (excelente material de entrevista).

**Checklist de cierre**
- [ ] Metodología aplicada · [ ] Causa raíz identificada · [ ] Caso documentado

---

## Módulo 7 — Monitorización: Prometheus + Grafana

**Preparación**
- Repasar la diferencia entre métricas, logs y trazas, y el modelo de recolección por "pull".

**Pasos**
1. Instalar el exporter de métricas en bastión, web y db.
2. Instalar Prometheus en la monitor-server.
3. Configurar Prometheus para raspar las métricas de los 3 hosts.
4. Verificar que Prometheus recibe datos de todos.
5. Instalar Grafana y conectarla a Prometheus.
6. Construir un dashboard con las métricas clave (CPU, memoria, disco, red, estado de servicios).
7. Definir 1-2 alertas accionables (p. ej. disco lleno).

**Verificación**
- El dashboard muestra datos en vivo de las 3 máquinas.
- Una alerta de prueba se dispara cuando debe.

**Documentar y commit**
- Capturas del dashboard, qué se monitoriza y por qué; configs versionadas.

**Checklist de cierre**
- [ ] Métricas de 3 hosts · [ ] Dashboard útil · [ ] Alerta accionable probada

---

## Módulo 8 — Backups y recuperación

**Preparación**
- Decidir qué hay que respaldar (datos de la DB, configs) y con qué frecuencia (pensar RPO).

**Pasos**
1. Repasar conceptos de estrategia de backup (qué, cuándo, dónde, retención) y la regla 3-2-1.
2. Definir el procedimiento de copia de la base de datos y de las configuraciones.
3. Automatizar las copias con un script + cron (reaprovechando el Módulo 5).
4. Establecer una política de retención (cuántas copias se guardan).
5. **Probar una restauración real** en un entorno de prueba y medir cuánto cuesta (pensar RTO).
6. Documentar el procedimiento de recuperación paso a paso.

**Verificación**
- Una restauración desde cero recupera los datos correctamente.

**Documentar y commit**
- Estrategia, procedimiento de restore y resultado de la prueba.

**Checklist de cierre**
- [ ] Backups automatizados · [ ] Retención definida · [ ] Restore probado y documentado

---

## Módulo 9 — Integración AWS: IAM + S3

**Preparación**
- Repasar el aislamiento del lab dentro de tu cuenta AWS (cómo distinguir sus recursos y controlar gasto).

**Pasos**
1. Definir la estrategia de identidad: usuario/rol específico para el lab con **mínimo privilegio**.
2. Crear la política que permita solo lo necesario sobre el bucket del lab.
3. Crear el bucket de S3 para los backups (con buenas prácticas: bloqueo de acceso público, versionado).
4. Configurar el AWS CLI en el nodo de control (bastión) con credenciales del usuario/rol del lab.
5. Extender el procedimiento de backup del Módulo 8 para subir las copias a S3 (**backup offsite**).
6. Verificar permisos: que ese identity NO pueda hacer más de lo previsto.
7. Asegurar que ninguna credencial acaba en el repositorio.

**Verificación**
- Los backups llegan a S3 automáticamente.
- El usuario del lab no puede operar fuera de su alcance (probar una acción que debería estar denegada).

**Documentar y commit**
- Estrategia IAM, política aplicada, esquema del flujo de backup a S3.

**Checklist de cierre**
- [ ] IAM mínimo privilegio · [ ] Bucket seguro · [ ] Backups en S3 · [ ] Sin credenciales en Git

---

## Módulo 10 — AWS extra (opcional): CloudWatch · Route53 · HTTPS

**Preparación**
- Decidir qué subdominio de tu dominio usarás y si expones el web públicamente o solo haces el DNS.

**Pasos**
1. (CloudWatch) Decidir qué métricas o logs del lab tiene sentido enviar y configurarlo.
2. (Route53) Crear la zona/registros para apuntar un subdominio a tu servicio.
3. (HTTPS) Obtener un certificado TLS válido para ese subdominio.
4. Configurar Nginx para servir por HTTPS y forzar redirección desde HTTP.
5. Configurar la renovación automática del certificado.
6. Vigilar el panel de billing tras activar servicios que puedan tener coste.

**Verificación**
- El subdominio resuelve y el sitio carga con HTTPS válido (candado).
- (Si aplica) CloudWatch muestra los datos enviados.

**Documentar y commit**
- Registros DNS, proceso de certificado y notas de coste.

**Checklist de cierre**
- [ ] DNS funcionando · [ ] HTTPS válido con renovación · [ ] Coste controlado

---

## Módulo 11 — Capstone: documentación, diagrama y post-mortem

**Preparación**
- Revisar todos los READMEs de módulo y unificar el relato.

**Pasos**
1. Crear el **diagrama de arquitectura** final (las 4 VMs, segmentación, integración AWS).
2. Escribir el README profesional del proyecto: contexto, arquitectura, decisiones y por qué, cómo se despliega, qué demuestra.
3. Redactar un **post-mortem** de un incidente simulado de principio a fin.
4. Repasar el historial de Git para que cuente una buena historia.
5. Preparar un breve resumen orientado a recruiter (qué competencias demuestra cada parte).
6. Revisión final de seguridad: confirmar que no hay credenciales ni datos sensibles en el repo.

**Verificación**
- Una persona externa entendería el proyecto solo leyendo el README y el diagrama.

**Documentar y commit**
- README final, diagrama, post-mortem y resumen para portfolio.

**Checklist de cierre**
- [ ] Diagrama · [ ] README profesional · [ ] Post-mortem · [ ] Repo limpio de secretos

---

## Registro de cambios

- 2026-06-17 — v1: creación de la guía de pasos para los 12 módulos (0-11), alineada con el roadmap v2 (topología de 4 VMs).
