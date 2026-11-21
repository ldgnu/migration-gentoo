# Bitácora

Registro cronológico de la instalación. Se escribe mientras pasa, no al final.

Solo se anota lo que efectivamente ocurrió y se puede mostrar con una salida de
terminal. Los tiempos se registran únicamente si se midieron; si no, no se inventan.

## Formato

```
## <fecha> — <etapa>
Qué hice:
Qué falló (mensaje literal):
Cómo lo resolví:
Verificación:
Qué aprendí:
```

## Entradas


## 2026-11-15 — Preparación del host

Qué hice:
Liberé espacio en el disco del host antes de crear la VM. De 50 GB libres pasé a 85 GB.
Borré el caché de uv, el de paru, zen, go-build, imágenes Docker sin uso y modelos de
Ollama que no estaban corriendo.

Qué falló:
Después de borrar `~/.ollama` (15 GB), el `df` seguía igual.

Cómo lo resolví:
Había dos stores de Ollama: el servicio corre como usuario `ollama` y usa
`/var/lib/ollama/.ollama`, mientras que `~/.ollama` era un store viejo sin uso. Además
el snapshot 731 de snapper retenía 24 GiB exclusivos. Borré el store huérfano y ese
snapshot; después de `btrfs filesystem sync` el espacio apareció.

Verificación:
```
$ df -h /
/dev/mapper/luks-...   473G   383G   85G  82% /
```

Qué aprendí:
En btrfs el espacio libre no es lo que borrás, es lo que no está referenciado por
ningún snapshot. `df` no lo refleja hasta el sync.

## 2026-11-15 — Libvirt: la red default no arrancaba

Qué hice:
Intenté crear la VM desde virt-manager y falló al validar el medio de instalación.

Qué falló (mensaje literal):
```
Requested operation is not valid: network 'default' is not active
```
```
error: internal error: Network is already in use by interface virbr0
```
```
Incorrecto al conectar zócalo a '/var/run/libvirt/virtstoraged-sock': No existe el fichero o el directorio
```

Cómo lo resolví:
Tres problemas apilados.

1. dnsmasq huérfanos y un `virbr0` sin dueño:
```
sudo virsh -c qemu:///system net-destroy default
sudo systemctl restart virtnetworkd
sudo virsh -c qemu:///system net-start default
```
2. virt-manager estaba creando la VM en `qemu:///session`, donde la red no se puede
   activar porque no hay permisos para crear el bridge. Puse `qemu:///system` primero
   en la lista de conexiones.
3. `virtstoraged` estaba apagado y no habilitado, así que el socket de almacenamiento
   no existía:
```
sudo systemctl enable --now virtstoraged.socket
```

Verificación:
```
$ virsh -c qemu:///system net-list --all
 default   activo   si   si

$ ip -br addr show virbr0
virbr0   UP   192.168.122.1/24
```

Qué aprendí:
Libvirt 12 es modular: cada función es un daemon con su socket (`virtqemud`,
`virtnetworkd`, `virtstoraged`, `virtlogd`, `virtlockd`). Si un error menciona un socket
que no existe, es un servicio apagado, no la VM. Y `virsh` sin `-c` habla con
`qemu:///session`, que tiene su propia red default inactiva.

## 2026-11-15 — Verificación de la ISO

Qué hice:
Bajé la Minimal Installation CD de amd64 (1.05 GB) y verifiqué la firma OpenPGP.

Qué falló:
El primer `curl` del `.asc` armé mal la URL y bajó un archivo vacío.

Cómo lo resolví:
```
curl -O https://distfiles.gentoo.org/releases/amd64/autobuilds/20261115T170104Z/install-amd64-minimal-20261115T170104Z.iso.asc
curl -sSL https://qa-reports.gentoo.org/output/service-keys.gpg | gpg --import
gpg --verify install-amd64-minimal-20261115T170104Z.iso.asc install-amd64-minimal-20261115T170104Z.iso
```

