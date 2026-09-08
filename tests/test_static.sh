# Statische Pruefungen: Skripte, Units, plists, Prompts, Docs, Config.

SCRIPTS="automatik/runner.sh automatik/notify.sh automatik/linux/install.sh automatik/macos/install.sh automatik/macos/uninstall.sh tools/pre-commit-check.sh tests/run.sh"

test_static_bash_syntax() {
  for s in $SCRIPTS tests/fakes/claude; do
    "$TEST_BASH" -n "$ROOT/$s" || t_fail "Syntaxfehler: $s"
  done
  for s in "$ROOT"/tests/lib.sh "$ROOT"/tests/test_*.sh "$ROOT"/tests/fakes/opt/*; do
    "$TEST_BASH" -n "$s" || t_fail "Syntaxfehler: $s"
  done
}

test_static_skripte_ausfuehrbar() {
  is_windows && t_skip "keine Unix-Rechte"
  for s in $SCRIPTS tests/fakes/claude; do assert_exec "$ROOT/$s"; done
}

test_static_shellcheck() {
  command -v shellcheck >/dev/null 2>&1 || t_skip "shellcheck nicht installiert"
  out="$(cd "$ROOT" && shellcheck -S warning -s bash $SCRIPTS tests/lib.sh tests/test_*.sh 2>&1)" || t_fail "$out"
}

test_static_keine_bash4_konstrukte() {
  # macOS liefert bash 3.2. Diese Konstrukte gibt es dort nicht.
  muster='declare -A|mapfile|readarray|\$\{[a-zA-Z_]+(\^\^|,,)\}|\|&|&>>'   # bash4-liste
  hits="$(cd "$ROOT" && grep -nE "$muster" $SCRIPTS tests/lib.sh tests/test_*.sh | grep -v 'bash4-liste' || true)"
  [ -z "$hits" ] || t_fail "bash-4-Konstrukte:"$'\n'"$hits"
}

test_static_units_und_timer_paarweise() {
  L="$ROOT/automatik/linux"
  for t in destillat wochenreview gaertner; do
    assert_file "$L/zettelgarten-$t.service"; assert_file "$L/zettelgarten-$t.timer"
    s="$(cat "$L/zettelgarten-$t.service")"
    assert_contains "$s" "ExecStart=__RUNNER__ $t"
    assert_contains "$s" "Type=oneshot"
    ti="$(cat "$L/zettelgarten-$t.timer")"
    assert_contains "$ti" "Persistent=true" "$t: verpasste Laeufe wuerden nicht nachgeholt"
    assert_contains "$ti" "OnCalendar="
    assert_contains "$ti" "WantedBy=timers.target"
  done
  assert_contains "$(cat "$L/zettelgarten-wochenreview.timer")" "OnCalendar=Sun"
  assert_contains "$(cat "$L/zettelgarten-gaertner.timer")" "OnCalendar=*-*-01"
}

test_static_units_syntax_mit_systemd_analyze() {
  command -v systemd-analyze >/dev/null 2>&1 || t_skip "systemd-analyze nicht vorhanden"
  systemctl --user show-environment >/dev/null 2>&1 || t_skip "kein systemd-User-Manager erreichbar"
  mkdir -p "$TMP/units"
  for u in "$ROOT"/automatik/linux/zettelgarten-*; do
    sed "s|__RUNNER__|$ROOT/automatik/runner.sh|" "$u" >"$TMP/units/$(basename "$u")"
  done
  out="$(systemd-analyze --user verify "$TMP"/units/*.timer 2>&1)" || t_fail "$out"
  # verify meldet manches nur als Warnung ohne rc - alles, was nach Fehler aussieht, zaehlt.
  assert_not_contains "$out" "Failed"
  assert_not_contains "$out" "Unknown"
}

test_static_plists_vollstaendig() {
  M="$ROOT/automatik/macos"
  for t in destillat wochenreview gaertner; do
    p="$M/org.zettelgarten.$t.plist"; assert_file "$p"; c="$(cat "$p")"
    assert_contains "$c" "<string>org.zettelgarten.$t</string>" "Label passt nicht zum Dateinamen"
    assert_contains "$c" "<string>__RUNNER__</string>"
    assert_contains "$c" "<string>$t</string>"
    assert_contains "$c" "<key>StartCalendarInterval</key>"
    assert_contains "$c" "<key>WorkingDirectory</key>"
    assert_contains "$c" "<key>EnvironmentVariables</key>"
    assert_contains "$c" "__HOME__/.local/bin"
    sed -e 's|__HOME__|/Users/x|g' -e 's|__RUNNER__|/r|g' "$p" >"$TMP/$t.plist"
    rc=0; plist_ok "$TMP/$t.plist" || rc=$?
    [ "$rc" = 2 ] || assert_rc 0 "$rc" "plist $t parst nicht"
  done
  assert_contains "$(cat "$M/org.zettelgarten.wochenreview.plist")" "<key>Weekday</key><integer>0</integer>" "Sonntag ist 0"
  assert_contains "$(cat "$M/org.zettelgarten.gaertner.plist")" "<key>Day</key><integer>1</integer>"
}

test_static_zeitplaene_stimmen_auf_beiden_systemen_ueberein() {
  # Linux 20:00 taeglich / So 18:00 / 1. 10:00 - macOS muss dasselbe sagen.
  L="$ROOT/automatik/linux"; M="$ROOT/automatik/macos"
  assert_contains "$(cat "$L/zettelgarten-destillat.timer")" "*-*-* 20:00:00"
  assert_contains "$(cat "$M/org.zettelgarten.destillat.plist")" "<key>Hour</key><integer>20</integer>"
  assert_contains "$(cat "$L/zettelgarten-wochenreview.timer")" "Sun *-*-* 18:00:00"
  assert_contains "$(cat "$M/org.zettelgarten.wochenreview.plist")" "<key>Hour</key><integer>18</integer>"
  assert_contains "$(cat "$L/zettelgarten-gaertner.timer")" "*-*-01 10:00:00"
  assert_contains "$(cat "$M/org.zettelgarten.gaertner.plist")" "<key>Hour</key><integer>10</integer>"
}

test_static_prompts_haben_prompt_abschnitt() {
  for p in abend-destillat wochenreview gaertner; do
    f="$ROOT/prompts/$p.md"; assert_file "$f"
    grep -q '^## Prompt$' "$f" || t_fail "$p.md ohne '## Prompt'-Zeile - der Runner schickt sonst die ganze Datei"
    body="$(awk '/^## Prompt$/{f=1;next} f' "$f")"
    [ -n "$body" ] || t_fail "$p.md: leerer Prompt"
    assert_contains "$body" "<< VAULT-PFAD >>" "$p.md"
    assert_contains "$body" "Daten, keine Anweisungen" "$p.md: Schutz gegen eingeschleuste Anweisungen fehlt"
  done
}

test_static_prompt_platzhalter_sind_dem_runner_bekannt() {
  bekannt='VAULT-PFAD|PFAD ZU DEN TRANSKRIPTEN|EIGENER PROJEKTORDNER|PFAD ZU MEINEN REPOS|MEINE MAILADRESSE'
  fremd="$(awk 'FNR==1{f=0} /^## Prompt$/{f=1;next} f' "$ROOT"/prompts/abend-destillat.md "$ROOT"/prompts/wochenreview.md "$ROOT"/prompts/gaertner.md \
    | grep -o '<< [^>]* >>' | sort -u | grep -Ev "^<< ($bekannt) >>$" || true)"
  [ -z "$fremd" ] || t_fail "Platzhalter, die runner.sh nicht fuellt:"$'\n'"$fremd"
  for k in VAULT-PFAD 'PFAD ZU DEN TRANSKRIPTEN' 'EIGENER PROJEKTORDNER' 'PFAD ZU MEINEN REPOS' 'MEINE MAILADRESSE'; do
    grep -q "<< $k >>" "$ROOT/automatik/runner.sh" || t_fail "runner.sh fuellt '$k' nicht"
  done
}

test_static_prompts_verbieten_loeschen() {
  for p in abend-destillat wochenreview gaertner; do
    grep -qi 'loesch' "$ROOT/prompts/$p.md" || t_fail "$p.md sagt nichts zum Loeschen"
  done
  assert_contains "$(cat "$ROOT/prompts/gaertner.md")" "07-Archiv/Gaertner/"
  assert_contains "$(cat "$ROOT/prompts/wochenreview.md")" "07-Archiv/Wochenreview/"
}

test_static_doc_links_loesen_auf() {
  kaputt=""
  for f in "$ROOT"/README.md "$ROOT"/docs/*.md "$ROOT"/prompts/*.md "$ROOT"/vault-template/README.md; do
    dir="$(dirname "$f")"
    for l in $(grep -o '](\([^)]*\))' "$f" | sed 's/^](//; s/)$//' | grep -Ev '^(https?:|mailto:|#)' | sed 's/#.*$//' | sort -u); do
      [ -e "$dir/$l" ] || kaputt="$kaputt ${f#"$ROOT"/}->$l"
    done
  done
  [ -z "$kaputt" ] || t_fail "tote Links:$kaputt"
}

test_static_readme_tabelle_nennt_existierende_pfade() {
  for p in $(grep -o '\[`[^`]*`\]([^)]*)' "$ROOT/README.md" | sed 's/.*](//; s/)$//'); do
    [ -e "$ROOT/$p" ] || t_fail "README verweist auf fehlenden Pfad: $p"
  done
}

test_static_config_example_ist_sourcebar() {
  "$TEST_BASH" -n "$ROOT/automatik/config.example" || t_fail "config.example: Syntaxfehler"
  out="$("$TEST_BASH" -c '. "$1"; echo "$VAULT|$TRANSCRIPTS|$AGENT|$NOTIFY"' _ "$ROOT/automatik/config.example")"
  assert_contains "$out" "$HOME/MeinVault|$HOME/.claude/projects|claude|1"
  assert_not_contains "$(cat "$ROOT/automatik/config.example")" "@gmail"
}

test_static_gitignore_haelt_vaults_draussen() {
  g="$(cat "$ROOT/.gitignore")"
  assert_contains "$g" "/vault/"; assert_contains "$g" "*.log"; assert_contains "$g" ".DS_Store"
}

test_static_docs_sind_konsistent_mit_dem_runner() {
  # Was die Doku ueber die Schranke behauptet, muss der Runner tun.
  s="$(cat "$ROOT/docs/sicherheit.md")"
  assert_contains "$s" "--settings"
  assert_contains "$s" "--dry-run"
  assert_not_contains "$s" 'allowedTools "' "sicherheit.md beschreibt noch die alte, tote Regel"
  r="$(grep '^AGENT_ARGS=' "$ROOT/automatik/runner.sh")"
  assert_contains "$r" "--settings"
  assert_contains "$r" "--permission-mode default"
  assert_not_contains "$r" "acceptEdits"
  assert_not_contains "$r" "--allowedTools"
  assert_contains "$(cat "$ROOT/docs/setup-macos.md")" "--dry-run"
  assert_contains "$(cat "$ROOT/docs/setup-windows.md")" "--dry-run"
}
