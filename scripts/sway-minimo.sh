#!/bin/bash
# sway-minimo.sh — escritorio Sway andando en OpenRC, sin Xorg. Idempotente.
# Uso:  sudo ./sway-minimo.sh
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "correr con sudo"; exit 1; }

echo "== 1. USE global (sin X) =="
if grep -q '^USE=' /etc/portage/make.conf; then
  sed -i 's/^USE=.*/USE="bluetooth dbus elogind wayland"/' /etc/portage/make.conf
else
  echo 'USE="bluetooth dbus elogind wayland"' >> /etc/portage/make.conf
fi

echo "== 2. USE flags de sway =="
mkdir -p /etc/portage/package.use
cat > /etc/portage/package.use/sway <<'EOF'
gui-wm/sway elogind gtk tray
gui-libs/wlroots elogind
EOF

echo "== 3. paquetes =="
emerge --ask=n --oneshot \
  gui-libs/wlroots gui-wm/sway x11-base/xwayland \
  gui-apps/foot gui-apps/wofi gui-apps/mako gui-apps/swaybg gui-apps/swaylock \
  media-fonts/dejavu media-fonts/noto dev-libs/libinput sys-auth/elogind \
  media-video/pipewire media-video/wireplumber media-sound/alsa-utils

echo "== 4. elogind (NO seatd) =="
rc-update add elogind default
rc-service elogind start || true

echo "== 5. config minima de sway =="
CFG=/home/javi/.config/sway
install -d -o javi -g javi "$CFG"
if [[ ! -f $CFG/config ]]; then
cat > $CFG/config <<'EOF'
set $mod Mod4
set $term foot
output * bg #1e1e2e solid_color
input * {
    kb_layout latam
    tap-to-click enabled
}
bindsym $mod+Return exec $term
bindsym $mod+d exec wofi --show drun
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exec swaymsg exit
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right
bindsym $mod+1 workspace number 1
bindsym $mod+2 workspace number 2
bindsym $mod+3 workspace number 3
bindsym $mod+4 workspace number 4
bindsym $mod+5 workspace number 5
bindsym $mod+f fullscreen
bindsym $mod+space floating toggle
bindsym XF86AudioRaiseVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
exec mako
bar {
    position top
    status_command while date +'%H:%M'; do sleep 30; done
    colors {
        background #1e1e2e
        statusline #ffffff
        focused_workspace #89b4fa #89b4fa #1e1e2e
    }
}
EOF
chown javi:javi $CFG/config
fi

echo "== 6. arranque automatico en tty1 =="
grep -q 'dbus-run-session sway' /home/javi/.bash_profile 2>/dev/null || \
  echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec dbus-run-session sway' >> /home/javi/.bash_profile
chown javi:javi /home/javi/.bash_profile

echo
echo "LISTO. Salir de root, loguearte como javi y correr:  dbus-run-session sway"
echo "Verificar:  swaymsg -t get_outputs"
