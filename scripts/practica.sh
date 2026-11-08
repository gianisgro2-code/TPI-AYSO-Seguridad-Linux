#!/usr/bin/env bash
# Laboratorio local de permisos. Ejecutar como usuario normal en Cloud Shell.
set -Eeuo pipefail
[[ $(id -u) != 0 ]] || { echo 'Ejecutar como usuario normal'; exit 1; }
sudo -v
for cmd in mktemp stat getent useradd groupadd usermod runuser; do
  command -v "$cmd" >/dev/null || { echo "Falta $cmd"; exit 1; }
done
mkdir -p "$HOME/TP_AYSO_Seguridad/evidencias"
LOG=$(mktemp "$HOME/TP_AYSO_Seguridad/evidencias/prueba.XXXXXX.log")
chmod 600 "$LOG"
exec > >(tee "$LOG") 2>&1
LAB=$(mktemp -d /tmp/tpi-ayso.XXXXXX)
chmod 755 "$LAB"
TAG=$(basename "$LAB" | tr '[:upper:].-' '[:lower:]__')
USR="${TAG}_u"
GRP="${TAG}_g"
CREATED_USER=0
CREATED_GROUP=0
cleanup() {
  # Solo cuentas creadas por esta ejecución. Se conservan archivos de prueba.
  if [[ $CREATED_USER == 1 ]]; then sudo userdel "$USR"; fi
  if [[ $CREATED_GROUP == 1 ]]; then sudo groupdel "$GRP"; fi
  echo "Laboratorio conservado en $LAB; registro en $LOG"
}
trap cleanup EXIT
getent passwd "$USR" >/dev/null && exit 1
getent group "$GRP" >/dev/null && exit 1
sudo groupadd "$GRP"
CREATED_GROUP=1
sudo useradd -M -g "$GRP" -s /usr/sbin/nologin "$USR"
CREATED_USER=1
# Cuenta sin contraseña utilizable; no se habilita acceso remoto.
probe() {
  local testid=$1 expected=$2 rc
  shift 2
  echo "=== $testid | esperado: $expected ==="
  printf 'Comando: '; printf '%q ' "$@"; printf '\n'
  if "$@"; then rc=0; else rc=$?; fi
  echo "codigo_salida=$rc"
  if [[ $expected == permite && $rc == 0 ]] ||
     [[ $expected == deniega && $rc != 0 ]]; then
    echo 'COINCIDE con la expectativa; revisar también mensaje y contexto'
  else
    echo 'DIFIERE de la expectativa; investigar'
  fi
}
date -Is
cat /etc/os-release
uname -r
whoami
id
sudo -u "$USR" -- id
printf 'LAB=%s\nUSR=%s\nGRP=%s\n' "$LAB" "$USR" "$GRP"
printf 'Documento ficticio del TPI\n' > "$LAB/datos.txt"
chmod 644 "$LAB/datos.txt"
ls -ld /tmp "$LAB"
stat -c '%A %a %U %G %n' "$LAB/datos.txt"
if command -v getfacl >/dev/null; then getfacl -p "$LAB/datos.txt"; fi
probe P01 permite sudo -u "$USR" -- cat "$LAB/datos.txt"
chmod 600 "$LAB/datos.txt"
stat -c '%A %a %U %G %n' "$LAB/datos.txt"
probe P02 permite cat "$LAB/datos.txt"
probe P03 deniega sudo -u "$USR" -- cat "$LAB/datos.txt"
probe P04 deniega sudo -u "$USR" -- sh -c 'printf "intrusion\n" >> "$1"' sh "$LAB/datos.txt"
probe P05 permite sudo cat "$LAB/datos.txt"
sudo chgrp "$GRP" "$LAB/datos.txt"
chmod 640 "$LAB/datos.txt"
stat -c '%A %a %U %G %n' "$LAB/datos.txt"
probe P06 permite sudo -u "$USR" -- cat "$LAB/datos.txt"
probe P07 deniega sudo -u "$USR" -- sh -c 'printf "intrusion\n" >> "$1"' sh "$LAB/datos.txt"
# Aislar el efecto del permiso de búsqueda del directorio.
chmod 644 "$LAB/datos.txt"
chmod 700 "$LAB"
probe P08 deniega sudo -u "$USR" -- cat "$LAB/datos.txt"
chmod 755 "$LAB"
probe P09 permite sudo -u "$USR" -- cat "$LAB/datos.txt"
(umask 077; touch "$LAB/privado.txt"; mkdir "$LAB/privado")
stat -c '%A %a %U %G %n' "$LAB/privado.txt" "$LAB/privado"
echo 'P10: comprobar 600 y 700; la subshell no cambia la umask original'
sudo -l
echo 'P11: interpretar la política real de sudo, sin cambiarla'
chmod 600 "$LAB/datos.txt"
chmod 700 "$LAB"
echo 'Fin. Ningún resultado de este registro existía antes de ejecutar el script.'
