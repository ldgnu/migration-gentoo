#!/bin/bash
# Genera una foto legible del estado del sistema Gentoo instalado.
#
# Solo lectura. No muestra hashes de contraseñas, claves ni direcciones IP.
# Uso:
#   ./scripts/estado-instalacion.sh
#   ROOT=/mnt/gentoo ./scripts/estado-instalacion.sh
#
# Pensado para que lo consuma scripts/vigilancia.sh, pero se puede correr a mano.

set -u

ROOT="${ROOT:-/mnt/gentoo}"
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo -n"
fi

seccion() {
  printf '\n### %s\n\n' "$1"
}

linea_o_ausente() {
  if [ -f "$1" ]; then
    cat "$1"
  else
    echo "(ausente)"
  fi
}

printf '# Foto del sistema instalado\n'
printf '\nRaíz: `%s`\n' "$ROOT"

seccion "Montajes"
findmnt -rn -o TARGET,SOURCE,FSTYPE,OPTIONS 2>/dev/null |
  awk -v r="$ROOT" '$1 == r || index($1, r "/") == 1' |
  sort

seccion "Swap activa"
swapon --show=NAME,SIZE,USED,PRIO --noheadings 2>/dev/null || echo "(ninguna)"

seccion "Particiones del disco destino"
lsblk -rn -o NAME,SIZE,TYPE,FSTYPE,LABEL,UUID /dev/nvme0n1 2>/dev/null ||
  echo "(no se pudo leer nvme0n1)"

seccion "fstab"
linea_o_ausente "$ROOT/etc/fstab"

seccion "Hostname"
linea_o_ausente "$ROOT/etc/hostname"
printf '\nconf.d/hostname (activo):\n'
grep -vE '^[[:space:]]*(#|$)' "$ROOT/etc/conf.d/hostname" 2>/dev/null || echo "(sin líneas activas)"

seccion "Zona horaria"
printf 'localtime -> %s\n' "$(readlink -f "$ROOT/etc/localtime" 2>/dev/null | sed "s|$ROOT||")"
printf 'timezone: '
linea_o_ausente "$ROOT/etc/timezone"

seccion "Locale"
printf 'env.d/02locale:\n'
linea_o_ausente "$ROOT/etc/env.d/02locale"
printf '\nlocale.gen (activas):\n'
grep -vE '^[[:space:]]*(#|$)' "$ROOT/etc/locale.gen" 2>/dev/null || echo "(ninguna)"

seccion "Cuentas"
printf 'root: '
$SUDO awk -F: '$1 == "root" { print ($2 == "*" || $2 == "!") ? "bloqueada" : "con clave" }' \
  "$ROOT/etc/shadow" 2>/dev/null || echo "(sin acceso a shadow)"
printf 'usuarios UID>=1000:\n'
awk -F: '$3 >= 1000 && $3 < 65534 { print $1 ":" $3 ":" $6 ":" $7 }' \
  "$ROOT/etc/passwd" 2>/dev/null || echo "(sin usuarios)"
printf 'wheel: '
awk -F: '$1 == "wheel" { print $4 }' "$ROOT/etc/group" 2>/dev/null || echo "(sin grupo wheel)"

seccion "Perfil de Portage"
readlink -f "$ROOT/etc/portage/make.profile" 2>/dev/null | sed "s|$ROOT||" || echo "(sin perfil)"

seccion "make.conf"
linea_o_ausente "$ROOT/etc/portage/make.conf"

seccion "package.use"
if [ -d "$ROOT/etc/portage/package.use" ]; then
  find "$ROOT/etc/portage/package.use" -maxdepth 1 -type f -print0 2>/dev/null |
    sort -z |
    while IFS= read -r -d '' f; do
      printf -- '--- %s\n' "${f#$ROOT/}"
      cat "$f"
      printf '\n'
    done
else
  echo "(no existe)"
fi

seccion "package.license"
linea_o_ausente "$ROOT/etc/portage/package.license"

seccion "repos.conf/gentoo.conf"
linea_o_ausente "$ROOT/etc/portage/repos.conf/gentoo.conf"

seccion "Red"
if [ -f "$ROOT/etc/conf.d/net" ]; then
  grep -vE '^[[:space:]]*(#|$)' "$ROOT/etc/conf.d/net" 2>/dev/null || echo "(sin líneas activas)"
else
  echo "(sin /etc/conf.d/net)"
fi
printf 'interfaces del live (sin IP):\n'
ip -br link 2>/dev/null | awk '{ print $1, $2 }' | sort

seccion "Servicios en runlevels"
find "$ROOT/etc/runlevels" -type l -printf '%p -> %l\n' 2>/dev/null |
  sed "s|$ROOT||" | sort

seccion "Paquetes"
printf 'total: '
find "$ROOT/var/db/pkg" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | wc -l
printf '\núltimos instalados/actualizados:\n'
find "$ROOT/var/db/pkg" -mindepth 2 -maxdepth 2 -type d -printf '%T@ %P\n' 2>/dev/null |
  sort -n | tail -n 12 | cut -d' ' -f2-

seccion "Kernel y bootloader"
printf 'usr/src:\n'
ls -1 "$ROOT/usr/src" 2>/dev/null || echo "(vacío)"
printf '\nlib/modules:\n'
ls -1 "$ROOT/lib/modules" 2>/dev/null || echo "(vacío)"
printf '\nboot:\n'
find "$ROOT/boot" -maxdepth 1 -type f -printf '%f (%s bytes)\n' 2>/dev/null || echo "(vacío)"
printf '\nefi:\n'
find "$ROOT/efi" -type f -printf '%P (%s bytes)\n' 2>/dev/null || echo "(vacío)"
printf '\npaquetes sys-boot:\n'
ls -1 "$ROOT/var/db/pkg/sys-boot" 2>/dev/null || echo "(ninguno)"
printf '\npaquetes sys-kernel:\n'
ls -1 "$ROOT/var/db/pkg/sys-kernel" 2>/dev/null || echo "(ninguno)"

seccion "Entradas UEFI"
efibootmgr 2>/dev/null | sed -n '1,15p' || echo "(sin efibootmgr)"

seccion "emerge.log (últimas 20 líneas)"
$SUDO tail -n 20 "$ROOT/var/log/emerge.log" 2>/dev/null || echo "(sin acceso)"

seccion "emerge-fetch.log (últimas 8 líneas)"
$SUDO tail -n 8 "$ROOT/var/log/emerge-fetch.log" 2>/dev/null || echo "(sin acceso)"
