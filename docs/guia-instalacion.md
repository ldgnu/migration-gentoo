# Guía definitiva — Gentoo en el escritorio (bare metal)

Una sola página, en orden, para ejecutar de arriba abajo sin abrir el handbook.
Hardware: i5-10400F · RX 6600 (Navi 23) · NVMe WD SN740 512 GB · UEFI sin Secure Boot ·
Intel GbE · audio HDA Intel + HDMI · BT TP-Link USB.

> **Regla de oro**: cada bloque se ejecuta y se verifica. Si un `echo $?` no da 0, no se
> avanza. Un paso que "parece que anduvo" es el que rompe en el reboot.

**Convenciones**: `(live)` = consola del USB · `(chroot)` = dentro de `/mnt/gentoo` ·
`(target)` = sistema ya booteado desde el disco.

---

## Resumen del recorrido

| # | Etapa | Dónde | Tiempo |
|---|---|---|---|
| 0 | Rescate de lo que hay en el disco | live actual | 10 min |
| 1 | Arranque del live y verificación del disco | live | 10 min |
| 2 | Particionado y formateo | live | 5 min |
| 3 | Stage3 y `make.conf` | live | 15 min |
| 4 | Chroot, perfil, `@world` | chroot | 30–60 min |
| 5 | Kernel a mano + dracut | chroot | 40 min |
| 6 | `fstab`, hostname, red, usuarios | chroot | 15 min |
| 7 | GRUB UEFI | chroot | 5 min |
| 8 | Primer arranque | target | 10 min |
| 9 | Escritorio (Xorg+i3 **o** Sway/Wayland §9-bis) | target | 60 min |
| 10 | Audio y Bluetooth | target | 30 min |
| 11 | Limpieza y verificación final | target | 10 min |

---

## 0. Rescate (antes de tocar el disco)

El `nvme0n1` es el destino: lo que esté ahí se pierde. Montá **otro** disco y guardá:

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT
sudo mkdir -p /mnt/rescate && sudo mount /dev/sdb1 /mnt/rescate
sudo chown $USER /mnt/rescate
R=/mnt/rescate/qwertoo-$(date +%F); mkdir -p $R
sudo cp /proc/config.gz $R/config-viejo.gz       # mejor base posible para el kernel nuevo
sudo cp -a /var/lib/tailscale/ $R/tailscale/     # IP Tailscale + subnet router
lspci -nnk > $R/lspci.txt
lsusb     > $R/lsusb.txt
lsmod     > $R/lsmod.txt
docker ps -a > $R/docker-ps.txt 2>/dev/null; docker volume ls > $R/docker-vols.txt 2>/dev/null
sudo cp -r /etc $R/etc
```

Si `docker volume ls` devuelve algo, **parar y respaldar volúmenes** antes de formatear.

---

## 1. Live: arranque y verificación del disco

1. USB en UEFI (F12 en el firmware). Secure Boot **off**.
2. Si el NVMe tuvo errores de I/O, agregá al final de la línea `linux` del live:
   `nvme_core.default_ps_max_latency_us=0 pcie_aspm=off pcie_port_pm=off`
3. Verificar que el disco **existe** antes de escribir un byte:

```bash
sudo nvme list
sudo lsblk -o NAME,SIZE,FSTYPE,MODEL,SERIAL
sudo dmesg | grep -i nvme
sudo smartctl -a /dev/nvme0n1 | grep -Ei "critical|temperature|available spare|percentage used|media and data"
```

- `nvme list` vacío o sin `nvme0n1` en `lsblk` → **no es software**: revisar slot/alimentación.
- `Media and Data Integrity Errors` distinto de 0 → no usar ese disco para instalar.

**Confirmá tres veces**: destino = `nvme0n1` **476 GB**. Los otros (`sda` NTFS, `sdb` exFAT,
`sdc` Windows) no se tocan.

```bash
# Red del live
ip -br a
ping -c2 gentoo.org
```

---

## 2. Particionado y formateo

Esquema: 3 particiones, GPT, sin cifrado, sin `/boot` separado.

| # | Tamaño | Tipo | FS | Montaje |
|---|---|---|---|---|
| p1 | 1 GiB | EFI System (EF00) | vfat | `/efi` |
| p2 | 16 GiB | Linux swap (8200) | swap | — |
| p3 | resto (~455 GiB) | Linux filesystem (8300) | ext4 | `/` |

```bash
# (live) — DESTRUCTIVO: borra la tabla del disco
parted -s /dev/nvme0n1 mklabel gpt
parted -s /dev/nvme0n1 mkpart ESP fat32 1MiB 1025MiB
parted -s /dev/nvme0n1 set 1 esp on
parted -s /dev/nvme0n1 mkpart swap linux-swap 1025MiB 17409MiB
parted -s /dev/nvme0n1 mkpart root ext4 17409MiB 100%

