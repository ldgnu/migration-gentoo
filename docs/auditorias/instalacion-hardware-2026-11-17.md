# Auditoría de la instalación en hardware — 2026-11-17

Auditoría de solo lectura del sistema que se está instalando en el NVMe, hecha desde el
live USB. El corte original es **2026-11-17 18:15 UTC**; el §10 agrega la verificación del
**2026-11-17 20:40 UTC**, después de compilar el kernel e instalar GRUB. No se modificó nada
durante el relevamiento.

La auditoría no reemplaza a `bitacora.md`: la bitácora cuenta lo que se hizo, esto cuenta
**lo que hay**. Cuando las dos no coinciden, la diferencia es un hallazgo.

## Veredicto

_(Actualizado al 2026-11-17 20:40 UTC. El veredicto original del corte de 18:15 está al
final de esta sección.)_

El sistema **ya es arrancable**: kernel `6.18.63-gentoo-gentoo-dist`, módulos, initramfs,
fstab real, GRUB en la ESP y entrada UEFI `Gentoo` primera en el orden de arranque. Falta
el usuario cotidiano (solo existe `root`), `sudo`/`doas` y el escritorio. No se probó el
arranque real todavía.

Veredicto original (18:15 UTC): el sistema base estaba extraído, sincronizado y con
`make.conf` propio, pero **todavía no era arrancable**: no había kernel, módulos ni
bootloader, y `/etc/fstab` seguía siendo la plantilla del stage3. Faltaban además
identidad, locale, zona horaria, contraseña de root, usuario y red.

El trabajo de documentación está en un clon del repo dentro del live, en RAM. Si se apaga
sin copiarlo o sin hacer `push`, se pierde.

## 1. Contexto de ejecución

| Dato | Valor |
|---|---|
| Live | Gentoo LiveGUI `gentoo-amd64-livegui` del 2026-09-14 |
| Kernel del live | `7.2.5-gentoo-dist` |
| Arranque | UEFI, Secure Boot desactivado (`SecureBoot=0`) |
| Medio | Ventoy en un Kingston DataTraveler (dos entradas UEFI en el firmware) |
| CPU | Intel Core i5-10400F, 6c/12t, Comet Lake |
| RAM | 15 GiB |
| GPU | AMD Radeon RX 6600 (Navi 23) |
| Red | Intel I219-V, interfaz **`eno1`** |
| Disco destino | WD PC SN740 512 GB, `nvme0n1` |

El live arrancó a las 04:43 UTC del 2026-11-17 (`uptime -s`) y sigue encendido. La sesión
de chroot se abrió a las 17:55 UTC.

## 2. Discos y particiones reales

### 2.1 Disco destino: `nvme0n1`

| Partición | Tamaño | Tipo | FS | Label | UUID | Montaje actual |
|---|---:|---|---|---|---|---|
| `nvme0n1p1` | 1 GiB | EF00 (ESP) | vfat | — | `CBD5-7071` | `/mnt/gentoo/efi` |
| `nvme0n1p2` | 16 GiB | 8200 (swap) | swap | — | `a843caf6-6f1e-4712-b151-b3e275149399` | activa |
| `nvme0n1p3` | 100 GiB | 8300 | ext4 | `root` | `f58fb93f-1681-423f-a6f2-ce6a6e8d9752` | `/mnt/gentoo` |
| `nvme0n1p4` | 359.9 GiB | 8300 | ext4 | `home` | `43f0b8b6-4345-4494-b4b9-5c5be26f7e6b` | `/mnt/gentoo/home` |

No hay LUKS ni btrfs. El disco está 100 % particionado (quedan 327 KiB libres). La ESP está
vacía y `/boot` también: el kernel irá dentro de la raíz, no en una partición aparte.

### 2.2 Otros discos (no tocar)

| Disco | Tamaño | Contenido | Estado |
|---|---:|---|---|
| `sda` | 465.8 GB | NTFS `PirateGames` | sin montar |
| `sdb` | 931.5 GB | exFAT `PirateNW` | sin montar |
| `sdc` | 111.8 GB | Windows: ESP 260 MiB, MSR 128 MiB, NTFS `ProducerWin` | sin montar |

