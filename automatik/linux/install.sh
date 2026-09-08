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

[ -f "$HOME/.config/mega-brain/config" ] || {
  echo "FEHLER: ~/.config/mega-brain/config fehlt."
  echo "  mkdir -p ~/.config/mega-brain"
  echo "  cp $HERE/../config.example ~/.config/mega-brain/config"
  echo "  \$EDITOR ~/.config/mega-brain/config"
  exit 1
}

mkdir -p "$UNITS"
cp -f "$HERE"/mega-brain-*.service "$HERE"/mega-brain-*.timer "$UNITS/"
systemctl --user daemon-reload

echo "Welche Laeufe sollen aktiv sein? (mehrfach moeglich, Leerzeichen getrennt)"
echo "  1) destillat (taeglich 20:00)   2) wochenreview (So 18:00)   3) gaertner (monatlich)"
read -r -p "Auswahl [1 2 3]: " sel
sel="${sel:-1 2 3}"
for n in $sel; do
  case "$n" in
    1) u=mega-brain-destillat ;;
    2) u=mega-brain-wochenreview ;;
    3) u=mega-brain-gaertner ;;
    *) echo "uebersprungen: $n"; continue ;;
  esac
  systemctl --user enable --now "$u.timer"
  echo "aktiv: $u.timer"
done

echo
echo "Pruefen:  systemctl --user list-timers 'mega-brain-*'"
echo "Testlauf: ~/mega-brain/automatik/runner.sh destillat"
