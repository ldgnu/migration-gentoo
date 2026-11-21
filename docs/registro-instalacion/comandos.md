# Comandos registrados

Comandos nuevos leídos de los historiales de bash. El chroot tiene que tener el historial
activado (ver `docs/estado/README.md`). Los comandos se agrupan por archivo de origen.

No se registran contraseñas: `passwd` aparece como comando, no como entrada.

## 2026-11-17 18:32:00Z — chroot-root (historial completo hasta ahora)

~~~text
# 2026-11-17 18:27:35Z
emerge --verbose --update --deep --newuse @world
# 2026-11-17 18:28:06Z
clear
# 2026-11-17 18:28:17Z
cd 
# 2026-11-17 18:28:18Z
ls
# 2026-11-17 18:28:35Z
cd /mnt/
# 2026-11-17 18:28:36Z
ls
# 2026-11-17 18:28:40Z
ll
# 2026-11-17 18:28:41Z
ls
# 2026-11-17 18:28:43Z
cd 
# 2026-11-17 18:29:10Z
cd /mnt/gentoo/
# 2026-11-17 18:29:17Z
exit
~~~

## 2026-11-17 18:45:00Z — chroot-root

~~~text
# 2026-11-17 18:44:44Z
clear

~~~

## 2026-11-17 18:45:21Z — chroot-root

~~~text
# 2026-11-17 18:45:02Z
emerge --info | grep ^USE

~~~

## 2026-11-17 18:45:41Z — live-gentoo

~~~text
lsblk 
lsblk /dev/nvme0n1

~~~

## 2026-11-17 18:48:43Z — chroot-root

~~~text
# 2026-11-17 18:45:25Z
nano /etc/portage/make.conf

~~~

## 2026-11-17 18:49:44Z — chroot-root

~~~text
# 2026-11-17 18:49:27Z
clear
# 2026-11-17 18:49:33Z
[ -d /sys/firmware/efi ] && echo "UEFI OK" || echo "¡Estás en BIOS!"
# 2026-11-17 18:49:33Z
efibootmgr -v

~~~

## 2026-11-17 18:50:24Z — chroot-root

~~~text
# 2026-11-17 18:50:09Z
lspci -k > /tmp/lspci-live.txt
# 2026-11-17 18:50:09Z
lsusb > /tmp/lsusb-live.txt
# 2026-11-17 18:50:09Z
lsmod > /tmp/lsmod-live.txt
# 2026-11-17 18:50:09Z
zcat /proc/config.gz > /tmp/config-live

~~~

## 2026-11-17 18:53:47Z — chroot-root

~~~text
# 2026-11-17 18:53:31Z
emerge -pv media-video/pipewire

~~~

## 2026-11-17 18:54:27Z — chroot-root

~~~text
# 2026-11-17 18:54:15Z
clear

~~~

## 2026-11-17 19:11:26Z — chroot-root

~~~text
clear
export PS1="(chroot) ${PS1}"
clear
emerge --ask --verbose --oneshot app-portage/mirrorselect
mkdir -p /etc/portage/repos.conf
cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf
emerge --ask --verbose --oneshot app-portage/mirrorselect
mirrorselect -i -o >> /etc/portage/make.conf
nano /etc/portage/repos.conf/gentoo.conf
emerge --sync
emerge --ask --verbose --oneshot app-portage/mirrorselect
mirrorselect -i -o >> /etc/portage/make.conf
eselect profile show
screen -S world 
emerge --ask 
emerge --ask --verbose --oneshot app-misc/screen
cd /etc/portage/binrepos.conf/
ls
nano gentoo.conf 
cĺear
mkdir -p /etc/portage/sets
cat > /etc/portage/sets/binarios <<'EOF'
sys-devel/gcc
sys-devel/clang
dev-lang/rust
www-client/firefox
app-office/libreoffice
EOF

emerge -pv --getbinpkg sys-devel/gcc
cd /etc/portage/binrepos.conf/
ls
nano gentoo.conf 
nano gentoo.conf 
mirrorselect -i -o >> /etc/portage/make.conf
cd 
ls
cd /etc/
ls
cd portage/
ls
clear
nano make.conf 
emerge --info | grep -i GENTOO_MIRRORS
screen -S world
emerge --verbose --update --deep --newuse @world
emerge --verbose --update --deep --newuse @world
emerge --depclean
eselect news read
echo 'ACCEPT_KEYWORDS="~amd64"' >> /etc/portage/make.conf
emerge --sync
emerge --ask --verbose --update --deep --newuse @world
exit

~~~

## 2026-11-17 19:11:47Z — chroot-root

~~~text
# 2026-11-17 19:11:40Z
source /etc/profile
# 2026-11-17 19:11:44Z
hash -r
# 2026-11-17 19:11:47Z
exit