La entrada UEFI `Windows Boot Manager` apunta a la ESP de **`sdc1`**
(`PARTUUID=da44bdcc-d79a-462b-b504-7859cc1d199d`), no a la del NVMe. La ESP del NVMe está
libre para Gentoo. El orden de arranque actual es Windows primero; no hay ninguna entrada
Gentoo todavía.

## 3. Esquema real contra el esquema documentado

`docs/hardware.md` describe el disco antes de reparticionar. Ya no coincide.

| Tema | Documentado en el repo | Real el 2026-11-17 | Impacto |
|---|---|---|---|
| ESP | `nvme0n1p1`, 4 GB | `nvme0n1p1`, 1 GiB | El tamaño cambió; no es un problema, pero invalida la tabla |
| Raíz | 472 GB LUKS + btrfs (CachyOS) | 100 GB ext4, sin cifrado | Cambia fstab, kernel, espacio de build y decisión de seguridad |
| Swap | no figura en el esquema nuevo | 16 GB, `nvme0n1p2` | Falta en fstab |
| Home | no figura | 359.9 GB ext4, `nvme0n1p4` | Falta en fstab |
| `/boot` | `configs/etc/fstab` espera `LABEL=boot` en partición aparte | `/boot` es un directorio dentro de la raíz | El fstab del repo no sirve para esta máquina |
| ESP montada en | no está claro | `/efi` | `grub-install` debe usar `--efi-directory=/efi` |
| Red | ejemplos con `enp1s0` / `eth0` | `eno1` | `net.enp1s0` no existe; el servicio correcto es `net.eno1` |
| Alcance | `README.md`: servidor sin entorno gráfico | `hardware.md`: i3, Xorg, kitty, audio, GPU | Hay que decidir si es servidor o escritorio antes de fijar USE y perfil |

## 4. Cronología reconstruida

No hay historial de shell dentro del chroot (`/root/.bash_history` está vacío), así que la
cronología sale de mtime, de `emerge.log` y de los procesos vivos.

| Fecha/hora UTC | Hecho | Evidencia |
|---|---|---|
| 2026-11-15 17:34 | Descarga del stage3 `20261115T170104Z` | mtime del `.tar.xz` |
| 2026-11-15 18:01 | Firma y hash junto al tarball | `.asc` y `.sha256` |
| 2026-11-15 (sin hora exacta) | Extracción y perfil por defecto | árbol con enlaces `bin -> usr/bin`, `lib -> usr/lib` |
| 2026-11-17 04:43 | Arranque del live actual | `uptime -s`, inicio del PID 1 |
| 2026-11-17 17:55 | Apertura del chroot | proceso `arch-chroot /mnt/gentoo/` |
| 2026-11-17 18:00 | Edición de `repos.conf` | mtime |
| 2026-11-17 18:04:28 | `emerge --sync` | `emerge.log` |
| 2026-11-17 18:07:08 | Instalación de `mirrorselect` | `emerge.log` |
| 2026-11-17 18:09:31 | Edición de `make.conf` | mtime |
| 2026-11-17 18:10:51 | `emerge screen` falla por nombre ambiguo | `emerge.log` |
| 2026-11-17 18:11:17 | Instalación de `app-misc/screen` | `emerge.log` |
| 2026-11-17 18:11 | Descarga de `screen` con caída del primer mirror | `emerge-fetch.log` |

La extracción del stage3 no se puede fechar con precisión: los mtime del árbol vienen del
tarball, no del momento de extracción. Lo que sí está comprobado es que el árbol está
extraído, con propietario `root:root` y enlaces de `usr-merge` correctos.

## 5. Estado detallado del sistema instalado

### 5.1 Lo que está hecho

