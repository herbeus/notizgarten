# Tests fuer automatik/notify.sh.

notify() { "$TEST_BASH" "$ROOT/automatik/notify.sh" "$@"; }

test_notify_endet_immer_mit_null() {
  rc=0; notify "Titel" "Nachricht" >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc"
  rc=0; notify >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc" "ohne Argumente"
}

test_notify_linux_uebergibt_woertlich_ohne_auswertung() {
  [ "$(os_name)" = Linux ] || t_skip "nur Linux-Desktop-Pfad"
  is_wsl && t_skip "WSL nutzt PowerShell"
  use_fake notify-send
  export FAKE_LOG="$TMP/notify.log"
  msg='Zitat " und $(touch '"$TMP"'/pwned) und `id`'
  notify "Zettelgarten: test" "$msg" >/dev/null 2>&1
  assert_file "$FAKE_LOG" "notify-send nicht aufgerufen"
  assert_eq "Zettelgarten: test" "$(sed -n 1p "$FAKE_LOG")" "Titel"
  assert_eq "$msg" "$(sed -n '2,$p' "$FAKE_LOG")" "Nachricht nicht woertlich"
  assert_no_file "$TMP/pwned" "Nachricht wurde als Code ausgefuehrt"
}

test_notify_ohne_desktop_ist_kein_fehler() {
  [ "$(os_name)" = Linux ] || t_skip "nur Linux"
  # PATH ohne notify-send: nur die Fakes und die Systempfade ohne Desktop-Tools.
  rc=0; PATH="$TMP/bin:/usr/bin:/bin" notify "t" "m" >/dev/null 2>&1 || rc=$?
  assert_rc 0 "$rc"
}
