# Migración de CachyOS a Gentoo

Qué hacer con los 493 paquetes instalados hoy. Validado contra el árbol oficial de Gentoo
(`/var/db/repos/gentoo`), no contra el buscador web.

## Resumen

| Categoría | Cantidad |
|---|---|
| Existe con el mismo nombre | 244 |
| Nombre parecido en el árbol | 125 |
| Sin coincidencia de nombre | 124 |

"Sin coincidencia de nombre" **no** significa "no existe": muchos paquetes de Arch se llaman
distinto en Gentoo. La lista completa está en `configs/inventario/mapeo-gentoo.txt`.

## No se migran: son de la distro

```
cachyos-fish-config      cachyos-packageinstaller   cachyos-v3-mirrorlist
cachyos-gaming-apps      cachyos-plymouth-*         cachyos-v4-mirrorlist
cachyos-gaming-meta      cachyos-rate-mirrors       cachyos-wallpapers
cachyos-hello            cachyos-settings           cachyos-zsh-config
cachyos-hooks            cachyos-snapper-support    cachy-update
cachyos-keyring          cachyos-mirrorlist         chwd
cachyos-kernel-manager   cachyos-micro-settings     archlinux-wallpaper
linux-cachyos            linux-cachyos-lts          linux-cachyos-server-lto
pacman-contrib           yay                        hwdetect
rebuild-detector         limine-*                   limine-snapper-sync
```

Nada de eso tiene equivalente ni sentido en Gentoo. Se descarta.

## Equivalencias verificadas

| Arch | Gentoo |
|---|---|
| `intel-ucode` | `sys-firmware/intel-microcode` |
| `npm` | incluido en `net-libs/nodejs` |
| `mkinitcpio` | `sys-kernel/dracut` |
| `qemu-desktop` | `app-emulation/qemu` |
| `virt-install` | `app-emulation/virt-manager` |
| `device-mapper` | `sys-fs/lvm2` |
| `noto-fonts-emoji` | `media-fonts/noto-emoji` |
| `noto-fonts-cjk` | `media-fonts/noto-cjk` |
| `ttf-liberation` | `media-fonts/liberation-fonts` |
| `ttf-opensans` | `media-fonts/open-sans` |
| `bluez-hid2hci` | incluido en `net-wireless/bluez` |
| `gst-plugin-pipewire` | `media-video/pipewire` con `USE=gstreamer` |
| `vlc-plugins-all` | `media-video/vlc` (los plugins van por USE) |
| `vulkan-radeon` | `media-libs/vulkan-loader` + `mesa` (radv) |
| `pnpm` | `npm install -g pnpm` |

## Fuentes Nerd

`ttf-jetbrains-mono-nerd`, `ttf-meslo-nerd` y `nerd-fonts-sf-mono` **no tienen paquete en el
árbol oficial**. Se instalan con el script de nerd-fonts desde el upstream, o desde un overlay.

```
media-fonts/open-sans
media-fonts/liberation-fonts
media-fonts/noto-emoji
media-fonts/noto-cjk
```

Y para las Nerd:

```
git clone https://github.com/ryanoasis/nerd-fonts
cd nerd-fonts && ./install.sh JetBrainsMono
```

## Audio: el bloque grande

Alrededor de 30 paquetes son plugins LV2 y VST, más `yabridgectl`. Ninguno está en el árbol
oficial con ese nombre. Opciones, en orden de esfuerzo:

1. **Overlay `proaudio`** — agrupa muchos de estos plugins ya empaquetados:
   ```
   eselect repository add proaudio git https://github.com/gentoo-mirror/proaudio.git
   emerge --sync proaudio
   ```
2. **Compilar desde el código fuente** los que no estén.
3. **`yabridge`** para los VST de Windows: tiene overlay propio, o se compila.

Es el trabajo más grande de la migración y merece una sesión aparte.

## Binarios que no tienen equivalente

`apple-music-bin`, `balena-etcher-bin`, `jellyfin-media-player`, `zen-browser-bin`,
`peazip-qt-bin`, `rustdesk-bin`, `sunshine-beta-bin`, `dsp-bin`, `terax-bin`, `termix-bin`.
Son paquetes que en Arch existen solo como binarios preempaquetados. En Gentoo: buscar
ebuild en overlays, AppImage, o descartar.

## Cómo verificar cualquier caso

En la máquina con el árbol sincronizado:

```
emerge --search nombre
qsearch nombre        # con gentoolkit, busca en descripción también
eselect repository list
```

Y para ver si está en un overlay antes de agregarlo:

```
https://gpo.zugaina.org/Search?search=nombre
```
