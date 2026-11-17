# Instalación en hardware real — esta máquina

Datos relevados del sistema actual (CachyOS) con `lspci`, `lsusb`, `lsblk` y `lscpu`.
Reemplazan las suposiciones de la versión genérica de esta guía.

## Hardware

| Componente | Modelo | Driver |
|---|---|---|
| CPU | Intel Core i5-10400F (6c/12t, Comet Lake) | `intel_pstate`, `skl_uncore` |
| GPU | AMD Radeon RX 6600 (Navi 23) | `amdgpu` |
| Audio GPU | AMD Navi 21/23 HDMI/DP | `snd_hda_intel` |
| Audio placa | Intel 400 Series HD Audio | `snd_hda_intel` |
| Red | Intel 400 Series GbE | `e1000e` |
| Disco principal | WD PC SN740 512 GB (NVMe) | `nvme` |
| SATA | Intel 400 Series AHCI | `ahci` |
| USB | Intel xHCI 3.2 Gen 2x1 | `xhci_pci` |
| SMBus | Intel 400 Series | `i2c_i801` |

## Firmware: UEFI

El sistema actual arranca en **UEFI**, no en BIOS. Eso cambia dos cosas respecto de la VM:

1. Hace falta una **EFI System Partition** (en este equipo ya existe: `nvme0n1p1`, 4 GB, vfat).
2. El bootloader se instala con `--target=x86_64-efi`, y `efibootmgr` pasa a ser útil.

Sin Secure Boot, como se decidió. Eso evita firmar kernel y módulos.

## Discos

| Disco | Tamaño | Contenido actual |
|---|---|---|
| `nvme0n1` | 476 GB | CachyOS: p1 4G EFI + p2 472G LUKS/btrfs |
| `sda` | 465 GB | NTFS, datos (`/mnt/PirateGames`) |
| `sdb` | 931 GB | exFAT, datos (`/mnt/PirateNW`) |
| `sdc` | 111 GB | Windows: p1 EFI 260M, p2 MSR, p3 NTFS |

**El disco de destino es `nvme0n1`.** Instalar ahí implica perder CachyOS y todo lo que
tiene adentro. Los otros tres discos no se tocan si se elige bien el dispositivo.

## Drivers obligatorios en el kernel

Si alguno de estos falta, el sistema no arranca o queda sin hardware:

```
CONFIG_EFI=y
CONFIG_EFI_STUB=y
CONFIG_BLK_DEV_NVME=y        # disco raíz
CONFIG_EXT4_FS=y             # sistema de archivos
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_VFAT_FS=y             # partición EFI si se monta
CONFIG_FB_EFI=y              # consola en UEFI
CONFIG_USB_XHCI_HCD=y        # todos los periféricos
CONFIG_USB_HID=y
CONFIG_HID_GENERIC=y
CONFIG_INPUT_EVDEV=y
CONFIG_E1000E=y              # red
CONFIG_DRM=y
CONFIG_DRM_AMDGPU=y          # GPU (consola y 3D)
CONFIG_SND=y
CONFIG_SND_HDA_INTEL=y       # audio
CONFIG_SND_USB_AUDIO=y       # headset USB
CONFIG_SATA_AHCI=y           # discos SATA de datos
CONFIG_NTFS3_FS=m            # leer los discos NTFS
CONFIG_EXFAT_FS=m            # leer el disco exFAT
```

Bluetooth (adaptador USB TP-Link):

```
CONFIG_BT=m
CONFIG_BT_HCIBTUSB=m
```

## Audio Bluetooth (auriculares JBL)

Los auriculares **no tienen driver propio**. Lo que se configura es esto:

- **El adaptador** (TP-Link USB, `2357:0604`): driver `btusb`, que es kernel.
- **El stack Bluetooth**: kernel + BlueZ en userspace.
- **El audio**: PipeWire o PulseAudio con soporte A2DP. No es kernel.

En el kernel, `Networking support → Bluetooth subsystem support → Bluetooth device drivers →
HCI USB driver`.

En userspace:

```
net-wireless/bluez
media-video/pipewire[bluetooth]
media-libs/libfreeaptx      # códecs A2DP, opcional
```

Y el servicio `bluetooth` en el runlevel default. Con eso aparecen los JBL en `bluetoothctl`.

Si no carga `btusb`, el adaptador no existe para el sistema y no hay forma de conectar nada.

## Rutas del menú del kernel

Todo lo de arriba, ubicado donde se toca. `make nconfig` o `menuconfig`:

| Qué | Ruta |
|---|---|
| EFI | `Processor type and features → EFI runtime service support` |
| Consola EFI | `Device Drivers → Graphics support → EFI framebuffer` |
| NVMe | `Device Drivers → NVME Support` |
| SATA/AHCI | `Device Drivers → Serial ATA and Parallel ATA drivers → AHCI SATA support` |
| Red Intel | `Device Drivers → Network device support → Ethernet driver support → Intel devices → Intel PRO/1000 PCI-Express` |
| GPU AMD | `Device Drivers → Graphics support → AMD GPU` |
| Audio HDA | `Device Drivers → Sound card support → Advanced Linux Sound Architecture → HD-Audio → HD Audio PCI` |
| Audio USB | `Device Drivers → Sound card support → ALSA → USB sound devices` |
| USB xHCI | `Device Drivers → USB support → xHCI HCD` |
| HID | `Device Drivers → HID support → USB HID support` + `Generic HID driver` |
| Bluetooth | `Networking support → Bluetooth subsystem support → HCI USB driver` |
| ext4 | `File systems → Ext4` |
| vfat | `File systems → DOS/FAT/EXFAT/NTFS → VFAT` |
| exFAT | `File systems → DOS/FAT/EXFAT/NTFS → EXFAT` |
| NTFS | `File systems → DOS/FAT/EXFAT/NTFS → NTFS3` |

