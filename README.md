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
README.md          este archivo
docs/indice.md     checklist de todo el recorrido, con links al handbook
docs/vm.md         instalación paso a paso en una máquina virtual
docs/hardware.md   instalación en la PC real: hardware, drivers, UEFI, paquetes
docs/migracion.md  qué hacer con los 493 paquetes de CachyOS
docs/audio.md      PipeWire, WirePlumber, Bluetooth y codecs A2DP
docs/decisiones.md cada bifurcación y el motivo de la elección
docs/bitacora.md   fecha, qué se rompió, cómo se resolvió
docs/conceptos.md  explicaciones con analogías
docs/retomar.md    cómo volver al chroot después de apagar (etapa de instalación)
docs/img/          capturas de pantalla
configs/           portage, make.conf, kernels, servicios
scripts/           bootstrap, post-instalación y sync de configs
```

**Empezá por `docs/indice.md`**: tiene el checklist completo, marcado lo que ya está hecho
y lo que falta, con el enlace al capítulo del handbook en cada paso.

## Las dos guías

- **`docs/vm.md`** — el recorrido completo que se hizo en una VM con libvirt: del host vacío
  al sistema que bootea. Es la que se ejecutó y se documentó con errores reales.
- **`docs/hardware.md`** — qué cambia para instalar en la PC física: inventario de hardware,
  drivers obligatorios con su ruta en el menú del kernel, UEFI sin Secure Boot, qué conviene
  compilar y qué bajar como binario.

La VM es el laboratorio. El hardware es el destino.


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