parted -s /dev/nvme0n1 print          # verificar antes de formatear
```

**Antes de formatear**: nada montado, swap apagada. Si algo falla con "is mounted" o
"target is busy", el problema es que el disco está en uso, **no** que esté roto:

```bash
swapoff /dev/nvme0n1p2 /dev/nvme0n1p3 2>/dev/null
findmnt -R /mnt/gentoo
umount -R /mnt/gentoo 2>/dev/null

mkfs.vfat -F 32 -n EFI /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.ext4 -m 1 -L root /dev/nvme0n1p3
```

Cada `mkfs` tiene que terminar **sin `Warning!`** ni `Input/output error`.

```bash
mkdir -p /mnt/gentoo
mount /dev/nvme0n1p3 /mnt/gentoo
mkdir -p /mnt/gentoo/efi
mount /dev/nvme0n1p1 /mnt/gentoo/efi
swapon /dev/nvme0n1p2
findmnt -R /mnt/gentoo; swapon --show
```

---

## 3. Stage3 y `make.conf`

```bash
# (live)
cd /mnt/gentoo
# Elegí el tarball openrc + multilib más reciente de:
#   https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-openrc/
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-openrc/stage3-amd64-openrc-<FECHA>.tar.xz
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-openrc/stage3-amd64-openrc-<FECHA>.tar.xz.DIGESTS
sha512sum stage3-amd64-openrc-<FECHA>.tar.xz   # comparar con el .DIGESTS
tar xpvf stage3-amd64-openrc-<FECHA>.tar.xz --xattrs-include='*.*' --numeric-owner
rm stage3-amd64-openrc-<FECHA>.tar.xz*
```

`make.conf` del repo (`configs/etc/portage/make.conf`) — copiar tal cual, es el que anda:

```bash
cp configs/etc/portage/make.conf /mnt/gentoo/etc/portage/make.conf   # si el repo está a mano
```

Si no, escribilo a mano:

```ini
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"
MAKEOPTS="-j8 -l12"
EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=12"
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"
LC_MESSAGES=C.UTF-8
```

- `-j8` (no `-j12`): con ~8 GB libres un `llvm` a 12 procesos entra al OOM killer.
- Mirrors ya elegidos en el `make.conf` del repo (zero.com.ar primero).

---

## 4. Chroot, perfil y `@world`

```bash
# (live)
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run && mount --make-slave /mnt/gentoo/run
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

```bash
# (chroot)
emerge-webrsync
emerge --sync                                   # o: emaint sync -a
eselect profile list
eselect profile set <N>                          # default/linux/amd64/23.0 (multilib)
emerge --ask --verbose --update --deep --newuse @world
```

Si el `@world` tarda más de lo tolerable, aceptalo: es la base.

### USE flags y variables de Portage (una sola vez, bien)

```bash
# (chroot) — válido para este hardware, verificado contra packages.gentoo.org
mkdir -p /etc/portage/package.use

cat > /etc/portage/package.use/00cpu-flags <<'EOF'
*/* CPU_FLAGS_X86: aes avx avx2 bmi1 bmi2 f16c fma3 mmx mmxext pclmul popcnt rdrand sse sse2 sse3 sse4_1 sse4_2 ssse3
EOF

# GPU real: amdgpu + radeonsi (NO "virgl", eso es para VM)
cat > /etc/portage/package.use/00video_cards <<'EOF'
*/* VIDEO_CARDS: -* amdgpu radeonsi
*/* INPUT_DEVICES: libinput
EOF

cat > /etc/portage/package.use/installkernel <<'EOF'
sys-kernel/installkernel dracut grub
EOF

# GRUB_PLATFORMS está deprecado: se usa el USE flag
cat > /etc/portage/package.use/grub <<'EOF'
sys-boot/grub grub_platforms_efi-64
EOF

cat > /etc/portage/package.use/pipewire <<'EOF'
media-video/pipewire sound-server pipewire-alsa bluetooth dbus extra lv2
media-video/wireplumber bluetooth
EOF

echo "sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE" >> /etc/portage/package.license

# USE global
grep -q '^USE=' /etc/portage/make.conf || cat >> /etc/portage/make.conf <<'EOF'

USE="bluetooth dbus elogind X wayland"
EOF
```

