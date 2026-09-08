#!/usr/bin/env bash
# runner.sh <destillat|wochenreview|gaertner> [--dry-run] - startet einen Automatik-Lauf headless.
#
# Wird von systemd (Linux/WSL) oder launchd (macOS) aufgerufen, laeuft aber auch von Hand.
# Bewusst portabel gehalten: macOS bringt bash 3.2 mit, kein flock, und BSD-stat statt GNU-stat.
#
# --dry-run zeigt den zusammengesetzten Prompt, die Rechte und die Argumentliste, ohne den
# Agenten zu starten. Erster Schritt bei jeder Einrichtung.
set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TASK="${1:-}"
DRY=0
[ "${2:-}" = "--dry-run" ] && DRY=1
case "$TASK" in
  destillat|wochenreview|gaertner) ;;
  *) echo "usage: runner.sh <destillat|wochenreview|gaertner> [--dry-run]" >&2; exit 2 ;;
esac

# ---------- Konfiguration ----------
# Reihenfolge: Umgebungsvariable, dann Konfigdatei, dann Fehler.
CONF="${ZETTELGARTEN_CONF:-$HOME/.config/zettelgarten/config}"
# shellcheck source=/dev/null
[ -f "$CONF" ] && . "$CONF"

: "${VAULT:=}"                                   # Pflicht: Pfad zum Vault
: "${PROMPT_DIR:=$HERE/../prompts}"
: "${AGENT:=claude}"                             # CLI des Agenten
: "${LOG:=$HOME/.local/state/zettelgarten/run.log}"
: "${TIMEOUT_SECS:=900}"
: "${TIMEOUT_BIN:=}"                             # leer = timeout oder gtimeout suchen
: "${NOTIFY:=1}"                                 # 0 = keine Benachrichtigung
: "${TRANSCRIPTS:=}"
: "${REPOS:=}"
: "${GIT_AUTHOR:=}"

if [ -z "$VAULT" ]; then
  echo "FEHLER: VAULT ist nicht gesetzt. Lege $CONF an - Vorlage: config.example" >&2
  exit 1
fi
if [ ! -d "$VAULT" ]; then
  echo "FEHLER: Vault-Pfad existiert nicht: $VAULT" >&2
  exit 1
fi
# Das Destillat hat genau eine Quelle. Ohne sie laeuft es ins Leere und meldet
# "nichts zu destillieren" - der stille Fehlschlag, den wir nicht wollen.
if [ "$TASK" = "destillat" ] && [ ! -d "$TRANSCRIPTS" ]; then
  echo "FEHLER: TRANSCRIPTS fehlt oder existiert nicht: '$TRANSCRIPTS'. Fuer das Destillat ist das Pflicht." >&2
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

# ---------- Prompt vorbereiten ----------
# Der Kopf der Datei ist Doku fuer Menschen; an den Agenten geht alles ab der Zeile "## Prompt".
BODY="$(awk '/^## Prompt$/{flag=1;next} flag' "$PROMPT_FILE")"
[ -n "$BODY" ] || BODY="$(cat "$PROMPT_FILE")"

# Die Transkripte der Automatik-Laeufe selbst liegen im selben Transkript-Ordner, in einem
# Projektordner, der aus dem Arbeitsverzeichnis (= Vault) abgeleitet ist: jedes Zeichen ausser
# [a-zA-Z0-9] wird zu "-". Der Agent bekommt diesen Namen, damit er seine eigenen Vorlaeufe
# nicht als "woran ich gearbeitet habe" auswertet.
OWN_PROJECT="$(printf '%s' "$VAULT" | sed 's/[^a-zA-Z0-9]/-/g')"

# Platzhalter fuellen. Optionales, das nicht konfiguriert ist, wird als solches benannt -
# ein leerer String liesse den Agenten raten.
BODY="${BODY//<< VAULT-PFAD >>/$VAULT}"
BODY="${BODY//<< PFAD ZU DEN TRANSKRIPTEN >>/${TRANSCRIPTS:-(nicht konfiguriert)}}"
BODY="${BODY//<< EIGENER PROJEKTORDNER >>/$OWN_PROJECT}"
BODY="${BODY//<< PFAD ZU MEINEN REPOS >>/${REPOS:-(nicht konfiguriert)}}"
BODY="${BODY//<< MEINE MAILADRESSE >>/${GIT_AUTHOR:-(nicht konfiguriert)}}"

