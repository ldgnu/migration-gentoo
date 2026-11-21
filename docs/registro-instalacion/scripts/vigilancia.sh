#!/bin/bash
# Vigilancia de la instalación: guarda una foto del sistema cada N segundos,
# registra solo los cambios y captura los comandos nuevos del historial de bash.
#
# Uso:
#   ./scripts/vigilancia.sh start [segundos]   inicia en segundo plano (20 s por defecto)
#   ./scripts/vigilancia.sh stop               detiene
#   ./scripts/vigilancia.sh status             muestra estado y última actividad
#   ./scripts/vigilancia.sh once               guarda una foto ahora y sale
#   ./scripts/vigilancia.sh captura ["nota"]   saca una captura de pantalla ahora
#   ./scripts/vigilancia.sh run [segundos]     corre en primer plano (para depurar)
#
# Archivos humanos:
#   docs/estado/actual.md       última foto completa
#   docs/estado/cambios.md      historial de diffs
#   docs/estado/comandos.md     comandos nuevos del chroot y del live
#   docs/estado/vigilancia.md   inicio, paradas y errores del watcher
#   docs/capturas/              capturas de pantalla, con índice en README.md
#
# Copia persistente (sobrevive al reinicio del live):
#   /mnt/gentoo/var/log/qwertoo-instalacion/

set -u

REPO="${REPO:-$(cd "$(dirname "$0")/.." && pwd)}"
STATE_DIR="$REPO/docs/estado"
CAPDIR="$REPO/docs/capturas"
PERSIST="${PERSIST:-/mnt/gentoo/var/log/qwertoo-instalacion}"
SNAP="$REPO/scripts/estado-instalacion.sh"
SCRIPT="$(readlink -f "$0")"

# Capturas: cada cuántos segundos como mínimo, y cada cuántos tras un comando.
CAPTURE_INTERVALO="${CAPTURE_INTERVALO:-600}"
CAPTURE_TRAS_COMANDO="${CAPTURE_TRAS_COMANDO:-60}"
SESSION_UID="${SESSION_UID:-1000}"
SESSION_USER="${SESSION_USER:-$(id -un)}"

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo -n"
fi

STATE=""
PIDFILE=""
LOCKFILE=""

ensure_dirs() {
  mkdir -p "$STATE_DIR" "$CAPDIR"

  if [ ! -d "$PERSIST" ]; then
    $SUDO install -d -o "$(id -un)" -g "$(id -gn)" -m 0775 "$PERSIST" 2>/dev/null ||
      mkdir -p "$PERSIST" 2>/dev/null || true
  fi

  if [ ! -w "$PERSIST" ]; then
    PERSIST="$STATE_DIR/.persist"
    mkdir -p "$PERSIST"
  fi

  STATE="$PERSIST/state"
  mkdir -p "$STATE" "$PERSIST/capturas"
  PIDFILE="$STATE/watcher.pid"
  LOCKFILE="$STATE/watcher.lock"

  if [ ! -f "$CAPDIR/README.md" ]; then
    cat > "$CAPDIR/README.md" <<'EOF'
# Capturas

Capturas de pantalla del escritorio mientras se instala Gentoo. Las saca
`scripts/vigilancia.sh`: cada 10 minutos, después de cada comando nuevo (con una espera
mínima de 60 segundos) y a pedido.

| Archivo | Fecha (UTC) | Nota |
|---|---|---|
EOF
  fi

  if [ ! -f "$STATE_DIR/cambios.md" ]; then
    cat > "$STATE_DIR/cambios.md" <<'EOF'
# Cambios detectados

Historial generado por `scripts/vigilancia.sh`. Cada bloque muestra el diff entre dos
fotos consecutivas del sistema instalado. La foto inicial está al principio.

Los cambios de `emerge.log` aparecen durante las compilaciones; eso es esperado.
EOF
  fi

  if [ ! -f "$STATE_DIR/comandos.md" ]; then
    cat > "$STATE_DIR/comandos.md" <<'EOF'
# Comandos registrados

Comandos nuevos leídos de los historiales de bash. El chroot tiene que tener el historial
activado (ver `docs/estado/README.md`). Los comandos se agrupan por archivo de origen.

No se registran contraseñas: `passwd` aparece como comando, no como entrada.
EOF
  fi

  if [ ! -f "$STATE_DIR/vigilancia.md" ]; then
    cat > "$STATE_DIR/vigilancia.md" <<'EOF'
# Vigilancia

Bitácora del watcher: inicio, paradas, cambios detectados y errores.
EOF
  fi
}

