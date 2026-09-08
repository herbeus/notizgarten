# Tests fuer automatik/linux/install.sh, automatik/macos/install.sh und uninstall.sh.
# systemctl, launchctl und uname sind Fakes - die Skripte laufen damit auf jedem System.

linux_install() { "$TEST_BASH" "$ROOT/automatik/linux/install.sh"; }
macos_install() { "$TEST_BASH" "$ROOT/automatik/macos/install.sh"; }
macos_uninstall() { "$TEST_BASH" "$ROOT/automatik/macos/uninstall.sh"; }
linux_uninstall() { "$TEST_BASH" "$ROOT/automatik/linux/uninstall.sh"; }
conf_anlegen() { mkdir -p "$HOME/.config/zettelgarten"; cp "$ZETTELGARTEN_CONF" "$HOME/.config/zettelgarten/config"; }

# ---------- Linux / WSL ----------

test_install_linux_ohne_config_bricht_ab() {
  use_fake systemctl
  rc=0; out="$(echo | linux_install 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "config fehlt"
}

test_install_linux_ohne_user_manager_bricht_ab() {
  use_fake systemctl; conf_anlegen
  rc=0; out="$(FAKE_SYSTEMD_DOWN=1 sh -c 'echo | '"$TEST_BASH $ROOT/automatik/linux/install.sh" 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "wsl.conf"
}

test_install_linux_units_tragen_den_echten_runner_pfad() {
  use_fake systemctl; conf_anlegen
  export FAKE_LOG="$TMP/systemctl.log"
  echo "1 2 3" | linux_install >/dev/null
  U="$HOME/.config/systemd/user"
  for t in destillat wochenreview gaertner; do
    assert_file "$U/zettelgarten-$t.service"; assert_file "$U/zettelgarten-$t.timer"
    assert_contains "$(cat "$U/zettelgarten-$t.service")" "ExecStart=$ROOT/automatik/runner.sh $t"
    assert_not_contains "$(cat "$U/zettelgarten-$t.service")" "__RUNNER__"
    assert_not_contains "$(cat "$U/zettelgarten-$t.service")" "%h/zettelgarten" "hart verdrahteter Klonpfad"
  done
}

test_install_linux_aktiviert_nur_die_auswahl() {
  use_fake systemctl; conf_anlegen
  export FAKE_LOG="$TMP/systemctl.log"
  echo "1 3" | linux_install >/dev/null
  log="$(cat "$FAKE_LOG")"
  assert_contains "$log" "daemon-reload"
  assert_contains "$log" "enable --now zettelgarten-destillat.timer"
  assert_contains "$log" "enable --now zettelgarten-gaertner.timer"
  assert_not_contains "$log" "zettelgarten-wochenreview.timer"
}

test_install_linux_leere_eingabe_aktiviert_alle() {
  use_fake systemctl; conf_anlegen
  export FAKE_LOG="$TMP/systemctl.log"
  echo "" | linux_install >/dev/null
  log="$(cat "$FAKE_LOG")"
  for t in destillat wochenreview gaertner; do assert_contains "$log" "enable --now zettelgarten-$t.timer"; done
}

test_install_linux_ungueltige_auswahl_wird_uebersprungen() {
  use_fake systemctl; conf_anlegen
  export FAKE_LOG="$TMP/systemctl.log"
  out="$(echo "9 2" | linux_install)"
  assert_contains "$out" "uebersprungen: 9"
  assert_contains "$(cat "$FAKE_LOG")" "zettelgarten-wochenreview.timer"
}

test_uninstall_linux_entfernt_alles() {
  use_fake systemctl; conf_anlegen
  export FAKE_LOG="$TMP/systemctl.log"
  echo "1 2 3" | linux_install >/dev/null
  out="$(linux_uninstall)"
  U="$HOME/.config/systemd/user"
  for t in destillat wochenreview gaertner; do
    assert_no_file "$U/zettelgarten-$t.timer"; assert_no_file "$U/zettelgarten-$t.service"
    assert_contains "$(cat "$FAKE_LOG")" "disable --now zettelgarten-$t.timer"
  done
  assert_contains "$(cat "$FAKE_LOG")" "daemon-reload"
  assert_contains "$out" "fertig"
}