> **Ojo**: `media-video/pipewire` **no tiene** el flag `pulseaudio` (la emulación Pulse viene
> de `pipewire-alsa`/`libpulse`). Escribirlo corta el emerge con `USE flag 'pulseaudio' is not
> in IUSE`.
>
> `elogind` es necesario en OpenRC para sesiones/logind (X, PipeWire, suspensión). `X` y
> `wayland` se pueden sacar si el escritorio no los pide, pero con i3 + Xorg hacen falta.

### locales y zona horaria

```bash
# (chroot)
cat > /etc/locale.gen <<'EOF'
en_US.UTF-8 UTF-8
es_AR.UTF-8 UTF-8
EOF
locale-gen
eselect locale set <N>            # es_AR.utf8
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

---

## 5. Kernel a mano

```bash
# (chroot)
emerge --ask sys-kernel/gentoo-sources
emerge --ask sys-kernel/linux-firmware      # imprescindible: amdgpu + BT USB
emerge --ask sys-kernel/dracut sys-kernel/installkernel
emerge --ask app-admin/eclean-kernel        # opcional, para limpiar kernels viejos
eselect kernel list && eselect kernel set 1
cd /usr/src/linux
```

Base del config: **nunca** el `.config` de la VM (trae virtio, le falta el fierro). Partí del
kernel que ya andaba en esta máquina o de `localmodconfig`:

```bash
# opción A (recomendada): config del kernel que ya andaba
zcat /mnt/rescate/qwertoo-<FECHA>/config-viejo.gz > /usr/src/linux/.config
make olddefconfig
```

```bash
# opción B: desde el live, cargando primero los módulos del hardware
# (volver al live, modprobe amdgpu e1000e btusb nvme, y después:)
make localmodconfig
```

### Lo que NO puede faltar (verificar uno por uno)

```bash
cd /usr/src/linux
for s in CONFIG_BLK_DEV_NVME CONFIG_EXT4_FS CONFIG_DEVTMPFS CONFIG_DEVTMPFS_MOUNT \
         CONFIG_EFI CONFIG_EFI_STUB CONFIG_FB_EFI CONFIG_VFAT_FS CONFIG_E1000E \
         CONFIG_DRM CONFIG_DRM_AMDGPU CONFIG_USB_XHCI_HCD CONFIG_USB_HID \
         CONFIG_HID_GENERIC CONFIG_INPUT_EVDEV CONFIG_SND CONFIG_SND_HDA_INTEL \
         CONFIG_SND_HDA_CODEC_REALTEK CONFIG_SND_HDA_CODEC_HDMI CONFIG_SND_USB_AUDIO \
         CONFIG_BT CONFIG_BT_HCIBTUSB CONFIG_SATA_AHCI CONFIG_NTFS3_FS CONFIG_EXFAT_FS \
         CONFIG_FW_LOADER; do
  printf '%-32s ' "$s"; grep -E "^(# )?${s} is not set|^${s}=" .config || echo "AUSENTE"