| Elemento | Estado | Evidencia |
|---|---|---|
| Stage3 openrc amd64 | extraído | `stage3-amd64-openrc-20261115T170104Z.tar.xz` presente |
| Firma/hash del stage3 | archivos presentes | `.asc` + `.sha256` junto al tarball |
| Árbol Portage | sincronizado | `var/db/repos/gentoo`, timestamp `2026-11-17T17:27:34Z` |
| Perfil | `default/linux/amd64/23.0` (multilib) | symlink `make.profile` |
| `make.conf` | configurado | `-march=native`, `-j8 -l12`, mirrors, licencias |
| Paquetes instalados | 297 | `var/db/pkg` |
| Instalaciones manuales | 4 + 1 dependencia | `netselect`, `dialog`, `mirrorselect`, `screen`, `acct-group/utmp` |
| Swap | activa ahora | `swapon --show` |
| Montajes | raíz, home y ESP | `findmnt` |
| `resolv.conf` | existe copia real en la raíz | inodo en `nvme0n1p3`, 79 bytes |

Contenido actual de `/etc/portage/make.conf`:

```
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

MAKEOPTS="-j8 -l12"
EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=12"

LC_MESSAGES=C.UTF-8
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

GENTOO_MIRRORS="https://gentoo.zero.com.ar/gentoo/ \
    https://gentoo.c3sl.ufpr.br/ \
    https://br.mirrors.cicku.me/gentoo/ \
    https://umbriel.br.ext.planetunix.net/pub/gentoo/ \
    https://elmirror.cl/gentoo/"
```

### 5.2 Lo que falta o está incompleto

| Elemento | Estado real | Consecuencia |
|---|---|---|
| `/etc/fstab` | plantilla original del stage3, sin entradas activas | Al reiniciar no se montan raíz, home, ESP ni swap |
| Hostname | `/etc/hostname` no existe; `conf.d/hostname` dice `localhost` | El sistema arranca como `localhost` |
| Locale | `locale.gen` todo comentado; `LANG=C.UTF-8` en `env.d/02locale` | Sin locale generado; acentos y ordenamiento roto |
| Zona horaria | `/etc/localtime -> Factory` | Hora local incorrecta |
| Contraseña de root | `root:*` (bloqueada) | No se puede iniciar sesión como root |
| Usuarios | ninguno con UID ≥ 1000 | Sin cuenta de trabajo |
| Red | sin `conf.d/net` ni `net.eno1`; `dhcpcd` y `netifrc` instalados | Sin red al arrancar |
| Servicios | solo `local` y `netmount` en `default` | Sin sshd, cron, syslog ni chrony |
| Fuentes del kernel | `/usr/src` vacío | No hay kernel que compilar |
| Kernel y módulos | `/boot` vacío, `/lib/modules` vacío | No arranca |
| Bootloader | `sys-boot/grub` y `efibootmgr` no instalados; ESP vacía | No arranca |
| Entrada UEFI Gentoo | no existe; solo Windows y el USB | El firmware no sabe que hay Gentoo |
| `package.use` | directorio vacío | Sin `CPU_FLAGS_X86`, sin `VIDEO_CARDS`, sin `installkernel` |
| `package.license` | no existe en el sistema | El repo tiene uno, pero no está aplicado |
| Servicios de red | sin `net.eno1` | `net.enp1s0` del repo no aplica |

## 6. Hallazgos priorizados

### P0 — impiden arrancar o ponen en riesgo el trabajo

**H-01. El sistema no es arrancable.**
No hay kernel, módulos ni bootloader. `/boot` y la ESP están vacíos, `/usr/src` también.
Cualquier reinicio deja el sistema en el live. Es el bloqueante principal.

**H-02. `/etc/fstab` es la plantilla del stage3.**
No tiene ni una entrada activa para `root`, `home`, `swap` ni `/efi`. Aunque hubiera kernel,
OpenRC no montaría la raíz ni el home correctamente. Hay que escribirlo con los UUID reales
de la sección 2.1.

**H-03. Identidad, locale, zona horaria y credenciales están sin configurar.**
`hostname` ausente, `locale.gen` vacío, `localtime -> Factory`, `root:*` bloqueada y sin
usuarios. Un arranque exitoso terminaría en un sistema sin login utilizable.

