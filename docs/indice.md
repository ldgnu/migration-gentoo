# Índice de la instalación

Mapa de todo el recorrido. **La guía ejecutable es [`guia-instalacion.md`](guia-instalacion.md)**:
se sigue de arriba abajo y no hace falta abrir el handbook.

Acá está el checklist para ir marcando lo que se hizo en el fierro. La instalación de la VM
(`vm.md`) queda abajo como registro histórico: ya está completa y no se repite.

## Antes de arrancar

- [ ] Backup de lo que esté en el NVMe (y de los volúmenes Docker, si hay)
- [ ] ISO de Gentoo descargada y verificada con GPG
- [ ] UEFI confirmado, Secure Boot desactivado
- [ ] Otro dispositivo para leer la guía durante la instalación
- [ ] `lsblk` confirmado: destino = `nvme0n1` (476 GB)

## Instalación en el fierro (i5-10400F / RX 6600)

**§0-1 · Rescate y verificación del disco** — [Disks](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/es)

| # | Paso | Hecho |
|---|---|---|
| 1 | Rescate: `/proc/config.gz`, tailscale state, `lspci -nnk`, `lsusb`, `/etc` | [ ] |
| 2 | Live arrancado en UEFI; disco visible en `nvme list` y `lsblk` | [ ] |
| 3 | `smartctl` sin errores de integridad ni porcentaje de uso crítico | [ ] |

**§2 · Discos**

| # | Paso | Hecho |
|---|---|---|
| 4 | GPT + p1 EFI 1 GiB / p2 swap 16 GiB / p3 root resto | [ ] |
| 5 | `mkfs.vfat`, `mkswap`, `mkfs.ext4` sin `Warning!` ni I/O error | [ ] |
| 6 | Montaje en `/mnt/gentoo` + `/efi` + `swapon` | [ ] |

**§3-4 · Stage3 y base** — [Stage](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/es) · [Base](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/es)

| # | Paso | Hecho |
|---|---|---|
| 7 | Stage3 **openrc + multilib** verificado con sha512 y extraído | [ ] |
| 8 | `make.conf`: `-march=native`, `MAKEOPTS="-j8 -l12"`, mirrors | [ ] |
| 9 | `resolv.conf`, mounts, `chroot` | [ ] |
| 10 | `emerge-webrsync` / `emerge --sync` | [ ] |
| 11 | Perfil `default/linux/amd64/23.0` (multilib) | [ ] |
| 12 | `@world` actualizado | [ ] |
| 13 | USE: CPU flags, `VIDEO_CARDS amdgpu radeonsi`, `INPUT_DEVICES libinput`, grub efi-64, pipewire | [ ] |
| 14 | `locale-gen` + `eselect locale` | [ ] |

**§5 · Kernel** — [Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/es)

| # | Paso | Hecho |
|---|---|---|
| 15 | `gentoo-sources` + **`linux-firmware`** + `dracut` + `installkernel` | [ ] |
| 16 | `.config` desde `/proc/config.gz` del sistema viejo + `make olddefconfig` | [ ] |
| 17 | Verificados los 26 símbolos críticos (`amdgpu=m`, codecs HDA, e1000e, vfat, nvme, ext4) | [ ] |
| 18 | `make -j8 && make modules_install && make install` | [ ] |
| 19 | `initramfs` generado en `/boot` | [ ] |

**§6-7 · Sistema y arranque** — [System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/es) · [Bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/es)

| # | Paso | Hecho |
|---|---|---|
| 20 | `fstab` con `LABEL=root` / `LABEL=EFI` / `LABEL=swap` | [ ] |
| 21 | hostname `qwertoo` + `/etc/hosts` | [ ] |
| 22 | `net.enp1s0` en el runlevel default | [ ] |
| 23 | `sysklogd`, `cronie`, `chronyd`, `sshd` | [ ] |
| 24 | root + usuario `javi` en `wheel,audio,video,input` + sudoers | [ ] |
| 25 | `grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo` | [ ] |
| 26 | `grub-mkconfig` + `efibootmgr -v` lista Gentoo | [ ] |

