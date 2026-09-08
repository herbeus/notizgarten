# Tests fuer automatik/runner.sh. Der Agent ist ein Fake (tests/fakes/claude).

# ---------- Vorpruefungen ----------

test_runner_ohne_task_gibt_usage() {
  rc=0; out="$(runner 2>&1)" || rc=$?
  assert_rc 2 "$rc"; assert_contains "$out" "usage:"
}

test_runner_unbekannter_task() {
  rc=0; out="$(runner kaffee 2>&1)" || rc=$?
  assert_rc 2 "$rc"
}

test_runner_vault_nicht_gesetzt() {
  : >"$TMP/leer.conf"
  rc=0; out="$(ZETTELGARTEN_CONF="$TMP/leer.conf" runner destillat 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "VAULT ist nicht gesetzt"
}

test_runner_vault_pfad_existiert_nicht() {
  write_conf "VAULT=\"$TMP/gibtsnicht\""
  rc=0; out="$(runner destillat 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "existiert nicht"
}

test_runner_destillat_braucht_transcripts() {
  write_conf 'TRANSCRIPTS=""'
  rc=0; out="$(runner destillat 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "TRANSCRIPTS"
  # Fuer die anderen beiden Laeufe ist es optional.
  rc=0; runner gaertner --dry-run >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc" "gaertner ohne TRANSCRIPTS"
}

test_runner_agent_nicht_im_path() {
  write_conf 'AGENT="agent-den-es-nicht-gibt"'
  rc=0; out="$(runner destillat 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "nicht im PATH"
}

test_runner_prompt_datei_fehlt() {
  mkdir -p "$TMP/keine-prompts"
  write_conf "PROMPT_DIR=\"$TMP/keine-prompts\""
  rc=0; out="$(runner destillat 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "Prompt fehlt"
}

test_runner_prompt_dir_liegt_neben_dem_runner() {
  # Kein PROMPT_DIR in der Config, Aufruf aus einem fremden Verzeichnis: prompts/ wird
  # relativ zum Runner gefunden, nicht relativ zum cwd und nicht unter ~/zettelgarten.
  cd "$TMP" || exit 1
  out="$(runner destillat --dry-run | dry_prompt)"
  assert_contains "$out" "Chronist"
}

# ---------- Dry-Run ----------

test_dryrun_startet_keinen_agenten() {
  rc=0; runner destillat --dry-run >/dev/null || rc=$?
  assert_rc 0 "$rc"
  assert_no_file "$FAKE_RECORD/argv" "Agent wurde trotz --dry-run gestartet"
  assert_no_file "$LOGF" "Dry-Run hat ins Log geschrieben"
  assert_no_dir "$TMPDIR/zettelgarten-destillat.lock"
}

test_dryrun_zeigt_aufruf_rechte_und_prompt() {
  out="$(runner destillat --dry-run)"
  assert_contains "$out" "== Aufruf:"
  assert_contains "$out" "== Rechte:"
  assert_contains "$out" "== Prompt:"
  assert_contains "$out" "cd \"$VAULT\""
}

test_dryrun_settings_json_ist_gueltig() {
  runner wochenreview --dry-run | dry_rechte >"$TMP/settings.json"
  rc=0; json_ok "$TMP/settings.json" || rc=$?
  [ "$rc" = 2 ] && t_skip "kein JSON-Pruefer (python3/node) vorhanden"
  assert_rc 0 "$rc" "settings JSON parst nicht"
}

test_dryrun_edit_regel_absolut_auch_mit_leerzeichen_im_pfad() {
  V="$TMP/Mobile Documents/Mein Vault"; mkdir -p "$(dirname "$V")"; cp -R "$VAULT" "$V"
  write_conf "VAULT=\"$V\""
  rechte="$(runner destillat --dry-run | dry_rechte)"
  assert_contains "$rechte" "\"Edit(/$V/**)\""        # ergibt //... = absolut
  assert_not_contains "$rechte" "allowedTools"
  assert_not_contains "$rechte" "acceptEdits"
}

test_dryrun_kein_acceptedits_kein_allowedtools() {
  out="$(runner destillat --dry-run)"
  assert_contains "$out" "--permission-mode default"
  assert_not_contains "$out" "acceptEdits"
  assert_not_contains "$out" "--allowedTools"
}