UNFILLED="$(printf '%s' "$BODY" | grep -o '<<[^>]*>>' | sort -u || true)"

# ---------- Rechte ----------
# Zwei Schranken, beide ueber eine Settings-Datei statt ueber --allowedTools:
#   1. --allowedTools ist "comma or space-separated". Ein Vault-Pfad mit Leerzeichen
#      ("Mobile Documents") wird dort zerlegt und die Regel ist kaputt.
#   2. Pfadregeln brauchen "//" fuer absolute Pfade. "Edit(/Users/...)" ist RELATIV zum
#      Arbeitsverzeichnis und trifft nie.
# Der Lauf startet im Vault (cd unten), damit CLAUDE.md automatisch geladen wird und das
# Arbeitsverzeichnis exakt das Vault ist. Modus "default": was keine Regel erlaubt, wird
# headless verweigert - es gibt niemanden, der einen Dialog beantworten koennte. Das ist die
# Schranke: Transkripte und Repos sind lesbar (additionalDirectories), aber nicht beschreibbar.
# Der Gaertner darf nur seinen Report-Ordner schreiben.
case "$TASK" in
  gaertner) EDIT_SCOPE="$VAULT/07-Archiv/Gaertner" ;;
  *)        EDIT_SCOPE="$VAULT" ;;
esac
json_str() { local s="${1//\\/\\\\}"; s="${s//\"/\\\"}"; printf '"%s"' "$s"; }
EXTRA_DIRS=""
for d in "$TRANSCRIPTS" "$REPOS"; do
  [ -n "$d" ] && [ -d "$d" ] && EXTRA_DIRS="$EXTRA_DIRS${EXTRA_DIRS:+,}$(json_str "$d")"