**§8-11 · Primer arranque y escritorio**

| # | Paso | Hecho |
|---|---|---|
| 27 | Bootea desde el disco, red arriba | [ ] |
| 28 | `dmesg` sin `failed to load` (firmware amdgpu/BT) | [ ] |
| 29 | Xorg + `xorg-drivers` + `xf86-input-libinput` + i3/kitty/dmenu/picom | [ ] |
| 30 | `xrandr` con el modo nativo · `glxinfo` = RX 6600 | [ ] |
| 31 | PipeWire + WirePlumber + BlueZ (`pactl info` = "on PipeWire") | [ ] |
| 32 | `bluetooth` en default, `blueman`, `rtkit`, usuario en grupo `pipewire` | [ ] |
| 33 | `aplay -l` lista placa Intel y HDMI | [ ] |
| 34 | `eclean-dist -d`, `--depclean`, `eselect news read` | [ ] |

## Mantenimiento

- [ ] `eclean-dist -d` periódico
- [ ] `emerge --ask --depclean` después de cada `--newuse @world`
- [ ] `eselect news read all` antes de actualizar
- [ ] `eclean-kernel -n 2` para limpiar kernels viejos

## Registro histórico: instalación base en la VM

Ya completa. Se conserva como evidencia de lo que se ejecutó en el laboratorio
(BIOS + virtio + `no-multilib`). Detalle en `vm.md`.

| # | Paso | Hecho |
|---|---|---|
| 1 | Preparar el host: qemu, libvirt, red default | [x] |
| 2 | Verificar la ISO con OpenPGP | [x] |
| 3 | Crear la VM | [x] |
| 4 | Levantar sshd en el live y conectarse | [x] |
| 5 | Particionar el disco | [x] |
| 6 | Formatear y montar | [x] |
| 7 | Descargar y verificar el stage3 | [x] |
| 8 | Extraer el stage3 | [x] |
| 9 | Configurar `make.conf` | [x] |
| 10 | Copiar `resolv.conf` y entrar al chroot | [x] |
| 11 | Configurar `repos.conf` y sincronizar | [x] |
| 12 | Elegir el perfil | [x] |
| 13 | Actualizar `@world` | [x] |
| 14 | Configurar locales | [x] |
| 15 | Escribir `/etc/fstab` | [x] |
| 16 | Hostname y contraseña de root | [x] |
| 17 | Instalar fuentes del kernel | [x] |
| 18 | Configurar el kernel (`nconfig`) | [x] |
| 19 | Compilar e instalar el kernel | [x] |
| 20 | Instalar GRUB | [x] |
| 21 | Primer arranque | [x] |
| 22 | Configurar `net.enp1s0` | [x] |
| 23 | Desbloquear la cuenta (`pam_faillock`) | [x] |
| 24 | Habilitar `sshd`, `sysklogd`, `cronie`, `chronyd` | [x] |
| 25 | Sincronizar el árbol e instalar `gentoolkit` | [x] |
| 26 | Primer `@world` (gcc, glibc) | [x] |

## Documentación de referencia

- [Handbook completo (español)](https://wiki.gentoo.org/wiki/Handbook:AMD64/es) — copia local en `~/docs/gentoo-handbook/`
- [Portage](https://wiki.gentoo.org/wiki/Portage)
- [USE flags](https://wiki.gentoo.org/wiki/USE_flag)
- [Kernel](https://wiki.gentoo.org/wiki/Kernel/es)
- [GRUB](https://wiki.gentoo.org/wiki/GRUB/es)
- [OpenRC](https://wiki.gentoo.org/wiki/OpenRC)
- [Bluetooth](https://wiki.gentoo.org/wiki/Bluetooth)
- [PipeWire](https://wiki.gentoo.org/wiki/PipeWire)
- [i3](https://wiki.gentoo.org/wiki/I3)
- [Binary packages](https://wiki.gentoo.org/wiki/Binary_package_guide)
