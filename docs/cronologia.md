# Gentoo en endymion — paso a paso

Cronología consolidada de la instalación y de los primeros días de uso. Sale de tres fuentes
que se complementan:

- `registro-instalacion/` — el watcher que corrió durante la instalación en hardware
  (`actual.md`, `cambios.md`, `comandos.md`, 24 capturas).
- `historial-paquetes.md` — cada sesión de `emerge` con fecha y paquetes mergeados.
- `auditorias/2026-11-20/estado/` — salidas crudas del sistema ya funcionando.

Los horarios son los del sistema (UTC-3) salvo que se aclare UTC.

Hardware: Intel i5-10400F (6c/12t), 15 GiB RAM, Radeon RX 6600 (Navi 23), WD SN740 512 GB,
placa con UEFI y Secure Boot apagado. Nombre del equipo: **endymion**.

---

## Fase 0 — Antes: la VM de práctica (15 y 16 de noviembre)

La instalación real se ensayó en una VM con libvirt sobre el sistema anterior (CachyOS,
btrfs + LUKS). Esa VM quedó en BIOS/SeaBIOS, con esquema GPT: BIOS boot de 1 MiB, `/boot`
de 1 GiB, swap de 4 GiB y raíz de 45 GiB.

Lo que se aprendió ahí y se aplicó después:

| Tema | Aprendizaje |
|---|---|
| Red del live | El ISO trae `sshd` pero no lo arranca; sin `passwd root` el login rebota. |
| Particiones | En BIOS+GPT hace falta la partición BIOS boot o `grub-install` falla. |
| `lsblk -f` | No muestra el tipo de partición; para eso está `sfdisk -d`. |
| Stage3 | La firma `.asc` tiene que corresponder al nombre exacto del tarball. |
| Perfil | `no-multilib` exige stage3 `nomultilib`; se verifica con `ls -d /lib32`. |
| Red | `net.eth0` no existe: los nombres predecibles piden `net.<interfaz>`. |
| Bloqueo | `pam_faillock` bloquea la cuenta (no la IP) tras 3 intentos fallidos. |
| Kernel | `make` sin `-j` tarda 18 minutos lo que con `-j6` sale en menos de la mitad. |
| `installkernel` | Con `USE="dracut grub"`, `make install` genera initramfs y corre `grub-mkconfig`. |

Detalle completo en `bitacora.md`, entradas del 2026-11-15 y 16.

---

## Fase 1 — Instalación en hardware (17 de noviembre)

### 1.1 Particionado del NVMe

El disco anterior (CachyOS con LUKS y btrfs) se reemplazó. **No se hizo backup previo del
sistema viejo**: el paso 32 del checklist quedó sin marcar y esa información ya no existe.

Esquema final, confirmado con `lsblk` y `sgdisk`:

| Partición | Tamaño | FS | UUID | Punto de montaje |
|---|---:|---|---|---|
| `nvme0n1p1` | 1 GiB | vfat (ESP) | `CBD5-7071` | `/efi` |
| `nvme0n1p2` | 16 GiB | swap | `a843caf6-…` | swap |
| `nvme0n1p3` | 100 GiB | ext4 | `f58fb93f-…` | `/` |
| `nvme0n1p4` | 359.9 GiB | ext4 | `43f0b8b6-…` | `/home` |

Sin LUKS y sin btrfs. `/boot` quedó como directorio dentro de la raíz, no como partición.
Los discos `sda` (NTFS), `sdb` (exFAT) y `sdc` (Windows) no se tocaron; la entrada UEFI de
Windows sigue apuntando a la ESP de `sdc`.

### 1.2 Base, stage3 y Portage

```
# stage3 openrc del 2026-11-15, extraído en /mnt/gentoo
tar xpvf stage3-amd64-openrc-20261115T170104Z.tar.xz \
    --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo

arch-chroot /mnt/gentoo
mkdir -p /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge --sync
emerge --oneshot app-portage/mirrorselect app-misc/screen
```

`make.conf` quedó con `-march=native -O2 -pipe`, `MAKEOPTS="-j8 -l12"`,
`EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=12"`, `ACCEPT_KEYWORDS="~amd64"` y
`ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"`.

Errores reales de este tramo:

- `gentoo.zero.com.ar` no resuelve por DNS: el primer mirror de `GENTOO_MIRRORS` nunca sirve.
- `emerge screen` sin categoría → `short ebuild name "screen" is ambiguous`.
- `emerge --newest-use` y `--new-use` no existen: la bandera es `--newuse`.

### 1.3 Primer `@world` grande: 61 paquetes

```
emerge --ask --verbose --update --deep --newuse @world
# Jobs: 61 of 61 complete — Load avg: 3.58, 4.56, 4.26
```

Avisos con consecuencia real:

- `Unable to find kernel sources at /usr/src/linux` (normal en ese momento).
- Después de actualizar glibc hay que reiniciar procesos o reiniciar el equipo.

### 1.4 Identidad, fstab y red

```
cat > /etc/fstab <<'EOF'
UUID=f58fb93f-1681-423f-a6f2-ce6a6e8d9752  /      ext4  defaults,noatime  0 1
UUID=43f0b8b6-4345-4494-b4b9-5c5be26f7e6b  /home  ext4  defaults,noatime  0 2
UUID=CBD5-7071                             /efi   vfat  umask=0077        0 2
UUID=a843caf6-6f1e-4712-b151-b3e275149399  none   swap  sw                0 0
EOF
findmnt --verify
```

- Hostname `endymion` en `/etc/hostname`, `/etc/conf.d/hostname` y `/etc/hosts`.
- Zona horaria `America/Argentina/Cordoba`, `clock="UTC"`.
- Locales `en_US.utf8` y `es_AR.utf8`; `LANG=es_AR.utf8`. Teclado `la-latin1`.
- `root` con clave. Red `config_eno1="dhcp"`, servicio `net.eno1`, `sshd` en `default`.

### 1.5 Kernel 6.18.63 y GRUB EFI

```
emerge --ask =sys-kernel/gentoo-sources-6.18.63 sys-kernel/linux-firmware \
              sys-kernel/installkernel sys-kernel/dracut sys-boot/grub
eselect kernel set 1
cd /usr/src/linux
zcat /proc/config.gz > .config   # base: kernel del live
make olddefconfig && make nconfig
make -j8 && make modules_install && make install

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

Resultado: `6.18.63-gentoo-gentoo-dist`, 189 módulos, initramfs con dracut (zstd),
`/efi/EFI/Gentoo/grubx64.efi`, entrada `Boot0000 Gentoo` primera en el `BootOrder` y
Windows intacto en `Boot0008`.

### 1.6 Registro automático de la instalación

Se armó `vigilancia.sh` (en `registro-instalacion/scripts/`): cada 20 segundos saca una foto
del sistema (`actual.md`), guarda el diff (`cambios.md`), copia los comandos nuevos de los
historiales de bash (`comandos.md`) y toma capturas JPEG después de cada comando y cada 10
minutos. Todo persistió en `/var/log/qwertoo-instalacion/` dentro del sistema instalado.

Eso produjo 24 capturas y 90 instantáneas de cambios durante la instalación. Son las que
están en `registro-instalacion/capturas/`.

### 1.7 Primer arranque

Arrancó con 6.18.63. Se verificó: raíz y home montados por UUID, swap activa, `eno1` con IP
por DHCP, DNS OK, fecha y locale correctos, servicios `sshd`, `chronyd`, `sysklogd`,
`cronie` y `net.eno1` arriba.

---

## Fase 2 — Escritorio y herramientas (17 y 18 de noviembre)

Todo con OpenRC, sin systemd: `elogind` + `seatd` + `dbus`.

### 2.1 Sway y stack Wayland

```
emerge gui-wm/sway gui-apps/foot media-fonts/dejavu sys-auth/elogind sys-apps/dbus
emerge gui-apps/wmenu gui-apps/mako gui-apps/wl-clipboard gui-apps/grim gui-apps/slurp \
       gui-apps/swayidle gui-apps/swaylock gui-apps/swaybg x11-base/xwayland \
       sys-apps/xdg-desktop-portal gui-libs/xdg-desktop-portal-wlr \
       sys-apps/xdg-desktop-portal-gtk media-fonts/liberation-fonts