done
SETTINGS_JSON="{\"permissions\":{
  \"allow\":[\"Read\",\"Glob\",\"Grep\",\"Bash(ls:*)\",\"Bash(find:*)\",\"Bash(git log:*)\",\"Bash(git diff:*)\",$(json_str "Edit(/$EDIT_SCOPE/**)")],
  \"deny\":[\"Bash(rm:*)\",\"Bash(mv:*)\",\"WebFetch\",\"WebSearch\"],
  \"additionalDirectories\":[$EXTRA_DIRS]
}}"
AGENT_ARGS=(-p --permission-mode default --max-turns 40 --settings "$SETTINGS_JSON")

if [ "$DRY" = 1 ]; then
  echo "== Aufruf: (cd \"$VAULT\" && $AGENT ${AGENT_ARGS[*]})"
  if [ -n "$TIMEOUT_BIN" ] || command -v timeout >/dev/null 2>&1 || command -v gtimeout >/dev/null 2>&1; then
    echo "== Zeitlimit: $TIMEOUT_SECS s"
  else
    echo "== Zeitlimit: keins (weder timeout noch gtimeout gefunden - coreutils installieren)"
  fi
  echo "== Rechte:"; printf '%s\n' "$SETTINGS_JSON"
  [ -n "$UNFILLED" ] && { echo "== WARN, ungefuellte Platzhalter:"; printf '%s\n' "$UNFILLED"; }
  echo "== Prompt:"; printf '%s\n' "$BODY"
  exit 0
fi

# ---------- Nur ein Lauf gleichzeitig ----------
# mkdir ist atomar und gibt es ueberall - flock fehlt auf macOS. Die PID im Lock erlaubt,
# ein verwaistes Lock (Reboot, OOM-Kill mitten im Lauf) zu erkennen; sonst blockiert es
# stumm jeden weiteren Lauf, und niemand merkt es.
LOCK="${TMPDIR:-/tmp}/zettelgarten-$TASK.lock"
if ! mkdir "$LOCK" 2>/dev/null; then
  OLDPID="$(cat "$LOCK/pid" 2>/dev/null || true)"
  if [ -n "$OLDPID" ] && kill -0 "$OLDPID" 2>/dev/null; then
    echo "$(date '+%F %T') [$TASK] laeuft bereits (pid $OLDPID), Abbruch" >>"$LOG"
    exit 0
  fi
  echo "$(date '+%F %T') [$TASK] verwaistes Lock entfernt (pid ${OLDPID:-?})" >>"$LOG"
  rm -rf "$LOCK"
  mkdir "$LOCK" 2>/dev/null || { echo "$(date '+%F %T') [$TASK] Lock nicht zu bekommen" >>"$LOG"; exit 1; }
fi
echo $$ >"$LOCK/pid"
trap 'rm -rf "$LOCK" 2>/dev/null' EXIT INT TERM

# ---------- Log-Rotation (portabel: kein stat) ----------
if [ -f "$LOG" ] && [ "$(wc -c <"$LOG" | tr -d ' ')" -gt 1048576 ]; then
  mv "$LOG" "$LOG.1"
fi

echo "===== $(date '+%F %T') [$TASK] =====" >>"$LOG"
if [ -n "$UNFILLED" ]; then
  echo "WARN: ungefuellte Platzhalter im Prompt:" >>"$LOG"
  printf '%s\n' "$UNFILLED" | sed 's/^/  /' >>"$LOG"
fi

# ---------- Lauf ----------
# Der Prompt geht ueber stdin, NICHT als Argument. Zwei Gruende:
#   1. Ein nachfolgendes Argument wird von variadischen Flags als weiterer Wert geschluckt.
#   2. Ein Prompt in argv laeuft irgendwann gegen ARG_MAX. Ueber stdin nie.
# Homebrew installiert die GNU-coreutils mit g-Praefix: gtimeout, nicht timeout.
# TIMEOUT_BIN aus der Config gewinnt; leer = beide Namen probieren.
if [ -z "$TIMEOUT_BIN" ]; then
  for c in timeout gtimeout; do
    command -v "$c" >/dev/null 2>&1 && { TIMEOUT_BIN="$c"; break; }
  done
fi
cd "$VAULT" || exit 1
RC=0
OUT="$(
  if [ -n "$TIMEOUT_BIN" ]; then
    printf '%s' "$BODY" | "$TIMEOUT_BIN" --kill-after=30s "$TIMEOUT_SECS" "$AGENT" "${AGENT_ARGS[@]}" 2>&1
  else
    # macOS ohne coreutils: kein timeout. Dann eben ohne - der Agent hat --max-turns als Bremse.
    printf '%s' "$BODY" | "$AGENT" "${AGENT_ARGS[@]}" 2>&1
  fi
)" || RC=$?

printf '%s\n' "$OUT" >>"$LOG"

SUMMARY="$(printf '%s' "$OUT" | grep -v '^$' | tail -3 | tr '\n' ' ')"
[ -n "$SUMMARY" ] || SUMMARY="keine Ausgabe"
if [ "$RC" -ne 0 ]; then
  SUMMARY="FEHLER (rc=$RC): $SUMMARY"
fi

# Zwei stille Fehlschlaege, die beide NICHT als Fehler zurueckkommen: der Lauf endet mit
# Erfolg, hat aber nichts geschrieben. Ohne diese Pruefungen faellt so etwas monatelang
# nicht auf - genau die Sorte Defekt, an der das Vorgaengersetup gestorben ist.

# (1) Rechte: eine Schreibregel greift nicht (falscher Pfad, Vault ausserhalb des Scopes).
case "$OUT" in
  *"nicht freigegeben"*|*"not granted"*|*"requires approval"*|*"permission denied"*|*"Permission denied"*)
    SUMMARY="RECHTE: Schreiben wurde abgelehnt. 'runner.sh $TASK --dry-run' zeigt die Regeln. $SUMMARY"
    echo "WARN: Schreibzugriff abgelehnt - Regeln mit --dry-run pruefen" >>"$LOG"
    ;;
esac

# (2) macOS-TCC: die Freigabe haengt am Binary-Pfad des Agenten, und der enthaelt die
# Versionsnummer. Nach einem Update zeigt sie ins Leere.
case "$OUT" in
  *"Operation not permitted"*|*"EPERM"*|*"operation not permitted"*)
    SUMMARY="RECHTEFEHLER: Festplattenvollzugriff pruefen. Nach einem Update des Agenten muss die Freigabe fuer den neuen Binary-Pfad erneut erteilt werden. $SUMMARY"
    echo "WARN: Zugriff verweigert - siehe docs/setup-macos.md, Abschnitt Festplattenvollzugriff" >>"$LOG"
    ;;
esac
echo "$(date '+%F %T') [$TASK] fertig (rc=$RC)" >>"$LOG"

# ---------- Benachrichtigung ----------
if [ "$NOTIFY" = "1" ]; then
  "$HERE/notify.sh" "Zettelgarten: $TASK" "$SUMMARY" 2>/dev/null || true
fi

echo "[$TASK] $SUMMARY"
exit "$RC"