sync_persist() {
  local f="$1"
  local dest="$PERSIST/$(basename "$f")"
  [ "$f" -ef "$dest" ] 2>/dev/null || cp -f "$f" "$dest" 2>/dev/null || true
}

log_event() {
  local ts
  ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
  printf '\n- %s — %s\n' "$ts" "$1" >> "$STATE_DIR/vigilancia.md"
  sync_persist "$STATE_DIR/vigilancia.md"
}

write_actual() {
  local snap="$1" ts="$2"
  {
    echo "# Estado actual de la instalación"
    echo
    echo "Corte: $ts"
    echo
    cat "$snap"
  } > "$STATE_DIR/actual.md"
  sync_persist "$STATE_DIR/actual.md"
}

append_change() {
  local snap="$1" ts="$2" baseline="$3" n
  {
    echo
    echo "## $ts"
    echo
    if [ "$baseline" = "si" ]; then
      echo '```text'
      cat "$snap"
      echo '```'
    else
      echo '```diff'
      diff -u "$STATE/last.snapshot" "$snap" 2>/dev/null | sed -n '1,300p' || true
      echo '```'
      n=$(diff -u "$STATE/last.snapshot" "$snap" 2>/dev/null | wc -l || true)
      if [ "${n:-0}" -gt 300 ]; then
        echo
        echo "_(diff recortado: ${n} líneas)_"
      fi
    fi
  } >> "$STATE_DIR/cambios.md"
  sync_persist "$STATE_DIR/cambios.md"
}

history_specs() {
  printf '%s\t%s\n' \
    "chroot-root" "$ROOT/root/.bash_history" \
    "chroot-ldgnu" "$ROOT/home/ldgnu/.bash_history" \
    "live-root" "/root/.bash_history" \
    "live-gentoo" "/home/gentoo/.bash_history"
}

init_history_offsets() {
  local label file size
  while IFS=$'\t' read -r label file; do
    size=$($SUDO stat -c %s "$file" 2>/dev/null || echo 0)
    printf '%s\n' "${size:-0}" > "$STATE/hist-$label"
  done < <(history_specs)
}

HUBO_COMANDOS=0

capture_history() {
  local ts="$1" label file size off
  HUBO_COMANDOS=0
  while IFS=$'\t' read -r label file; do
    $SUDO test -f "$file" 2>/dev/null || continue
    size=$($SUDO stat -c %s "$file" 2>/dev/null || echo 0)
    off=$(cat "$STATE/hist-$label" 2>/dev/null || echo 0)
    [ "${size:-0}" -lt "${off:-0}" ] && off=0

    if [ "${size:-0}" -gt "${off:-0}" ]; then
      {
        echo
        echo "## $ts — $label"
        echo
        echo '~~~text'
        $SUDO tail -c +$((off + 1)) "$file" 2>/dev/null | while IFS= read -r line; do
          case "$line" in
            \#[0-9]*)
              printf '# %s\n' "$(date -u -d "@${line#\#}" +'%Y-%m-%d %H:%M:%SZ' 2>/dev/null || printf '%s' "$line")"
              ;;
            *)
              printf '%s\n' "$line"
              ;;
          esac
        done
        echo
        echo '~~~'
      } >> "$STATE_DIR/comandos.md"
      sync_persist "$STATE_DIR/comandos.md"
      printf '%s\n' "$size" > "$STATE/hist-$label"
      HUBO_COMANDOS=1
    fi
  done < <(history_specs)
}