test_dryrun_gaertner_darf_nur_report_ordner_schreiben() {
  rechte="$(runner gaertner --dry-run | dry_rechte)"
  assert_contains "$rechte" "\"Edit(/$VAULT/07-Archiv/Gaertner/**)\""
  assert_not_contains "$rechte" "\"Edit(/$VAULT/**)\""
}

test_dryrun_destillat_und_review_duerfen_ins_vault() {
  for t in destillat wochenreview; do
    rechte="$(runner $t --dry-run | dry_rechte)"
    assert_contains "$rechte" "\"Edit(/$VAULT/**)\"" "$t"
  done
}

test_dryrun_zusatzordner_lesbar_aber_nicht_schreibbar() {
  rechte="$(runner wochenreview --dry-run | dry_rechte)"
  assert_contains "$rechte" "\"$TMP/transcripts\""
  assert_contains "$rechte" "\"$TMP/repos\""
  assert_not_contains "$rechte" "Edit(/$TMP/transcripts"
  assert_not_contains "$rechte" "Edit(/$TMP/repos"
}

test_dryrun_fehlender_zusatzordner_wird_ausgelassen() {
  write_conf "REPOS=\"$TMP/nope\""
  rechte="$(runner wochenreview --dry-run | dry_rechte)"
  assert_not_contains "$rechte" "$TMP/nope"
}

test_dryrun_verbietet_loeschen_und_netz() {
  rechte="$(runner destillat --dry-run | dry_rechte)"
  for r in 'Bash(rm:*)' 'Bash(mv:*)' 'WebFetch' 'WebSearch'; do
    assert_contains "$rechte" "\"$r\"" "deny"
  done
}

test_dryrun_alle_platzhalter_gefuellt() {
  for t in destillat wochenreview gaertner; do
    p="$(runner $t --dry-run | dry_prompt)"
    assert_not_contains "$p" "<<" "$t: offener Platzhalter"
    assert_contains "$p" "$VAULT" "$t"
  done
}

test_dryrun_optionales_wird_als_nicht_konfiguriert_benannt() {
  write_conf 'REPOS=""' 'GIT_AUTHOR=""'
  p="$(runner wochenreview --dry-run | dry_prompt)"
  assert_contains "$p" "(nicht konfiguriert)"
  assert_not_contains "$p" "<<"
  assert_not_contains "$p" 'Autor ``'
}

test_dryrun_eigener_projektordner_wie_claude_ihn_kodiert() {
  # Unabhaengige Zweitimplementierung der Kodierung: alles ausser [a-zA-Z0-9] wird "-".
  V="$TMP/Mein Vault~x.y"; cp -R "$VAULT" "$V"; write_conf "VAULT=\"$V\""
  expected="$(printf '%s' "$V" | tr -c 'a-zA-Z0-9' '-')"
  p="$(runner destillat --dry-run | dry_prompt)"
  assert_contains "$p" "Unterordner \`$expected\`"
}

test_dryrun_prompt_ohne_doku_kopf() {
  p="$(runner destillat --dry-run | dry_prompt)"
  assert_not_contains "$p" "Wird vom Runner headless aufgerufen"
  assert_not_contains "$p" "## Prompt"
}

# ---------- Echter Lauf mit Fake-Agent ----------

test_lauf_prompt_geht_ueber_stdin_nicht_argv() {
  runner destillat >/dev/null
  assert_file "$FAKE_RECORD/argv"
  assert_not_contains "$(cat "$FAKE_RECORD/argv")" "Chronist"
  assert_contains "$(cat "$FAKE_RECORD/stdin")" "Chronist"
  assert_contains "$(cat "$FAKE_RECORD/stdin")" "$VAULT"
}

test_lauf_argumente_des_agenten() {
  runner destillat >/dev/null
  argv="$(cat "$FAKE_RECORD/argv")"
  for a in '-p' '--permission-mode' 'default' '--max-turns' '--settings'; do
    has_line "$argv" "^$a\$" || t_fail "argv ohne '$a':"$'\n'"$argv"
  done
  assert_not_contains "$argv" "--allowedTools"
  assert_not_contains "$argv" "acceptEdits"
  assert_not_contains "$argv" "--add-dir"
}

test_lauf_arbeitsverzeichnis_ist_das_vault() {
  runner destillat >/dev/null
  expected="$(cd "$VAULT" && pwd -P)"
  assert_eq "$expected" "$(cat "$FAKE_RECORD/cwd")" "cwd des Agenten"
}

