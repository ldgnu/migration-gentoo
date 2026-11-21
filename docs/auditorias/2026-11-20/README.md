# Auditoría Gentoo — endymion — 2026-11-20

Auditoría de solo lectura hecha sobre el sistema en funcionamiento, tres días después de la
instalación en hardware. No se modificó nada durante el relevamiento. Las salidas crudas
están en `estado/`; el registro original de la instalación sigue en disco en
`/var/log/qwertoo-instalacion/` y su copia íntegra está en `../registro-instalacion/`.

## Veredicto

**El sistema está sano y es mantenible.** Arranca por UEFI con GRUB, corre el kernel 7.3.5,
Sway con Wayland, audio por PipeWire, Bluetooth, Steam, Zen y Tailscale. Portage está
consistente (`revdep-rebuild` limpio, `depclean` sin candidatos, `qcheck` sin errores) y el
disco no muestra errores de integridad.

Lo que falta no es funcionalidad: es **higiene y dos decisiones que nunca se escribieron**.
Los puntos que hay que atender, en orden, son los rebuilds pendientes por ABI de 32 bits
(102 paquetes), la ausencia total de firewall, el `sudo` sin contraseña, y el hecho de que
la migración dejó el disco sin cifrado y sin backup del sistema anterior.

## 1. Plataforma

| Dato | Valor |
|---|---|
| Perfil | `default/linux/amd64/23.0` (multilib) |
| Init | OpenRC |
| Kernel en uso | `7.3.5-gentoo-gentoo-dist` (compilado 19/11 23:56) |
| Kernel de respaldo | `6.18.63-gentoo-gentoo-dist` |
| CPU | i5-10400F, `-march=native`, `CPU_FLAGS_X86` completos |
| GPU | RX 6600, `VIDEO_CARDS="amdgpu radeonsi"`, driver `amdgpu` cargado |
| Memoria | 15 GiB RAM, 16 GiB swap (2.1 GiB en uso) |
| Raíz | ext4, 37 GB usados de 98 GB (40 %) |
| Home | ext4, 132 GB usados de 354 GB (40 %) |
| Uptime al corte | 4 h 53 min (boot 2026-11-20 17:31) |
| Paquetes | 739 instalados, 88 en `world` |
| Árbol Portage | 720 MB, último sync 2026-11-18 18:37 UTC |

## 2. Arranque

| Pieza | Estado |
|---|---|
| Entrada UEFI | `Boot0000 Gentoo` → `\EFI\Gentoo\grubx64.efi`, primera en el orden |
| Windows | `Boot0008` intacta, apunta a la ESP de `sdc` |
| `grub.cfg` | 7.3.5 por defecto, 6.18.63 como fallback, entradas `.old` y recovery |
| Initramfs | dracut, zstd, `intel-uc.img` + `amd-uc.img` antes del initramfs |
| Cmdline | `root=UUID=f58fb93f-… ro` (sin parámetros extra) |
| Secure Boot | desactivado |
| Respaldo en ESP | **no hay** `EFI/BOOT/BOOTX64.EFI` |

## 3. Servicios (OpenRC)

Arriba en `default`: `bluetooth`, `chronyd`, `sysklogd`, `cronie`, `elogind`, `net.eno1`,
`netmount`, `seatd`, `sshd`, `local`. `tailscale` corre y está conectado (nodo `endymion` y otros cuatro equipos del tailnet, uno offline).

Red: `eno1` por DHCP, `192.168.0.10/24` + IPv6 global. DNS y ruteo OK.

Lo que **no** hay: firewall (ni nftables instalado ni tablas iptables en el kernel), zram,
ningún mecanismo de snapshots ni backup automático.

## 4. Salud de Portage

| Chequeo | Resultado |
|---|---|
| `revdep-rebuild -p` | `Your system is consistent` |
| `emerge -p --depclean` | 0 paquetes a remover |
| `qcheck` | sin errores en lo revisado |
| `@preserved-rebuild` | vacío |
| Noticias sin leer | **29** |
| Rebuilds pendientes | **102** |
| Actualizaciones reales pendientes | 1 (`net-mail/mailutils`) |

