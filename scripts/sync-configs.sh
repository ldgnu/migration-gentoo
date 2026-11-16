#!/bin/bash
# Sincroniza los archivos de configuración del sistema Gentoo instalado hacia el repo.
#
# Uso: ./scripts/sync-configs.sh [IP]
# Requiere: sshpass y acceso root al live de la VM.
#
# Nunca copia: shadow, gshadow, passwd, group, gnupg, claves ssh, machine-id.

set -u
VM_IP="${1:-192.168.122.34}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/configs"
SRC="/mnt/gentoo"

ARCHIVOS=(
  "etc/fstab"
  "etc/hostname"
  "etc/locale.gen"
  "etc/rc.conf"
  "etc/conf.d/keymaps"
  "etc/conf.d/hostname"
  "etc/portage/make.conf"
  "etc/portage/package.license"
  "etc/portage/package.use/00cpu-flags"
  "etc/portage/package.use/00video_cards"
  "etc/portage/package.use/installkernel"
  "etc/portage/repos.conf/gentoo.conf"
)

export SSHPASS="${SSHPASS:-5512}"
SSH="sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR -o ConnectTimeout=6 root@${VM_IP}"

for f in "${ARCHIVOS[@]}"; do
  mkdir -p "$DEST/$(dirname "$f")"
  if $SSH "test -f $SRC/$f" 2>/dev/null; then
    $SSH "cat $SRC/$f" > "$DEST/$f"
    printf '  %-45s %s bytes\n' "$f" "$(wc -c < "$DEST/$f")"
  else
    printf '  %-45s (no existe)\n' "$f"
  fi
done

# Configuración del kernel, si existe
KVER=$($SSH "ls -1 $SRC/usr/src | grep '^linux-[0-9]' | tail -1" 2>/dev/null)
if [ -n "${KVER:-}" ] && $SSH "test -f $SRC/usr/src/$KVER/.config" 2>/dev/null; then
  mkdir -p "$DEST/kernel"
  $SSH "cat $SRC/usr/src/$KVER/.config" > "$DEST/kernel/config-$KVER"
  printf '  %-45s %s bytes\n' "kernel/config-$KVER" "$(wc -c < "$DEST/kernel/config-$KVER")"
fi

echo "Sincronizado en $DEST"
