# Registro automático de la instalación

`scripts/vigilancia.sh` saca una foto del sistema instalado cada 20 segundos, guarda solo
los cambios y captura los comandos nuevos del historial de bash. Sirve para no reconstruir
la instalación de memoria al final.

## Qué se guarda

| Archivo | Contenido |
|---|---|
| `actual.md` | Última foto completa: montajes, fstab, hostname, locale, cuentas, perfil, `make.conf`, `package.use`, red, servicios, paquetes, kernel, bootloader, UEFI y `emerge.log` |
| `cambios.md` | Diff entre fotos consecutivas, con fecha UTC |
| `comandos.md` | Comandos nuevos de `/root/.bash_history` del chroot y de los historiales del live |
| `vigilancia.md` | Inicio, paradas, cambios detectados y errores del watcher |

Las capturas de pantalla van a `docs/capturas/`, con su índice en `docs/capturas/README.md`.
Se sacan al arrancar el watcher, cada 10 minutos, después de cada comando nuevo (con una
espera mínima de 60 segundos) y a mano:

```
./scripts/vigilancia.sh captura "instalando el kernel"
```

El script las comprime a JPEG de 1600 px de ancho (~200 KB) para no inflar el repo. Se
pueden ajustar con `CAPTURE_INTERVALO`, `CAPTURE_TRAS_COMANDO` y `SESSION_UID`.

No se guardan hashes de contraseñas, claves, tokens ni direcciones IP en el estado. Las
capturas sí muestran la pantalla tal cual: pueden incluir rutas, correos o texto de
documentación. Revisarlas antes de publicar si algo no debe salir.

## Cómo verlo

```
# última foto
less docs/estado/actual.md

# cambios en vivo
tail -f docs/estado/cambios.md

# comandos en vivo
tail -f docs/estado/comandos.md
```

## Cómo controlarlo

```
./scripts/vigilancia.sh status
./scripts/vigilancia.sh start 20
./scripts/vigilancia.sh stop
./scripts/vigilancia.sh once
```

El watcher queda desprendido del shell (`setsid` + `nohup`), así que sigue vivo al cerrar
la terminal del live.

## Historial de comandos del chroot

Se agregó un bloque en `/mnt/gentoo/root/.bashrc` que activa `HISTTIMEFORMAT` y
`history -a` para que cada comando se escriba en el archivo apenas vuelve el prompt.

En la sesión de chroot que ya estaba abierta hay que activarlo una vez:

```
source /root/.bashrc
```

Las sesiones nuevas lo toman solas. Los comandos anteriores a esa activación no quedan en
el historial; para los paquetes, `emerge.log` los cubre.

## Persistencia

Además del repo, todo se copia a:

```
/mnt/gentoo/var/log/qwertoo-instalacion/
```

Eso sobrevive al reinicio del live. El repo, en cambio, vive en RAM hasta que se haga
`commit` y `push`.

## Límites

- El watcher solo ve cambios de archivos y del historial; no reconstruye intenciones.
- Un comando largo (`emerge`, `make`) aparece en `comandos.md` cuando termina y vuelve el
  prompt, pero su avance se ve en `cambios.md` por las líneas nuevas de `emerge.log`.
- Si el live se cuelga antes de que el watcher copie, se pierde lo último. La copia
  persistente se actualiza en cada cambio detectado.