Los 102 rebuilds no son actualizaciones: son reconstrucciones por `ABI_X86="64 32"`, que se
agregó a `make.conf` el 18/11 para Steam. La mitad del sistema todavía no tiene su variante
de 32 bits. Funciona igual, pero Steam y los juegos de 32 bits quedan en un estado incierto
hasta terminar ese `emerge -uDN @world`. Es la tarea más larga pendiente (varias horas de
compilación).

## 5. Historial de la instalación

Resumen; el detalle está en `../historial-paquetes.md` (66 sesiones de `emerge`, 697 merges) y
en `../cronologia.md`.

| Día | Sesiones | Merges | Qué pasó |
|---|---:|---:|---|
| 17/11 | 45 | 430 | Stage3, sync, `@world` de 61, identidad, kernel 6.18.63, GRUB, Sway, PipeWire, Zen |
| 18/11 | 20 | 266 | Herramientas TUI, Steam/gaming, mesa, `@world`, kernel 7.3.5 |
| 19/11 | 1 | 1 | Tailscale y recompilación del kernel con `CONFIG_TUN=m` |

Evidencia visual: 24 capturas en `../registro-instalacion/capturas/`, desde el `emerge @world`
en curso hasta la última pantalla antes de reiniciar.

## 6. Hallazgos

### P1 — resolver esta semana

**A-01. Firewall inexistente.**
No hay `nftables` instalado ni tablas `iptables` en el kernel (`ip_tables` no existe en
`/lib/modules/7.3.5-…`; el config solo tiene `CONFIG_NETFILTER=y`). `sshd` escucha en
`0.0.0.0:22` y en la interfaz de Tailscale. Cualquier equipo de la LAN puede intentar SSH.
Opciones: compilar `NF_TABLES`/`IP_NF_IPTABLES` y usar nftables, o dejar SSH solo en
`tailscale0`. Lo segundo es más simple y no requiere kernel nuevo.

**A-02. `sudo` sin contraseña para todo `wheel`.**
`/etc/sudoers` tiene `%wheel ALL=(ALL:ALL) NOPASSWD: ALL`, y `ldgnu` está en `wheel`.
Cualquier proceso que corra como `ldgnu` escala a root sin credencial. Si fue deliberado,
anotarlo; si no, sacar el `NOPASSWD`.

**A-03. Credencial en texto plano dentro del registro de instalación.**
`/var/log/qwertoo-instalacion/scripts/sync-configs.sh` tiene
`export SSHPASS="${SSHPASS:-<valor>}"` con una contraseña SSH hardcodeada. Esa contraseña
está en disco desde el 17/11 y el script se copió a `/root/qwertoo-vigilancia/`. La copia del
repo va redactada, pero el original sigue ahí. Conviene rotar la contraseña y limpiar ambas
copias.

**A-04. 102 rebuilds por ABI 32 bits.**
Ver §4. Planificarlo en una sesión larga (`screen`/`tmux`), no en un rato suelto.

### P2 — decisiones que faltan y deuda chica

**A-05. El disco quedó sin cifrado y no está documentado como decisión.**
El sistema anterior (CachyOS) era LUKS + btrfs; este es ext4 sin cifrado. Puede ser
deliberado, pero no hay registro. Agregarlo después implica reinstalar o hacer un
`cryptsetup` sobre el disco en uso. Decidir y anotar.

**A-06. Nunca hubo backup del sistema anterior.**
El paso 32 del checklist ("Backup del NVMe") quedó sin marcar y el disco se reparticionó.
No hay nada que recuperar; lo que importa es no repetir el patrón: hoy el único respaldo del
sistema es este repo (configuración) y nada de `/home`.

**A-07. `ACCEPT_KEYWORDS="~amd64"` global.**
Todo el sistema corre en rama testing. Es una decisión válida para un equipo personal, pero
aumenta la chance de actualizaciones rotas y explica los 29 avisos de noticias.

**A-08. Sin respaldo de arranque en la ESP.**
Solo existe `EFI/Gentoo/grubx64.efi`. Si se borra la entrada NVRAM, el firmware no encuentra
nada. `cp /efi/EFI/Gentoo/grubx64.efi /efi/EFI/BOOT/BOOTX64.EFI` es una red de seguridad de
un comando.

