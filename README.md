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
| vCPU asignadas | 6 |
| RAM asignada | 6 GB |
| Disco | 40 GB (qcow2) |
| Host OS | CachyOS, btrfs + LUKS |

## Estructura

```
README.md          este archivo
docs/decisiones.md cada bifurcación y el motivo de la elección
docs/bitacora.md   fecha, qué se rompió, cómo se resolvió
configs/           portage, make.conf, kernels, servicios
scripts/           bootstrap y post-instalación
```

## Reglas del repositorio

- Solo texto y configuración. Nada de binarios ni artefactos de compilación.
- Nunca se commitean claves, tokens, contraseñas, `/etc/shadow` ni direcciones internas.
- Todo secreto que entre al historial sigue ahí cuando el repo se haga público.

## Estado

Planificación. Sin instalación iniciada.
