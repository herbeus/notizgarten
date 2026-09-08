# Tests fuer vault-template/: Struktur, Vorlagen, Obsidian-Konfiguration, Links.

VT() { echo "$ROOT/vault-template"; }

test_vault_jeder_ordner_hat_eine_info() {
  fehlt=""
  while IFS= read -r d; do
    [ -f "$d/.info.md" ] || fehlt="$fehlt ${d#"$(VT)"/}"
  done <<EOF
$(find "$(VT)" -mindepth 1 -type d ! -path '*/.obsidian*')
EOF
  [ -z "$fehlt" ] || t_fail "Ordner ohne .info.md:$fehlt"
}

test_vault_report_ordner_der_automatik_existieren() {
  assert_dir "$(VT)/07-Archiv/Gaertner"
  assert_dir "$(VT)/Tagebuch/Wochenreview"
  assert_dir "$(VT)/Tagebuch"
}

test_vault_genau_sieben_vorlagen() {
  n="$(find "$(VT)/05-Vorlagen" -name '*.md' ! -name '.info.md' | wc -l | tr -d ' ')"
  assert_eq 7 "$n" "Anzahl Vorlagen"
  for v in Tagesnotiz Wochenreview Projektnotiz Permanente-Notiz Literaturnotiz MOC Bereich; do
    assert_file "$(VT)/05-Vorlagen/$v.md"
  done
}

test_vault_vorlagen_frontmatter_nach_konvention() {
  for f in "$(VT)"/05-Vorlagen/*.md "$(VT)/Home.md" "$(VT)/08-Arbeit/MOC - Arbeit.md"; do
    n="$(basename "$f")"
    assert_eq "---" "$(sed -n 1p "$f")" "$n: erste Zeile"
    kopf="$(awk 'NR>1 && /^---$/{exit} NR>1' "$f")"
    for k in typ erstellt tags; do
      has_line "$kopf" "^$k:" || t_fail "$n: Frontmatter ohne '$k:' (CLAUDE.md: immer typ, erstellt, tags)"
    done
    has_line "$kopf" '^tags: \[' || t_fail "$n: tags nicht als Inline-Array"
  done
}

test_vault_projekt_und_bereich_haben_status() {
  has_line "$(cat "$(VT)/05-Vorlagen/Projektnotiz.md")" '^status:' || t_fail "Projektnotiz ohne status"
  has_line "$(cat "$(VT)/05-Vorlagen/Projektnotiz.md")" '^deadline:' || t_fail "Projektnotiz ohne deadline"
  has_line "$(cat "$(VT)/05-Vorlagen/Bereich.md")" '^status: aktiv' || t_fail "Bereich ohne status: aktiv"
}

test_vault_automatik_vorlagen_ohne_platzhalter() {
  # Diese beiden schreibt der Agent headless. Ein "<< >>" darin landet 1:1 in der Notiz.
  for v in Tagesnotiz Wochenreview; do
    assert_not_contains "$(cat "$(VT)/05-Vorlagen/$v.md")" "<<" "$v"
  done
}

test_vault_obsidian_json_gueltig() {
  for f in "$(VT)"/.obsidian/*.json; do
    rc=0; json_ok "$f" || rc=$?
    [ "$rc" = 2 ] && t_skip "kein JSON-Pruefer vorhanden"
    assert_rc 0 "$rc" "$(basename "$f") ist kein gueltiges JSON"
  done
}

test_vault_obsidian_verweist_auf_existierendes() {
  c="$(cat "$(VT)/.obsidian/daily-notes.json")"
  assert_contains "$c" '"folder": "Tagebuch"'
  assert_contains "$c" '"template": "05-Vorlagen/Tagesnotiz"'
  assert_file "$(VT)/05-Vorlagen/Tagesnotiz.md"
  c="$(cat "$(VT)/.obsidian/app.json")"
  assert_contains "$c" '"newFileFolderPath": "00-Inbox"'; assert_dir "$(VT)/00-Inbox"
  assert_contains "$c" '"attachmentFolderPath": "06-Anhaenge"'; assert_dir "$(VT)/06-Anhaenge"
  c="$(cat "$(VT)/.obsidian/templates.json")"
  assert_contains "$c" '"folder": "05-Vorlagen"'
  c="$(cat "$(VT)/.obsidian/core-plugins.json")"
  for p in daily-notes templates backlink; do assert_contains "$c" "\"$p\": true"; done
}

test_vault_hoechstens_fuenf_community_plugins() {
  n="$(grep -c '"' "$(VT)/.obsidian/community-plugins.json" | tr -d ' ')"
  [ "$n" -le 5 ] || t_fail "$n Community-Plugins eingetragen, Konzept sagt maximal fuenf"
  for p in dataview templater-obsidian calendar; do
    assert_contains "$(cat "$(VT)/.obsidian/community-plugins.json")" "\"$p\""
  done
}

test_vault_keine_datierten_notizen() {
  d="$(find "$(VT)" -name '*.md' | grep -E '[0-9]{4}-[0-9]{2}-[0-9]{2}' || true)"
  [ -z "$d" ] || t_fail "datierte Notizen im Template:"$'\n'"$d"
}

test_vault_keine_echten_notizen() {
  # Nur Vorlagen, .info.md, CLAUDE.md, README.md, Home.md, MOC - Arbeit.md und .obsidian/.
  extra="$( (cd "$(VT)" && find . -type f | sed 's|^\./||') \
    | grep -Ev '^(README\.md|CLAUDE\.md|Home\.md|05-Vorlagen/[^/]+\.md|08-Arbeit/MOC - Arbeit\.md|(.*/)?\.info\.md|\.obsidian/.*)$' || true)"
  [ -z "$extra" ] || t_fail "unerwartete Dateien:"$'\n'"$extra"
}