Verificación:
```
gpg: Firma correcta de "Gentoo Linux Release Engineering (Automated Weekly Release Key)"
Huella primaria: 13EB BDBE DE7A 1277 5DFD  B1BA BB57 2E0E 2D18 2910
```
Huella comparada contra `gentoo.org/downloads/signatures`.

Qué aprendí:
Que gpg diga "clave sin confianza" no invalida nada. La confianza la aporta comparar la
huella contra la web oficial, que es un canal distinto del mirror de donde salió el
archivo.

## 2026-11-15 — VM creada

Qué hice:
Creé la VM `qwertoo` desde virt-manager sobre `qemu:///system`.

Verificación (leída del XML del dominio):
```
memory   8290304 KiB  (8 GiB)
vcpu     8
machine  pc-q35-11.1, BIOS (sin loader ni nvram)
disk     /var/lib/libvirt/images/qwertoo.qcow2  (vda, virtio, 50G)
cdrom    install-amd64-minimal-20261115T170104Z.iso  (sda, sata)
net      virtio, red default
```

Qué falló:
Nada, una vez arreglado lo anterior.

Qué aprendí:
La VM quedó en BIOS (SeaBIOS), no en UEFI. Eso define el esquema de particiones: en
BIOS con GPT hace falta una partición BIOS boot de 1 MiB.

Nota:
Al planificar había anotado 6 vCPU / 6 GB / 40 GB. La VM terminó con 8 vCPU, 8 GiB y
50 GB de disco.

## 2026-11-15 — SSH al live

Qué hice:
Levanté sshd en el live para trabajar por SSH en lugar de SPICE.

Qué falló:
Tipeé `/etc/init.d/` solo y saltó "Display all 118 possibilities?". Después
`/etc/init.d/sshd` sin argumento, que escupe el usage. Y `ip -br addrr` dos veces, con
una r de más.

Cómo lo resolví:
```
passwd root
/etc/init.d/sshd start
ip -br addr
```

Verificación:
```
enp1s0   UP   192.168.122.34/24
$ virsh -c qemu:///system net-dhcp-leases default
 192.168.122.34   livecd
```

Qué aprendí:
El live trae openssh pero no lo arranca, y sin contraseña de root el login por SSH
rebota. La IP se confirma desde el host con `net-dhcp-leases`.

## 2026-11-15 — Particiones y filesystems

Qué hice:
Particioné `/dev/vda` (50 GB) con cfdisk: GPT, 1 MiB BIOS boot, 1 GiB boot, 4 GiB swap
y 45 GiB root. Después formateé.

Comandos:
```
cfdisk /dev/vda
```
```
mkfs.ext4 -L boot /dev/vda2
mkswap -L swap /dev/vda3
mkfs.ext4 -L root /dev/vda4
```

Qué falló:
Pegué los tres `mkfs` en una sola línea y bash los concatenó:
```
mkfs.ext4: invalid blocks '/dev/vda3mkfs.ext4' on device '/dev/vda2mkswap'
```
Y tipeé `lslbk` cuatro veces antes de darme cuenta de que era `lsblk`.

Cómo lo resolví:
Uno por línea. Los tipos de partición se verifican con `sfdisk -d`, porque `lsblk -f`
no muestra el GUID:
```
/dev/vda1 : type=21686148-6449-6E6F-744E-656564454649   (BIOS boot)
/dev/vda3 : type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F   (Linux swap)
```

Verificación:
```
NAME   FSTYPE FSVER LABEL UUID
vda2   ext4         boot  9d841b3e-4d5a-4261-aee7-9eceeca04bc2
vda3   swap         swap  2facd8f6-8e4a-4a09-b744-850b10c3f1ad
vda4   ext4         root  07dcb0e4-487f-47c3-a139-4b2c9664228f
```

Qué aprendí:
En BIOS con GPT, GRUB necesita una partición BIOS boot de 1 MiB; sin ella `grub-install`
falla. Y `lsblk -f` no muestra el tipo de partición: para eso está `sfdisk -d`.