**H-04. No hay configuración de red para el sistema instalado.**
`dhcpcd` y `netifrc` están instalados, pero no existe `/etc/conf.d/net` ni el enlace
`/etc/init.d/net.eno1`. La interfaz real es `eno1`; los ejemplos del repo usan `enp1s0`.

**H-05. El trabajo del repo vive en RAM.**
El clon está en `/tmp/opencode/qwertoo`, sobre el overlay del live. No está en el NVMe ni
en GitHub. Un apagado o un cuelgue del live lo borra. Hay que copiarlo al disco instalado
y/o hacer `commit` + `push` antes de seguir.

### P1 — errores probables si se sigue con la documentación actual

**H-06. `docs/hardware.md` describe otro particionado.**
Habla de una ESP de 4 GB y de CachyOS en 472 GB con LUKS/btrfs. La realidad es 1 GiB de ESP,
16 GiB de swap, 100 GiB de raíz ext4 y 360 GiB de home, sin cifrado. Quien siga la guía al
pie de la letra va a escribir un fstab y un `grub-install` que no corresponden.

**H-07. Los archivos de `configs/` son de la VM, no de esta máquina.**
`configs/etc/fstab` usa `LABEL=boot` en una partición que acá no existe;
`configs/etc/portage/make.conf` tiene `-march=skylake` y `-j6`;
`configs/etc/portage/package.use/00video_cards` dice `VIDEO_CARDS: virgl` (GPU virtual);
`configs/net-services.txt` lista `net.enp1s0` y `net.eth0`. Ninguno se puede aplicar tal
cual. El `sync-configs.sh` actual, además, está pensado para copiar por SSH desde la VM.

**H-08. El kernel del repo es solo para la VM.**
`configs/kernel/config-linux-6.18.63-gentoo` tiene `CONFIG_VIRTIO_BLK=y` y no tiene
`CONFIG_E1000E`, `CONFIG_DRM_AMDGPU`, `CONFIG_VFAT_FS`, `CONFIG_SND_USB_AUDIO`,
`CONFIG_NTFS3_FS`, `CONFIG_EXFAT_FS` ni `CONFIG_BT_HCIBTUSB`. Reutilizarlo en el hardware
dejaría el sistema sin red, sin GPU, sin audio USB y sin poder leer los discos de datos.
En esta máquina hay que partir del config del live (`/proc/config.gz`) y revisar.

**H-09. El bootloader tiene tres particularidades que el repo no contempla.**
No hay partición `/boot` separada; la ESP se monta en `/efi`; y la entrada de Windows vive
en la ESP de `sdc`, no en la del NVMe. El comando correcto es
`grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo`, y después
hay que verificar con `efibootmgr` que la entrada de Windows siga intacta.

**H-10. El alcance del proyecto está contradictorio.**
`README.md` dice "servidor, sin entorno gráfico"; `hardware.md` planifica i3, Xorg, kitty,
dmenu, PipeWire y Bluetooth. Eso cambia perfil, USE flags, servicios y kernel. Hay que
decidirlo antes de instalar el escritorio, no después.

**H-11. El primer mirror no resuelve.**
`gentoo.zero.com.ar` falla por DNS (`Name or service not known`) y devuelve `000` por HTTPS.
En el fetch de `screen` Portage pasó al segundo mirror y funcionó. Cada descarga pierde
tiempo en el primero. Conviene reordenar o sacarlo de `GENTOO_MIRRORS`.

**H-12. Faltan USE flags de CPU y GPU.**
`-march=native` solo afecta al compilador. No hay `CPU_FLAGS_X86` ni `VIDEO_CARDS` en
`package.use`, así que paquetes como `ffmpeg`, `mesa` o `pipewire` no reciben los flags
del hardware. En la VM se usó `virgl`; acá corresponde `amdgpu radeonsi`.

**H-13. El disco nuevo no tiene cifrado, y eso no está documentado como decisión.**
El esquema anterior (CachyOS) era LUKS + btrfs. El nuevo es ext4 sin LUKS. Puede ser
deliberado, pero `decisiones.md` no lo registra y el README no lo menciona. Si se esperaba
cifrado en reposo, ya no es trivial agregarlo sin reinstalar.