~~~

## 2026-11-17 19:12:28Z — chroot-root

~~~text
# 2026-11-17 19:12:12Z
clear

~~~

## 2026-11-17 19:12:49Z — chroot-root

~~~text
# 2026-11-17 19:12:38Z
export PS1="(chroot) ${PS1}"
# 2026-11-17 19:12:49Z
eselect news read

~~~

## 2026-11-17 19:13:09Z — chroot-root

~~~text
# 2026-11-17 19:13:00Z
dispatch-conf

~~~

## 2026-11-17 19:13:29Z — chroot-root

~~~text
# 2026-11-17 19:13:09Z
emerge --ask --depclean
# 2026-11-17 19:13:19Z
emerge --ask @preserved-rebuild

~~~

## 2026-11-17 19:13:50Z — chroot-root

~~~text
# 2026-11-17 19:13:39Z
emerge --update --deep --newuse @world

~~~

## 2026-11-17 19:16:13Z — chroot-root

~~~text
# 2026-11-17 19:16:05Z
cat > /etc/fstab <<'EOF'
UUID=f58fb93f-1681-423f-a6f2-ce6a6e8d9752  /      ext4  defaults,noatime  0 1
UUID=43f0b8b6-4345-4494-b4b9-5c5be26f7e6b  /home  ext4  defaults,noatime  0 2
UUID=CBD5-7071                             /efi   vfat  umask=0077        0 2
UUID=a843caf6-6f1e-4712-b151-b3e275149399  none   swap  sw                0 0
EOF

# 2026-11-17 19:16:05Z
findmnt --verify

~~~

## 2026-11-17 19:16:34Z — chroot-root

~~~text
# 2026-11-17 19:16:19Z
nano /etc/fstab 

~~~

## 2026-11-17 19:16:54Z — chroot-root

~~~text
# 2026-11-17 19:16:34Z
blkid 
# 2026-11-17 19:16:39Z
blkid  | grep UID
# 2026-11-17 19:16:49Z
blkid  | grep UUID

~~~

## 2026-11-17 19:17:14Z — chroot-root

~~~text
# 2026-11-17 19:17:07Z
CLEAR

~~~

## 2026-11-17 19:17:56Z — chroot-root

~~~text
# 2026-11-17 19:17:51Z
clear

~~~

## 2026-11-17 19:18:16Z — chroot-root

~~~text
# 2026-11-17 19:17:58Z
nano /etc/fstab 

~~~

## 2026-11-17 19:18:37Z — chroot-root

~~~text
# 2026-11-17 19:18:22Z
cat  /etc/fstab 
# 2026-11-17 19:18:24Z
blkid /dev/nvme0n1p*

~~~

## 2026-11-17 19:29:27Z — chroot-root

~~~text
# 2026-11-17 19:19:28Z
nano /etc/conf.d/hostname 

~~~

## 2026-11-17 19:30:08Z — chroot-root

~~~text
# 2026-11-17 19:29:55Z
nano /etc/hostname

~~~

## 2026-11-17 19:30:28Z — chroot-root

~~~text
# 2026-11-17 19:30:06Z
nano /etc/hostname

~~~

## 2026-11-17 19:31:50Z — chroot-root

~~~text
# 2026-11-17 19:30:24Z
nano /etc/hosts 

~~~

## 2026-11-17 19:32:11Z — chroot-root

~~~text
# 2026-11-17 19:31:45Z
passwd

~~~

## 2026-11-17 19:32:32Z — chroot-root

~~~text
# 2026-11-17 19:32:14Z
nano /etc/conf.d/keymaps 

~~~

## 2026-11-17 19:33:12Z — chroot-root

~~~text
# 2026-11-17 19:32:38Z
nano /etc/timezone
# 2026-11-17 19:33:11Z
emerge --config sys-libs/timezone-data

~~~

## 2026-11-17 19:33:33Z — chroot-root

~~~text
# 2026-11-17 19:33:23Z
nano /etc/localtime 

~~~

## 2026-11-17 19:33:53Z — chroot-root

~~~text
# 2026-11-17 19:33:45Z
date

~~~

## 2026-11-17 19:36:36Z — chroot-root

~~~text
# 2026-11-17 19:34:04Z
nano /etc/timezone

~~~

## 2026-11-17 19:36:57Z — chroot-root

~~~text
# 2026-11-17 19:36:27Z
nano /etc/locale.gen
# 2026-11-17 19:36:44Z
locale gen
# 2026-11-17 19:36:49Z
locale-gen
# 2026-11-17 19:36:53Z
date

~~~

## 2026-11-17 19:37:17Z — chroot-root

~~~text
# 2026-11-17 19:37:04Z
eselect locale set 
# 2026-11-17 19:37:15Z
eselect locale set es_AR.utf8

~~~