Estado: los filesystems están creados pero **no montados**. `lsblk` muestra MOUNTPOINTS
vacío en las cuatro particiones.

## 2026-11-15 — Falsa alarma de red: 1.1.1.1 no es un buen test

Qué hice:
Ante la duda de si la VM tenía internet, probé conectividad desde el host creando una
interfaz virtual metida en `virbr0` con una IP de esa red.

Resultado:
```
ping 192.168.122.1   → 2/2 recibidos
ping 1.1.1.1         → 100% packet loss
DNS gentoo.org       → resuelve
https gentoo.org     → timeout
```
Conclusión apurada: el forward estaba roto y la culpa era la política `DROP` de la
cadena `FORWARD` que pone Docker.

Qué falló:
La conclusión. Desde la VM, `ping google.com.ar` responde en 16 ms y sin pérdida. La red
funciona. Lo único que no responde es ICMP a `1.1.1.1`, que está filtrado en esta red.

Cómo lo resolví:
Nada que resolver: no había nada roto. El error fue usar un único destino externo como
prueba de conectividad, sin control sobre si ese destino responde ICMP.

Qué aprendí:
Para probar salida a internet, el gateway y un host real (o una petición HTTPS) dicen
más que un ping a una IP pública elegida de memoria. Y un `timeout` corto contra un solo
dominio no prueba que no haya internet: prueba que esa petición falló.

## 2026-11-15 — Stage3: descarga y verificación

Qué hice:
Bajé el stage3 openrc (264 MB) y verifiqué la firma antes de extraerlo. También ajusté
el reloj, que estaba 1.45 s adelantado.

Comandos:
```
cd /mnt/gentoo
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/20261115T170104Z/stage3-amd64-openrc-20261115T170104Z.tar.xz
gpg --import /usr/share/openpgp-keys/gentoo-release.asc
wget .../stage3-amd64-openrc-20261115T170104Z.tar.xz.asc
wget .../stage3-amd64-openrc-20261115T170104Z.tar.xz.DIGESTS
wget .../stage3-amd64-openrc-20261115T170104Z.tar.xz.sha256
gpg --verify stage3-amd64-openrc-20261115T170104Z.tar.xz.asc
chronyd -q
```

Qué falló:
- Pedí `stage3-...tar.asc` en vez de `stage3-...tar.xz.asc` → 404.
- Verifiqué el `.tar.xz` directamente con gpg → `invalid packet (ctb=10)`.
- Corrí `sha256sum --check` sin pasarle archivo.

Cómo lo resolví:
Bajé el `.asc` que corresponde al nombre exacto del tarball y verifiqué contra ese. También
corrí `chronyd -q`, que ajustó el reloj del live en 1.45 s: el `Wrong owner of /run/chrony`
que tiró no impidió el ajuste.

Verificación:
```
gpg: Good signature from "Gentoo Linux Release Engineering (Automated Weekly Release Key)"
      13EBBDBEDE7A12775DFDB1BABB572E0E2D182910
      534E4209AB49EEE1C19D96162C44695DB9F6043D
```
Los mismos hashes salieron bien contra `.DIGESTS` y `.sha256`, que están firmados igual.

Qué aprendí:
gpg verifica un archivo contra una firma concreta, no un hash suelto: el `.asc` tiene que
corresponder al nombre exacto del tarball. Y el reloj del live puede estar corrido; conviene
ajustarlo antes de confiar en TLS y en los timestamps de Portage.

## 2026-11-15 — Extracción del stage3

Qué hice:
Extraje el tarball sobre `/mnt/gentoo` usando las banderas del handbook.

Comando:
```
tar xpvf stage3-amd64-openrc-20261115T170104Z.tar.xz \
    --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
```

Verificación:
```
$ ls /mnt/gentoo | wc -l
25
$ du -sh /mnt/gentoo
1.5G
$ ls -ld /mnt/gentoo/root /mnt/gentoo/etc
drwx------ root root  /mnt/gentoo/root
drwxr-xr-x root root  /mnt/gentoo/etc
```

