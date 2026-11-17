# Audio y Bluetooth

Lo que hay que instalar y configurar para que el audio ande igual que en el sistema actual:
PipeWire como servidor, WirePlumber como gestor, BlueZ para Bluetooth y los codecs A2DP para
los auriculares.

## Cómo está hoy (CachyOS)

```
pipewire  wireplumber  alsa-lib  alsa-utils  alsa-ucm-conf
bluez  blueman  bluetuith  libfreeaptx  opus
gst-plugin-pipewire  gst-plugins-{base,good,bad,ugly}
```

Los tres servicios activos: `pipewire`, `wireplumber`, `bluetooth`.

## Kernel

```
Device Drivers → Sound card support
  CONFIG_SND=y
  CONFIG_SND_PROC_FS=y
  CONFIG_SND_HDA_INTEL=y        # audio de la placa y de la GPU
  CONFIG_SND_USB_AUDIO=y        # headset USB
  CONFIG_SND_HDA_CODEC_HDMI=y

Networking support → Bluetooth subsystem support
  CONFIG_BT=y
  CONFIG_BT_HCIBTUSB=y          # adaptador USB TP-Link
```

## Paquetes

```
media-video/pipewire
media-video/wireplumber
media-libs/libpulse
media-sound/alsa-utils
media-libs/libfreeaptx
media-libs/opus
net-wireless/bluez
net-wireless/blueman
sys-auth/rtkit
```

Opcionales pero útiles:

```
media-sound/pwvucontrol     # control de volumen gráfico
media-sound/helvum          # patchbay
media-libs/gst-plugins-*    # si alguna app usa GStreamer
```

## USE flags

En `make.conf`, global:

```
USE="bluetooth dbus elogind X wayland"
```

En `package.use`, para PipeWire:

```
media-video/pipewire sound-server pipewire-alsa bluetooth dbus extra lv2
media-video/wireplumber bluetooth
```

- `sound-server` es el flag clave: sin eso PipeWire no funciona como servidor de audio.
- `pipewire-alsa` instala el plugin ALSA que da la emulación que usan casi todas las
  aplicaciones. **`pulseaudio` no es un flag de pipewire**: escribirlo corta el emerge con
  `USE flag 'pulseaudio' is not in IUSE` (`media-libs/libpulse` es el paquete que aporta la
  compatibilidad).
- `bluetooth` habilita el soporte de dispositivos Bluetooth en PipeWire.
- `lv2` permite cargar plugins LV2 en el grafo, útil si hacés música.

Y un chequeo importante: **no tener `media-sound/pulseaudio-daemon` instalado**. Dos
servidores de audio al mismo tiempo es garantía de problemas.

## Servicios

Bluetooth, a nivel sistema:

```
rc-update add bluetooth default
rc-service bluetooth start
```

PipeWire y WirePlumber, como servicios de usuario (OpenRC ≥ 0.60):

```
rc-update --user add pipewire default
rc-update --user add pipewire-pulse default
rc-update --user add wireplumber default
```

Y el grupo:

```
usermod -aG pipewire ldgnu
```

## Verificación

```
pactl info | grep "Server Name"
```
Tiene que decir `PulseAudio (on PipeWire x.y.z)`.

```
wpctl status
```
Muestra sinks, sources y streams.

```
bluetoothctl
> power on
> scan on
> pair XX:XX:XX:XX:XX:XX
> connect XX:XX:XX:XX:XX:XX
```

Con los JBL conectados, aparecen como sink nuevo en `wpctl status`.

## Codecs de los auriculares

BlueZ y PipeWire manejan SBC y AAC. Para aptX hace falta `media-libs/libfreeaptx`, y para
LDAC existe `media-libs/libldac`. Sin esos paquetes, los auriculares andan igual, pero con
SBC y algo más de latencia.

## Problemas típicos

| Síntoma | Causa |
|---|---|
| No hay sonido y `pactl` falla | PipeWire no está corriendo o falta D-Bus de sesión |
| Suena pero no aparece en el mezclador | WirePlumber no está activo |
| Bluetooth no enciende | `bluetooth` no está en el runlevel, o falta `bluetoothd` |
| Los auriculares se conectan y no suenan | codec o perfil A2DP mal elegido |
| Cortes y latencia | falta `rtkit` o el usuario no está en el grupo `pipewire` |
| Dos servidores peleando | `pulseaudio-daemon` instalado junto a PipeWire |

## Orden de instalación

1. Compilar el kernel con `SND*` y `BT*`.
2. `emerge` de los paquetes.
3. USE flags y `emerge --changed-use --deep @world`.
4. Servicios: `bluetooth` en sistema, `pipewire`/`wireplumber` por usuario.
5. Grupo `pipewire`.
6. Probar con `pactl info` y `wpctl status`.

Referencias:
- [PipeWire](https://wiki.gentoo.org/wiki/PipeWire)
- [WirePlumber](https://wiki.gentoo.org/wiki/WirePlumber)
- [ALSA](https://wiki.gentoo.org/wiki/ALSA)
- [Bluetooth](https://wiki.gentoo.org/wiki/Bluetooth)
