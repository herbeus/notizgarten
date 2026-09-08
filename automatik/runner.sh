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
CONF="${ZETTELGARTEN_CONF:-$HOME/.config/zettelgarten/config}"
# shellcheck source=/dev/null
[ -f "$CONF" ] && . "$CONF"

: "${VAULT:=}"                                   # Pflicht: Pfad zum Vault
: "${PROMPT_DIR:=$HOME/zettelgarten/prompts}"      # wo die Prompt-Dateien liegen
: "${AGENT:=claude}"                             # CLI des Agenten
: "${LOG:=$HOME/.local/state/zettelgarten/run.log}"
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

# Achtung: das case bewusst NICHT in eine $()-Ersetzung schachteln - bash 3.2 (macOS)
# kann ein mehrzeiliges case innerhalb von $( ) nicht parsen, bash 5 dagegen schon.
# Der Fehler faellt damit erst auf dem Mac auf.
case "$TASK" in
  destillat)    PROMPT_NAME=abend-destillat.md ;;
  wochenreview) PROMPT_NAME=wochenreview.md ;;
  gaertner)     PROMPT_NAME=gaertner.md ;;
esac
PROMPT_FILE="$PROMPT_DIR/$PROMPT_NAME"
[ -f "$PROMPT_FILE" ] || { echo "FEHLER: Prompt fehlt: $PROMPT_FILE" >&2; exit 1; }

mkdir -p "$(dirname "$LOG")"

# ---------- Nur ein Lauf gleichzeitig ----------
# mkdir ist atomar und gibt es ueberall - flock fehlt auf macOS.
LOCK="${TMPDIR:-/tmp}/zettelgarten-$TASK.lock"
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
# Schreibrechte bewusst auf das Vault beschraenkt.
# Wichtig: die Regel heisst Edit(pfad), nicht Write(pfad) - Edit deckt alle schreibenden
# Datei-Werkzeuge ab, eine Write(pfad)-Regel wird von der Rechtepruefung nicht beachtet.
ALLOW="Read Glob Grep Edit($VAULT/**) Bash(ls:*) Bash(find:*) Bash(cat:*)"
# Der Prompt geht ueber stdin, NICHT als Argument. Zwei Gruende:
#   1. --allowedTools ist variadisch und verschluckt ein nachfolgendes Argument als weitere
#      Regel. Der Prompt landete dadurch in der Rechtepruefung ("Wildcard tool name **Nichts
#      is not supported") und fehlte gleichzeitig als Eingabe.
#   2. Ein Prompt in argv laeuft irgendwann gegen ARG_MAX. Ueber stdin nie.
RC=0
OUT="$(
  if command -v timeout >/dev/null 2>&1; then
    printf '%s' "$BODY" | timeout --kill-after=30s "$TIMEOUT_SECS" \
      "$AGENT" -p --permission-mode acceptEdits --max-turns 40 \
      --allowedTools "$ALLOW" 2>&1
  else
    # macOS ohne coreutils: kein timeout. Dann eben ohne - der Agent hat --max-turns als Bremse.
    printf '%s' "$BODY" | "$AGENT" -p --permission-mode acceptEdits --max-turns 40 \
      --allowedTools "$ALLOW" 2>&1
  fi
)" || RC=$?

printf '%s\n' "$OUT" >>"$LOG"

SUMMARY="$(printf '%s' "$OUT" | grep -v '^$' | tail -3 | tr '\n' ' ')"
[ -n "$SUMMARY" ] || SUMMARY="keine Ausgabe"
if [ "$RC" -ne 0 ]; then
  SUMMARY="FEHLER (rc=$RC): $SUMMARY"
fi

# macOS-Falle: die Festplattenvollzugriff-Freigabe haengt am Binary-Pfad des Agenten, und der
# enthaelt die Versionsnummer. Nach einem Update des Agenten zeigt die Freigabe ins Leere - der
# Lauf bricht dann nicht ab, er findet nur nichts mehr. Genau die stille Sorte Defekt, die man
# monatelang nicht bemerkt. Deshalb hier explizit danach suchen und laut werden.
case "$OUT" in
  *"Operation not permitted"*|*"EPERM"*|*"operation not permitted"*)
    SUMMARY="RECHTEFEHLER: Festplattenvollzugriff pruefen. Nach einem Update des Agenten muss die Freigabe fuer den neuen Binary-Pfad erneut erteilt werden. $SUMMARY"
    echo "WARN: Zugriff verweigert - siehe docs/setup-macos.md, Abschnitt Festplattenvollzugriff" >>"$LOG"
    ;;
esac
echo "$(date '+%F %T') [$TASK] fertig (rc=$RC)" >>"$LOG"

# ---------- Benachrichtigung ----------
if [ "$NOTIFY" = "1" ]; then
  "$(dirname "$0")/notify.sh" "Zettelgarten: $TASK" "$SUMMARY" 2>/dev/null || true
fi

echo "[$TASK] $SUMMARY"
exit "$RC"