Qué aprendí:
`-C /mnt/gentoo` fija el destino y evita depender del directorio actual. Importa porque
el live corre en RAM: extraer los 1.5 GB en tmpfs habría consumido memoria y posiblemente
matado la sesión.

## 2026-11-15 — make.conf y entrada al chroot

Qué hice:
Configuré las opciones de compilación y entré al sistema nuevo.

Contenido de `/mnt/gentoo/etc/portage/make.conf`:
```
COMMON_FLAGS="-march=skylake -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
MAKEOPTS="-j6 -l6"
RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"
```

Comandos:
```
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
arch-chroot /mnt/gentoo
```

Decisión: `-march=skylake` en lugar de `-march=native`.
Motivo: native compila solo para esta CPU. Skylake cubre Intel desde 2015 y AMD Zen, así
que el sistema sigue siendo portable si el disco se mueve a otro hardware o a un VPS.

Verificación:
```
$ ls /mnt/gentoo/proc | head -3
1
10
100
$ cat /mnt/gentoo/etc/resolv.conf
nameserver 192.168.122.1
```

Qué aprendí:
`arch-chroot` no es del handbook de Gentoo, pero el live lo trae. Monta `/proc`, `/sys`,
`/dev` y `/run` y copia el `resolv.conf`, que es justo lo que el handbook pide hacer a mano
antes de entrar. Por eso `cp --dereference /etc/resolv.conf` quedó duplicado: el flag `-L`
ya lo había resuelto.

## 2026-11-15 — repos.conf y primer sync

Qué hice:
Configuré el repositorio de Portage y lancé la primera sincronización del árbol de ebuilds.

Comandos:
```
mkdir /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge --sync
```

Qué falló:
- `mirrorselect -i -o >> /etc/portage/make.conf` lo corrí **fuera** del chroot, así que el
  `GENTOO_MIRRORS` quedó en el `make.conf` del live y no en el del sistema instalado.
- `emerge --ask --verbose --oneshot app-portage/mirrorselect` no funcionaba: el paquete ya
  estaba instalado en el live y, además, dentro del chroot todavía no existía el árbol de
  ebuilds, así que no había nada que resolver.

Cómo lo resolví:
Nada que resolver: el sync siguió su curso y `GENTOO_MIRRORS` no es obligatorio (sin esa
variable Portage usa `distfiles.gentoo.org`).

Verificación:
```
$ grep -E "sync-type|sync-uri" /etc/portage/repos.conf/gentoo.conf
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
$ du -sh /var/db/repos/gentoo
352M
```

Qué aprendí:
Dentro del chroot, `/` es `/mnt/gentoo`. La ruta delata dónde estás: `/etc/...` es el
sistema nuevo, `/mnt/gentoo/etc/...` es el live desde afuera. Y `mkdir` sin `--parents`
falla si el directorio ya existe; con `--parents` es idempotente.

## 2026-11-15 — Sync terminado y perfil de sistema

Qué hice:
Terminó el sync del árbol de ebuilds y quedó seteado el perfil del sistema.

Verificación:
```
$ du -sh /var/db/repos/gentoo
719M
$ readlink -f /etc/portage/make.profile
/mnt/gentoo/var/db/repos/gentoo/profiles/default/linux/amd64/23.0/no-multilib
$ ls -d /lib32
ls: cannot access '/lib32': No such file or directory
```

Decisión: `default/linux/amd64/23.0/no-multilib`, sin perfil de escritorio.
Motivo: el proyecto es un servidor. El perfil `desktop/plasma` habría activado `qt5`,
`X`, `wayland`, `opengl` y el resto del stack gráfico, con horas de compilación y varios
GB de disco para una máquina que no tiene pantalla.

Qué aprendí:
El perfil `no-multilib` requiere un stage3 `nomultilib`: si el stage3 fuera multilib,
existiría `/lib32` y el perfil quedaría inconsistente. La forma rápida de verificarlo es
comprobar si existe ese directorio.

## 2026-11-15 — USE flags, licencias y locale

