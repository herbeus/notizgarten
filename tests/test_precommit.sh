# Tests fuer tools/pre-commit-check.sh.

# Ein Wegwerf-Repo mit Template und Pruefskript, ein Commit als Basis.
mkrepo() {
  R="$TMP/repo"; mkdir -p "$R/tools"
  cp -R "$ROOT/vault-template" "$R/vault-template"
  cp "$ROOT/tools/pre-commit-check.sh" "$R/tools/"; chmod +x "$R/tools/pre-commit-check.sh"
  git -c init.defaultBranch=main -C "$R" init -q
  gitc add -A; gitc commit -q -m init
}
gitc() { git -C "$R" -c user.email=t@example.org -c user.name=t "$@"; }
# Testmuster stehen mit einem "#" im Quelltext, damit die Pruefung dieses Repos nicht auf
# die Testdatei selbst anspringt. unmask entfernt es.
unmask() { printf '%s' "$1" | tr -d '#'; }
# shellcheck disable=SC2120
pcc()  { "$TEST_BASH" "$R/tools/pre-commit-check.sh" "$@"; }

test_precommit_dieses_repo_ist_sauber() {
  rc=0; out="$("$TEST_BASH" "$ROOT/tools/pre-commit-check.sh" "$ROOT" 2>&1)" || rc=$?
  assert_rc 0 "$rc" "$out"
  assert_contains "$out" "sauber"
}

test_precommit_leeres_template_ist_sauber() {
  mkrepo
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 0 "$rc" "$out"
}

test_precommit_als_hook_symlink_blockt_den_commit() {
  # Der Fehler der ersten Fassung: als Symlink zeigte BASH_SOURCE nach .git/hooks/,
  # die Wurzel wurde .git/, und der Hook meldete "sauber", ohne etwas zu pruefen.
  mkrepo
  ln -sf ../../tools/pre-commit-check.sh "$R/.git/hooks/pre-commit"
  echo "GEHEIM: $(unmask 'to#ken=abcdefghijklmnopqrstuvwxyz123456')" >"$R/vault-template/03-Notizen/Echt.md"
  gitc add -A
  rc=0; out="$(gitc commit -q -m test 2>&1)" || rc=$?
  assert_rc 1 "$rc" "Commit ging durch"
  assert_contains "$out" "unerwartete Dateien"
  assert_contains "$out" "Zugangsdaten"
}

test_precommit_findet_wurzel_aus_unterordner() {
  mkrepo
  echo x >"$R/vault-template/00-Inbox/Notiz.md"
  rc=0; out="$(cd "$R/tools" && pcc 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "00-Inbox/Notiz.md"
}

test_precommit_pfadargument() {
  mkrepo
  echo x >"$R/vault-template/00-Inbox/Notiz.md"
  rc=0; out="$(cd / && "$TEST_BASH" "$ROOT/tools/pre-commit-check.sh" "$R" 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "00-Inbox/Notiz.md"
}

test_precommit_falsche_wurzel_bricht_ab() {
  mkdir -p "$TMP/nix"
  rc=0; out="$("$TEST_BASH" "$ROOT/tools/pre-commit-check.sh" "$TMP/nix" 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "nicht gefunden"
}

test_precommit_datierte_notiz() {
  mkrepo
  echo x >"$R/vault-template/Tagebuch/2026-09-08.md"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "datierte Notizen"
  # Auch ein Review mit Datum im Namen, auch in einem erlaubten Unterordner.
  rm "$R/vault-template/Tagebuch/2026-09-08.md"
  echo x >"$R/vault-template/Tagebuch/Wochenreview/Wochenreview 2026-09-07.md"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "datierte Notizen"
}

test_precommit_erlaubte_dateien_bleiben_erlaubt() {
  mkrepo
  mkdir -p "$R/vault-template/09-Neu"
  echo x >"$R/vault-template/09-Neu/.info.md"
  echo x >"$R/vault-template/05-Vorlagen/Neue-Vorlage.md"
  echo '{}' >"$R/vault-template/.obsidian/neu.json"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 0 "$rc" "$out"
}

test_precommit_secret_muster() {
  mkrepo
  i=0
  for m in \
    'ey#JhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ey#JzdWIiOiIxMjM0NTY3ODkwIn0' \
    'gh#p_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789' \
    'gl#pat-ABCDEFGHIJKLMNOPQRST' \
    'AK#IAIOSFODNN7EXAMPLE' \
    'sk#-ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
    'Bea#rer ABCDEFGHIJKLMNOPQRSTUVWXYZ012345' \
    'pass#word: Tr0ub4dor-und-mehr' \
    'api#_key = ABCDEFGHIJKLMNOPQRSTUV' \
    '-----BEGIN OPEN#SSH PRIVATE KEY-----'
  do
    i=$((i + 1))
    s="$(unmask "$m")"
    echo "$s" >"$R/docs-$i.md"
    rc=0; out="$(pcc 2>&1)" || rc=$?
    assert_rc 1 "$rc" "Muster $i nicht erkannt: $s"
    assert_contains "$out" "Zugangsdaten" "Muster $i"
    rm "$R/docs-$i.md"
  done
}

test_precommit_gibt_secret_nie_ganz_aus() {
  mkrepo
  secret="$(unmask 'gh#p_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789XYZ')"
  echo "$(unmask 'to#ken'): $secret" >"$R/x.md"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 1 "$rc"
  assert_not_contains "$out" "$secret" "voller Wert in der Ausgabe"
}

test_precommit_persoenliche_spuren() {
  mkrepo
  unmask 'liegt unter /Us#ers/alice/Vault' >"$R/x.md"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "konkrete Pfade"
  unmask 'schreib an alice.beispiel@firma-int#ern.de' >"$R/x.md"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "Mailadressen"
}

test_precommit_platzhalter_sind_keine_spuren() {
  mkrepo
  printf '%s\n' '/Users/<benutzer>/x' '/home/<user>/x' '$HOME/x' '__HOME__/x' 'ich@example.org' >"$R/x.md"
  rc=0; out="$(pcc 2>&1)" || rc=$?
  assert_rc 0 "$rc" "$out"
}

test_precommit_nennt_absender_der_historie() {
  mkrepo
  out="$(pcc 2>&1)"
  assert_contains "$out" "t@example.org"
}