test_lauf_agent_kann_ins_vault_schreiben() {
  FAKE_WRITE="03-Notizen/Test.md" runner destillat >/dev/null
  assert_file "$VAULT/03-Notizen/Test.md" "relativer Pfad landet nicht im Vault"
}

test_lauf_log_und_zusammenfassung() {
  out="$(runner destillat)"
  log="$(cat "$LOGF")"
  assert_contains "$log" "[destillat] ====="
  assert_contains "$log" "fake agent: nichts zu destillieren"
  assert_contains "$log" "[destillat] fertig (rc=0)"
  assert_contains "$out" "[destillat] fake agent: nichts zu destillieren"
}

test_lauf_agent_fehler_wird_durchgereicht() {
  rc=0; out="$(FAKE_RC=3 runner destillat)" || rc=$?
  assert_rc 3 "$rc"
  assert_contains "$out" "FEHLER (rc=3)"
}

test_lauf_erkennt_tcc_rechtefehler() {
  out="$(FAKE_OUT='ls: /x: Operation not permitted' runner destillat)"
  assert_contains "$out" "RECHTEFEHLER"
  assert_contains "$(cat "$LOGF")" "WARN: Zugriff verweigert"
}

test_lauf_erkennt_abgelehnte_schreibregel() {
  out="$(FAKE_OUT='Edit to /x requires approval' runner destillat)"
  assert_contains "$out" "RECHTE: Schreiben wurde abgelehnt"
}

test_lauf_leere_ausgabe_wird_benannt() {
  out="$(FAKE_OUT='' runner destillat)"
  assert_contains "$out" "keine Ausgabe"
}

test_lauf_benachrichtigung_an_bricht_nichts() {
  write_conf 'NOTIFY=1'
  rc=0; runner destillat >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc"
}

test_lauf_alle_drei_tasks() {
  for t in destillat wochenreview gaertner; do
    rc=0; runner $t >/dev/null || rc=$?
    assert_rc 0 "$rc" "$t"
    assert_contains "$(cat "$LOGF")" "[$t] fertig (rc=0)"
  done
}

# ---------- Lock ----------

test_lock_verhindert_parallellauf() {
  FAKE_SLEEP=3 runner destillat >"$TMP/erster.out" 2>&1 &
  p1=$!
  sleep 1
  rc=0; runner destillat >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc" "zweiter Lauf soll leise aussteigen"
  assert_contains "$(cat "$LOGF")" "laeuft bereits"
  wait "$p1"
  assert_no_dir "$TMPDIR/zettelgarten-destillat.lock" "Lock nach Ende nicht entfernt"
}

test_lock_ist_pro_task() {
  FAKE_SLEEP=2 runner destillat >/dev/null 2>&1 &
  p1=$!
  sleep 1
  rc=0; runner gaertner >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc"
  assert_not_contains "$(cat "$LOGF")" "[gaertner] laeuft bereits"
  assert_contains "$(cat "$LOGF")" "[gaertner] fertig"
  wait "$p1"
}

test_lock_verwaist_mit_toter_pid_wird_entfernt() {
  sleep 0 & dead=$!; wait "$dead"
  mkdir -p "$TMPDIR/zettelgarten-destillat.lock"; echo "$dead" >"$TMPDIR/zettelgarten-destillat.lock/pid"
  rc=0; runner destillat >/dev/null || rc=$?
  assert_rc 0 "$rc"
  assert_contains "$(cat "$LOGF")" "verwaistes Lock entfernt (pid $dead)"
  assert_file "$FAKE_RECORD/argv" "Lauf fand trotz totem Lock nicht statt"
  assert_no_dir "$TMPDIR/zettelgarten-destillat.lock"
}

test_lock_verwaist_ohne_pid_datei_wird_entfernt() {
  mkdir -p "$TMPDIR/zettelgarten-destillat.lock"
  rc=0; runner destillat >/dev/null || rc=$?
  assert_rc 0 "$rc"
  assert_contains "$(cat "$LOGF")" "verwaistes Lock entfernt"
  assert_file "$FAKE_RECORD/argv"
}

