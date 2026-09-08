#!/usr/bin/env bash
# tests/run.sh [muster] - fuehrt alle Tests aus. Ohne Abhaengigkeiten ausser bash und git.
#
# Laeuft mit bash 3.2 (macOS /bin/bash), bash 5 (Linux) und Git Bash (Windows).
# Jeder Test laeuft in einer eigenen Subshell mit eigenem Temp-Ordner, eigenem HOME,
# eigenem TMPDIR und einem Fake-Agenten im PATH. Nichts beruehrt das echte System.
#
#   tests/run.sh                 alle
#   tests/run.sh lock            nur Tests, deren Name "lock" enthaelt
#   TEST_BASH=/bin/bash tests/run.sh   Skripte unter einer bestimmten bash pruefen
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export ROOT
export TEST_BASH="${TEST_BASH:-bash}"
PATTERN="${1:-}"

# shellcheck source=tests/lib.sh
. "$ROOT/tests/lib.sh"
for f in "$ROOT"/tests/test_*.sh; do
  # shellcheck source=/dev/null
  . "$f"
done

echo "Umgebung: $(uname -s) $(uname -m), Tests unter $("$TEST_BASH" -c 'echo "bash $BASH_VERSION"')"
echo

PASS=0; FAIL=0; SKIP=0; N=0
FAILED=""
for fn in $(declare -F | awk '{print $3}' | grep '^test_' | sort); do
  case "$fn" in *"$PATTERN"*) ;; *) continue ;; esac
  N=$((N + 1))
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/zgtest.XXXXXX")"
  export TMP
  out="$( (set -e; cd "$TMP" && t_setup && "$fn") 2>&1 )"
  rc=$?
  case "$rc" in
    0)  PASS=$((PASS + 1)); echo "ok   $N $fn" ;;
    77) SKIP=$((SKIP + 1)); echo "skip $N $fn"; printf '%s\n' "$out" | sed 's/^/     /' ;;
    *)  FAIL=$((FAIL + 1)); FAILED="$FAILED $fn"; echo "FAIL $N $fn (rc=$rc)"
        printf '%s\n' "$out" | sed 's/^/     /' ;;
  esac
  rm -rf "$TMP"
done

echo
echo "$N Tests: $PASS bestanden, $FAIL fehlgeschlagen, $SKIP uebersprungen"
[ -n "$FAILED" ] && echo "fehlgeschlagen:$FAILED"
[ "$FAIL" -eq 0 ]
