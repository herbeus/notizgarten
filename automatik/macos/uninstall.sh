#!/usr/bin/env bash
# Entfernt die launchd-Jobs wieder.
set -euo pipefail
for t in destillat wochenreview gaertner; do
  label="org.megabrain.$t"
  launchctl bootout "gui/$UID/$label" 2>/dev/null && echo "gestoppt: $label" || true
  rm -f "$HOME/Library/LaunchAgents/$label.plist"
done
echo "fertig"
