#!/usr/bin/env bash
# pre-commit-check.sh [pfad] - haelt echte Vault-Inhalte und Zugangsdaten aus diesem Repo.
#
# Dieses Repo enthaelt ausschliesslich das LEERE Template. Ein gefuelltes Vault enthaelt
# Gesundheit, Finanzen, Namen von Angehoerigen und berufliche Interna. Wenn davon etwas
# hineinrutscht, faellt es sonst erst auf, wenn es oeffentlich ist - und ein Loeschen aus
# der Git-Historie ist danach muehsam bis unmoeglich.
#
# Als Hook einhaengen:
#   ln -sf ../../tools/pre-commit-check.sh .git/hooks/pre-commit
#
# Exit 0 = sauber, 1 = Fund.
set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
VT="$ROOT/vault-template"
RC=0
say() { printf '%s\n' "$*"; }

# ---------- 1) Echte Notizen im Template ----------
# Erlaubt ist nur, was zur Vorlage gehoert. Alles andere ist vermutlich echter Inhalt.
ALLOW='^(README\.md|CLAUDE\.md|Home\.md|05-Vorlagen/[^/]+\.md|08-Arbeit/MOC - Arbeit\.md|(.*/)?\.info\.md|\.obsidian/.*|\.gitkeep)$'
if [ -d "$VT" ]; then
  STRAY="$( (cd "$VT" && find . -type f ! -path '*/.git/*' | sed 's|^\./||') \
            | grep -Ev "$ALLOW" || true )"
  if [ -n "$STRAY" ]; then
    say "ABBRUCH: unerwartete Dateien in vault-template/ - sieht nach echtem Vault-Inhalt aus:"
    printf '%s\n' "$STRAY" | sed 's/^/  /'
    say "  Erlaubt sind nur Vorlagen, .info.md, CLAUDE.md, README.md, Home.md, MOC - Arbeit.md und .obsidian/."
    RC=1
  fi

  # Tagesnotizen und Reviews haben ein Datumsmuster - die duerfen nie mitkommen.
  DATED="$(find "$VT" -type f -regextype posix-extended -regex '.*[0-9]{4}-[0-9]{2}-[0-9]{2}.*\.md' 2>/dev/null || true)"
  if [ -n "$DATED" ]; then
    say "ABBRUCH: datierte Notizen im Template (Tagesnotiz oder Review?):"
    printf '%s\n' "$DATED" | sed 's/^/  /'
    RC=1
  fi
fi

# ---------- 2) Zugangsdaten ----------
# Kodiertes braucht eigene Muster: in einem JWT steht Klartext base64 und wird von einer
# Stichwortsuche NIE gefunden.
SECRET='eyJ[A-Za-z0-9_-]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|Bearer [A-Za-z0-9._-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|glpat-[A-Za-z0-9_-]{15,}|AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{20,}|(pass(word|wd)?|secret|token|api[_-]?key)[[:space:]]*[:=][[:space:]]*.?[A-Za-z0-9_+/-]{12,}'
# Treffer nur gekuerzt ausgeben - ein Secret gehoert nicht noch einmal in ein Terminal oder Log.
if HITS="$(grep -rnIoE --exclude-dir=.git "$SECRET" "$ROOT" 2>/dev/null | cut -c1-70 || true)"; [ -n "$HITS" ]; then
  say "ABBRUCH: sieht nach Zugangsdaten aus (gekuerzt):"
  printf '%s\n' "$HITS" | sed 's/^/  /'
  RC=1
fi

# ---------- 3) Persoenliche Spuren ----------
# Bewusst grob. Ein Fehlalarm kostet zehn Sekunden, ein Durchrutscher kostet mehr.
# Eigene Stichworte hier ergaenzen: Arbeitgeber, Kundennamen, interne Hostnamen.
PERSONAL='/Users/[a-z][a-z0-9._-]+|/home/[a-z][a-z0-9._-]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
EXCL='example\.org|example\.com|<benutzer>|<user>|__HOME__|\$HOME|\$\{HOME\}|/home/<|/Users/<'
if HITS="$(grep -rnIE --exclude-dir=.git "$PERSONAL" "$ROOT" 2>/dev/null | grep -Ev "$EXCL" || true)"; [ -n "$HITS" ]; then
  say "WARNUNG: konkrete Pfade oder Mailadressen gefunden - bitte durch Platzhalter ersetzen:"
  printf '%s\n' "$HITS" | cut -c1-140 | sed 's/^/  /'
  RC=1
fi

# ---------- 4) Commit-Identitaeten ----------
# Ein privates Repo mit dienstlicher Absenderadresse in der Historie faellt in jedem Clone auf.
if [ -d "$ROOT/.git" ]; then
  MAILS="$(git -C "$ROOT" log --format='%ae%n%ce' 2>/dev/null | sort -u | grep -v '^$' || true)"
  if [ -n "$MAILS" ]; then
    say "Hinweis - Absenderadressen in der Historie:"
    printf '%s\n' "$MAILS" | sed 's/^/  /'
    say "  Stimmt das? Sonst: git config user.email setzen und die Historie umschreiben, bevor gepusht wird."
  fi
fi

[ "$RC" -eq 0 ] && say "pre-commit-check: sauber"
exit "$RC"
