#!/usr/bin/env bash
# runner.sh <destillat|wochenreview|gaertner> - startet einen Automatik-Lauf headless.
#
# Wird von systemd (Linux/WSL) oder launchd (macOS) aufgerufen, laeuft aber auch von Hand.
# Bewusst portabel gehalten: macOS bringt bash 3.2 mit, kein flock, und BSD-stat statt GNU-stat.
set -uo pipefail

TASK="${1:-}"
case "$TASK" in
  destillat|wochenreview|gaertner) ;;
  *) echo "usage: runner.sh <destillat|wochenreview|gaertner>" >&2; exit 2 ;;
esac

# ---------- Konfiguration ----------
# Reihenfolge: Umgebungsvariable, dann Konfigdatei, dann Fehler.
CONF="${MEGABRAIN_CONF:-$HOME/.config/mega-brain/config}"
# shellcheck source=/dev/null
[ -f "$CONF" ] && . "$CONF"

: "${VAULT:=}"                                   # Pflicht: Pfad zum Vault
: "${PROMPT_DIR:=$HOME/mega-brain/prompts}"      # wo die Prompt-Dateien liegen
: "${AGENT:=claude}"                             # CLI des Agenten
: "${LOG:=$HOME/.local/state/mega-brain/run.log}"
: "${TIMEOUT_SECS:=900}"
: "${NOTIFY:=1}"                                 # 0 = keine Benachrichtigung

if [ -z "$VAULT" ]; then
  echo "FEHLER: VAULT ist nicht gesetzt. Lege $CONF an - Vorlage: config.example" >&2
  exit 1
fi
if [ ! -d "$VAULT" ]; then
  echo "FEHLER: Vault-Pfad existiert nicht: $VAULT" >&2
  exit 1
fi

# Timer und launchd starten mit minimalem PATH - der Agent liegt oft in ~/.local/bin.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v "$AGENT" >/dev/null 2>&1 || { echo "FEHLER: '$AGENT' nicht im PATH" >&2; exit 1; }

PROMPT_FILE="$PROMPT_DIR/$(case "$TASK" in
  destillat) echo abend-destillat.md ;;
  wochenreview) echo wochenreview.md ;;
  gaertner) echo gaertner.md ;;
esac)"
[ -f "$PROMPT_FILE" ] || { echo "FEHLER: Prompt fehlt: $PROMPT_FILE" >&2; exit 1; }

mkdir -p "$(dirname "$LOG")"

# ---------- Nur ein Lauf gleichzeitig ----------
# mkdir ist atomar und gibt es ueberall - flock fehlt auf macOS.
LOCK="${TMPDIR:-/tmp}/mega-brain-$TASK.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "$(date '+%F %T') [$TASK] laeuft bereits, Abbruch" >>"$LOG"
  exit 0
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT INT TERM

# ---------- Log-Rotation (portabel: kein stat) ----------
if [ -f "$LOG" ] && [ "$(wc -c <"$LOG" | tr -d ' ')" -gt 1048576 ]; then
  mv "$LOG" "$LOG.1"
fi

echo "===== $(date '+%F %T') [$TASK] =====" >>"$LOG"

# ---------- Prompt vorbereiten ----------
# Der Kopf der Datei ist Doku fuer Menschen; an den Agenten geht alles ab der Zeile "## Prompt".
BODY="$(awk '/^## Prompt$/{flag=1;next} flag' "$PROMPT_FILE")"
[ -n "$BODY" ] || BODY="$(cat "$PROMPT_FILE")"

# Platzhalter fuellen, soweit konfiguriert.
BODY="${BODY//<< VAULT-PFAD >>/$VAULT}"
BODY="${BODY//<< PFAD ZU DEN TRANSKRIPTEN >>/${TRANSCRIPTS:-}}"
BODY="${BODY//<< PFAD ZU MEINEN REPOS >>/${REPOS:-}}"
BODY="${BODY//<< MEINE MAILADRESSE >>/${GIT_AUTHOR:-}}"

if printf '%s' "$BODY" | grep -q '<<'; then
  echo "WARN: ungefuellte Platzhalter im Prompt:" >>"$LOG"
  printf '%s' "$BODY" | grep -o '<<[^>]*>>' | sort -u | sed 's/^/  /' >>"$LOG"
fi

# ---------- Lauf ----------
# Schreibrechte bewusst auf das Vault beschraenkt. Der Agent soll nichts ausserhalb anfassen.
RC=0
OUT="$(
  if command -v timeout >/dev/null 2>&1; then
    timeout --kill-after=30s "$TIMEOUT_SECS" \
      "$AGENT" -p --permission-mode acceptEdits --max-turns 40 \
      --allowedTools "Read Glob Grep Write($VAULT/**) Edit($VAULT/**) Bash(ls:*) Bash(find:*) Bash(cat:*)" \
      "$BODY" 2>&1
  else
    # macOS ohne coreutils: kein timeout. Dann eben ohne - der Agent hat --max-turns als Bremse.
    "$AGENT" -p --permission-mode acceptEdits --max-turns 40 \
      --allowedTools "Read Glob Grep Write($VAULT/**) Edit($VAULT/**) Bash(ls:*) Bash(find:*) Bash(cat:*)" \
      "$BODY" 2>&1
  fi
)" || RC=$?

printf '%s\n' "$OUT" >>"$LOG"

SUMMARY="$(printf '%s' "$OUT" | grep -v '^$' | tail -3 | tr '\n' ' ')"
[ -n "$SUMMARY" ] || SUMMARY="keine Ausgabe"
if [ "$RC" -ne 0 ]; then
  SUMMARY="FEHLER (rc=$RC): $SUMMARY"
fi
echo "$(date '+%F %T') [$TASK] fertig (rc=$RC)" >>"$LOG"

# ---------- Benachrichtigung ----------
if [ "$NOTIFY" = "1" ]; then
  "$(dirname "$0")/notify.sh" "Mega Brain: $TASK" "$SUMMARY" 2>/dev/null || true
fi

echo "[$TASK] $SUMMARY"
exit "$RC"
