# Estado actual de la instalación

Corte: 2026-11-17 20:34:27Z

# Foto del sistema instalado

Raíz: `/mnt/gentoo`

### Montajes

/mnt/gentoo /dev/nvme0n1p3 ext4 rw,relatime
/mnt/gentoo/dev udev devtmpfs rw,nosuid,relatime,size=10240k,nr_inodes=2012213,mode=755,inode64
/mnt/gentoo/dev udev devtmpfs rw,nosuid,relatime,size=10240k,nr_inodes=2012213,mode=755,inode64
/mnt/gentoo/dev/pts devpts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000
/mnt/gentoo/dev/pts devpts devpts rw,nosuid,noexec,relatime,gid=5,mode=620,ptmxmode=000
/mnt/gentoo/dev/shm shm tmpfs rw,nosuid,nodev,relatime,inode64
/mnt/gentoo/dev/shm shm tmpfs rw,nosuid,nodev,relatime,inode64
/mnt/gentoo/efi /dev/nvme0n1p1 vfat rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,errors=remount-ro
/mnt/gentoo/etc/resolv.conf LiveOS_rootfs[/etc/resolv.conf] overlay rw,relatime,lowerdir=/run/rootfsbase,upperdir=/run/overlayfs,workdir=/run/ovlwork,uuid=on
/mnt/gentoo/etc/resolv.conf LiveOS_rootfs[/etc/resolv.conf] overlay rw,relatime,lowerdir=/run/rootfsbase,upperdir=/run/overlayfs,workdir=/run/ovlwork,uuid=on
/mnt/gentoo/home /dev/nvme0n1p4 ext4 rw,relatime
/mnt/gentoo/proc proc proc rw,nosuid,nodev,noexec,relatime
/mnt/gentoo/proc proc proc rw,nosuid,nodev,noexec,relatime
/mnt/gentoo/run tmpfs tmpfs rw,nosuid,nodev,noexec,mode=755,inode64
/mnt/gentoo/run tmpfs tmpfs rw,nosuid,nodev,noexec,mode=755,inode64
/mnt/gentoo/sys sys sysfs ro,nosuid,nodev,noexec,relatime
/mnt/gentoo/sys sys sysfs ro,nosuid,nodev,noexec,relatime
/mnt/gentoo/sys/firmware/efi/efivars efivarfs efivarfs rw,nosuid,nodev,noexec,relatime
/mnt/gentoo/sys/firmware/efi/efivars efivarfs efivarfs rw,nosuid,nodev,noexec,relatime
/mnt/gentoo/tmp tmp tmpfs rw,nosuid,nodev,inode64
/mnt/gentoo/tmp tmp tmpfs rw,nosuid,nodev,inode64

### Swap activa

/dev/nvme0n1p2 16G 316.5M -1

### Particiones del disco destino

nvme0n1 476.9G disk   
nvme0n1p1 1G part vfat  CBD5-7071
nvme0n1p2 16G part swap  a843caf6-6f1e-4712-b151-b3e275149399
nvme0n1p3 100G part ext4 root f58fb93f-1681-423f-a6f2-ce6a6e8d9752
nvme0n1p4 359.9G part ext4 home 43f0b8b6-4345-4494-b4b9-5c5be26f7e6b

### fstab

UUID=f58fb93f-1681-423f-a6f2-ce6a6e8d9752  /      ext4  defaults,noatime  0 1
UUID=43f0b8b6-4345-4494-b4b9-5c5be26f7e6b  /home  ext4  defaults,noatime  0 2
UUID=CBD5-7071                             /efi   vfat  umask=0077        0 2
UUID=a843caf6-6f1e-4712-b151-b3e275149399  none   swap  sw                0 0

### Hostname

endymion

conf.d/hostname (activo):
hostname="endymion"

### Zona horaria

localtime -> /usr/share/zoneinfo/America/Argentina/Cordoba
timezone: America/Argentina/Cordoba

### Locale

env.d/02locale:
# Configuration file for eselect
# This file has been automatically generated.
LANG="es_AR.utf8"

locale.gen (activas):
en_US.UTF-8 UTF-8
es_AR.UTF-8 UTF-8

### Cuentas

root: con clave
usuarios UID>=1000:
wheel: root

### Perfil de Portage

/var/db/repos/gentoo/profiles/default/linux/amd64/23.0

### make.conf

COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"

MAKEOPTS="-j8 -l12"
EMERGE_DEFAULT_OPTS="--jobs=3 --load-average=12"

LC_MESSAGES=C.UTF-8
ACCEPT_LICENSE="-* @FREE @BINARY-REDISTRIBUTABLE"

GENTOO_MIRRORS="https://umbriel.br.ext.planetunix.net/pub/gentoo/ \
    https://br.mirrors.cicku.me/gentoo/ \
    https://distfiles.gentoo.org/"