**H-14. El binhost está configurado pero inactivo.**
`/etc/portage/binrepos.conf/gentoo.conf` existe, pero `make.conf` no tiene
`FEATURES=getbinpkg`. Con `-march=native` y USE flags propios, el binario oficial puede no
coincidir; hay que decidir si se usa para paquetes grandes o se deja apagado. Hoy no hace
nada, pero confunde.

### P2 — higiene y documentación

**H-15. Quedan 277 MB de stage3 en la raíz del sistema instalado.** No molesta para
arrancar, pero conviene borrarlo después del primer boot.

**H-16. README, índice y `retomar.md` siguen describiendo la VM.** El checklist de hardware
tiene los pasos 32–39 sin marcar, aunque el 31 (relevar hardware) y buena parte del 33–35
ya están hechos. `retomar.md` habla de `vda` y de la VM.

**H-17. No hay historial de comandos dentro del chroot.** `/root/.bash_history` está vacío.
La auditoría se pudo reconstruir por logs, pero se pierde el detalle de qué se tipeó. Para
la próxima etapa conviene activar historial con marca de tiempo o registrar en la bitácora
a medida que se hace.

**H-18. La swap no está en fstab.** Hoy está activa porque se activó a mano. Si no se agrega
la entrada, el próximo arranque no la usa.

**H-19. Los discos de datos no están montados ni tienen entrada en fstab.** `sda` (NTFS) y
`sdb` (exFAT) no se tocan. Si se quieren montar al inicio, hacen falta `ntfs3`/`exfat` en el
kernel y entradas con `nofail`, idealmente por UUID.

**H-20. `/etc/resolv.conf` está tapado por un bind mount del live.** La copia real existe en
la raíz (inodo en `nvme0n1p3`, 79 bytes), pero el archivo visible ahora es el del live.
Antes de reiniciar hay que confirmar que la copia de disco tenga nameservers válidos.

## 7. Plan de continuación

### Paso 0 — Asegurar el repo

Antes de tocar nada:

```
cd /tmp/opencode/qwertoo
git status
git add docs/auditoria-instalacion-hardware.md
git commit -m "docs: auditoría del estado real de la instalación en hardware"
git push
```

Si no se quiere hacer `push` ahora, copiar el repo al disco instalado:

```
sudo mkdir -p /mnt/gentoo/home/qwertoo
sudo cp -a /tmp/opencode/qwertoo/. /mnt/gentoo/home/qwertoo/
```

Cualquiera de las dos cosas evita perder la documentación al apagar el live.

### Paso 1 — Completar la base

Dentro del chroot (`arch-chroot /mnt/gentoo`):

```
# fstab
cat > /etc/fstab <<'EOF'
UUID=f58fb93f-1681-423f-a6f2-ce6a6e8d9752  /      ext4  defaults,noatime  0 1
UUID=43f0b8b6-4345-4494-b4b9-5c5be26f7e6b  /home  ext4  defaults,noatime  0 2
UUID=CBD5-7071                             /efi   vfat  umask=0077        0 2
UUID=a843caf6-6f1e-4712-b151-b3e275149399  none   swap  sw                0 0
EOF
findmnt --verify

# hostname
echo qwertoo > /etc/hostname

# locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/; s/^#es_AR.UTF-8/es_AR.UTF-8/' /etc/locale.gen
locale-gen
eselect locale set es_AR.UTF-8
env-update && . /etc/profile

# zona horaria (ajustar la ciudad si corresponde)
echo 'America/Argentina/Buenos_Aires' > /etc/timezone
emerge --config sys-libs/timezone-data

# root y usuario
passwd root
emerge --ask app-admin/sudo
useradd -m -G users,wheel,audio,video,usb,portage -s /bin/bash ldgnu
passwd ldgnu
```

Habilitar `wheel` en `sudo` con `visudo` (descomentar `%wheel ALL=(ALL:ALL) ALL`).

### Paso 2 — Red y servicios

