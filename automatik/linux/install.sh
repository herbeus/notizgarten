#!/usr/bin/env bash
# Richtet die systemd-user-Timer ein. Linux und WSL (WSL braucht systemd=true in /etc/wsl.conf).
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNITS="$HOME/.config/systemd/user"

command -v systemctl >/dev/null || { echo "FEHLER: systemd nicht verfuegbar"; exit 1; }
systemctl --user show-environment >/dev/null 2>&1 || {
  echo "FEHLER: systemd-user laeuft nicht."
  echo "In WSL: 'systemd=true' unter [boot] in /etc/wsl.conf eintragen, dann 'wsl --shutdown'."
  exit 1
}

[ -f "$HOME/.config/notizgarten/config" ] || {
  echo "FEHLER: ~/.config/notizgarten/config fehlt."
  echo "  mkdir -p ~/.config/notizgarten"
  echo "  cp $HERE/../config.example ~/.config/notizgarten/config"
  echo "  \$EDITOR ~/.config/notizgarten/config"
  exit 1
}

# Die Units zeigen per %h/notizgarten auf das Repo. Liegt es woanders (z.B. unter
# ~/projects/notizgarten), muss der Pfad beim Einspielen ersetzt werden - sonst startet
# systemd ein Skript, das es nicht gibt, und der Timer scheitert stumm.
REPO="$(cd "$HERE/../.." && pwd)"
mkdir -p "$UNITS"
for f in "$HERE"/notizgarten-*.service; do
  sed "s|%h/notizgarten/|$REPO/|" "$f" > "$UNITS/$(basename "$f")"
done
cp -f "$HERE"/notizgarten-*.timer "$UNITS/"
echo "Runner-Pfad in den Units: $REPO/automatik/runner.sh"
systemctl --user daemon-reload

echo "Welche Laeufe sollen aktiv sein? (mehrfach moeglich, Leerzeichen getrennt)"
echo "  1) abendlese (taeglich 20:00)   2) wochenreview (So 18:00)   3) gaertner (monatlich)"
read -r -p "Auswahl [1 2 3]: " sel
sel="${sel:-1 2 3}"
for n in $sel; do
  case "$n" in
    1) u=notizgarten-abendlese ;;
    2) u=notizgarten-wochenreview ;;
    3) u=notizgarten-gaertner ;;
    *) echo "uebersprungen: $n"; continue ;;
  esac
  systemctl --user enable --now "$u.timer"
  echo "aktiv: $u.timer"
done

echo
echo "Pruefen:  systemctl --user list-timers 'notizgarten-*'"
echo "Testlauf: ~/notizgarten/automatik/runner.sh abendlese"