done
```

Criterio:

| Símbolo | Valor | Por qué |
|---|---|---|
| `BLK_DEV_NVME`, `EXT4_FS`, `DEVTMPFS*`, `VFAT_FS` | `=y` | tienen que existir antes de montar root y `/efi` |
| `E1000E` | `=y` | red disponible sin módulos |
| `DRM_AMDGPU` | `=m` | como builtin dracut no puede incorporar el firmware |
| `SND_HDA_INTEL`, `SND_HDA_CODEC_REALTEK`, `SND_HDA_CODEC_HDMI`, `SND_USB_AUDIO` | `=y` o `=m` | sin los **codecs** la placa y el HDMI quedan mudos |
| `BT`, `BT_HCIBTUSB` | `=m` | adaptador TP-Link `2357:0604` (RTL8761BU) |
| `NTFS3_FS`, `EXFAT_FS` | `=m` | los discos de datos |

Rutas del menú: ver `docs/hardware.md` § "Rutas del menú del kernel".

```bash
make -j8 && make modules_install && make install
```

> Si `make install` no genera initramfs, `installkernel` con el USE `dracut` no está activo.
> Verificar: `qlist sys-kernel/installkernel` y repetir el paso de USE flags.

```bash
dracut --force /boot/initramfs-$(make kernelrelease).img $(make kernelrelease)
ls -lh /boot/vmlinuz-* /boot/initramfs-*
```

---

## 6. `fstab`, hostname, red y usuario

```bash
# (chroot)
cat > /etc/fstab <<'EOF'
LABEL=root   /      ext4   defaults,noatime   0 1
LABEL=EFI    /efi   vfat   umask=0077         0 2
LABEL=swap   none   swap   sw                 0 0
EOF
```

```bash
echo qwertoo > /etc/hostname
cat > /etc/hosts <<'EOF'
127.0.0.1   qwertoo.localdomain qwertoo localhost
::1         qwertoo.localdomain qwertoo localhost
EOF
```

Red con OpenRC (sin NetworkManager, que es lo que usa el sistema viejo pero acá sobra):

```bash
emerge --ask net-misc/netifrc net-misc/dhcpcd
cd /etc/init.d && ln -sf net.lo net.enp1s0      # nombre real: ip -br a
rc-update add net.enp1s0 default
```

> Si la interfaz no se llama `enp1s0`, `net.eth0 failed to start` es esperable. Confirmar con
> `ip -br a` **desde el live** y usar ese nombre.

Servicios del sistema:

```bash
emerge --ask app-admin/sysklogd sys-process/cronie net-misc/chrony
rc-update add sysklogd default
rc-update add cronie default
rc-update add chronyd default
rc-update add sshd default            # si se instaló openssh
```

Root y usuario:

```bash
passwd root
emerge --ask app-admin/sudo
useradd -m -G users,wheel,audio,video,input,usb,portage -s /bin/bash javi
passwd javi
cat > /etc/sudoers.d/10-javi <<'EOF'
%wheel ALL=(ALL:ALL) ALL
EOF
chmod 0440 /etc/sudoers.d/10-javi
```

> `wheel` es lo que habilita `sudo` (y `su -`). Sin `wheel` no hay forma de administrar.
> `audio`, `video`, `input` son los que dan acceso a `/dev/snd`, DRM y evdev sin root.

---

## 7. GRUB (UEFI)

```bash
# (chroot)
emerge --ask sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo
```

- El target es **el disco** (`/dev/nvme0n1`) solo si se usa `grub-install` sin `--target`;
  con `--target=x86_64-efi` **no** se pasa dispositivo. Pasar `/dev/nvme0n1p1` es el error
  que deja blocklists muertos.
- Sin `grub_platforms_efi-64` el emerge instala solo `pc`, y `x86_64-efi` "no existe".

```bash
grub-mkconfig -o /boot/grub/grub.cfg
grep -c "menuentry" /boot/grub/grub.cfg       # tiene que dar >=1
efibootmgr -v                                  # tiene que listar Gentoo
```

Salir y reiniciar:

```bash
exit                                            # (chroot)
cd /
umount -l /mnt/gentoo/dev /mnt/gentoo/sys
umount -R /mnt/gentoo
swapoff /dev/nvme0n1p2
poweroff                                        # sacar el USB antes de encender
```

---

## 8. Primer arranque (target)

Si no arranca: `unable to mount root fs` = falta `EXT4_FS`/`BLK_DEV_NVME` o el initramfs.
Ver `docs/retomar.md`.

```bash
# (target, como root)
ip -br a && ping -c2 gentoo.org
dmesg | grep -i -E "firmware|amdgpu|nvme|failed to load"
```

Sin `failed to load`: el firmware entró. Si aparece `amdgpu ... firmware: failed to load
amdgpu/navi23_*.bin` → falta `sys-kernel/linux-firmware` o el initramfs no lo tiene:

```bash
emerge --ask --oneshot sys-kernel/linux-firmware
dracut --force /boot/initramfs-$(uname -r).img $(uname -r)
```

---

## 9. Escritorio: Xorg + i3

```bash
# (target)
emerge --ask x11-base/xorg-drivers x11-drivers/xf86-input-libinput
emerge --ask x11-base/xorg-server x11-wm/i3 x11-terms/kitty x11-misc/dmenu x11-misc/picom
emerge --ask media-fonts/dejavu media-fonts/noto media-fonts/liberation-fonts
emerge --ask x11-misc/xinit app-shells/bash-completion sys-apps/mlocate
```

Verificar que `VIDEO_CARDS` esté bien aplicado (sin esto X dice "no screens found"):

```bash
emerge -pv x11-base/xorg-server | grep -i -E "VIDEO_CARDS|libinput"
```

`.xinitrc` mínimo:

```bash
cat > ~/.xinitrc <<'EOF'
exec dbus-launch --sh-syntax --exit-with-session i3
EOF
```

```bash
chown javi: /home/javi/.xinitrc
startx            # desde la consola de javi
```

Verificación: `xrandr` lista el modo nativo del monitor · `glxinfo | grep "OpenGL renderer"`
dice `AMD Radeon RX 6600`.

---

## 9-bis. Alternativa: Sway (Wayland puro, sin Xorg)

Si preferís Wayland, **no instales Xorg**. Todo lo de la sección 9 se reemplaza por esto.
Sway en OpenRC usa **elogind** (no systemd).

### Kernel: lo que agrega Wayland

```
CONFIG_DRM_AMDGPU=m          # ya está
CONFIG_DRM_FBDEV_EMULATION=y # consola + fbcon mientras arranca el compositor
```

### Paquetes

```bash
emerge --ask gui-libs/wlroots gui-wm/sway x11-base/xwayland
emerge --ask gui-apps/foot gui-apps/wofi gui-apps/mako gui-apps/swaybg \
            gui-apps/swaylock gui-apps/swayidle gui-apps/wl-clipboard