Atajo para no pelear con 3000 opciones: `make localmodconfig` desde el live. Toma los módulos
que el kernel del live tiene cargados y deja seleccionado exactamente lo que esta máquina
necesita. Después se revisa con `nconfig` y se fija en `=y` lo que va en el disco y en el
filesystem.


## Periféricos conectados hoy

| Dispositivo | ID | Módulo |
|---|---|---|
| Apple Aluminium Keyboard | `05ac:024f` | `usbhid` (`hid-apple` opcional) |
| Teclado/mouse inalámbrico YICHIP | `3151:3022` | `usbhid` |
| Dongle F108Pro | — | `usbhid` |
| Headset Redragon | `0d8c:0173` | `snd-usb-audio` |
| Adaptador Bluetooth TP-Link | `2357:0604` | `btusb` |

Todos son USB HID o audio USB: con `USB_HID`, `HID_GENERIC` y `SND_USB_AUDIO` alcanza.
No hay wifi en esta máquina.

## Qué compilar y qué no

La idea de "rendimiento a full" se logra con `-march=native` y USE flags ajustados, no con
compilar todo. Un binario oficial compilado con `-O2` y x86-64-v3 rinde prácticamente igual
que uno compilado en casa.

**Compilar (vale la pena):**

- Paquetes con tus USE flags: sin soporte de escritorio, con lo justo.
- Paquetes chicos donde el binario no existe o no coincide.
- El kernel, si se quiere control real (como en la VM).

**Bajar binario (no vale la pena compilar):**

| Paquete | Por qué |
|---|---|
| `sys-devel/gcc` | 40+ minutos, cero ganancia real |
| `sys-devel/clang` / `llvm` | horas y RAM |
| `dev-lang/rust` | 1-2 horas, y el binario es idéntico |
| `www-client/firefox` / `chromium` | 2+ horas, y los binarios oficiales ya están optimizados |
| `app-office/libreoffice` | horas, sin diferencia perceptible |
| `sys-kernel/*-bin` | si se elige dist-kernel |
| `sys-firmware/*` | firmware, no se compila |

El binhost oficial de Gentoo cubre x86-64 y x86-64-v3. Para el resto, `emerge` compila.

## Paquetes indispensables

Base mínima para un escritorio liviano con i3, sin arrastrar GNOME ni KDE:

```
sys-apps/portage
app-admin/sudo
app-shells/bash-completion
net-misc/dhcpcd
net-misc/netifrc
sys-apps/mlocate
app-admin/sysklogd
sys-process/cronie
net-misc/chrony
sys-boot/grub
app-portage/gentoolkit
app-misc/screen

# escritorio
x11-base/xorg-server
x11-wm/i3
x11-terms/kitty
x11-misc/dmenu
x11-misc/picom
media-fonts/dejavu
media-fonts/noto
```

Todo lo demás se agrega cuando se necesite.

## Checklist antes de formatear

1. **Backup de CachyOS**: lo que haya en el NVMe que no esté en otro lado. Los otros discos
   de datos no se tocan, pero conviene tener el backup igual.
2. **USB con la ISO** de Gentoo (minimal o LiveGUI), verificada con GPG.
3. **Confirmar el modo de arranque**: UEFI, Secure Boot desactivado en el firmware.
4. **Anotar los UUID** de los discos de datos si se van a montar en el `fstab`.
5. **Tener otra máquina o el celular** para leer el handbook durante la instalación.
6. Saber que `nvme0n1p1` es la partición EFI actual y que se puede reutilizar (4 GB, vfat)
   o reformatear.

## Orden de instalación en este equipo

1. Arrancar del USB en UEFI.
2. Particionar `nvme0n1`: EFI 1G, swap 8G, root resto (ext4).
3. Stage3, `make.conf` con `-march=native`, chroot.
4. Perfil `default/linux/amd64/23.0` (multilib, sin escritorio al principio).
5. Kernel manual con los `CONFIG_*` de arriba, o `gentoo-sources` + `localmodconfig`.
6. `grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=Gentoo`.
7. Primer arranque, red, usuario, i3.

## Riesgos

- **Elegir mal el disco** en `cfdisk` es el error más caro. Confirmar con `lsblk` antes.
- **UEFI con la partición EFI mal montada**: `grub-install` falla o el sistema no aparece en
  el menú del firmware.
- **Sin `CONFIG_BLK_DEV_NVME`**: el kernel no ve el disco y muere con `unable to mount root fs`.
- **Sin `amdgpu`**: consola a 640x480 y sin aceleración.
- **No es reversible** sin backup: el NVMe pierde CachyOS.
