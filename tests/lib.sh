# tests/lib.sh - Assertions und Testumgebung. Wird von run.sh gesourct. bash 3.2-kompatibel.

t_skip() { echo "  SKIP: $*"; exit 77; }
t_fail() { echo "  FAIL: $*"; exit 1; }

assert_rc()           { [ "$1" = "$2" ] || t_fail "${3:-rc}: erwartet $1, ist $2"; }
assert_eq()           { [ "$1" = "$2" ] || t_fail "${3:-Wert}: erwartet '$1', ist '$2'"; }
assert_contains()     { case "$1" in *"$2"*) ;; *) t_fail "${3:-Ausgabe} enthaelt nicht: '$2'"$'\n'"--- Ausgabe:"$'\n'"$1" ;; esac; }
assert_not_contains() { case "$1" in *"$2"*) t_fail "${3:-Ausgabe} enthaelt unerwartet: '$2'"$'\n'"--- Ausgabe:"$'\n'"$1" ;; esac; }
assert_file()         { [ -f "$1" ] || t_fail "${2:-Datei fehlt}: $1"; }
assert_no_file()      { [ ! -e "$1" ] || t_fail "${2:-existiert unerwartet}: $1"; }
assert_dir()          { [ -d "$1" ] || t_fail "${2:-Ordner fehlt}: $1"; }
assert_no_dir()       { [ ! -d "$1" ] || t_fail "${2:-Ordner existiert unerwartet}: $1"; }
assert_exec()         { [ -x "$1" ] || t_fail "${2:-nicht ausfuehrbar}: $1"; }

# Wahr, wenn "$1" ein leeres Muster-Match liefert, d.h. grep -q Ersatz fuer Strings.
has_line() { printf '%s\n' "$1" | grep -q -- "$2"; }

os_name() { uname -s; }
is_windows() { case "$(os_name)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; *) return 1 ;; esac; }
is_wsl() { grep -qi microsoft /proc/version 2>/dev/null; }

# JSON und plist mit dem pruefen, was da ist. rc 2 = kein Pruefer vorhanden.
json_ok() {
  if command -v python3 >/dev/null 2>&1; then python3 -c 'import json,sys;json.load(open(sys.argv[1]))' "$1"
  elif command -v python >/dev/null 2>&1; then python -c 'import json,sys;json.load(open(sys.argv[1]))' "$1"
  elif command -v node >/dev/null 2>&1; then node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$1"
  else return 2; fi
}
plist_ok() {
  if command -v plutil >/dev/null 2>&1; then plutil -lint -s "$1" >/dev/null
  elif command -v python3 >/dev/null 2>&1; then python3 -c 'import plistlib,sys;plistlib.load(open(sys.argv[1],"rb"))' "$1"
  elif command -v python >/dev/null 2>&1; then python -c 'import plistlib,sys;plistlib.load(open(sys.argv[1],"rb"))' "$1"
  else return 2; fi
}

# ---------- Testumgebung ----------
# Wird vor jedem Test in dessen Subshell aufgerufen. $TMP ist frisch und wird danach geloescht.
t_setup() {
  export HOME="$TMP/home"; mkdir -p "$HOME"
  export TMPDIR="$TMP/tmp"; mkdir -p "$TMPDIR"
  VAULT="$TMP/vault"; cp -R "$ROOT/vault-template" "$VAULT"
  mkdir -p "$TMP/transcripts" "$TMP/repos" "$TMP/bin"
  cp "$ROOT/tests/fakes/claude" "$TMP/bin/claude"; chmod +x "$TMP/bin/claude"
  export PATH="$TMP/bin:$PATH"
  export FAKE_RECORD="$TMP/rec"
  LOGF="$TMP/run.log"
  export ZETTELGARTEN_CONF="$TMP/conf"
  write_conf
}

# Config schreiben. Zusaetzliche Zeilen als Argumente, z.B. write_conf 'NOTIFY=1'.
# Ueberschreibt Standardwerte, weil spaetere Zeilen gewinnen.
# shellcheck disable=SC2120  # Argumente kommen aus anderen Dateien
write_conf() {
  {
    echo "VAULT=\"$VAULT\""
    echo "TRANSCRIPTS=\"$TMP/transcripts\""
    echo "REPOS=\"$TMP/repos\""
    echo "GIT_AUTHOR=\"ich@example.org\""
    echo "LOG=\"$LOGF\""
    echo "NOTIFY=0"
    for kv in "$@"; do echo "$kv"; done
  } >"$ZETTELGARTEN_CONF"
}

# Optionale Fakes (uname, launchctl, systemctl, notify-send) in den PATH legen.
use_fake() {
  cp "$ROOT/tests/fakes/opt/$1" "$TMP/bin/$1"; chmod +x "$TMP/bin/$1"
}

runner()   { "$TEST_BASH" "$ROOT/automatik/runner.sh" "$@"; }
dry_rechte() { awk '/^== Rechte:/{f=1;next} /^== /{f=0} f'; }
dry_prompt() { awk '/^== Prompt:/{f=1;next} f'; }