emerge --ask media-fonts/dejavu media-fonts/noto
emerge --ask dev-libs/libinput sys-auth/elogind
```

`configs/paquetes-escritorio-sway.txt` tiene la lista completa.

### USE flags

```bash
mkdir -p /etc/portage/package.use
cat > /etc/portage/package.use/sway <<'EOF'
gui-wm/sway elogind gtk tray
gui-libs/wlroots elogind
sys-auth/seatd server
EOF
```

Y en `make.conf` el USE global **sin `X`** (con `X` se arrastra medio Xorg):

```
USE="bluetooth dbus elogind wayland"
```

> Sin `elogind` el compositor arranca pero no puede abrir `/dev/dri/card0` ni tomar el
> teclado: `sway: unable to open backend`. Es el error número uno.

### Servicios (OpenRC)

```bash
rc-update add elogind default
rc-service elogind start
```

`seatd` **no** se activa si usás elogind: son dos formas de conseguir lo mismo y pelearse
rompe la sesión. Con elogind alcanza.

### Config mínima

```bash
mkdir -p ~/.config/sway
cp /ruta/configs/sway-config.txt ~/.config/sway/config
```

La config del repo ya trae: `$mod=Mod4`, `foot` en `Mod+Return`, `wofi` en `Mod+d`,
workspaces 1-9, foco/mover con vim keys, volumen con `wpctl`, barra con reloj, `swaylock`
en `Mod+Escape`. **Cambiá `output * resolution`** al modo real del monitor.

`output * bg` va antes que nada: sin salida configurada la pantalla queda negra y parece
que no arrancó.

### Arrancar

Sin display manager, desde la consola de `javi`:

```bash
# si el sistema bootea en modo texto (recomendado: predecible y rápido)
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec dbus-run-session sway' >> ~/.bash_profile
```

O a mano, para la primera vez:

```bash
dbus-run-session sway
```

### Verificación

```bash
swaymsg -t get_outputs        # lista la salida y el modo activo
swaymsg -t get_version
dmesg | grep -i amdgpu | tail
foot                          # abre terminal (Mod+Return)
```

Si `swaymsg` dice `Unable to connect to /run/user/1000/sway-ipc.*` → corriste sway sin
`dbus-run-session` o sin `elogind` activo. No es la config.

## 10. Audio (PipeWire) y Bluetooth

```bash
# (target)
emerge --ask media-video/pipewire media-video/wireplumber media-libs/libpulse
emerge --ask media-sound/alsa-utils media-libs/libfreeaptx media-libs/opus
emerge --ask net-wireless/bluez net-wireless/blueman sys-auth/rtkit
```

Servicios: `bluetooth` a nivel sistema, el resto por usuario (OpenRC ≥ 0.60):

```bash
rc-update add bluetooth default && rc-service bluetooth start
usermod -aG pipewire javi