# Saca una captura del escritorio KDE/Wayland y la guarda como JPEG liviano.
# Uso: capturar "nota"
capturar() {
  local nota="${1:-manual}" ts slug name raw err out auth
  ensure_dirs

  if [ ! -S "/run/user/$SESSION_UID/wayland-0" ]; then
    log_event "captura omitida: no hay sesión gráfica en /run/user/$SESSION_UID"
    return 1
  fi

  ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
  slug="$(printf '%s' "$nota" | tr ' ' '-' | tr -cd '[:alnum:]._-' | cut -c1-50)"
  name="$(date -u +'%Y%m%dT%H%M%SZ')-${slug:-captura}"
  out="$CAPDIR/$name.jpg"
  raw="$(mktemp --suffix=.png)"
  err="$(mktemp)"
  auth="$(ls -1 "/run/user/$SESSION_UID"/xauth_* 2>/dev/null | head -n 1)"

  local runner=()
  if [ "$(id -u)" -eq 0 ] && [ "$SESSION_UID" -ne 0 ]; then
    runner=(sudo -n -u "$SESSION_USER")
  fi

  if ! timeout 25 "${runner[@]}" env \
      XDG_RUNTIME_DIR="/run/user/$SESSION_UID" \
      WAYLAND_DISPLAY=wayland-0 \
      DISPLAY=:0 \
      XAUTHORITY="$auth" \
      XDG_SESSION_TYPE=wayland \
      XDG_CURRENT_DESKTOP=KDE \
      XDG_SESSION_DESKTOP=KDE \
      KDE_FULL_SESSION=true \
      KDE_SESSION_VERSION=6 \
      spectacle -b -n -f -o "$raw" >"$err" 2>&1; then
    log_event "captura falló: $(tr '\n' ' ' < "$err" | cut -c1-160)"
    rm -f "$raw" "$err"
    return 1
  fi

  if command -v magick >/dev/null 2>&1; then
    magick "$raw" -resize 1600x -strip -quality 82 "$out" 2>/dev/null || cp -f "$raw" "$out"
  else
    cp -f "$raw" "$out"
  fi

  if [ ! -s "$out" ]; then
    log_event "captura falló: archivo vacío"
    rm -f "$raw" "$err" "$out"
    return 1
  fi

  # Pantalla apagada o bloqueada: no sirve de registro, no se guarda.
  if [ "$(magick "$out" -colorspace Gray -format '%[fx:mean<0.02]' info: 2>/dev/null)" = "1" ]; then
    rm -f "$raw" "$err" "$out"
    log_event "captura omitida: pantalla en negro o apagada"
    return 0
  fi

  printf '| [%s](%s) | %s | %s |\n' "$name" "$(basename "$out")" "$ts" "$nota" >> "$CAPDIR/README.md"
  cp -f "$out" "$PERSIST/capturas/" 2>/dev/null || true
  log_event "captura guardada: $name.jpg ($(du -h "$out" | cut -f1))"
  rm -f "$raw" "$err"
}

run() {
  local interval="${1:-20}" ts tmp hash last_hash
  local ultima_captura=0 ahora auto_capturas=1
  ensure_dirs

  exec 9>"$LOCKFILE"
  if ! flock -n 9; then
    echo "Ya hay un watcher corriendo (lock $LOCKFILE)." >&2
    exit 0
  fi

  printf '%s\n' "$$" > "$PIDFILE"
  log_event "watcher iniciado (pid $$, intervalo ${interval}s)"

  cleanup() {
    log_event "watcher detenido (pid $$)"
    rm -f "$PIDFILE"
  }
  trap cleanup EXIT INT TERM

  init_history_offsets

  ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
  tmp="$(mktemp)"
  "$SNAP" > "$tmp" 2>/dev/null 9>&- || true

  if [ -f "$STATE/last.snapshot" ]; then
    last_hash="$(sha256sum "$STATE/last.snapshot" | awk '{print $1}')"
    hash="$(sha256sum "$tmp" | awk '{print $1}')"
    if [ "$hash" != "$last_hash" ]; then
      append_change "$tmp" "$ts" no
      cp -f "$tmp" "$STATE/last.snapshot"
      last_hash="$hash"
    fi
    write_actual "$tmp" "$ts"
  else
    cp -f "$tmp" "$STATE/last.snapshot"
    write_actual "$tmp" "$ts"
    append_change "$tmp" "$ts" si
    last_hash="$(sha256sum "$tmp" | awk '{print $1}')"
  fi

  rm -f "$tmp"

  ultima_captura="$(date +%s)"
  if ! capturar "inicio de la vigilancia"; then
    auto_capturas=0
    log_event "capturas automáticas desactivadas (falló la primera)"
  fi

  while :; do
    sleep "$interval" 9>&-
    ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
    tmp="$(mktemp)"
    if ! "$SNAP" > "$tmp" 2>/dev/null 9>&-; then
      log_event "error al generar la foto; se reintenta"
      rm -f "$tmp"
      continue
    fi

    hash="$(sha256sum "$tmp" | awk '{print $1}')"
    if [ "$hash" != "$last_hash" ]; then
      append_change "$tmp" "$ts" no
      write_actual "$tmp" "$ts"
      cp -f "$tmp" "$STATE/last.snapshot"
      log_event "cambio detectado"
      last_hash="$hash"
    fi

    capture_history "$ts"

    ahora="$(date +%s)"
    if [ "$auto_capturas" -eq 1 ]; then
      if [ "$HUBO_COMANDOS" -eq 1 ] &&
         [ $((ahora - ultima_captura)) -ge "$CAPTURE_TRAS_COMANDO" ]; then
        capturar "tras comando" && ultima_captura="$ahora" || auto_capturas=0
      elif [ $((ahora - ultima_captura)) -ge "$CAPTURE_INTERVALO" ]; then
        capturar "periódica" && ultima_captura="$ahora" || auto_capturas=0
      fi
    fi

    rm -f "$tmp"
  done
}

