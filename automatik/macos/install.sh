#!/usr/bin/env bash
# Richtet die launchd-Jobs auf macOS ein.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS="$HOME/Library/LaunchAgents"

[ "$(uname -s)" = "Darwin" ] || { echo "FEHLER: nur fuer macOS - unter Linux/WSL ../linux/install.sh nutzen"; exit 1; }

[ -f "$HOME/.config/zettelgarten/config" ] || {
  echo "FEHLER: ~/.config/zettelgarten/config fehlt."
  echo "  mkdir -p ~/.config/zettelgarten"
  echo "  cp $HERE/../config.example ~/.config/zettelgarten/config"
  echo "  \$EDITOR ~/.config/zettelgarten/config"
  exit 1
}

RUNNER="$(cd "$HERE/.." && pwd)/runner.sh"
[ -x "$RUNNER" ] || { echo "FEHLER: $RUNNER fehlt oder ist nicht ausfuehrbar"; exit 1; }

mkdir -p "$AGENTS" "$HOME/.local/state/zettelgarten"

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
  label="org.zettelgarten.$t"
  # __HOME__ und __RUNNER__ ersetzen: plists kennen keine Variablenexpansion, und wo das
  # Repo liegt, soll egal sein.
  sed -e "s|__HOME__|$HOME|g" -e "s|__RUNNER__|$RUNNER|g" "$HERE/$label.plist" > "$AGENTS/$label.plist"
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
   Unter launchd zaehlt das Programm selbst: /bin/bash UND das Binary des Agenten.
   Details und die Versionspfad-Falle: docs/setup-macos.md.

2. SCHLAFENDER MAC
   launchd holt einen verpassten Lauf nach dem Aufwachen nach, aber nur einmal -
   nicht fuer jeden ausgefallenen Tag. Bei einem Rechner, der nachts zu ist, lohnt
   eine Startzeit am fruehen Abend statt spaet.

Pruefen:  launchctl list | grep zettelgarten
Testlauf: <repo>/automatik/runner.sh destillat --dry-run   (zeigt Prompt und Rechte)
          <repo>/automatik/runner.sh destillat             (im Terminal am Mac, nicht per SSH)
HINT