Qué hice:
Configuré las licencias aceptadas, los flags de CPU, el binhost y los locales.

Contenido de `/etc/portage/make.conf` (fragmentos):
```
GENTOO_MIRRORS="https://gentoo.zero.com.ar/gentoo/ \
    https://gentoo.c3sl.ufpr.br/ ..."
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
FEATURES="${FEATURES} getbinpkg"
FEATURES="${FEATURES} binpkg-request-signature"
```

Archivos en `package.use`:
```
*/* CPU_FLAGS_X86: aes avx avx2 bmi1 bmi2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3
*/* VIDEO_CARDS: virgl
```

Decisión: sacar el binhost.
Motivo: el binhost oficial está construido para el perfil `default` (multilib). Con
`no-multilib` y CPU flags propios, la mayoría de los binarios no coinciden y Portage los
compila igual. Agrega una consulta de índice sin ahorro real, y el proyecto es aprender
compilando.

Locale:
```
en_US.UTF-8 UTF-8
es_AR.UTF-8 UTF-8
```
`eselect locale set` quedó en `es_AR.UTF-8`. Se descartaron los `ISO-8859-1`: latin-1
rompe acentos y caracteres fuera del latín; UTF-8 es el estándar.

Qué aprendí:
`ACCEPT_LICENSE` no es decorativo: Portage no instala un paquete si su licencia no está
aceptada, aunque lo pidas explícitamente. El `-*` al principio borra lo que trae el perfil
y deja ver qué se acepta de verdad. Y las licencias se pueden exceptuar por paquete en
`/etc/portage/package.license` sin aflojar la regla global.

## 2026-11-16 — Primer arranque

Qué hice:
El sistema booteó con el kernel compilado y quedó accesible por SSH.

Qué falló:
- `net.eth0 failed to start: interface eth0 does not exist`. La interfaz real es `enp1s0`
  (nombres predecibles); el enlace `net.eth0` no servía.
- La consola se quedaba en `login:` sin aceptar texto, y aparecía
  `INIT: Id "s1" respawning too fast: disabled for 5 minutes`: un getty de consola serie
  fallando en bucle.
- SSH rechazaba la conexión con `The account is locked due to 3 failed logins`. No era
  SSH sino `pam_faillock`: tres intentos fallidos bloquean la cuenta ocho minutos.

Cómo lo resolví:
```
cd /etc/init.d
ln -s net.lo net.enp1s0
rc-update add net.enp1s0 default
rc-update del net.eth0 default
/etc/init.d/net.enp1s0 start
```
Y el desbloqueo de la cuenta:
```
faillock --user ldgnu --reset
```

Verificación:
```
$ ip -br addr
enp1s0  UP  192.168.122.35/24
$ ping -c 2 gentoo.org
2 packets transmitted, 2 received
$ rc-update show default
 chronyd | default
 cronie  | default
 net.enp1s0 | default
 sshd    | default
 sysklogd | default
```

Qué aprendí:
- Los nombres predecibles obligan a que el script de netifrc se llame igual que la interfaz.
  `net.eth0` es la convención vieja.
- `pam_faillock` viene activo por defecto en Gentoo y bloquea la cuenta, no la IP.
- Tener `dhcpcd` y `net.enp1s0` en el mismo runlevel deja dos clientes DHCP peleando por la
  misma interfaz. `netifrc` ya invoca su propio cliente.

## 2026-11-16 — Versión del kernel

Qué hice:
Comparé la versión compilada contra la disponible en el árbol.

Verificación:
```
$ ls /var/db/repos/gentoo/sys-kernel/gentoo-sources/
gentoo-sources-6.1.192.ebuild
gentoo-sources-6.6.162.ebuild
gentoo-sources-6.12.117.ebuild
gentoo-sources-6.18.63.ebuild
gentoo-sources-7.3.4.ebuild
```

Decisión: quedarse en 6.18.63 por ahora.
Motivo: es la última de su serie. Actualizar a 7.3.4 implica `make oldconfig`, recompilar y
volver a probar el arranque; conviene hacerlo después del primer `@world` y con el snapshot
del disco ya tomado.