test_uninstall_linux_ohne_installation_ist_kein_fehler() {
  use_fake systemctl
  rc=0; linux_uninstall >/dev/null || rc=$?
  assert_rc 0 "$rc"
}

# ---------- macOS ----------

test_install_macos_nur_auf_darwin() {
  use_fake uname; use_fake launchctl; conf_anlegen
  rc=0; out="$(FAKE_UNAME=Linux sh -c 'echo | '"$TEST_BASH $ROOT/automatik/macos/install.sh" 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "nur fuer macOS"
}

test_install_macos_ohne_config_bricht_ab() {
  use_fake uname; use_fake launchctl
  rc=0; out="$(FAKE_UNAME=Darwin sh -c 'echo | '"$TEST_BASH $ROOT/automatik/macos/install.sh" 2>&1)" || rc=$?
  assert_rc 1 "$rc"; assert_contains "$out" "config fehlt"
}

test_install_macos_plists_sind_gueltig_und_ersetzt() {
  use_fake uname; use_fake launchctl; conf_anlegen
  export FAKE_UNAME=Darwin FAKE_LOG="$TMP/launchctl.log"
  echo "1 2 3" | macos_install >/dev/null
  A="$HOME/Library/LaunchAgents"
  for t in destillat wochenreview gaertner; do
    p="$A/org.zettelgarten.$t.plist"
    assert_file "$p"
    c="$(cat "$p")"
    assert_not_contains "$c" "__HOME__"; assert_not_contains "$c" "__RUNNER__"
    assert_contains "$c" "<string>$ROOT/automatik/runner.sh</string>"
    assert_contains "$c" "<string>$t</string>"
    assert_contains "$c" "<string>$HOME/.local/state/zettelgarten/launchd.out</string>"
    assert_contains "$c" "<key>WorkingDirectory</key>"
    rc=0; plist_ok "$p" || rc=$?
    [ "$rc" = 2 ] || assert_rc 0 "$rc" "plist $t parst nicht"
  done
  assert_dir "$HOME/.local/state/zettelgarten" "Log-Ordner fuer launchd fehlt"
}

test_install_macos_bootstrap_aufrufe() {
  use_fake uname; use_fake launchctl; conf_anlegen
  export FAKE_UNAME=Darwin FAKE_LOG="$TMP/launchctl.log"
  echo "2" | macos_install >/dev/null
  log="$(cat "$FAKE_LOG")"
  assert_contains "$log" "bootout gui/$UID/org.zettelgarten.wochenreview"
  assert_contains "$log" "bootstrap gui/$UID $HOME/Library/LaunchAgents/org.zettelgarten.wochenreview.plist"
  assert_not_contains "$log" "org.zettelgarten.destillat"
}

test_install_macos_zeigt_tcc_hinweis() {
  use_fake uname; use_fake launchctl; conf_anlegen
  out="$(FAKE_UNAME=Darwin sh -c 'echo 1 | '"$TEST_BASH $ROOT/automatik/macos/install.sh")"
  assert_contains "$out" "VOLLZUGRIFF"
  assert_contains "$out" "--dry-run"
}

test_uninstall_macos_entfernt_alles() {
  use_fake uname; use_fake launchctl; conf_anlegen
  export FAKE_UNAME=Darwin FAKE_LOG="$TMP/launchctl.log"
  echo "1 2 3" | macos_install >/dev/null
  out="$(macos_uninstall)"
  for t in destillat wochenreview gaertner; do
    assert_no_file "$HOME/Library/LaunchAgents/org.zettelgarten.$t.plist"
    assert_contains "$(cat "$FAKE_LOG")" "bootout gui/$UID/org.zettelgarten.$t"
  done
  assert_contains "$out" "fertig"
}

test_uninstall_macos_ohne_installation_ist_kein_fehler() {
  use_fake launchctl
  rc=0; macos_uninstall >/dev/null || rc=$?
  assert_rc 0 "$rc"
}