start() {
  local interval="${1:-20}"
  ensure_dirs

  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "La vigilancia ya está corriendo (pid $(cat "$PIDFILE"))."
    return 0
  fi

  rm -f "$PIDFILE"

  # Esperar a que el lock quede libre si el watcher anterior todavía está cerrando.
  local i
  for i in $(seq 1 50); do
    flock -n "$LOCKFILE" true 2>/dev/null && break
    sleep 0.2
  done

  setsid nohup "$SCRIPT" run "$interval" >/dev/null 2>&1 < /dev/null &

  for i in $(seq 1 50); do
    [ -s "$PIDFILE" ] && break
    sleep 0.2
  done

  if [ -s "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "Vigilancia iniciada (pid $(cat "$PIDFILE"), cada ${interval}s)."
    echo "  Última foto:  $STATE_DIR/actual.md"
    echo "  Cambios:      $STATE_DIR/cambios.md"
    echo "  Comandos:     $STATE_DIR/comandos.md"
    echo "  Persistente:  $PERSIST"
  else
    echo "No se pudo iniciar la vigilancia. Revisá $STATE_DIR/vigilancia.md" >&2
    return 1
  fi
}

stop() {
  ensure_dirs
  if [ ! -f "$PIDFILE" ]; then
    echo "No hay watcher registrado."
    return 0
  fi
  local pid i
  pid="$(cat "$PIDFILE")"
  if kill -0 "$pid" 2>/dev/null; then
    # El watcher es líder de sesión (setsid): matar el grupo se lleva también el sleep.
    kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
    for i in $(seq 1 50); do
      kill -0 "$pid" 2>/dev/null || break
      sleep 0.2
    done
    kill -0 "$pid" 2>/dev/null && { kill -KILL -- "-$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null || true; }
    echo "Vigilancia detenida (pid $pid)."
  else
    echo "El pid $pid ya no está vivo; limpio el archivo."
  fi
  rm -f "$PIDFILE"
}

status() {
  ensure_dirs
  if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "Corriendo (pid $(cat "$PIDFILE"))."
  else
    echo "Detenida."
  fi
  echo "  Última foto:  $STATE_DIR/actual.md"
  [ -f "$STATE_DIR/actual.md" ] && stat -c '                %y' "$STATE_DIR/actual.md"
  local cambios comandos
  cambios=$(grep -c '^## ' "$STATE_DIR/cambios.md" 2>/dev/null)
  comandos=$(grep -c '^## ' "$STATE_DIR/comandos.md" 2>/dev/null)
  echo "  Cambios:      ${cambios:-0} bloques"
  echo "  Comandos:     ${comandos:-0} bloques"
  local caps
  caps=$(find "$CAPDIR" -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l)
  echo "  Capturas:     ${caps:-0} archivos"
  echo "  Persistente:  $PERSIST"
  echo
  echo "Últimos eventos:"
  grep '^- ' "$STATE_DIR/vigilancia.md" 2>/dev/null | tail -n 6 || true
}

once() {
  ensure_dirs
  local ts tmp
  ts="$(date -u +'%Y-%m-%d %H:%M:%SZ')"
  tmp="$(mktemp)"
  "$SNAP" > "$tmp" 2>/dev/null || true
  write_actual "$tmp" "$ts"
  rm -f "$tmp"
  echo "Foto guardada en $STATE_DIR/actual.md"
}

ROOT="${ROOT:-/mnt/gentoo}"

cmd="${1:-start}"
[ $# -gt 0 ] && shift

case "$cmd" in
  start) start "${1:-20}" ;;
  run) run "${1:-20}" ;;
  stop) stop ;;
  status) status ;;
  once) once ;;
  captura|capture) capturar "${1:-manual}" ;;
  *)
    cat >&2 <<EOF
Uso: $0 {start [segundos]|stop|status|once|captura [nota]|run [segundos]}
EOF
    exit 2
    ;;
esac