## 2026-11-16 — Primer @world y herramientas de Portage

Qué hice:
Sincronicé el árbol, instalé gentoolkit y screen, y corrí el primer update completo.

Comandos:
```
sudo emerge --sync
sudo emerge --ask app-portage/gentoolkit
sudo emerge --ask app-misc/screen
sudo emerge --update --deep --newuse @world
```

Qué falló:
- `emerge --newest-use` y `--new-use`: la bandera correcta es `--newuse`. Las otras dos no
  existen y emerge tira el usage entero.
- `eclean-dist` como usuario: `Permission denied: you must be root or belong to the portage
  group`. Va con sudo.
- `screen -S world` desde kitty: `Cannot find terminfo entry for 'xterm-kitty'`. Se resuelve
  con `TERM=xterm-256color screen -S world` o entrando con `kitty +kitten ssh`.
- `emerge app-misc/screen` sin categoría: `short ebuild name "screen" is ambiguous`. Hay que
  dar el nombre completo.

Verificación:
```
$ gcc-config -l
  [1] x86_64-pc-linux-gnu-16 *
$ ls -d /var/db/pkg/sys-libs/glibc-*
/var/db/pkg/sys-libs/glibc-2.43-r4
```

El primer `@world` fueron 18 paquetes, con `sys-devel/gcc` y `sys-libs/glibc` entre ellos.

Qué aprendí:
Actualizar gcc y glibc juntos es la operación más delicada del sistema: si se corta en el
medio, quedás sin compilador o sin libc utilizable. Se hace dentro de `screen` o `tmux`, no
en una sesión SSH suelta. Después hay que revisar `gcc-config -l` para confirmar qué versión
quedó seleccionada.

## 2026-11-16 — Kernel compilado y primer arranque

Qué hice:
Compilé el kernel a mano, instalé los módulos y el bootloader.

Comandos:
```
make -j6
make modules_install
make install
grub-install /dev/vda
```

Verificación:
```
/boot/vmlinuz-6.18.63-gentoo          20 MB
/boot/initramfs-6.18.63-gentoo.img    9.6 MB
/boot/System.map-6.18.63-gentoo       12 MB
menuentry 'Gentoo GNU/Linux' ... 6.18.63-gentoo
```

Qué falló:
- El primer `make` corrió sin `-j`: 18 minutos, 1167 objetos y load average 1.00 con seis
  hilos disponibles. Se cortó y se relanzó con `make -j6`, que retomó desde donde estaba.
- `sudo virsh snapshot-create-as` ejecutado **dentro** de la VM: `virsh: command not found`.
  `virsh` es del host; el snapshot se hace desde afuera.
- `grub-install /dev/vda2` y `grub-install /boot/` fallaron: el primero por blocklists, los
  otros dos porque un directorio no es un dispositivo.

Qué aprendí:
`make install` con `installkernel` en `USE="dracut grub"` genera el initramfs y corre
`grub-mkconfig` solo. Lo único manual es `grub-install` en el disco.
Y un `make` sin `-j` en un kernel se nota: 1167 objetos en 18 minutos es un proceso por vez.

## 2026-11-17 — Instalación en hardware: corte de estado

Qué hice:
Instalé el stage3 openrc del 2026-11-15 en el NVMe, sincronicé el árbol de Portage,
instalé `mirrorselect` y `screen`, y ajusté `make.conf` con `-march=native`, `-j8` y los
mirrors. Después audité el sistema completo desde el live, sin modificar nada.

Verificación:
```
nvme0n1p1   1 GiB   vfat   /mnt/gentoo/efi
nvme0n1p2   16 GiB  swap   activa
nvme0n1p3   100 GiB ext4   /mnt/gentoo
nvme0n1p4   360 GiB ext4   /mnt/gentoo/home

/var/db/pkg: 297 paquetes
/boot: vacío
/usr/src: vacío
/etc/fstab: plantilla del stage3, sin entradas activas
```