test_vault_wikilinks_loesen_auf() {
  kaputt=""
  # Codespans (`[[Wikilink]]` als Begriff) und << >>-Leerstellen sind keine Links.
  links="$(find "$(VT)" -name '*.md' -exec cat {} + | tr '\n' ' ' | sed 's/<<[^>]*>>//g; s/`[^`]*`//g' \
    | grep -o '\[\[[^]]*\]\]' | sed 's/^\[\[//; s/\]\]$//; s/[|#].*$//' | sort -u | tr ' ' '\001')"
  for l in $links; do
    name="$(printf '%s' "$l" | tr '\001' ' ')"
    [ -z "$name" ] && continue
    [ -n "$(find "$(VT)" -name "$name.md" | head -1)" ] || kaputt="$kaputt [[${name}]]"
  done
  [ -z "$kaputt" ] || t_fail "Wikilinks ohne Ziel im Template:$kaputt"
}

test_vault_claude_md_nennt_alle_ordner() {
  c="$(cat "$(VT)/CLAUDE.md")"
  for d in "$(VT)"/*/; do
    n="$(basename "$d")"
    assert_contains "$c" "$n" "CLAUDE.md nennt Ordner nicht: $n"
  done
  for r in "Schreibe nichts Leeres" "Wiederhole nichts" "Ernte, statt Formulare"; do
    assert_contains "$c" "$r" "Regel fehlt in CLAUDE.md"
  done
  assert_contains "$c" "Tagebuch/Wochenreview/"
  assert_contains "$c" "07-Archiv/Gaertner/"
}

test_vault_readme_nennt_alle_ordner() {
  c="$(cat "$(VT)/README.md")"
  for d in "$(VT)"/*/; do
    n="$(basename "$d")"
    assert_contains "$c" "\`$n\`" "README nennt Ordner nicht: $n"
  done
}

test_vault_keine_dateinamen_mit_sonderzeichen_die_obsidian_stoeren() {
  bad="$(find "$(VT)" -name '*[\\:*?"<>|]*' || true)"
  [ -z "$bad" ] || t_fail "Dateinamen mit unzulaessigen Zeichen:"$'\n'"$bad"
}

test_vault_dataview_abfragen_zeigen_auf_existierende_ordner() {
  for f in "$(VT)/Home.md" "$(VT)/08-Arbeit/MOC - Arbeit.md" "$(VT)"/05-Vorlagen/*.md; do
    for d in $(grep -o 'FROM "[^"]*"' "$f" | sed 's/FROM "//; s/"$//' | tr ' ' '\001'); do
      d="$(printf '%s' "$d" | tr '\001' ' ')"
      assert_dir "$(VT)/$d" "$(basename "$f"): Dataview FROM zeigt ins Leere"
    done
  done
}
