# Decisiones

Registro de cada bifurcación técnica: qué opciones había, cuál se eligió y por qué.
Una decisión sin motivo escrito no sirve para nada seis meses después.

## Formato

```
### <fecha> — <decisión>
Opciones:
Elegido:
Motivo:
Consecuencias / costo:
```

## Registro

### 2026-11-15 — Entorno de práctica: VM KVM local
Opciones: desktop bare metal / Docker / contenedor con systemd / VM completa.
Elegido: VM KVM sobre el host actual.
Motivo: snapshots baratos, aislamiento del entorno de trabajo, ciclo de boot completo
(kernel, bootloader, init).
Consecuencias: compilación más lenta que bare metal; la VM no expone el hardware real.

### 2026-11-15 — Alcance: servidor
Opciones: servidor / escritorio / ambos.
Elegido: servidor, sin entorno gráfico.
Motivo: superficie acotada, objetivos verificables, no mezcla dos aprendizajes.
Consecuencias: queda fuera X11, audio, GPU y todo lo de escritorio.

**Corrección (2026-11-17):** el alcance real terminó siendo escritorio. Al pasar al hierro
se instaló Sway, PipeWire, Bluetooth, mesa con `amdgpu` y Steam. La decisión de "servidor"
valía para la VM y quedó sin efecto; ver [`guia-instalacion.md`](guia-instalacion.md) y
[`auditorias/2026-11-20/README.md`](auditorias/2026-11-20/README.md).

### 2026-11-15 — Init: OpenRC
Opciones: OpenRC / systemd.
Elegido: OpenRC.
Motivo: init propio de Gentoo, camino principal del handbook, scripts legibles, menos
caja negra para un primer contacto.
Consecuencias: algunos servicios de terceros asumen systemd; se resuelve caso por caso.
