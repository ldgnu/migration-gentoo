# Gentoo en endymion

Un registro de instalación, contado con las capturas del proceso.

**endymion** — i5-10400F, 15 GiB, Radeon RX 6600, NVMe de 512 GB.
Gentoo amd64, OpenRC, kernel 7.3.5, Sway sobre Wayland.
Instalado el **17/11/2026**, auditado el **20/11/2026**.

Durante toda la instalación corrió un watcher que sacaba una foto cada 20 segundos. Las 24
capturas que están en este repo son de ahí: el proceso tal como pasó.

![El @world de 61 paquetes terminando](docs/registro-instalacion/capturas/20261117T191021Z-fin-world-61-de-61.jpg)

*17/11, 19:10. Jobs 61 of 61 complete. Ahí supe que el sistema iba a arrancar.*

## Empezá por acá

| Si querés… | Andá a |
|---|---|
| Instalar Gentoo en un equipo parecido | [`docs/guia-instalacion.md`](docs/guia-instalacion.md) |
| Entender qué pasó, en orden | [`docs/cronologia.md`](docs/cronologia.md) |
| Leer la opinión sin filtro | [`docs/experiencia.md`](docs/experiencia.md) |
| Ver qué está roto hoy | [`docs/auditorias/2026-11-20/`](docs/auditorias/2026-11-20/README.md) |

## Todo lo que hay

### La instalación

| Documento | Qué vas a encontrar |
|---|---|
| [`docs/guia-instalacion.md`](docs/guia-instalacion.md) | La guía ejecutable, de arriba abajo, sin abrir el handbook |
| [`docs/indice.md`](docs/indice.md) | El checklist para ir marcando cada paso |
| [`docs/bitacora.md`](docs/bitacora.md) | Fecha, qué se rompió con el mensaje literal, y cómo se resolvió |
| [`docs/cronologia.md`](docs/cronologia.md) | Las cuatro fases consolidadas: VM, fierro, escritorio y kernel |
| [`docs/vm.md`](docs/vm.md) | El ensayo en la máquina virtual, como laboratorio |
| [`docs/decisiones.md`](docs/decisiones.md) | Cada bifurcación y el motivo de la elección |

### La experiencia

| Documento | Qué vas a encontrar |
|---|---|
| [`docs/experiencia.md`](docs/experiencia.md) | Qué me gustó, qué no, con qué renegué y la comparación con Arch |
| [`docs/conceptos.md`](docs/conceptos.md) | Las explicaciones con analogías |
| [`docs/auditorias/2026-11-20/README.md`](docs/auditorias/2026-11-20/README.md) | El estado real del sistema y 19 hallazgos priorizados |

### Las pruebas

| Documento | Qué vas a encontrar |
|---|---|
| [`docs/registro-instalacion/`](docs/registro-instalacion/) | El watcher: comandos, 90 cambios y las 24 capturas |
| [`docs/registro-instalacion/capturas/`](docs/registro-instalacion/capturas/) | La galería completa, del primer minuto al último |
| [`docs/auditorias/instalacion-hardware-2026-11-17.md`](docs/auditorias/instalacion-hardware-2026-11-17.md) | La auditoría hecha desde el live, antes del primer arranque |
| [`docs/auditorias/2026-11-20/estado/`](docs/auditorias/2026-11-20/estado/) | Las salidas crudas de la auditoría y el `emerge.log` |
| [`docs/historial-paquetes.md`](docs/historial-paquetes.md) | Cada sesión de `emerge` con fecha y paquetes |

### La referencia

| Documento | Qué vas a encontrar |
|---|---|
| [`docs/hardware.md`](docs/hardware.md) | Qué driver necesita cada componente y dónde está en el menú del kernel |
| [`docs/audio.md`](docs/audio.md) | PipeWire, WirePlumber, Bluetooth y codecs A2DP |
| [`docs/migracion.md`](docs/migracion.md) | Qué hacer con los paquetes de la distro anterior |
| [`docs/retomar.md`](docs/retomar.md) | Cómo volver al chroot después de apagar |
| [`configs/`](configs/) | Portage, kernel, servicios y configuración de Sway |
| [`scripts/`](scripts/) | Bootstrap, post-instalación y sync de configs |

## Los números

5 días de instalación · 697 merges en 66 sesiones · 739 paquetes · 3 kernels compilados ·
24 capturas automáticas · 102 rebuilds pendientes.

## Estado

En uso desde el 17/11. Portage consistente, Sway con Steam y Tailscale andando.
Lo que falta está en la [auditoría](docs/auditorias/2026-11-20/README.md): los rebuilds por
ABI de 32 bits, el firewall y dos decisiones que nunca se registraron (cifrado y backup).

## Reglas del repositorio

Solo texto y configuración. Las capturas van como evidencia en `docs/img/` y
`docs/registro-instalacion/capturas/`. Nunca claves, tokens, contraseñas ni direcciones
internas: todo lo que entre al historial sigue ahí.
