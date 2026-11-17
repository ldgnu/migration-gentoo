#!/bin/bash
# sway-hueso.sh — el MINIMO para que sway levante y puedas trabajar.
# Compila 5 paquetes. Todo lo demas se instala despues DENTRO de sway.
# Uso: sudo bash sway-hueso.sh
set -euo pipefail
[[ $EUID -eq 0 ]] || { echo "correr con sudo"; exit 1; }

echo "== USE flags =="
grep -q '^USE=' /etc/portage/make.conf \
  && sed -i 's/^USE=.*/USE="elogind dbus wayland"/' /etc/portage/make.conf \
  || echo 'USE="elogind dbus wayland"' >> /etc/portage/make.conf

mkdir -p /etc/portage/package.use
cat > /etc/portage/package.use/sway <<'EOF'
gui-wm/sway elogind
gui-libs/wlroots elogind
EOF

echo "== 5 paquetes =="
emerge --oneshot gui-wm/sway gui-apps/foot media-fonts/dejavu sys-auth/elogind dbus

echo "== elogind =="
rc-update add elogind default
rc-service elogind start 2>/dev/null || echo "(arranca en el proximo boot: no hay init en este chroot)"

echo "== config: una linea =="
install -d -o javi -g javi /home/javi/.config/sway
cat > /home/javi/.config/sway/config <<'EOF'
bindsym $mod+Return exec foot
bindsym $mod+Shift+e exec swaymsg exit
EOF
chown -R javi:javi /home/javi/.config

echo
echo "LISTO. Salir de root y:  dbus-run-session sway"
echo "Dentro de sway: Mod+Return = terminal, Mod+Shift+e = salir"
