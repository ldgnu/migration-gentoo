# Checklist de endymion

Mapa de lo que se hizo, con el estado final y dónde está el detalle. La guía ejecutable es
[`guia-instalacion.md`](guia-instalacion.md); esto es el registro de que se cumplió.

Instalación completa el **17/11/2026**. Última verificación: **21/11/2026**.

## Antes de arrancar

| Paso | Estado | Nota |
|---|---|---|
| Backup del disco | **no se hizo** | El sistema anterior (CachyOS) se perdió. Es el error 1 de [`errores.md`](errores.md) |
| ISO verificada con GPG | hecho | Firma y huella comparadas contra gentoo.org |
| UEFI confirmado, Secure Boot apagado | hecho | `SecureBoot=0`, `SetupMode=0` |
| `lsblk` confirmado | hecho | Destino `nvme0n1`, 476 GB |

## Instalación

| # | Paso | Estado | Dónde |
|---|---|---|---|
| 1 | Relevar el hardware antes de tocar nada | hecho | [`auditorias/instalacion-hardware-2026-11-17.md`](auditorias/instalacion-hardware-2026-11-17.md) |
| 2 | Live en UEFI, disco visible | hecho | bitácora, 17/11 |
| 3 | `smartctl` sin errores | hecho | SMART PASSED, 2 % usado |
| 4 | GPT: ESP 1 GiB, swap 16 GiB, raíz 100 GiB, home 360 GiB | hecho | [`hardware.md`](hardware.md) |
| 5 | `mkfs.vfat`, `mkswap`, `mkfs.ext4` | hecho | UUIDs en [`../configs/endymion/etc/fstab`](../configs/endymion/etc/fstab) |
| 6 | Montajes en `/mnt/gentoo`, `/efi`, `swapon` | hecho | bitácora |
| 7 | Stage3 openrc multilib verificado y extraído | hecho | bitácora |
| 8 | `make.conf` con `-march=native`, `-j8 -l12` | hecho | [`../configs/endymion/etc/portage/make.conf`](../configs/endymion/etc/portage/make.conf) |
| 9 | `resolv.conf`, mounts y chroot | hecho | bitácora |
| 10 | Sync del árbol de Portage | hecho | `emerge.log` |
| 11 | Perfil `default/linux/amd64/23.0` | hecho | multilib |
| 12 | `@world` actualizado (61 paquetes) | hecho | [`historial-paquetes.md`](historial-paquetes.md) |
| 13 | USE: CPU flags, `VIDEO_CARDS`, installkernel | hecho | [`../configs/endymion/etc/portage/package.use/`](../configs/endymion/etc/portage/package.use/) |
| 14 | Locales `en_US` y `es_AR`, teclado `la-latin1` | hecho | `conf.d/keymaps` |
| 15 | `gentoo-sources`, `linux-firmware`, `dracut`, `installkernel` | hecho | `emerge.log` |
| 16 | `.config` desde el kernel del live + `olddefconfig` | hecho | [`../configs/endymion/boot/`](../configs/endymion/boot/) |
| 17 | Símbolos críticos verificados | hecho | `nvme`, `ext4`, `vfat`, `amdgpu`, `e1000e`, codecs HDA |
| 18 | `make -j8`, `modules_install`, `install` | hecho | 189 módulos |
| 19 | Initramfs en `/boot` | hecho | dracut, zstd |
| 20 | `fstab` por UUID | hecho | `configs/endymion/etc/fstab` |
| 21 | Hostname `endymion` | hecho | `hostname`, `hosts`, `conf.d/hostname` |
| 22 | `net.eno1` en default | hecho | DHCP, IPv6 |
| 23 | `sysklogd`, `cronie`, `chronyd`, `sshd` | hecho | `rc-status --all` |
| 24 | Usuario `ldgnu` en `wheel,audio,video,usb,portage,seat,pipewire` + sudo | hecho | `id ldgnu` |
| 25 | `grub-install --target=x86_64-efi --efi-directory=/efi` | hecho | `EFI/Gentoo/grubx64.efi` |
| 26 | `grub-mkconfig` + entrada UEFI | hecho | `Boot0000`, Gentoo primero |
| 27 | Primer arranque con red | hecho | 17/11 |
| 28 | `dmesg` revisado | hecho | [`auditorias/2026-11-20/estado/09-dmesg-smart.txt`](auditorias/2026-11-20/estado/09-dmesg-smart.txt) |
| 29 | Escritorio: Sway (no Xorg, no i3) | hecho | [`../configs/endymion/home/ldgnu/.config/sway/config`](../configs/endymion/home/ldgnu/.config/sway/config) |
| 30 | GPU con `amdgpu`, `glxinfo`/`vulkaninfo` | hecho | `vulkan-tools` instalado |
| 31 | PipeWire + WirePlumber | hecho | 1.6.11, sink analógico |
| 32 | Bluetooth en default | hecho | BlueZ 5.88 |
| 33 | Audio: placa Intel y headset USB | hecho | `aplay -l` |
| 34 | Kernel 7.3.5 y rebuild con `CONFIG_TUN` | hecho | 18 y 19/11 |

## Mantenimiento

| Tarea | Estado al 21/11 |
|---|---|
| `emerge --sync` | árbol del 18/11; conviene sincronizar |
| `emerge -uDN @world` | **en curso**: 102 rebuilds por ABI 32 bits |
| `emerge --depclean` | al día, 0 candidatos |
| `revdep-rebuild` | consistente |
| `eselect news read` | **29 noticias sin leer** |
| `eclean-kernel -n 2` | pendiente: hay 7.3.5, 7.3.5 `.old` y 6.18.63 |
| `eclean-dist -d` | pendiente |
| Firewall | **no hay** (falta `NF_TABLES` en el kernel) |

El detalle de cada pendiente está en [`auditorias/2026-11-20/README.md`](auditorias/2026-11-20/README.md).

## El laboratorio

La instalación de práctica en la VM (BIOS, virtio, `no-multilib`) está en
[`vm.md`](vm.md), como registro histórico. No aplica a endymion.

## Referencia

- [Handbook AMD64 (español)](https://wiki.gentoo.org/wiki/Handbook:AMD64/es)
- [Portage](https://wiki.gentoo.org/wiki/Portage) · [USE flags](https://wiki.gentoo.org/wiki/USE_flag)
- [Kernel](https://wiki.gentoo.org/wiki/Kernel/es) · [GRUB](https://wiki.gentoo.org/wiki/GRUB/es)
- [OpenRC](https://wiki.gentoo.org/wiki/OpenRC) · [PipeWire](https://wiki.gentoo.org/wiki/PipeWire)