```

`wofi` se instaló, no arrancaba (`XDG_RUNTIME_DIR`/portal) y se reemplazó por `wmenu`
(`emerge --unmerge =gui-apps/wofi-1.5`). Hoy el launcher es `~/.local/bin/wmenu-run` y
`~/.local/bin/wmenu-drun`, estilizados como la barra (swaybar, monocromo).

Config del usuario: `~/.config/sway/config` (17 KB) más wrappers en `~/.local/bin/`
(`sway-audio`, `sway-shot`, `sway-status`, `sway-outputs`, `sway-power`, `sway-yt`, etc.).

### 2.2 Audio

```
emerge media-video/pipewire media-video/wireplumber media-libs/libpulse \
       media-sound/alsa-utils sys-auth/rtkit media-libs/libfreeaptx \
       media-libs/opus net-wireless/bluez
```

PipeWire 1.6.11 + WirePlumber, salida `Audio Interno Estéreo analógico` (ALC897) y entrada
por headset USB Redragon. Bluetooth arriba con BlueZ 5.88.

### 2.3 Herramientas

`neovim`, `yazi`, `ranger`, `lazygit`, `btop`, `ripgrep`, `fd`, `fzf`, `zoxide`, `bat`,
`eza`, `ncdu`, `duf`, `7zip`, `unrar`, `atool`, `jq`, `poppler`, `chafa`, `lm-sensors`,
`smartmontools`, `plocate`, `eclean-kernel`, `logrotate`, `playerctl`, `ncpamixer`,
`mpv`, `yt-dlp`, `swappy`, `cliphist`, `bluetui`, `github-cli`, `fastfetch`.

### 2.4 Navegador, gaming y VPN

```
emerge www-client/zen-bin                 # vía guru
eselect repository enable steam-overlay && emerge --sync
emerge games-util/steam-launcher @gaming  # gamemode, gamescope, vulkan-tools
emerge media-libs/mesa media-libs/vulkan-loader dev-util/vulkan-tools
emerge net-vpn/tailscale
```

`VIDEO_CARDS="amdgpu radeonsi"` en `make.conf`. Steam quedó con ABI de 32 bits:
`ABI_X86="64 32"` agregado a `make.conf` el 18/11, lo que disparó reconstrucciones.

---

## Fase 3 — Kernel 7.3.5 (18 y 19 de noviembre)

La rama 6.18.63 estaba al día pero se decidió subir a 7.3.5:

```
emerge --ask sys-kernel/gentoo-sources        # 18/11 11:54 → 7.3.5
eselect kernel set 2
cd /usr/src/linux
cp ../linux-6.18.63-gentoo/.config .
make olddefconfig
make -j8 && make modules_install && make install   # 18/11 15:53
```

El 19/11 se instaló `tailscale`, que necesita `/dev/net/tun`. El kernel no tenía
`CONFIG_TUN`, así que se habilitó como módulo y se recompiló:

```
# diff contra el binario anterior: +CONFIG_TUN=m
make -j8 && make modules_install && make install   # 19/11 23:56
```

Único cambio entre ambos builds de 7.3.5: `CONFIG_TUN`. GRUB quedó con `7.3.5` primero,
`6.18.63` como fallback y una entrada `.old` de la compilación previa.

---

## Fase 4 — Estado al 20 de noviembre

Ver [`auditorias/2026-11-20/README.md`](auditorias/2026-11-20/README.md). Resumen: sistema estable, 739 paquetes, Portage consistente,
sin dependencias rotas, 4h53m de uptime sobre 7.3.5, Sway funcionando con Steam, Zen y
Tailscale. Lo pendiente es higiene (rebuilds por ABI 32 bits, firewall, noticias, limpieza
de kernels) y dos decisiones que nunca se registraron: cifrado en reposo y backup.

---

## Comandos que quedaron como referencia

```sh
# estado general
uname -r && eselect kernel list
rc-status --all
find /var/db/pkg -mindepth 2 -maxdepth 2 -type d | wc -l

# salud de Portage
qcheck
revdep-rebuild -p
emerge -p --depclean
emerge -uDNp @world

# arranque
efibootmgr -v
grep -E "menuentry|linux |initrd " /boot/grub/grub.cfg
eclean-kernel -p -n 2

# logs de la instalación
less /var/log/qwertoo-instalacion/actual.md
tail -f /var/log/qwertoo-instalacion/cambios.md
```
