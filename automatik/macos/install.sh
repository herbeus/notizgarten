#!/usr/bin/env bash
# Richtet die launchd-Jobs auf macOS ein.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS="$HOME/Library/LaunchAgents"

[ "$(uname -s)" = "Darwin" ] || { echo "FEHLER: nur fuer macOS - unter Linux/WSL ../linux/install.sh nutzen"; exit 1; }

[ -f "$HOME/.config/mega-brain/config" ] || {
  echo "FEHLER: ~/.config/mega-brain/config fehlt."
  echo "  mkdir -p ~/.config/mega-brain"
  echo "  cp $HERE/../config.example ~/.config/mega-brain/config"
  echo "  \$EDITOR ~/.config/mega-brain/config"
  exit 1
}

mkdir -p "$AGENTS" "$HOME/.local/state/mega-brain"

echo "Welche Laeufe sollen aktiv sein? (mehrfach moeglich, Leerzeichen getrennt)"
echo "  1) destillat (taeglich 20:00)   2) wochenreview (So 18:00)   3) gaertner (monatlich)"
read -r -p "Auswahl [1 2 3]: " sel
sel="${sel:-1 2 3}"

for n in $sel; do
  case "$n" in
    1) t=destillat ;;
    2) t=wochenreview ;;
    3) t=gaertner ;;
    *) echo "uebersprungen: $n"; continue ;;
  esac
  label="org.megabrain.$t"
  # __HOME__ ersetzen: plists kennen keine Variablenexpansion.
  sed "s|__HOME__|$HOME|g" "$HERE/$label.plist" > "$AGENTS/$label.plist"
  launchctl bootout "gui/$UID/$label" 2>/dev/null || true
  launchctl bootstrap "gui/$UID" "$AGENTS/$label.plist"
  echo "aktiv: $label"
done

cat <<'HINT'

Zwei Dinge, die macOS eigen sind:

1. VOLLZUGRIFF AUF FESTPLATTE
   Liegt das Vault in iCloud, braucht das ausfuehrende Programm die Berechtigung
   "Festplattenvollzugriff" (Systemeinstellungen -> Datenschutz & Sicherheit).
   Ohne sie schlaegt der Lauf mit "Operation not permitted" fehl, ohne jede Nachfrage.
   Fuege dort dein Terminal-Programm hinzu und starte es neu.

2. SCHLAFENDER MAC
   launchd holt einen verpassten Lauf nach dem Aufwachen nach, aber nur einmal -
   nicht fuer jeden ausgefallenen Tag. Bei einem Rechner, der nachts zu ist, lohnt
   eine Startzeit am fruehen Abend statt spaet.

Pruefen:  launchctl list | grep megabrain
Testlauf: ~/mega-brain/automatik/runner.sh destillat
HINT