**A-09. Ocho entradas de arranque para dos kernels.**
7.3.5, 7.3.5 `.old`, 6.18.63, cada uno con su recovery. `eclean-kernel -n 2` limpia los
`.old`; después `grub-mkconfig`.

**A-10. `package.use/00cpu-flags` tiene una línea malformada.**
Contenido actual: `*/* */* CPU_FLAGS_X86: aes avx …`. El `*/*` repetido no es un USE flag
válido. Los flags se aplican igual, pero conviene dejarlo en `*/* CPU_FLAGS_X86: …`.

**A-11. `package.use` y `sets` con restos.**
`package.use/sway` todavía comenta `wofi` (desinstalado); `sets/binarios` lista `firefox` y
`libreoffice`, que no están instalados. Ruido, no error.

**A-12. Árbol de Portage de hace dos días y 29 noticias sin leer.**
Un `emerge --sync && eselect news read` antes del próximo `@world` evita sorpresas.

**A-13. `/var/log/qwertoo-instalacion` mezcla registro histórico con scripts ejecutables.**
Como evidencia está bien; como directorio de scripts, no. Mover los scripts a un lugar
propio y dejar el log inmutable.

### P3 — observaciones de hardware y kernel

**A-14. `amdgpu`: `Failed to setup vendor infoframe` en DP-2 y HDMI-A-1.**
Aparece en cada arranque. Afecta metadatos HDR/color por HDMI/DP; no rompe video ni audio
por el jack. Con dos conectores activos, es esperable en este driver.

**A-15. `snd_hda_intel: Cannot probe codecs, giving up` (dos veces al boot).**
El audio funciona (sink analógico presente y probado), pero el primer probe del códec falla
y se reintenta. Si algún día el audio no aparece, este es el primer sospechoso.

**A-16. `exFAT-fs (sdb1): bogus allocation bitmap size` en cada montaje.**
El disco de datos `PirateNW` tiene una inconsistencia en la tabla de asignación. Se monta
igual, pero conviene respaldar lo importante y correr `fsck.exfat -n` (solo lectura) antes de
escribir más.

**A-17. SMART del NVMe.**
`PASSED`, 2 % de vida usada, 0 errores de integridad, 49 °C (sensor 1: 69 °C). Lo llamativo:
**723 apagados inseguros** en 1.261 ciclos y 4.914 horas. No es crítico, pero sugiere cortes
de energía o resets. Vale un UPS o al menos revisar la fuente.

**A-18. `CONFIG_DRM_PANIC_SCREEN='qr_code'` no soportado.**
El kernel cae a `user`. Cosmético.

**A-19. `hwclock` en UTC con Windows instalado.**
Si Windows usa hora local, cada arranque cruzado mueve el reloj. No afecta a Gentoo.

## 7. Reproducir esta auditoría

```sh
# sistema
uname -a; cat /etc/os-release; lscpu | head; free -h; df -hT; lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINTS,UUID

# arranque
efibootmgr -v; grep -E "menuentry|linux |initrd " /boot/grub/grub.cfg
sudo eclean-kernel -p -n 2

# servicios y red
rc-status --all; rc-update show; ip -br a; ss -tulpn

# portage
sudo qcheck; sudo revdep-rebuild -p; sudo emerge -p --depclean; sudo emerge -uDNp @world
eselect news list

# hardware
sudo smartctl -H -A /dev/nvme0n1; sudo dmesg --level=err,warn
for c in /sys/class/drm/card*-*; do echo "$c $(cat $c/status)"; done

# historial
sudo tail -100 /var/log/emerge.log
```

## 8. Alcance y límites

- Solo lectura: no se instaló, actualizó ni borró nada.
- No se probó la suite de Steam ni se jugó: la auditoría de gaming es de estado, no de
  rendimiento.
- No se inspeccionó el contenido de `sda`, `sdb` ni `sdc`; solo se verificó que montan y qué
  filesystem tienen.
- No se auditaron credenciales ni claves: el hallazgo A-03 salió de leer los scripts del
  registro, no de buscar secretos.
- Las direcciones de la LAN se listan porque el repo documenta esta máquina; si se publica,
  conviene revisar `estado/12-red-log.txt`.
