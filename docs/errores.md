# Errores que no repetiría

Catálogo de lo que salió mal en esta instalación, con la causa y la forma de evitarlo. No es
una lista de vergüenzas: casi todos son errores de criterio, no de tipeo, y por eso vale
escribirlos.

Ordenados por etapa. Cada uno tiene el mensaje real cuando lo hubo.

---

## Antes de tocar el disco

**1. Reparticionar sin backup del sistema anterior.**
El NVMe tenía CachyOS con LUKS y no se respaldó nada. No se perdió información por suerte,
no por método.
*Evitarlo:* si el disco que vas a repartir tiene algo que te importa, primero copiarlo a otro
disco y verificar que se pueda leer. El paso "Backup del NVMe" del checklist no es decorativo.

**2. Arrastrar los valores de la VM al hardware.**
`make.conf` con `-march=skylake`, `-j6`, `VIDEO_CARDS: virgl`, `fstab` con `LABEL=` y un
kernel con drivers virtio. En el fierro eso deja el sistema sin GPU y sin red.
*Evitarlo:* la VM sirve para el procedimiento, no para los valores. Cada máquina tiene su
`make.conf`, su kernel y sus UUID.

**3. Pegar varios comandos en una línea.**
```
mkfs.ext4: invalid blocks '/dev/vda3mkfs.ext4' on device '/dev/vda2mkswap'
```
*Evitarlo:* un comando por línea en operaciones de disco. Y `lsblk` antes de cada `mkfs`.

## Kernel

**4. Confiar en `localmodconfig` como fuente de verdad.**
Toma los módulos cargados en el live. En ese momento `NTFS3`, `exFAT` y Bluetooth no estaban
en uso, así que no los incluyó: los discos de datos no se podían montar.
*Evitarlo:* partir de `/proc/config.gz` y después revisar a mano los drivers de hardware que
no está en uso durante la instalación.

**5. Descubrir un módulo faltante por un servicio que no arranca.**
Tailscale no levantaba la interfaz porque no existía `/dev/net/tun`: faltaba `CONFIG_TUN`.
No hay mensaje claro, solo un servicio que no funciona. Costó un build extra.
*Evitarlo:* antes de compilar, listar qué necesita cada servicio que vas a usar (VPN, Docker,
máquinas virtuales) y buscar su símbolo en el `.config`.

**6. Compilar sin `-j`.**
El primer `make` fue en un hilo: 1167 objetos en 18 minutos con seis núcleos libres.
*Evitarlo:* `make -j$(nproc)`, y hacerlo dentro de `screen` o `tmux`.

**7. Perder el rastro de qué kernel está instalado.**
`/usr/src/linux` apunta a `linux-7.3.5-gentoo` pero el release es `7.3.5-gentoo-gentoo-dist`,
porque `CONFIG_LOCALVERSION` agrega el sufijo. Y quedaron tres builds con `.old` en `/boot`.
*Evitarlo:* `uname -r` es la verdad, no el nombre del directorio. `eclean-kernel -n 2` después
de cada cambio estable.

**8. Suponer que el kernel del live es el del sistema.**
`arch-chroot` usa el kernel del live hasta que reiniciás. Compilar con ese entorno después de
actualizar glibc funciona, pero no es representativo.
*Evitarlo:* reiniciar antes de compilar el kernel definitivo, o al menos saber que el entorno
no es el final.

## Red y cuentas

**9. Tres nombres para la misma interfaz.**
`eth0` en la documentación, `enp1s0` en la VM, `eno1` en el fierro. El servicio se llama
`net.<interfaz>`: si el nombre no coincide, no arranca.
*Evitarlo:* `ip -br a` en el live y crear el enlace con ese nombre exacto.

**10. Dos clientes DHCP peleando.**
`dhcpcd` y `net.eno1` en el mismo runlevel. En la VM fue un dolor de cabeza.
*Evitarlo:* `netifrc` ya levanta su cliente. No agregar `dhcpcd` al runlevel default.

**11. Creer que el bloqueo era de SSH.**
`The account is locked due to 3 failed logins` es `pam_faillock`, no sshd. Bloquea la cuenta
ocho minutos.
*Evitarlo:* `faillock --user <usuario> --reset` desde una consola local.

**12. Dejar el primer mirror muerto en la lista.**
`gentoo.zero.com.ar` no resuelve y estaba primero: cada descarga perdía tiempo ahí antes de
caer al siguiente.
*Evitarlo:* probar los mirrors con `mirrorselect` o dejar solo los que responden.

## Chroot y Portage

