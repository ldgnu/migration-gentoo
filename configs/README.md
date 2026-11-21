# Configuración

Dos cosas distintas viven acá, y conviene no confundirlas.

## `endymion/` — la máquina real

Snapshot de la configuración viva del equipo, hecha el 21/11/2026. Es el backup que sirve
para reconstruir esta instalación. Se regenera con:

```sh
./scripts/capturar-configs.sh
```

Incluye, con las rutas absolutas originales:

| Qué | Dónde |
|---|---|
| Portage | `etc/portage/` — `make.conf`, `package.use/`, `package.env`, `env/opt-O3`, `sets/`, `repos.conf`, `package.license`, `package.accept_keywords` |
| Paquetes explícitos | `var/lib/portage/world` |
| Arranque | `etc/fstab`, `etc/default/grub`, `boot/config-<kernel>` |
| Identidad y servicios | `etc/hostname`, `etc/hosts`, `etc/timezone`, `etc/locale.gen`, `etc/rc.conf`, `etc/conf.d/`, `etc/local.d/` |
| Escritorio | `home/ldgnu/.config/sway/config`, `home/ldgnu/.local/bin/sway-*`, `wmenu-*` |
| Inventario | `inventario/` — `lspci`, `lsmod`, `rc-update`, lista de 740 paquetes, USE flags, `efibootmgr`, `lsblk`, DMI |
| Integridad | `MANIFEST.md` con el SHA-256 de cada archivo |

**Lo que no está, a propósito:** `/etc/shadow`, `/etc/gshadow`, `/etc/portage/gnupg` (tiene
la clave de firma de binarios y su passphrase), claves de host SSH, estado de Tailscale y
cualquier archivo de `~/.config` que pueda contener tokens. No es un backup de datos: es un
backup de decisiones.

### Restaurar

```sh
# ver qué cambiaría, primero
diff -ru /etc configs/endymion/etc | less

# copiar encima (hacer backup de /etc antes)
sudo cp -a configs/endymion/etc/. /etc/
sudo chmod 440 /etc/sudoers
```

Los archivos de `home/` van a mano: son configuración de usuario, no del sistema.

## El resto — material de la etapa anterior

`configs/etc/`, `configs/kernel/`, `configs/inventario/` y los `.txt` de la raíz son de la
VM de práctica y de la planificación previa. **No se copian tal cual en endymion**: tienen
`-march=skylake` y `-j6` en `make.conf`, `LABEL=root` en `fstab`, `VIDEO_CARDS: virgl` y un
kernel con drivers virtio. Están como registro histórico de cómo se llegó hasta acá.

Para el equipo real, usar `endymion/`.
