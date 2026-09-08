# Zettelgarten

Ein persoenliches "Second Brain" als Obsidian-Vault, das ein KI-Agent aktiv mitpflegt -
inklusive der Anleitung, dem leeren Vault-Skelett, den Automatik-Prompts und den Timern
fuer Linux und macOS.

Das Besondere ist nicht die Ordnerstruktur, die kennt jeder. Das Besondere ist die
`CLAUDE.md` im Vault-Root: eine Betriebsanleitung, die einen Agenten das Vault **fuehren**
laesst statt es nur zu lesen. Und drei Regeln, die aus dem Scheitern der ersten Fassung
entstanden sind.

## Der Kern in drei Regeln

**A. Schreibe nichts Leeres.** Nie eine Notiz anlegen, nur weil ein Zeitplan es sagt.
Ein leeres Formular ist keine Hilfe, sondern eine Bringschuld. Gibt es nichts zu berichten,
ist das Ergebnis: keine Datei.

**B. Wiederhole nichts, was schon dasteht.** Was sich seit dem letzten Durchgang nicht
geaendert hat, wird gezaehlt, nicht ausgebreitet.

**C. Ernte, statt Formulare zu verteilen.** Rueckblickend aus dem arbeiten, was tatsaechlich
passiert ist - nicht vorausschauend Platzhalter hinlegen.

Diese drei klingen banal. Sie sind der Unterschied zwischen einem System, das laeuft, und
32 leeren Tagesnotizen. Die Geschichte dazu steht in [docs/automatik.md](docs/automatik.md).

## Was hier drin ist

| Pfad | Inhalt |
|---|---|
| [`vault-template/`](vault-template/) | Das leere, sofort nutzbare Vault: Ordner, 7 Vorlagen, `CLAUDE.md`, vorkonfiguriertes `.obsidian/` |
| [`docs/konzept.md`](docs/konzept.md) | PARA + Zettelkasten + MOCs, Trennung privat/beruflich, warum was wohin |
| [`docs/setup-macos.md`](docs/setup-macos.md) | Einrichtung auf dem Mac, iCloud-Container |
| [`docs/setup-windows.md`](docs/setup-windows.md) | Einrichtung auf Windows, Zugriff aus WSL |
| [`docs/setup-mobil.md`](docs/setup-mobil.md) | iOS und Android, Capture unterwegs |
| [`docs/agent-betrieb.md`](docs/agent-betrieb.md) | Wie die `CLAUDE.md` den Agenten steuert |
| [`docs/automatik.md`](docs/automatik.md) | Abend-Destillat, Wochenreview, Gaertner - und was vorher schiefging |
| [`docs/grenzen.md`](docs/grenzen.md) | Was bewusst nicht geht und warum |
| [`docs/sicherheit.md`](docs/sicherheit.md) | Was nie ins Vault gehoert |
| [`prompts/`](prompts/) | Reproduktions-Prompt und die drei Automatik-Prompts |
| [`automatik/`](automatik/) | systemd-user-Timer (Linux) und launchd (macOS) |
| [`tools/`](tools/) | Pruefskript, das echte Notizen aus dem Repo haelt |
| [`tests/`](tests/) | Testsuite: Runner, Rechte, Lock, Hook, Installer, Template. `tests/run.sh` |

## Schnellstart

```bash
git clone <dieses-repo> ~/zettelgarten
cp -r ~/zettelgarten/vault-template ~/MeinVault
```

Der Ort des Klons ist frei - die Install-Skripte tragen den echten Pfad in Timer und plists ein.

Dann Obsidian oeffnen, *Open folder as vault*, `~/MeinVault` waehlen. Details je nach
Betriebssystem in `docs/setup-*.md`.

Wer es sich einrichten lassen will, statt es selbst zu tun:
[`prompts/reproduktion.md`](prompts/reproduktion.md) an einen Agenten mit Dateizugriff geben.

## Voraussetzungen

- [Obsidian](https://obsidian.md) - kostenlos, alle Plattformen
- Ein Sync-Weg, wenn du mehrere Geraete nutzt (iCloud, Obsidian Sync, Syncthing, Git)
- Fuer die Automatik: ein KI-Agent mit Dateizugriff auf das Vault, der sich per Kommandozeile
  aufrufen laesst

## Wichtig: das Vault gehoert nicht ins Repo

Dieses Repo enthaelt ausschliesslich das **leere Template**. Ein gefuelltes Vault enthaelt
Gesundheit, Finanzen, Namen von Angehoerigen und berufliche Interna - das hat auf einer
Plattform nichts verloren, auch nicht in einem privaten Repo.
[`tools/pre-commit-check.sh`](tools/pre-commit-check.sh) prueft das vor jedem Commit.

## Tests

```bash
tests/run.sh            # alles
tests/run.sh lock       # nur Tests mit "lock" im Namen
```

Ohne Abhaengigkeiten ausser bash und git. Der Agent ist ein Fake, der aufzeichnet, womit er
aufgerufen wurde - geprueft wird also der Vertrag zwischen Runner und Agent (Arbeitsverzeichnis,
Rechte, Prompt ueber stdin), nicht der Agent selbst. Die CI laeuft auf Linux, auf macOS unter
`/bin/bash` 3.2 und unter Git Bash auf Windows.

## Lizenz

MIT. Mach damit, was du willst.
