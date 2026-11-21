#!/bin/sh
# capturar-configs.sh — foto de la configuración viva de endymion
#
# Uso:
#   ./scripts/capturar-configs.sh            # escribe en configs/endymion/
#
# Qué hace: copia los archivos de configuración que definen esta instalación y genera un
# inventario del hardware y de los paquetes. Es idempotente: reemplaza el destino.
#
# Qué NO copia, a propósito: /etc/shadow, /etc/gshadow, /etc/portage/gnupg (tiene la clave
# de firma de binarios y su passphrase), claves de host SSH, estado de Tailscale y cualquier
# archivo de ~/.config que pueda tener tokens. Si algo de eso hace falta, se restaura a mano.

set -eu

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export PATH

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
DEST="$REPO/configs/endymion"

case "$DEST" in
  */configs/endymion) ;;
  *) echo "destino inesperado: $DEST" >&2; exit 1 ;;
esac

rm -rf "$DEST"
mkdir -p "$DEST"

copy() {
  for src in "$@"; do
    [ -e "$src" ] || continue
    mkdir -p "$DEST$(dirname "$src")"
    cp -a "$src" "$DEST$src" 2>/dev/null || echo "omitido (sin permiso): $src" >&2
  done
}

# Archivos que necesitan root para leerse (modo 0440). Se copian con sudo si está disponible.
copy_root() {
  for src in "$@"; do
    [ -e "$src" ] || continue
    mkdir -p "$DEST$(dirname "$src")"
    if [ -r "$src" ]; then
      cp -a "$src" "$DEST$src"
    elif sudo -n true 2>/dev/null; then
      sudo -n cat "$src" > "$DEST$src"
    else
      echo "omitido (sin permiso): $src" >&2
    fi
  done
}

# --- Portage ---
copy /etc/portage/make.conf \
     /etc/portage/package.env \
     /etc/portage/package.use \
     /etc/portage/env \
     /etc/portage/package.license \
     /etc/portage/package.accept_keywords \
     /etc/portage/sets \
     /etc/portage/repos.conf \
     /etc/portage/binrepos.conf \
     /var/lib/portage/world

# --- sistema ---
copy /etc/fstab \
     /etc/hostname \
     /etc/hosts \
     /etc/timezone \
     /etc/locale.gen \
     /etc/rc.conf \
     /etc/default/grub \
     /etc/conf.d/hostname \
     /etc/conf.d/net \
     /etc/conf.d/keymaps \
     /etc/conf.d/hwclock \
     /etc/conf.d/consolefont \
     /etc/local.d

# --- archivos que solo root puede leer ---
copy_root /etc/sudoers

# --- kernel en uso ---
for cfg in /boot/config-$(uname -r); do
  copy "$cfg"
done

# --- escritorio ---
copy /home/ldgnu/.config/sway/config
for f in /home/ldgnu/.local/bin/sway-* /home/ldgnu/.local/bin/wmenu-* /home/ldgnu/.local/bin/tui-run; do
  copy "$f"
done

# --- inventario ---
INV="$DEST/inventario"
mkdir -p "$INV"
inv() {
  file=$1; shift
  { "$@" || echo "(no disponible)"; } > "$INV/$file" 2>&1
}
{
  echo "# generado por scripts/capturar-configs.sh"
  date -Is
} > "$INV/fecha.txt"
inv uname.txt        uname -a
inv cmdline.txt      cat /proc/cmdline
inv lsblk.txt        lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
inv blkid.txt        blkid
inv efibootmgr.txt   efibootmgr -v
inv lspci.txt        lspci -nnk
inv lsusb.txt        lsusb
inv lsmod.txt        lsmod
inv rc-update.txt    rc-update show
inv rc-status.txt    rc-status --all
inv df.txt           df -hT
inv free.txt         free -h
inv kernels.txt      eselect kernel list
inv paquetes.txt     qlist -ICv
inv portage-resumen.txt sh -c 'emerge --info 2>/dev/null | grep -E "^(USE|CFLAGS|CXXFLAGS|MAKEOPTS|ABI_X86|ACCEPT_KEYWORDS|VIDEO_CARDS|CPU_FLAGS_X86)="'
inv dmi.txt          sh -c 'for f in /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name /sys/class/dmi/id/bios_version /sys/class/dmi/id/bios_date; do printf "%s: " "$(basename "$f")"; cat "$f" 2>/dev/null || echo "?"; done'

# --- manifiesto con hashes ---
{
  echo "# Manifiesto — configuración de endymion"
  echo
  echo "Generado: $(date -Is)"
  echo "Kernel: $(uname -r)"
  echo
  echo '```'
  ( cd "$DEST" && find . -type f ! -name MANIFEST.md -print0 | sort -z | xargs -0 sha256sum )
  echo '```'
} > "$DEST/MANIFEST.md"

echo "configuración capturada en configs/endymion/"
du -sh "$DEST"
