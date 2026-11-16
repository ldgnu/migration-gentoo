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
docs/decisiones.md cada bifurcación y el motivo de la elección
docs/bitacora.md   fecha, qué se rompió, cómo se resolvió
docs/conceptos.md  explicaciones con analogías
docs/retomar.md    cómo volver al chroot después de apagar
docs/img/          capturas de pantalla
configs/           portage, make.conf, kernels, servicios
scripts/           bootstrap y post-instalación
```

## Capturas

En `docs/img/`, con nombres que describan el momento:

```
01-emerge-inicial.png
02-grub-menu.png
03-primer-boot.png
```

Solo cuando el texto no alcanza: una salida de `emerge`, el menú de GRUB, el primer
arranque. Nunca capturas con direcciones IP públicas, claves, tokens ni rutas que
expongan el usuario real.

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