```
ln -s net.lo /etc/init.d/net.eno1
printf 'config_eno1="dhcp"\n' > /etc/conf.d/net
rc-update add net.eno1 default

emerge --ask net-misc/chrony app-admin/sysklogd sys-process/cronie app-portage/gentoolkit
rc-update add sshd default
rc-update add chronyd default
rc-update add sysklogd default
rc-update add cronie default
```

No agregar `dhcpcd` al runlevel `default`: `netifrc` ya levanta su propio cliente. Tener los
dos fue el problema documentado en la VM.

### Paso 3 — USE flags y bootloader

```
# CPU flags reales
emerge --ask app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

# GPU real (RX 6600)
echo '*/* VIDEO_CARDS: amdgpu radeonsi' > /etc/portage/package.use/00video_cards

# installkernel + grub
echo 'sys-kernel/installkernel dracut grub' > /etc/portage/package.use/installkernel
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

emerge --ask sys-boot/grub sys-boot/efibootmgr sys-kernel/dracut sys-kernel/linux-firmware
```

`sys-kernel/linux-firmware` es necesario para `amdgpu` y para el adaptador Bluetooth.

### Paso 4 — Kernel

```
emerge --ask sys-kernel/gentoo-sources
eselect kernel set 1
cd /usr/src/linux

zcat /proc/config.gz > .config
make olddefconfig
make localmodconfig
make nconfig
```

En `nconfig`, dejar en `=y` lo que hace falta antes de montar la raíz, y en `=m` lo que
puede cargarse después. La lista mínima para esta máquina:

```
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_BLK_DEV_NVME=y
CONFIG_NVME_CORE=y
CONFIG_EXT4_FS=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_VFAT_FS=y
CONFIG_FAT_FS=y
CONFIG_FB_EFI=y
CONFIG_DRM=y
CONFIG_DRM_AMDGPU=y
CONFIG_DRM_AMD_DC=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_HID=y
CONFIG_HID_GENERIC=y
CONFIG_INPUT_EVDEV=y
CONFIG_SATA_AHCI=y
CONFIG_E1000E=y

CONFIG_SND=m
CONFIG_SND_HDA_INTEL=m
CONFIG_SND_USB_AUDIO=m
CONFIG_NTFS3_FS=m
CONFIG_EXFAT_FS=m
CONFIG_BT=m
CONFIG_BT_HCIBTUSB=m
```

`localmodconfig` toma como referencia los módulos del kernel del live. Eso sirve para el
hardware presente, pero **no** para `NTFS3`, `EXFAT` y Bluetooth si no están cargados en ese
momento: hay que habilitarlos a mano. `VFAT` lo usa la ESP y conviene dejarlo en `=y`.

Compilar e instalar:

```
make -j8
make modules_install
make install
```

Con `installkernel` en `USE="dracut grub"` se genera el initramfs y se actualiza GRUB. Si
`make install` no corre `grub-mkconfig`, hacerlo en el paso siguiente.

### Paso 5 — Bootloader

```
grub-install --target=x86_64-efi \
  --efi-directory=/efi \
  --bootloader-id=Gentoo \
  --recheck

grub-mkconfig -o /boot/grub/grub.cfg
efibootmgr -v
```

Verificar en `efibootmgr -v`:

- que exista una entrada `Gentoo` en la ESP del NVMe;
- que `Windows Boot Manager` siga apuntando a `sdc1`;
- que el orden de arranque tenga a Gentoo primero si se quiere arrancar sin elegir en el
  firmware.

Si se quiere que GRUB liste Windows, instalar `sys-boot/os-prober` y poner
`GRUB_DISABLE_OS_PROBER=false` en `/etc/default/grub`.

### Paso 6 — Primer arranque y verificación

```
reboot
```

Al entrar:

```
findmnt / /home /efi
swapon --show
ip -br addr
ping -c 2 gentoo.org
date
locale
rc-status
```

Se espera: raíz y home montados, swap activa, `eno1` con IP, DNS funcionando, fecha local
correcta, locale `es_AR.UTF-8`, servicios `sshd`, `chronyd`, `sysklogd`, `cronie` y
`net.eno1` en `default`.

