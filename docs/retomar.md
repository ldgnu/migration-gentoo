# Cómo retomar

En endymion hay dos escenarios, y solo uno requiere trabajo.

## El sistema arranca

Nada que hacer. GRUB arranca el kernel 7.3.5, OpenRC levanta los servicios y Sway queda
disponible en tty1. Si algo quedó raro después de una actualización, revisá primero:

```sh
uname -r
rc-status --all
dmesg --level=err,warn | tail -20
```

## El sistema no arranca: entrar desde el live

Con el USB de Gentoo y el sistema apagado. Las particiones son las de `configs/endymion/etc/fstab`;
los UUID están ahí para confirmar con `blkid`.

```sh
# 1. Montar el sistema instalado
swapon /dev/nvme0n1p2
mount /dev/nvme0n1p3 /mnt/gentoo
mount /dev/nvme0n1p1 /mnt/gentoo/efi
mount /dev/nvme0n1p4 /mnt/gentoo/home

# 2. Entrar
arch-chroot /mnt/gentoo
```

`arch-chroot` monta `/proc`, `/sys`, `/dev` y `/run`, y copia `resolv.conf`.

Antes de salir, o al terminar de arreglar:

```sh
exit
umount -R /mnt/gentoo
swapoff /dev/nvme0n1p2
reboot
```

## Si el problema es el arranque

| Síntoma | Qué mirar |
|---|---|
| No aparece la entrada Gentoo | `efibootmgr -v`; reinstalar con `grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo` |
| Aparece pero no bootea | `grub-mkconfig -o /boot/grub/grub.cfg` desde el chroot; revisar que el `initramfs` exista en `/boot` |
| Bootea y queda en `login:` sin red | `rc-service net.eno1 status`; `ip -br a` |
| Bootea sin gráficos | `eselect kernel list`, `ls /lib/modules`, y el log de `dmesg` |

Hay dos kernels instalados (7.3.5 y 6.18.63) y ambos están en el menú de GRUB: si el nuevo
falla, se elige el viejo desde "Advanced options".

## La documentación de la instalación original

El procedimiento de la VM (BIOS, `/dev/vda`) está en [`vm.md`](vm.md) como registro histórico.
No aplica a endymion, que es UEFI sobre `/dev/nvme0n1`.
