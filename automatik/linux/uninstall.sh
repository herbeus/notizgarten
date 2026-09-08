#!/usr/bin/env bash
# Entfernt die systemd-user-Timer und Units wieder.
set -euo pipefail
UNITS="$HOME/.config/systemd/user"
for t in destillat wochenreview gaertner; do
  u="zettelgarten-$t"
  systemctl --user disable --now "$u.timer" 2>/dev/null && echo "gestoppt: $u.timer" || true
  rm -f "$UNITS/$u.timer" "$UNITS/$u.service"
done
systemctl --user daemon-reload 2>/dev/null || true
echo "fertig"