ACCEPT_KEYWORDS="~amd64"

### package.use

--- etc/portage/package.use/installkernel
sys-kernel/installkernel dracut grub


### package.license

(ausente)

### repos.conf/gentoo.conf

[DEFAULT]
main-repo = gentoo

[gentoo]
location = /var/db/repos/gentoo
sync-type = rsync
sync-uri = rsync://rsync.gentoo.org/gentoo-portage
auto-sync = yes
sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 3
sync-openpgp-key-package = sec-keys/openpgp-keys-gentoo-release
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
sync-openpgp-keyserver = hkps://keys.gentoo.org
sync-openpgp-key-refresh-retry-count = 40
sync-openpgp-key-refresh-retry-overall-timeout = 1200
sync-openpgp-key-refresh-retry-delay-exp-base = 2
sync-openpgp-key-refresh-retry-delay-max = 60
sync-openpgp-key-refresh-retry-delay-mult = 4
sync-webrsync-verify-signature = yes
sync-git-verify-commit-signature = true

### Red

config_eno1="dhcp"
interfaces del live (sin IP):
eno1 UP
lo UNKNOWN

### Servicios en runlevels

/etc/runlevels/boot/binfmt -> /etc/init.d/binfmt
/etc/runlevels/boot/bootmisc -> /etc/init.d/bootmisc
/etc/runlevels/boot/fsck -> /etc/init.d/fsck
/etc/runlevels/boot/hostname -> /etc/init.d/hostname
/etc/runlevels/boot/hwclock -> /etc/init.d/hwclock
/etc/runlevels/boot/keymaps -> /etc/init.d/keymaps
/etc/runlevels/boot/localmount -> /etc/init.d/localmount
/etc/runlevels/boot/loopback -> /etc/init.d/loopback
/etc/runlevels/boot/modules -> /etc/init.d/modules
/etc/runlevels/boot/mtab -> /etc/init.d/mtab
/etc/runlevels/boot/procfs -> /etc/init.d/procfs
/etc/runlevels/boot/root -> /etc/init.d/root
/etc/runlevels/boot/save-keymaps -> /etc/init.d/save-keymaps
/etc/runlevels/boot/save-termencoding -> /etc/init.d/save-termencoding
/etc/runlevels/boot/seedrng -> /etc/init.d/seedrng
/etc/runlevels/boot/swap -> /etc/init.d/swap
/etc/runlevels/boot/sysctl -> /etc/init.d/sysctl
/etc/runlevels/boot/systemd-tmpfiles-setup -> /etc/init.d/systemd-tmpfiles-setup
/etc/runlevels/boot/termencoding -> /etc/init.d/termencoding
/etc/runlevels/default/local -> /etc/init.d/local
/etc/runlevels/default/net.eno1 -> /etc/init.d/net.eno1
/etc/runlevels/default/netmount -> /etc/init.d/netmount
/etc/runlevels/default/sshd -> /etc/init.d/sshd
/etc/runlevels/nonetwork/local -> /etc/init.d/local
/etc/runlevels/shutdown/killprocs -> /etc/init.d/killprocs
/etc/runlevels/shutdown/mount-ro -> /etc/init.d/mount-ro
/etc/runlevels/shutdown/savecache -> /etc/init.d/savecache
/etc/runlevels/sysinit/cgroups -> /etc/init.d/cgroups
/etc/runlevels/sysinit/devfs -> /etc/init.d/devfs
/etc/runlevels/sysinit/dmesg -> /etc/init.d/dmesg
/etc/runlevels/sysinit/kmod-static-nodes -> /etc/init.d/kmod-static-nodes
/etc/runlevels/sysinit/sysfs -> /etc/init.d/sysfs
/etc/runlevels/sysinit/systemd-tmpfiles-setup-dev -> /etc/init.d/systemd-tmpfiles-setup-dev
/etc/runlevels/sysinit/udev -> /etc/init.d/udev
/etc/runlevels/sysinit/udev-trigger -> /etc/init.d/udev-trigger

### Paquetes

total: 322

últimos instalados/actualizados:
app-alternatives/bc-0
media-libs/freetype-2.15.0
sys-fs/lvm2-2.03.39
sys-boot/efibootmgr-18-r2
sys-kernel/dracut-112
sys-kernel/gentoo-sources-6.18.63
sys-kernel/linux-firmware-20261019
sys-boot/grub-2.16-r1
sys-kernel/installkernel-70-r1
sys-fs/dosfstools-4.2
dev-libs/libevent-2.1.13
app-misc/tmux-3.8

### Kernel y bootloader

usr/src:
linux
linux-6.18.63-gentoo

lib/modules:
6.18.63-gentoo-gentoo-dist

