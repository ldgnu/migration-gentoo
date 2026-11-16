# Cómo retomar

Procedimiento para volver al chroot después de apagar la VM. El sistema instalado vive en
el disco; lo que se pierde al apagar es el live y sus montajes.

## 1. Arrancar desde el CD

La VM todavía no bootea sola: no hay kernel ni bootloader instalados. En el menú de
SeaBIOS, `F12` o `Esc` para elegir el dispositivo de arranque, y seleccionar el CD.

## 2. Montar y entrar

```
swapon /dev/vda3
mount /dev/vda4 /mnt/gentoo
mount /dev/vda2 /mnt/gentoo/boot
arch-chroot /mnt/gentoo
```

`arch-chroot` monta `/proc`, `/sys`, `/dev` y `/run`, y copia `resolv.conf`. No hace falta
hacerlo a mano.

## 3. Verificar que quedó bien

```
findmnt /mnt/gentoo
findmnt /mnt/gentoo/boot
swapon --show
ls /usr/src
```

## Dónde quedamos

Estado al 2026-11-16:

- Particionado, formateo y montaje: listos.
- Stage3 extraído y verificado.
- Perfil: `default/linux/amd64/23.0/no-multilib`.
- `make.conf`, USE flags, locales: listos.
- Sistema base: 402 paquetes instalados.
- `fstab`, hostname y contraseña de root: listos.
- Bootloader: paquete instalado, `grub-install` pendiente con el target correcto (`/dev/vda`).
- Kernel: **no instalado**. `/usr/src` vacío.

## Lo que falta

1. `emerge --ask sys-kernel/gentoo-sources`
2. `eselect kernel set 1`
3. Configurar (`make localmodconfig` o partir de `/proc/config.gz`, después `make nconfig`)
4. `make -j6 && make modules_install && make install`
5. `grub-install /dev/vda`
6. `grub-mkconfig -o /boot/grub/grub.cfg`

Drivers que no pueden faltar y tienen que ser `=y` si no hay initramfs:
`VIRTIO_BLK`, `VIRTIO_PCI`, `EXT4_FS`, `DEVTMPFS`, `DEVTMPFS_MOUNT`.