### Paso 7 — Actualizar la documentación

- Reescribir la tabla de discos de `hardware.md` con el esquema real (1G/16G/100G/360G).
- Corregir `configs/etc/fstab`, `configs/etc/portage/make.conf` y `package.use` con lo que
  quede realmente en el sistema.
- Marcar en `indice.md` los pasos 32–35 y agregar el estado real del 36–37.
- Agregar a `bitacora.md` las entradas del 2026-11-15 (stage3) y 2026-11-17 (sync,
  mirrorselect, screen) con los errores reales.
- Adaptar `scripts/sync-configs.sh`: hoy copia por SSH desde la VM; para hardware conviene
  que lea directo de `/mnt/gentoo` o que acepte un destino local.
- Decidir y registrar: servidor o escritorio, multilib o no-multilib, LUKS o sin LUKS,
  binhost sí o no.

## 8. Verificación rápida del estado actual

Comandos de solo lectura usados para esta auditoría, por si hay que repetirla:

```
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID,MOUNTPOINTS
sgdisk -p /dev/nvme0n1
blkid /dev/nvme0n1p1 /dev/nvme0n1p2 /dev/nvme0n1p3 /dev/nvme0n1p4
efibootmgr -v
findmnt /mnt/gentoo /mnt/gentoo/home /mnt/gentoo/efi
swapon --show
ls -la /mnt/gentoo/boot /mnt/gentoo/efi /mnt/gentoo/usr/src
cat /mnt/gentoo/etc/fstab
readlink -f /mnt/gentoo/etc/localtime
find /mnt/gentoo/var/db/pkg -mindepth 2 -maxdepth 2 -type d | wc -l
tail -100 /mnt/gentoo/var/log/emerge.log
```

## 9. Limitaciones de esta auditoría

- No hay historial de shell del chroot; la cronología es inferida de logs y mtime.
- No se verificó criptográficamente el stage3 en esta máquina. Están el `.asc` y el
  `.sha256`, y la bitácora de la VM registra la verificación del mismo build, pero no quedó
  registro de haber corrido `gpg --verify` acá.
- No se probó ningún arranque: no hay kernel todavía.
- No se inspeccionó el contenido de los discos `sda`, `sdb` ni `sdc`; solo su tabla de
  particiones y tipo de filesystem.
- Las direcciones IP de la red local se omiten a propósito, según las reglas del repo.

## 10. Verificación de arranque — 2026-11-17 20:40 UTC

Segunda pasada, ya con kernel y bootloader instalados. Todo verificado desde el live, sin
reiniciar.

### 10.1 Kernel y módulos

| Dato | Valor |
|---|---|
| Fuente | `sys-kernel/gentoo-sources-6.18.63`, `/usr/src/linux` → `linux-6.18.63-gentoo` |
| Release | `6.18.63-gentoo-gentoo-dist` (`CONFIG_LOCALVERSION="-gentoo-dist"`) |
| Compilado | `#1 SMP PREEMPT_DYNAMIC Tue Nov 17 17:17:07 -03 2026`, gcc 16.2.1 |
| Instalado | 20:28 UTC |
| Módulos | `/lib/modules/6.18.63-gentoo-gentoo-dist`, 189 `.ko`, `modules.dep` presente |
| Initramfs | `dracut-112`, 9,4 MB, compresión zstd; kernel con `CONFIG_RD_ZSTD=y` |
| Microcódigo | `amd-uc.img` 306 KB, cargado antes del initramfs en GRUB |
| Firmware | `linux-firmware-20261019`, 699 archivos en `amdgpu/` |

Opciones del kernel que importan para este hardware, todas presentes:

```
CONFIG_BLK_DEV_NVME=y      CONFIG_EXT4_FS=y        CONFIG_VFAT_FS=y
CONFIG_EFI_STUB=y          CONFIG_DEVTMPFS_MOUNT=y CONFIG_EFIVAR_FS=y
CONFIG_DRM_AMDGPU=y        CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_E1000E=y            CONFIG_SND_HDA_INTEL=y  CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_USB_XHCI_HCD=y      CONFIG_USB_HID=y        CONFIG_INPUT_EVDEV=y
CONFIG_NTFS3_FS=m          CONFIG_EXFAT_FS=m       CONFIG_BT_HCIBTUSB=m
```