Qué falló:
- El primer mirror de `GENTOO_MIRRORS` (`gentoo.zero.com.ar`) no resuelve por DNS; el
  fetch de `screen` siguió con `gentoo.c3sl.ufpr.br`.
- `emerge screen` sin categoría: nombre ambiguo. Va `app-misc/screen`.
- No hay historial de shell dentro del chroot, así que la cronología se reconstruyó con
  mtime y `emerge.log`.

Qué aprendí:
El esquema real no coincide con `hardware.md`: la ESP es de 1 GiB, hay swap de 16 GiB y
home de 360 GiB, y no hay LUKS. El fstab y el `grub-install` del repo son de la VM y no
sirven acá. El detalle está en `auditorias/instalacion-hardware-2026-11-17.md`.

## 2026-11-17 — Segundo @world completo (61 paquetes)

Qué hice:
Dejé corriendo `emerge --ask --verbose --update --deep --newuse @world` en el chroot y
esperé a que terminara. Mientras tanto armé el registro automático de la instalación y las
capturas de pantalla.

Verificación:
```
Jobs: 61 of 61 complete    Load avg: 3.58, 4.56, 4.26
...
Regenerating GNU info directory index...
Processed 102 info files.
```

El total de paquetes pasó de 297 a 298: fueron 61 actualizaciones, no instalaciones nuevas.

Mensajes que importan:
```
* Unable to find kernel sources at /usr/src/linux          (normal: falta el kernel)
* After upgrading glibc, please restart all running processes.
* Make sure you run 'hash -r' in your active shells.
* The mesg/wall/write tools have been disabled due to USE=-tty-helpers.
```

Qué falló:
Nada. El único aviso con consecuencia real es el de glibc: hay que reiniciar procesos (o
directamente reiniciar), y como el chroot usa el glibc del live hasta que se reinicia, no
conviene confiar en el entorno para compilar el kernel. La salida quedó en
`docs/capturas/20261117T191021Z-detalle-emerge-fin.jpg`.

Qué aprendí:
`emerge` dentro de `arch-chroot` corre en un namespace de PID aparte: desde el live no se
ve con `pgrep`, solo con `nsenter -t <pid del chroot> -p -m -- ps`. Por eso el intento de
18:30:19 parecía colgado cuando en realidad estaba compilando.

## 2026-11-17 — Kernel manual, GRUB y red

Qué hice:
Compilé `gentoo-sources-6.18.63` a mano con `make && make modules_install && make install`,
instalé `installkernel` con `dracut` y `grub`, escribí el `/etc/fstab` real, puse hostname
`endymion`, zona horaria `America/Argentina/Cordoba`, locales `en_US` y `es_AR`, teclado
`la-latin1`, contraseña de root, y configuré `net.eno1` por DHCP con `sshd`.

Verificación:
```
6.18.63-gentoo-gentoo-dist (root@livecd) #1 SMP PREEMPT_DYNAMIC
/boot/vmlinuz-6.18.63-gentoo-gentoo-dist          28 MB
/boot/initramfs-6.18.63-gentoo-gentoo-dist.img   9,4 MB (zstd)
/lib/modules/6.18.63-gentoo-gentoo-dist           189 módulos
/efi/EFI/Gentoo/grubx64.efi                       167 KB
Boot0000* Gentoo  HD(1,GPT,7bb9c7f1-…)/\EFI\Gentoo\grubx64.efi
```

Qué falló:
Nada durante la compilación. El hueco fue de registro: la sesión de chroot donde se compiló
no tenía cargado `/root/.bashrc`, así que esos comandos no quedaron en `comandos.md`.
El rastro sí está en `emerge.log`, en los mtimes y en las capturas.

Qué aprendí:
El nombre `…-gentoo-dist` sale de `CONFIG_LOCALVERSION`, no de haber usado un binario
oficial. Por eso `/usr/src/linux` y `/lib/modules` no se llaman igual. El detalle completo
está en `auditorias/instalacion-hardware-2026-11-17.md` §10.
