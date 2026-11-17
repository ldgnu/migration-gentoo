# qwertoo

Instalación y operación de un servidor Gentoo desde cero, documentada en el proceso.

## Objetivo

Aprender Gentoo en profundidad: Portage, USE flags, kernel, init y administración real
de un sistema que compila todo lo que corre. El resultado esperado no es "un servidor que
anda", sino un registro verificable de decisiones, errores y resoluciones.

## Alcance

- Servidor, sin entorno gráfico.
- Init: OpenRC.
- Entorno de práctica: VM KVM local. El procedimiento debe ser replicable en hardware real
  o VPS.

## Hardware de práctica

| Recurso | Valor |
|---|---|
| Host | i5-10400F (6c/12t) |
| vCPU asignadas | 8 |
| RAM asignada | 8 GB |
| Disco | 50 GB (qcow2, virtio) |
| Firmware | BIOS (SeaBIOS), no UEFI |
| Host OS | CachyOS, btrfs + LUKS |

## Estructura

```
README.md                 este archivo
docs/guia-instalacion.md  ★ LA GUÍA: paso a paso completo, de arriba abajo, sin handbook
docs/indice.md            checklist y mapa de todo el recorrido
docs/hardware.md          hardware real, drivers, UEFI, rutas del menú del kernel
docs/audio.md             PipeWire, WirePlumber, Bluetooth y codecs A2DP
docs/vm.md                la instalación de práctica en una VM (laboratorio)
docs/migracion.md         qué hacer con los 493 paquetes de CachyOS
docs/decisiones.md        cada bifurcación y el motivo de la elección
docs/bitacora.md          fecha, qué se rompió, cómo se resolvió
docs/conceptos.md         explicaciones con analogías
docs/retomar.md           cómo volver al chroot después de apagar
docs/prompt-asistente.md  prompt autocontenido para asistencia desde el celular
docs/img/                 capturas de pantalla
configs/                  portage, make.conf, kernels, servicios
scripts/                  bootstrap, post-instalación y sync de configs
```

**Empezá por `docs/guia-instalacion.md`.** Es la guía única y en orden: rescate, live,
particionado, stage3, kernel, GRUB, escritorio, audio y verificación final. `docs/indice.md`
tiene el checklist para ir marcando.

## La guía

- **`docs/guia-instalacion.md`** — el paso a paso completo para el fierro. Cada bloque se
  ejecuta y se verifica; incluye los valores exactos de `make.conf`, `package.use` y del
  kernel, y la tabla de errores ya resueltos.
- **`docs/hardware.md`** — referencia: qué driver necesita cada componente y dónde está en
  el menú del kernel.
- **`docs/vm.md`** — el recorrido que se hizo en la VM. Es historia y evidencia, no el camino
  a seguir en el fierro (la VM es BIOS + virtio; el fierro es UEFI + amdgpu).

Cada paso de la guía linkea, cuando hace falta profundidad, al capítulo del handbook.


## Capturas

En `docs/img/`, con nombres que describan el momento:

```
01-handbook-aburrimiento.png
02-emerge-kernel.png
03-menuconfig.png
04-compilacion.png
```

Solo cuando el texto no alcanza: una salida de `emerge`, el menú de GRUB, el primer
arranque. Nunca capturas con direcciones IP públicas, claves, tokens ni rutas que
expongan el usuario real.

Para capturar directo a archivo:

```
maim -s docs/img/nombre.png
```

## Reglas del repositorio

- Solo texto y configuración. Nada de binarios ni artefactos de compilación.
- Nunca se commitean claves, tokens, contraseñas, `/etc/shadow` ni direcciones internas.
- Todo secreto que entre al historial sigue ahí cuando el repo se haga público.

## Estado

Instalación en curso. Sistema base instalado, kernel en configuración. Ver `docs/retomar.md`
para el estado detallado y lo que falta.

## Por qué configurar el kernel a mano

El handbook lista siete razones para hacerlo. La quinta es "aburrimiento severo".


Planificación. Sin instalación iniciada.