# como javi (no root)
rc-update --user add pipewire default
rc-update --user add pipewire-pulse default
rc-update --user add wireplumber default
```

Verificación (como javi):

```bash
pactl info | grep "Server Name"        # "PulseAudio (on PipeWire x.y.z)"
wpctl status                           # lista sinks/sources
aplay -l                               # placa Intel + HDMI de la GPU
bluetoothctl <<'EOF'
power on
scan on
EOF
```

Detalle y problemas típicos: `docs/audio.md`.

> **No instalar** `media-sound/pulseaudio-daemon` al lado de PipeWire.

---

## 11. Limpieza y cierre

```bash
# (target)
emerge --ask app-portage/gentoolkit
eclean-dist -d
emerge --ask --depclean
eselect news read all
rc-status --all
```

Checklist final:

- [ ] `ip -br a` con la MAC de la placa Intel
- [ ] `dmesg` sin `failed to load`
- [ ] `aplay -l` lista placa Intel y HDMI
- [ ] `xrandr` con el modo nativo
- [ ] `bluetoothctl` ve el adaptador
- [ ] `pactl info` dice "on PipeWire"
- [ ] `grub-install` hecho con `--target=x86_64-efi --efi-directory=/efi`
- [ ] `/efi` montado en el `fstab`
- [ ] usuario `javi` en `wheel`

---

## Errores ya resueltos

| Síntoma | Causa real | Solución |
|---|---|---|
| `mkfs: is mounted` / `target is busy` | disco en uso (no está roto) | `swapoff` + `umount -R /mnt/gentoo` + `findmnt -R` |
| `Identify namespace failed (-5)`, `NVME_IOCTL_ADMIN_CMD: I/O error` | el kernel perdió el namespace (APST/ASPM) | apagar, cortar energía, arrancar con `nvme_core.default_ps_max_latency_us=0 pcie_aspm=off` |
| `network 'default' is not active` | virsh en `qemu:///session` | `virsh -c qemu:///system` |
| `virtstoraged-sock` no existe | servicio apagado | `systemctl enable --now virtstoraged.socket` |
| `mount point does not exist` en `/boot` | se creó el dir antes de montar la raíz | montar root primero |
| `net.eth0 failed to start` | la interfaz se llama `enp1s0` | `ln -s net.lo net.enp1s0` |
| `account is locked due to 3 failed logins` | `pam_faillock` | `faillock --user <u> --reset` |
| `grub-install /dev/nvme0n1p1` falla, blocklists | target = partición | con `--target=x86_64-efi` no se pasa dispositivo |
| `Cannot find terminfo entry for 'xterm-kitty'` | falta el terminfo | `TERM=xterm-256color` o `kitty +kitten ssh` |
| `emerge: unrecognized arguments: --newest-use` | no existe la bandera | `--newuse` |
| `short ebuild name "screen" is ambiguous` | falta categoría | `emerge app-misc/screen` |
| `USE flag 'pulseaudio' is not in IUSE` (pipewire) | flag inexistente | usar `sound-server` + `pipewire-alsa` |
| X dice `no screens found` | falta `VIDEO_CARDS` o `xorg-drivers` | `*/* VIDEO_CARDS: -* amdgpu radeonsi` |
| Placa muda con driver cargado | faltan codecs HDA | `SND_HDA_CODEC_REALTEK` + `SND_HDA_CODEC_HDMI` |
| Pantalla negra hasta el login | `amdgpu=y` + dracut no mete firmware | `amdgpu=m` o `EXTRA_FIRMWARE` |

---

## Referencias

- Handbook AMD64 (es): <https://wiki.gentoo.org/wiki/Handbook:AMD64/es>
- Copia local offline: `~/docs/gentoo-handbook/`
- Decisions y bitácora: `docs/decisiones.md`, `docs/bitacora.md`
- Migración de los 493 paquetes de CachyOS: `docs/migracion.md`
- Hardware y rutas del menú del kernel: `docs/hardware.md`