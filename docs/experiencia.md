# Mi experiencia con Gentoo

> Borrador armado con el registro de la instalación en la mano (comandos, errores literales,
> capturas). La parte de hechos es comprobable; la de sensaciones es una lectura de lo que
> pasó. Si algo no coincide con lo que viviste, corregilo: este documento es tuyo.

## De dónde venía

Venía de CachyOS, o sea de Arch con esteroides: binarios, systemd, btrfs con snapshots y
LUKS. Funcionaba. La razón de cambiarlo no fue que fallara, fue no entender qué hacía cada
capa. Gentoo promete lo contrario: que cada pieza esté ahí porque la pusiste vos.

El recorrido fueron seis días: dos de ensayo en una VM, uno de instalación real, tres de
escritorio, herramientas y kernel.

## Qué hice

1. **VM primero (15 y 16/11).** libvirt, BIOS, disco de 50 GB. Ahí se rompió todo lo que
   tenía que romperse: red, particiones, `pam_faillock`, el primer `@world` con gcc y glibc.
2. **Hardware (17/11).** NVMe reparticionado, stage3 openrc, sync, 61 paquetes de `@world`,
   fstab real, hostname `endymion`, locale `es_AR`, red `eno1`, kernel 6.18.63 compilado a
   mano, GRUB EFI y primer arranque. Todo con un watcher tomando capturas cada 20 segundos.
3. **Escritorio (17 y 18/11).** Sway, foot, wmenu, PipeWire, Bluetooth, Zen, Steam, mesa con
   `amdgpu`, Tailscale, y una tanda de herramientas de terminal.
4. **Kernel 7.3.5 (18 y 19/11).** Upgrade de rama, y después recompilación para agregar
   `CONFIG_TUN` porque Tailscale lo pedía.

## Lo que me gustó

**Que el sistema se deje leer.** OpenRC son scripts de shell. Cuando algo no arranca, abrís
`/etc/init.d/net.eno1`, lo leés y entendés. No hay una capa de abstracción que te esconda el
motivo. Lo mismo con Portage: el ebuild es un script, el log dice qué archivo y qué línea.

**El `@world`.** 61 paquetes la primera vez en hardware, 430 merges ese día, y terminó sin
una sola dependencia rota. Un sistema que se construye desde el compilador hacia arriba y
queda consistente es una cosa bastante impresionante la primera vez que lo ves.

**`installkernel` con dracut y grub.** `make install` y listo: initramfs generado, GRUB
actualizado, entrada UEFI. La parte que en otros lados es manual acá está resuelta en un USE
flag.

**El kernel, driver por driver.** Es lo más divertido y lo cuento aparte más abajo.

**Que el error te hable.** `short ebuild name "screen" is ambiguous`, `pam_faillock`,
`Cannot find terminfo entry for 'xterm-kitty'`. Mensajes concretos, con causa identificable.
En otros sistemas el error es "algo falló".

## Lo que no me gustó

**El costo en tiempo y en ruido.** Compilar no es gratis: el cooler se escucha, la máquina
deja de ser tuya por horas, y un cambio de USE mal pensado te cuesta una tarde. Arch te
instala en 20 minutos; acá el primer día es un día.

**Los 102 rebuilds pendientes por Steam.** Cuando se agregó `ABI_X86="64 32"` a `make.conf`
para Steam, se disparó una reconstrucción de medio sistema que todavía no se terminó:
`/usr/lib32` está vacío. Es la deuda más grande que dejó la instalación, y no se ve hasta que
corrés `emerge -uDNp @world`.

**`~amd64` global.** Todo el sistema corre en testing. Es cómodo y es lo que hace que se
parezca a Arch, pero significa 29 noticias de Portage sin leer y actualizaciones que pueden
romper algo sin aviso previo.

**La documentación dispersa.** El handbook explica el camino feliz. Los problemas reales
(mirror muerto, `localmodconfig` que se come drivers, `pam_faillock`, el namespace del
chroot) no están ahí: están en foros, wikis y prueba y error.

**El chroot.** Trabajar dentro de `arch-chroot` desde el live tiene tres trampas: el `emerge`
corre en un namespace de PID aparte (parece colgado y no lo está), el historial de bash no se
guarda si no cargaste `.bashrc`, y `resolv.conf` es un bind mount del live. Nada grave, todo
incómodo.

## Con qué renegué más

Ranking por costo real medido en el registro, no por dificultad percibida.

1. **El kernel, pero no por difícil: por opaco.** Tres compilaciones en tres días.
   `localmodconfig` toma como referencia los módulos del live y se come lo que no está
   cargado en ese momento —NTFS3, exFAT, Bluetooth—. Y cuando Tailscale pidió `/dev/net/tun`,
   el kernel no sabía qué era `CONFIG_TUN`, así que hubo que recompilar. La lección: el
   `.config` no es un archivo de configuración, es una lista de decisiones y cada una tiene
   consecuencias que aparecen días después.