**13. Pensar que `emerge` estaba colgado.**
Dentro de `arch-chroot`, los procesos corren en otro namespace de PID: `pgrep` desde el live
no los ve.
*Evitarlo:* mirar `/var/log/emerge.log` o entrar con `nsenter -t <pid> -p -m`.

**14. No tener historial de comandos.**
La sesión del chroot no tenía cargado `.bashrc` con `history -a`, así que la cronología se
reconstruyó con mtimes.
*Evitarlo:* `export HISTTIMEFORMAT` y `history -a` en el `.bashrc` del chroot antes de empezar,
o un watcher que registre lo que pasa.

**15. Poner `~amd64` global desde el primer día.**
Todo el sistema en testing. Es cómodo y es lo que hace que se parezca a Arch, pero acumula
riesgo silencioso: 29 noticias sin leer.
*Evitarlo:* empezar en stable y subir solo los paquetes que lo necesitan, en
`package.accept_keywords`.

**16. Agregar `ABI_X86="64 32"` y no terminarlo.**
Se agregó para Steam y disparó 102 reconstrucciones que quedaron a medias durante días.
`/usr/lib32` quedó vacío.
*Evitarlo:* cuando cambiás una opción global de ABI o USE, completar el `@world` en la misma
sesión. Anotarlo como deuda si no se puede.

**17. Usar binarios y sorprenderse de que se sienta como Arch.**
11 sesiones con `--usepkg`. Es válido, pero cambia la naturaleza de la experiencia.
*Evitarlo:* decidirlo a conciencia y registrarlo, no descubrirlo tres días después.

**18. Una línea inválida en `package.use`.**
`*/* */* CPU_FLAGS_X86: ...` — el `*/*` duplicado no es un USE flag.
*Evitarlo:* revisar con `emerge --info | grep CPU_FLAGS_X86` después de escribir el archivo.

**19. Escribir `emerge` con nombres y banderas inexistentes.**
`emerge screen` (ambiguo), `--newest-use` (no existe), `emerge zen-browser` (no está en el
árbol). Cada uno tira el usage entero y hace perder tiempo.
*Evitarlo:* `emerge -s` para buscar, `--newuse` para la bandera, y categoría siempre.

## Escritorio

**20. Elegir un launcher que depende de un portal.**
`wofi` no arrancaba por `XDG_RUNTIME_DIR` y el portal. Terminó reemplazado por `wmenu`, que
hace lo mismo con menos piezas.
*Evitarlo:* para Sway mínimo, preferir herramientas sin portal. El portal se instala cuando
hace falta compartir pantalla o abrir archivos.

**21. Ignorar un fallo de probe de audio.**
`snd_hda_intel: Cannot probe codecs, giving up` aparece dos veces en cada arranque. El audio
funciona, pero el primer probe falla y hay un `hda-reset.start` en `local.d` que lo mitiga.
*Evitarlo:* si el audio anda, anotarlo como conocido; si un día no anda, ese es el primer
sospechoso.

**22. No usar binarios de Steam y esperar que ande igual.**
Steam arrastra 32 bits. Sin `ABI_X86` completo, el cliente arranca con su propio runtime y
queda en un estado que nadie verificó del todo.

## Documentación

**23. Documentar en RAM hasta el final.**
El repo vivía en `/tmp` del live, sobre tmpfs. Un apagado y no quedaba nada.
*Evitarlo:* commit y push temprano, o copia al disco instalado en cuanto se pueda montar.

**24. Dejar una contraseña en un script de sincronización.**
`sync-configs.sh` tenía `SSHPASS` hardcodeado y terminó en un repo público.
*Evitarlo:* credenciales por variable de entorno, nunca en el archivo. Y un grep de secretos
antes de cada push.

**25. Señalar como "los que andan" configuraciones que eran de otro sistema.**
La guía decía "copiar `configs/etc/portage/make.conf` tal cual", y ese `make.conf` era de la
VM con `virgl`.
*Evitarlo:* separar la configuración de la máquina real (`configs/endymion/`) de la histórica,
y regenerarla con un script.

---

## El error de fondo

Todos los anteriores son tácticos. El de fondo fue otro: **tratar la instalación como una
carrera contra el handbook** en lugar de como un sistema que hay que poder mantener. Lo que
quedó pendiente (ABI de 32 bits, firewall, backup, cifrado) es exactamente lo que se postergó
para "terminar antes".

La regla que saco de todo esto: *si una decisión va a costar horas después, se toma ahora o
se escribe ahora*. Nunca "después".