boot:
config-6.18.63-gentoo-gentoo-dist (232377 bytes)
initramfs-6.18.63-gentoo-gentoo-dist.img (9449258 bytes)
vmlinuz-6.18.63-gentoo-gentoo-dist (28017152 bytes)
System.map-6.18.63-gentoo-gentoo-dist (15467115 bytes)
amd-uc.img (306176 bytes)

efi:
EFI/Gentoo/grubx64.efi (167936 bytes)

paquetes sys-boot:
efibootmgr-18-r2
grub-2.16-r1
grub-themes-gentoo-1.0-r2

paquetes sys-kernel:
dracut-112
gentoo-sources-6.18.63
installkernel-70-r1
linux-firmware-20261019
linux-headers-7.1

### Entradas UEFI

BootCurrent: 000B
Timeout: 1 seconds
BootOrder: 0000,0008,000A,000B
Boot0000* Gentoo	HD(1,GPT,7bb9c7f1-d6a9-4082-9007-be24474d4cf8,0x800,0x200000)/\EFI\Gentoo\grubx64.efi
Boot0008* Windows Boot Manager	HD(1,GPT,da44bdcc-d79a-462b-b504-7859cc1d199d,0x800,0x82000)/\EFI\MICROSOFT\BOOT\BOOTMGFW.EFI0000424f
Boot000A* UEFI: KingstonDataTraveler 3.0PMAP, Partition 1	PciRoot(0x0)/Pci(0x14,0x0)/USB(18,0)/HD(1,MBR,0x2cadc550,0x800,0x7345800)0000424f
Boot000B* UEFI: KingstonDataTraveler 3.0PMAP, Partition 2	PciRoot(0x0)/Pci(0x14,0x0)/USB(18,0)/HD(2,MBR,0x2cadc550,0x7346000,0x10000)0000424f

### emerge.log (últimas 20 líneas)

1794947529: Started emerge on: nov 17, 2026 17:32:09
1794947529:  *** emerge --ask --jobs=3 --load-average=12.0 --regex-search-auto=y tmux
1794947534:  >>> emerge (1 of 2) dev-libs/libevent-2.1.13 to /
1794947535:  === (1 of 2) Cleaning (dev-libs/libevent-2.1.13::/var/db/repos/gentoo/dev-libs/libevent/libevent-2.1.13.ebuild)
1794947535:  === (1 of 2) Compiling/Merging (dev-libs/libevent-2.1.13::/var/db/repos/gentoo/dev-libs/libevent/libevent-2.1.13.ebuild)
1794947548:  === (1 of 2) Merging (dev-libs/libevent-2.1.13::/var/db/repos/gentoo/dev-libs/libevent/libevent-2.1.13.ebuild)
1794947548:  >>> AUTOCLEAN: dev-libs/libevent:0
1794947548:  === (1 of 2) Post-Build Cleaning (dev-libs/libevent-2.1.13::/var/db/repos/gentoo/dev-libs/libevent/libevent-2.1.13.ebuild)
1794947548:  ::: completed emerge (1 of 2) dev-libs/libevent-2.1.13 to /
1794947548:  >>> emerge (2 of 2) app-misc/tmux-3.8 to /
1794947548:  === (2 of 2) Cleaning (app-misc/tmux-3.8::/var/db/repos/gentoo/app-misc/tmux/tmux-3.8.ebuild)
1794947548:  === (2 of 2) Compiling/Merging (app-misc/tmux-3.8::/var/db/repos/gentoo/app-misc/tmux/tmux-3.8.ebuild)
1794947564:  === (2 of 2) Merging (app-misc/tmux-3.8::/var/db/repos/gentoo/app-misc/tmux/tmux-3.8.ebuild)
1794947565:  >>> AUTOCLEAN: app-misc/tmux:0
1794947565:  === (2 of 2) Updating world file (app-misc/tmux-3.8)
1794947565:  === (2 of 2) Post-Build Cleaning (app-misc/tmux-3.8::/var/db/repos/gentoo/app-misc/tmux/tmux-3.8.ebuild)
1794947565:  ::: completed emerge (2 of 2) app-misc/tmux-3.8 to /
1794947565:  *** Finished. Cleaning up...
1794947565:  *** exiting successfully.
1794947565:  *** terminating.

### emerge-fetch.log (últimas 8 líneas)

   700K .......... .......... .......... .......... .......... 85% 1,27M 0s
   750K .......... .......... .......... .......... .......... 91% 23,0M 0s
   800K .......... .......... .......... .......... .......... 97% 75,5M 0s
   850K .......... .......... ....                            100% 47,5M=0,3s

2026-11-17 17:32:16 (2,48 MB/s) - ‘/var/cache/distfiles/tmux-3.8.tar.gz.__download__’ saved [895926/895926]

 * tmux-3.8.tar.gz BLAKE2B SHA512 size ;-) ...                           [ ok ]
