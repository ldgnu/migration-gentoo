# Conceptos

Las piezas de Gentoo explicadas con analogías concretas. Se agrega una entrada cada vez
que aparece un concepto nuevo en la instalación.

## Stage3 — el cuerpo sin sistema nervioso

Un stage es un Gentoo a medio armar, empaquetado como tarball. Contiene un sistema base
ya compilado: glibc, gcc, bash, coreutils, Portage, OpenRC, los usuarios y los permisos.
Todo eso lo compiló el equipo de Release Engineering, no vos.

Pensalo como un cuerpo humano completo en cuanto a estructura: tiene huesos, músculos y
órganos, todo en su lugar. Pero no tiene sistema nervioso ni ha respirado nunca. Está
armado, no está vivo.

Lo que le falta es justamente lo que lo hace funcionar:

- **Kernel** — el sistema nervioso central. Sin él no hay coordinación entre las partes,
  no hay vida.
- **Bootloader** — la chispa inicial. Lo primero que corre, el que despierta al resto.
- **Init (OpenRC)** — el sistema nervioso autónomo. Arranca los servicios en orden sin
  que tengas que pensar en cada uno.
- **fstab** — el mapa que dice dónde está cada órgano: qué disco se monta en qué lugar.
- **Tu configuración** — la historia clínica: quién sos, cómo te llamás, cómo te conectás.

Por qué existe: compilar un toolchain desde cero (gcc compilándose a sí mismo en varias
etapas) lleva horas o días y es frágil. Eso era el stage1, y Gentoo hace años que no te
hace pasar por ahí. Te entrega el resultado, que es el stage3. Compilás todo lo demás,
pero no el compilador.

Variantes que viste en la página de descargas (openrc/systemd, multilib/nomultilib,
hardened, musl, llvm) son el mismo concepto con decisiones tomadas de antemano. Se eligió
`openrc` por ser el init clásico de Gentoo y el que tiene el camino mejor documentado.

## El live no es el sistema

El live CD es la sala de operaciones. Es el entorno desde donde operás, no el paciente.
Corre en RAM, no toca tu disco, y desaparece cuando apagás.

El sistema que estás instalando es el paciente, y vive en `/mnt/gentoo`. Todo lo que
hagas ahí adentro sobrevive; todo lo que hagas fuera se pierde al reiniciar.

Por eso el orden de montaje importa: cuando montás root encima de `/mnt/gentoo`, lo que
había antes en ese directorio queda tapado. Es como poner la mesa de operaciones sobre la
camilla: lo que estaba abajo deja de verse.

## chroot — mirar el mundo desde adentro del paciente

`chroot` cambia la raíz del sistema de archivos para el proceso que lo ejecuta. Después
de entrar, `/` deja de ser el live y pasa a ser `/mnt/gentoo`.

Es ponerse los lentes del paciente: desde ese momento, los comandos que corrés son los
del sistema nuevo, con sus librerías y su configuración. El live sigue existiendo por
fuera, pero ya no lo ves como raíz.

Se usa para terminar la instalación desde adentro, porque muchas herramientas esperan
estar en el sistema que están configurando.

## Por qué no hay instalador

El instalador de Gentoo es tu shell. No es una limitación: es el punto. Cada paso que un
instalador automático esconde, acá lo hacés vos y lo entendés.

El `fstab` que escribas a mano lo vas a recordar siempre. El que te genera un instalador
no lo mirás nunca.

## MAKEOPTS — cuántos albañiles

Cuando un paquete se compila, `make` no lo hace de una pieza: compila archivo por archivo,
y cada archivo es un proceso independiente. `-j N` significa "tené N de esos procesos
corriendo a la vez".

Es una obra. El paquete es la casa, cada archivo es un ambiente, y `-j6` son seis albañiles
trabajando en ambientes distintos al mismo tiempo. Con uno solo, la casa se termina igual,
pero uno por uno.

El límite no es solo la CPU, es la **RAM**. Cada albañil necesita material. Un archivo de
C++ normal usa 100-300 MB; los de LLVM, Rust o WebKit usan 1.5 GB o más. Si varios agarran
archivos pesados al mismo tiempo, el kernel empieza a matar procesos y el `emerge` falla con
`internal compiler error` o `Killed`. Parece un bug del paquete; es falta de memoria.

`-l N` es otro freno, distinto: si la carga del sistema (load average) llega a N, no arranca
trabajos nuevos aunque haya lugar. Es el capataz mirando si la obra está demasiado agitada.
Sirve cuando compilás en una máquina que también usás para trabajar.

## -march=native vs un -march específico

`-march=native` hace que gcc detecte la CPU donde compila y use todo su set de
instrucciones. En una VM con la CPU en `host-passthrough` eso es la CPU real del host, así
que funciona.

La contra: los binarios quedan atados a esa CPU. Si el disco se mueve a otro hardware o a
un VPS con otra arquitectura, el sistema puede no arrancar o crashear con "instrucción
ilegal".

Un `-march` específico (por ejemplo `skylake`) fija un piso: usa las instrucciones que esa
generación garantiza y no más. Se pierde algo de rendimiento y se gana portabilidad. Para
un server que puede migrar, es la opción razonable.
