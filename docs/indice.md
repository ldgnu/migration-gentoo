# Índice de la instalación

Checklist del recorrido completo. Marcado lo hecho en la VM, con el enlace al capítulo del
handbook y a la sección de `vm.md` donde está el detalle.

## Antes de arrancar

- [ ] Backup de lo que haya que conservar
- [ ] ISO de Gentoo descargada y verificada con GPG
- [ ] Modo de arranque confirmado (UEFI o BIOS)
- [ ] Otro dispositivo para leer el handbook durante la instalación

## Instalación base (VM)

| # | Paso | Hecho | Handbook |
|---|---|---|---|
| 1 | Preparar el host: qemu, libvirt, red default | [x] | — |
| 2 | Verificar la ISO con OpenPGP | [x] | [Signatures](https://www.gentoo.org/downloads/signatures/) |
| 3 | Crear la VM | [x] | — |
| 4 | Levantar sshd en el live y conectarse | [x] | [Networking](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Networking/es) |
| 5 | Particionar el disco | [x] | [Disks](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/es) |
| 6 | Formatear y montar | [x] | [Disks](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks/es) |
| 7 | Descargar y verificar el stage3 | [x] | [Stage](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/es) |
| 8 | Extraer el stage3 | [x] | [Stage](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/es) |
| 9 | Configurar `make.conf` | [x] | [Stage](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage/es) |
| 10 | Copiar `resolv.conf` y entrar al chroot | [x] | [Base](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/es) |
| 11 | Configurar `repos.conf` y sincronizar | [x] | [Base](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/es) |
| 12 | Elegir el perfil | [x] | [Base](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/es) |
| 13 | Actualizar `@world` | [x] | [Base](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base/es) |
| 14 | Configurar locales | [x] | [System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/es) |
| 15 | Escribir `/etc/fstab` | [x] | [System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/es) |
| 16 | Hostname y contraseña de root | [x] | [System](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/System/es) |
| 17 | Instalar fuentes del kernel | [x] | [Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/es) |
| 18 | Configurar el kernel (`nconfig`) | [x] | [Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/es) |
| 19 | Compilar e instalar el kernel | [x] | [Kernel](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Kernel/es) |
| 20 | Instalar GRUB | [x] | [Bootloader](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Bootloader/es) |
| 21 | Primer arranque | [x] | [Finalizing](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Finalizing/es) |

## Posterior al arranque

| # | Paso | Hecho | Detalle |
|---|---|---|---|
| 22 | Configurar `net.enp1s0` | [x] | `vm.md` §14 |
| 23 | Desbloquear la cuenta (`pam_faillock`) | [x] | `bitacora.md` |
| 24 | Habilitar `sshd`, `sysklogd`, `cronie`, `chronyd` | [x] | `vm.md` §15 |
| 25 | Sincronizar el árbol e instalar `gentoolkit` | [x] | `bitacora.md` |
| 26 | Primer `@world` (gcc, glibc) | [x] | `bitacora.md` |
| 27 | Limpiar distfiles (`eclean-dist -d`) | [ ] | [Portage tools](https://wiki.gentoo.org/wiki/Handbook:AMD64/Portage/Tools/es) |
| 28 | `emerge --depclean` | [ ] | [Portage](https://wiki.gentoo.org/wiki/Handbook:AMD64/Working/Portage/es) |
| 29 | `eselect news read` | [ ] | [News](https://wiki.gentoo.org/wiki/Project:News) |
| 30 | Actualizar el kernel a 7.x (opcional) | [ ] | [Kernel upgrade](https://wiki.gentoo.org/wiki/Kernel/Upgrade/es) |

## Instalación en hardware real

| # | Paso | Hecho | Detalle |
|---|---|---|---|
| 31 | Relevar el hardware | [x] | `hardware.md` |
| 32 | Backup del NVMe | [ ] | `hardware.md` |
| 33 | USB con la ISO | [ ] | `hardware.md` |
| 34 | Particionar con UEFI (ESP + swap + root) | [ ] | `hardware.md` |
| 35 | Stage3 y `make.conf` con `-march=native` | [ ] | `hardware.md` |
| 36 | Kernel con los drivers exactos | [ ] | `hardware.md` |
| 37 | GRUB con `--target=x86_64-efi` | [ ] | `hardware.md` |
| 38 | Escritorio: Xorg, i3, kitty, dmenu | [ ] | `hardware.md` |
| 39 | Bluetooth + audio (JBL) | [ ] | `hardware.md` |

## Documentación de referencia

- [Handbook completo (español)](https://wiki.gentoo.org/wiki/Handbook:AMD64/es)
- [Portage](https://wiki.gentoo.org/wiki/Portage)
- [USE flags](https://wiki.gentoo.org/wiki/USE_flag)
- [Kernel](https://wiki.gentoo.org/wiki/Kernel/es)
- [GRUB](https://wiki.gentoo.org/wiki/GRUB/es)
- [OpenRC](https://wiki.gentoo.org/wiki/OpenRC)
- [Bluetooth](https://wiki.gentoo.org/wiki/Bluetooth)
- [PipeWire](https://wiki.gentoo.org/wiki/PipeWire)
- [i3](https://wiki.gentoo.org/wiki/I3)
- [Binary packages](https://wiki.gentoo.org/wiki/Binary_package_guide)
