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

[ -f "$HOME/.config/zettelgarten/config" ] || {
  echo "FEHLER: ~/.config/zettelgarten/config fehlt."
  echo "  mkdir -p ~/.config/zettelgarten"
  echo "  cp $HERE/../config.example ~/.config/zettelgarten/config"
  echo "  \$EDITOR ~/.config/zettelgarten/config"
  exit 1
}

RUNNER="$(cd "$HERE/.." && pwd)/runner.sh"
[ -x "$RUNNER" ] || { echo "FEHLER: $RUNNER fehlt oder ist nicht ausfuehrbar"; exit 1; }

mkdir -p "$UNITS"
# __RUNNER__ durch den echten Pfad dieses Klons ersetzen - wo das Repo liegt, ist egal.
for u in "$HERE"/zettelgarten-*.service; do
  sed "s|__RUNNER__|$RUNNER|g" "$u" > "$UNITS/$(basename "$u")"
done
cp -f "$HERE"/zettelgarten-*.timer "$UNITS/"
systemctl --user daemon-reload

echo "Welche Laeufe sollen aktiv sein? (mehrfach moeglich, Leerzeichen getrennt)"
echo "  1) destillat (taeglich 20:00)   2) wochenreview (So 18:00)   3) gaertner (monatlich)"
read -r -p "Auswahl [1 2 3]: " sel
sel="${sel:-1 2 3}"
for n in $sel; do
  case "$n" in
    1) u=zettelgarten-destillat ;;
    2) u=zettelgarten-wochenreview ;;
    3) u=zettelgarten-gaertner ;;
    *) echo "uebersprungen: $n"; continue ;;
  esac
  systemctl --user enable --now "$u.timer"
  echo "aktiv: $u.timer"
done

echo
echo "Pruefen:  systemctl --user list-timers 'zettelgarten-*'"
echo "Testlauf: $RUNNER destillat --dry-run   (zeigt Prompt und Rechte, startet nichts)"
echo "          $RUNNER destillat"