test_lock_wird_bei_agentfehler_entfernt() {
  FAKE_RC=1 runner destillat >/dev/null 2>&1 || true
  assert_no_dir "$TMPDIR/zettelgarten-destillat.lock"
}

# ---------- Log ----------

test_log_rotation_ab_einem_megabyte() {
  mkdir -p "$(dirname "$LOGF")"
  dd if=/dev/zero bs=1024 count=1100 2>/dev/null | tr '\0' x >"$LOGF"
  runner destillat >/dev/null
  assert_file "$LOGF.1" "rotierte Datei fehlt"
  [ "$(wc -c <"$LOGF" | tr -d ' ')" -lt 100000 ] || t_fail "Log wurde nicht rotiert"
}

test_log_warnt_bei_offenem_platzhalter() {
  mkdir -p "$TMP/p"; printf '## Prompt\nHallo << UNBEKANNT >>\n' >"$TMP/p/abend-destillat.md"
  write_conf "PROMPT_DIR=\"$TMP/p\""
  runner destillat >/dev/null
  assert_contains "$(cat "$LOGF")" "WARN: ungefuellte Platzhalter"
  assert_contains "$(cat "$LOGF")" "<< UNBEKANNT >>"
}

# ---------- Timeout ----------

test_timeout_bricht_haengenden_agenten_ab() {
  command -v timeout >/dev/null 2>&1 || command -v gtimeout >/dev/null 2>&1 \
    || t_skip "weder timeout noch gtimeout (macOS ohne coreutils) - Runner laeuft dann ohne Limit"
  is_windows && t_skip "Signale unter Git Bash nicht verlaesslich"
  write_conf 'TIMEOUT_SECS=1'
  rc=0; out="$(FAKE_SLEEP=6 runner destillat 2>&1)" || rc=$?
  assert_rc 124 "$rc"
  assert_contains "$out" "FEHLER (rc=124)"
  assert_no_dir "$TMPDIR/zettelgarten-destillat.lock" "Lock nach Timeout nicht entfernt"
}

test_timeout_konfiguriertes_kommando_wird_benutzt() {
  # Homebrew nennt das GNU-Kommando gtimeout. TIMEOUT_BIN erzwingt ein bestimmtes Kommando,
  # hier als absoluter Pfad: der Runner stellt /opt/homebrew/bin vor den PATH, ein
  # gleichnamiger Fake im PATH wuerde auf einem Mac mit coreutils verlieren.
  cat >"$TMP/bin/fake-timeout" <<'EOF'
#!/usr/bin/env bash
echo "fake-timeout $1 $2" >>"$FAKE_RECORD.timeout"
shift 2; exec "$@"
EOF
  chmod +x "$TMP/bin/fake-timeout"
  write_conf 'TIMEOUT_SECS=7' "TIMEOUT_BIN=\"$TMP/bin/fake-timeout\""
  out="$(runner destillat --dry-run)"
  assert_contains "$out" "== Zeitlimit: 7 s ($TMP/bin/fake-timeout)"
  rc=0; runner destillat >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc"
  assert_file "$FAKE_RECORD.timeout" "konfiguriertes Kommando wurde nicht benutzt"
  assert_contains "$(cat "$FAKE_RECORD.timeout")" "fake-timeout --kill-after=30s 7"
  assert_file "$FAKE_RECORD/argv" "Agent wurde nicht durchgereicht"
}

test_timeout_autoerkennung_kennt_beide_namen() {
  # Deterministisch nicht auf jedem System pruefbar (auf einem Mac mit coreutils liegt ein
  # echtes timeout vor dem Test-PATH). Deshalb: die Suchliste selbst muss beide Namen tragen,
  # und der Dry-Run muss das gefundene Kommando nennen.
  grep -q 'for c in timeout gtimeout; do' "$ROOT/automatik/runner.sh" || t_fail "Suchliste ohne gtimeout"
  out="$(runner destillat --dry-run)"
  case "$out" in
    *"== Zeitlimit: 900 s (timeout)"*|*"== Zeitlimit: 900 s (gtimeout)"*|*"== Zeitlimit: keins"*) ;;
    *) t_fail "Zeitlimit-Zeile fehlt oder nennt kein Kommando:"$'\n'"$out" ;;
  esac
}

test_dryrun_zeigt_zeitlimit() {
  out="$(runner destillat --dry-run)"
  assert_contains "$out" "== Zeitlimit:"
}