No hay firma de módulos (`CONFIG_MODULE_SIG` vacío) ni módulos comprimidos: 189 `.ko`
planos, así que no hay riesgo de que el kernel rechace un módulo.

### 10.2 Arranque

| Pieza | Estado |
|---|---|
| `/etc/fstab` | real: root, home, `/efi` y swap por UUID; `/boot` vive dentro de root, sin entrada propia |
| GRUB | `grub-2.16-r1`, `grubx64.efi` de 167 KB en `/efi/EFI/Gentoo/` |
| Entrada UEFI | `Boot0000 Gentoo` apunta a la partición 1 correcta (`PARTUUID 7bb9c7f1-…`) |
| Orden de arranque | `0000,0008,000A,000B`: Gentoo primero, Windows intacto |
| Secure Boot | desactivado (`SecureBoot=0`, `SetupMode=0`) |
| `grub.cfg` | `search --fs-uuid`, `root=UUID=f58fb93f-…`, `initrd amd-uc.img initramfs…`, timeout 5 |

### 10.3 Identidad, red y servicios

- Hostname `endymion` (`/etc/hostname`, `conf.d/hostname` y `/etc/hosts`).
- Zona horaria `America/Argentina/Cordoba`, `clock="UTC"` en `conf.d/hwclock`.
- `LANG=es_AR.utf8`; `en_US.utf8` y `es_AR.utf8` generados en `locale-archive`.
- Teclado `la-latin1`.
- `root` con clave; **no hay ningún usuario UID≥1000** y el grupo `wheel` solo tiene a root.
- Red: `config_eno1="dhcp"`, `net.eno1` y `sshd` en `default`; `dhcpcd` instalado.
- Claves de host SSH ausentes todavía: las genera el propio servicio al arrancar.
- 322 paquetes instalados; 7 noticias de Portage sin leer; `--depclean` pendiente.

### 10.4 Hallazgos nuevos

1. **No hay usuario cotidiano.** Se puede entrar como root por tty1, pero falta crear el
   usuario, agregarlo a `wheel` y decidir `sudo`/`doas` (ninguno está instalado).
2. **Sin respaldo de arranque en la ESP.** Solo existe `EFI/Gentoo/grubx64.efi`. Si se
   borra la entrada NVRAM, el firmware no encuentra nada. Conviene copiar el binario a
   `EFI/BOOT/BOOTX64.EFI` como red de seguridad.
3. **Doble entrada de localhost en `/etc/hosts`.** Inofensivo, pero el archivo quedó con la
   línea original y la agregada al final.
4. **`hwclock` en UTC con Windows instalado.** Si Windows usa hora local, cada arranque
   cruzado mueve el reloj. No afecta el arranque de Gentoo.
5. **`ACCEPT_KEYWORDS="~amd64"` global** y `VIDEO_CARDS` sin definir en `make.conf`.
   Ninguna de las dos frena el arranque, pero la segunda va a hacer falta para el escritorio.
6. **Hueco en el historial de comandos.** `docs/estado/comandos.md` se corta a las 19:37:
   la sesión de chroot donde se compiló el kernel y se instaló GRUB no tenía cargado
   `/root/.bashrc`. El rastro quedó igual en `emerge.log` y en los cambios de archivos, y
   las capturas cubren ese tramo.
7. **`/usr/src/linux` apunta a `linux-6.18.63-gentoo` mientras el release instalado es
   `…-gentoo-dist`.** Es correcto (`LOCALVERSION`), pero explica por qué los nombres no
   coinciden.

### 10.5 Pendientes antes de reiniciar

- Decidir si se crea el usuario ahora o después del primer arranque.
- Opcional: `cp /efi/EFI/Gentoo/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI`.
- Anotar en la bitácora el resultado del primer arranque real, con `dmesg` si algo falla.
