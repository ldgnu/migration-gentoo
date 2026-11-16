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
