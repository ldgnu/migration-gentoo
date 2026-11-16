# Instalar en hardware real

La guía principal se hizo en una VM. Esto es lo que cambia cuando el destino es una
máquina física, y lo que hay que resolver antes de tocar un disco con datos.

## Antes de tocar nada

1. **Backup completo y verificado.** No "tengo las cosas en otro lado": un backup que se
   probó restaurando. El disco del host tiene ~400 GB en uso.
2. **Decidir el alcance:** reemplazo total de la distro actual, o dual boot en un disco
   aparte. Dual boot es más seguro y más lento de mantener.
3. **Averiguar el hardware real.** Con el sistema actual andando:

```
lspci -nnk | grep -A3 -E 'VGA|Ethernet|Network'
lsblk -o NAME,SIZE,MODEL
nproc
free -h
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
```

## Qué cambia respecto de la VM

| En la VM | En hardware real |
|---|---|
| Disco `vda` (virtio) | NVMe (`nvme0n1`) o SATA (`sda`) |
| Red virtio | `e1000e`, `r8169`, `iwlwifi` según placa |
| GPU virtual | `amdgpu` (Radeon), `i915` (Intel) |
| BIOS (SeaBIOS) | Probablemente UEFI |
| Sin firmware | `linux-firmware` y microcódigo hacen falta |
| `-march=skylake` | Igual, o `native` si no va a migrar |

## Drivers del kernel que no pueden faltar

Disco:

```
CONFIG_BLK_DEV_NVME=y      # si el disco es NVMe
CONFIG_SATA_AHCI=y         # si es SATA
```

Red:

```
CONFIG_E1000E=y            # Intel
CONFIG_R8169=y             # Realtek
CONFIG_IWLWIFI=m           # wifi Intel (requiere firmware)
```

Entrada y consola:

```
CONFIG_USB_HID=y
CONFIG_INPUT_EVDEV=y
CONFIG_FB_EFI=y            # consola en UEFI
CONFIG_DRM=y
CONFIG_DRM_AMDGPU=y        # o i915
```

Filesystem:

```
CONFIG_EXT4_FS=y
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
```

Si alguno de los del disco o del filesystem queda como módulo y no hay initramfs, el
sistema no arranca.

## Si la máquina es UEFI

Cambia el particionado y el bootloader:

| Partición | Tamaño | Tipo | Uso |
|---|---|---|---|
| p1 | 512 MiB | EFI System (EF00) | /efi o /boot |
| p2 | 4 GiB | swap | swap |
| p3 | resto | ext4 | / |

```
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo
```

Ya no hace falta la partición BIOS boot de 1 MiB, y `efibootmgr` pasa a tener sentido.

## Firmware y microcódigo

En hardware real sí sirven:

```
emerge --ask sys-kernel/linux-firmware sys-firmware/intel-microcode
```

Con `USE=initramfs` en esos paquetes y dracut configurado, el microcódigo se carga al
inicio. Sin eso, las mitigaciones de la CPU no se aplican hasta tarde.

## Riesgos concretos

- **Particionar el disco equivocado** es el error más caro. Antes de `cfdisk`, confirmar
  con `lsblk` y comparar tamaños y modelos.
- **Reemplazar la distro actual** implica reinstalar todo lo que hoy usás: contenedores,
  configuraciones, claves.
- **Un kernel sin el driver de disco** se detecta tarde: el sistema bootea y muere con
  `unable to mount root fs`.
- **Backup sin probar** no es backup.

## Estrategia recomendada

1. Terminar y validar la instalación en la VM.
2. Practicar una segunda vez en una VM limpia, siguiendo la guía sin improvisar.
3. Recién entonces, con backup verificado, instalar en hardware real.
4. Si se puede, en un disco distinto del que tiene los datos, con el disco original
   desconectado durante la instalación.