2. **Los nombres de red.** `eth0` en la doc, `enp1s0` en la VM, `eno1` en el hardware. Más
   `dhcpcd` y `netifrc` peleando por la misma interfaz en la VM. Tres nombres para la misma
   cosa y un servicio que no arranca si el archivo no se llama igual que la interfaz.
3. **`pam_faillock`.** Tres intentos fallidos y la cuenta queda bloqueada ocho minutos. El
   mensaje habla de SSH, así que uno busca en el lugar equivocado. No era SSH.
4. **El mirror muerto.** `gentoo.zero.com.ar` no resuelve por DNS y está primero en
   `GENTOO_MIRRORS`: cada descarga pierde timepo ahí antes de pasar al siguiente.
5. **`wofi`.** Se instaló, no arrancaba por el portal y `XDG_RUNTIME_DIR`. Se resolvió
   sacándolo y poniendo `wmenu`, que hace lo mismo con menos piezas.

## Lo que parecía simple y no lo fue

| Tema | Por qué |
|---|---|
| `wofi` | Un launcher. Dos dependencias del portal y una variable de entorno después, no arrancaba |
| Audio | PipeWire salió bien, pero el códec HDA falla el primer probe en cada arranque (`Cannot probe codecs`) y el HDMI tira `vendor infoframe` |
| Red | Un solo parámetro (`config_eno1="dhcp"`), pero el nombre de la interfaz y el cliente DHCP duplicado complican todo |
| Historial del chroot | Parece un detalle; sin él, reconstruir qué se hizo depende de mtimes y logs |
| Kernel incremental | "Agrego un módulo y recompilo" suena a diez minutos; son cuarenta y hay que volver a probar el arranque |

## Lo que parecía complicado y fue simple

| Tema | Por qué |
|---|---|
| Particionar con UEFI | `cfdisk`, cuatro particiones, tipos correctos. Sin drama |
| GRUB EFI | `grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo` y funcionó de una |
| Stage3 | Extraer un tarball y entrar al chroot. El handbook acierta |
| PipeWire + WirePlumber | El stack completo compiló y anduvo sin tocar nada |
| Sway | Instalar, configurar y usar. Más simple que pelear con un DE |
| Recuperar el arranque | La entrada UEFI quedó primera y Windows intacto sin hacer nada especial |

## ¿Gentoo o Arch? No le veo la diferencia

La pregunta es justa, y la respuesta corta es: **no lo hiciste mal, pero fuiste por el camino
corto**. El registro lo muestra con datos.

### Por qué hoy se siente como Arch

1. **Usaste binarios para lo pesado.** Hubo 11 sesiones con `--getbinpkg --usepkg`: Zen, el
   stack de Sway, los paquetes de gaming. Cuando el paquete viene compilado, Gentoo es un
   gestor de paquetes con otro nombre.
2. **`ACCEPT_KEYWORDS="~amd64"`.** Es rolling release, igual que Arch. La diferencia entre
   ambos deja de ser el modelo de versiones.
3. **El software es el mismo.** Sway, PipeWire, Zen, mesa, Steam: upstream idéntico. El
   escritorio no va a verse distinto porque lo compilaste vos.
4. **Tocaste pocos USE flags.** Hay siete archivos en `package.use`, y son razonables
   (`mpv -X`, `mesa vulkan`, `pipewire sound-server`). Eso alcanza para adelgazar un poco,
   no para redefinir el sistema.
5. **`-march=native` casi no se nota.** Compilás para tu CPU, sí, pero en un i5 de escritorio
   la diferencia contra un binario genérico es de un dígito porcentual en casos puntuales. No
   se siente en el uso diario.

Y hay un dato que lo confirma: `opt-O3` está definido y aplicado **solo a `mesa` y `ffmpeg`**.
La infraestructura para diferenciarte está armada y se usó en dos paquetes.

### Dónde sí es distinto, aunque no lo parezca

- **El init.** OpenRC en vez de systemd no es cosmético: cambia cómo arranca todo, cómo se
  escribe un servicio y qué podés leer cuando falla.
- **El kernel.** Tenés un kernel hecho para esta máquina, no el `linux` genérico de Arch.
  Eso ya es una diferencia real, y es la que más te gustó.
- **La cadena de herramientas es tuya.** gcc 16, Python 3.14, el perfil multilib. Cuando algo
  se rompe, sabés de dónde viene porque lo compilaste.
- **El control del árbol.** Podés fijar versiones, enmascarar paquetes y aplicar parches sin
  esperar a un maintainer.

### La diferencia que todavía no probaste

Gentoo se siente distinto cuando cambiás **decisiones**, no cuando compilás. Algunas que
tienen sentido para este equipo:

- **Terminar `ABI_X86="64 32"` de verdad.** Hoy está declarado y no construido. Eso es
  exactamente el tipo de deuda que Arch no te genera porque trae los binarios de 32 bits
  hechos.
- **Recortar USE por paquete** en lo que no usás: `-cups` si no imprimís, `-bluetooth` si un
  día no lo usás, `-X` donde ya es Wayland puro. Menos dependencias, menos superficie.
- **`opt-O3` y LTO en lo que importa** (mesa, ffmpeg, navegador), no en todo.
- **Un perfil más filoso**: `no-multilib` si algún día Steam deja de importar.
- **Kernel propio con lo justo**, que ya estás haciendo.

### El veredicto honesto

Gentoo no es más rápido porque compila. Es más **tuyo**. Si no cambiás las decisiones de
compilación, el resultado diario es indistinguible de Arch, y eso no es un fracaso: es
información. Significa que la parte de Gentoo que te interesa —entender, controlar, armar— la
estás usando a medias, y que el costo (días de compilación, 102 rebuilds, 29 noticias) lo
estás pagando igual.

La pregunta correcta no es "¿en qué se diferencia de Arch?" sino "¿qué decisión quiero tomar
que Arch no me deja tomar?". Si la respuesta es el kernel y el init, ya está: eso es Gentoo y
lo tenés. Si la respuesta es "ninguna", entonces Arch era la herramienta correcta y Gentoo
fue una forma cara de aprender cómo funciona un sistema operativo — que, dicho sea de paso,
parece haber sido el objetivo.

## Lo más divertido: el kernel

Fue lo mejor de toda la instalación, y no por el resultado sino por lo que obliga a entender.

Un kernel no es un programa que "hace que ande Linux". Es el traductor entre el hardware y
el resto del sistema, y cada opción de `.config` es una respuesta a "¿quién se va a encargar
de esto?":

- `CONFIG_BLK_DEV_NVME=y`: sin esto no hay disco donde montar la raíz. Va compilado adentro,
  no como módulo, porque el módulo vive en el disco que todavía no podés leer.
- `CONFIG_EXT4_FS=y`: lo mismo con el filesystem de la raíz.
- `CONFIG_DRM_AMDGPU`: acá sí `=m`, porque la placa puede esperar a que el sistema arranque.
- `CONFIG_E1000E`: la placa de red Intel. Si falta, el sistema arranca sin red y no hay forma
  de bajar el módulo.
- `CONFIG_NTFS3_FS=m` y `CONFIG_EXFAT_FS=m`: los discos de datos. `localmodconfig` no los
  incluyó porque en el live no estaban montados. Si no los agregás a mano, un día montás
  `sdb1` y no pasa nada.

Y después está el caso perfecto: **Tailscale**. El servicio arrancó, se conectó, y para crear
la interfaz virtual necesitaba `/dev/net/tun`. El kernel no tenía `CONFIG_TUN`, así que no
existía ese dispositivo. No hay mensaje de error épico: hay un servicio que no levanta la
interfaz. Se agrega `CONFIG_TUN=m`, se recompila, se reinicia, funciona.

Esa secuencia —un programa pide un dispositivo, el dispositivo no existe porque una opción del
kernel está apagada, se prende y se recompila— es la mejor clase de sistema operativo que se
puede tener. No hay magia en ningún lado. Todo lo que pasa tiene un porqué escrito en un
archivo de configuración, y ese archivo lo escribiste vos.

## Qué haría distinto

1. **Backup antes de reparticionar.** El sistema anterior no se respaldó. No hubo pérdida,
   pero fue suerte, no método.
2. **No poner `~amd64` global de entrada.** Empezar en stable y subir paquetes puntuales.
3. **Construir el ABI de 32 bits en el mismo momento en que se agrega**, no dejarlo para
   después. Es la deuda más grande que quedó.
4. **Un solo kernel estable y uno de prueba**, no tres builds en tres días con `.old`
   colgando.
5. **Anotar las decisiones mientras se toman.** Cifrado sí o no, backup sí o no, por qué
   `~amd64`. El registro técnico quedó impecable; lo que falta es el porqué.
6. **Usar binarios con criterio y decirlo.** No está mal usar `--usepkg`; está mal usarlo y
   después preguntarse por qué se siente igual que Arch.

## Los números del proyecto

| Dato | Valor |
|---|---|
| Días de la instalación a sistema usable | 2 (VM) + 1 (hardware) + 2 (escritorio) |
| Merges de Portage registrados | 697 en 66 sesiones |
| Paquetes instalados hoy | 739 |
| Kernels compilados | 3 (6.18.63, 7.3.5, 7.3.5 + `CONFIG_TUN`) |
| Capturas de la instalación | 24 |
| Rebuilds pendientes | 102 |
| Noticias de Portage sin leer | 29 |
