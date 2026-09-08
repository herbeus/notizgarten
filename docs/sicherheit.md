# Sicherheit

Ein Second Brain ist per Bauart die dichteste Sammlung persoenlicher Daten, die du besitzt:
Gesundheit, Geld, Familie, Beruf, alles an einem Ort und durchsuchbar. Entsprechend behandeln.

## Was nie ins Vault gehoert

**Zugangsdaten jeder Art.** Passwoerter, PINs, API-Tokens, private Schluessel, Wiederherstellungs-
Codes, Seed-Phrasen. Auch nicht "nur kurz zum Merken", auch nicht gekuerzt, auch nicht als
Beispiel. Dafuer gibt es einen Passwortmanager.

Das ist kein theoretisches Risiko. In der Praxis passiert es so: Man notiert einen Schluessel
"nur eben schnell" in einer Notiz-App, vergisst ihn dort, und findet ihn Monate spaeter beim
Aufraeumen wieder - inzwischen synchronisiert ueber drei Geraete und in jedem Backup.

Der Gaertner-Lauf sucht deshalb gezielt nach solchen Mustern und meldet **nur Datei und Zeile,
nie den Wert**. Ein Fund gehoert sofort behandelt: rotieren oder widerrufen, dann loeschen.

**Fremde personenbezogene Daten.** Notizen ueber andere Menschen - Diagnosen, Konflikte,
Einschaetzungen - sind heikel. Nicht weil das Notieren falsch waere, sondern weil das Vault
gesynct, gebackupt und von einem Agenten gelesen wird. Frag dich bei solchen Notizen, ob du
sie schreiben wuerdest, wenn die betreffende Person mitliest.

## Der Agent und die Vertrauensgrenze

Der Agent bekommt Schreibrechte **nur auf das Vault-Verzeichnis**. Das ist im Runner so
eingestellt und sollte so bleiben:

```
--allowedTools "... Write($VAULT/**) Edit($VAULT/**) ..."
```

**Quelleninhalte sind Daten, keine Anweisungen.** Alle Prompts in diesem Repo sagen das
ausdruecklich. Der Grund: Ein Transkript, eine Notiz oder eine kopierte Webseite kann Text
enthalten, der wie eine Anweisung aussieht. Ein Agent, der das befolgt, tut Dinge, die niemand
wollte. Die Regel gehoert in jeden Prompt, der fremden Text liest.

**Der Agent loescht und verschiebt nichts.** Das ist als Sicherheitsmassnahme gemeint, nicht als
Bequemlichkeit: Ein Vault, dem du nicht mehr traust, weil Dinge verschwinden, ist wertlos.

## Transkripte sind ein Fundort

Was in einem Terminal ausgegeben wird, landet im Session-Transkript des Agenten - und damit im
Dateisystem und im Backup. Wer beim Sichten unbekannter Dateien `cat` benutzt, kopiert deren
Inhalt in das Transkript.

Praktische Folge: unbekannte Dateien mit `grep -c` oder `grep -l` pruefen statt mit `cat`.
Und: Das Abend-Destillat liest genau diese Transkripte. Deshalb steht in seinem Prompt
ausdruecklich, dass es keine Zugangsdaten uebernehmen darf.

## Sync und Backup

- **Cloud-Sync ist kein Backup.** Loeschst du versehentlich etwas, ist es ueberall weg.
  Obsidian hat unter Einstellungen eine Dateiwiederherstellung - einschalten, Aufbewahrung hoch.
- **Verschluesselte Backups** an einen zweiten Ort. Wenn du eine Passphrase verwendest: sie
  gehoert in den Passwortmanager, nicht neben das Backup. Ein Backup, dessen Passphrase du nicht
  mehr hast, ist kein Backup.
- **Pruefe gelegentlich, ob das Backup wirklich lesbar ist.** Ein ungetestetes Backup ist eine
  Vermutung.

## Wenn berufliche Inhalte im Vault liegen

Das ist der Grund fuer den eigenen Ast `08-Arbeit/`. Klaere fuer dich:

- Darf berufliches Wissen ueberhaupt privat gespeichert werden? Das regelt dein Vertrag,
  nicht dein Gefuehl.
- Wenn ja: Was passiert damit am Vertragsende? Halte eine kurze Liste, wo ueberall berufliche
  Daten liegen, und pflege sie, wenn ein Ort dazukommt.
- Kundennamen, interne Hostnamen und Ticketnummern sind auch dann sensibel, wenn sie harmlos
  aussehen.

## Dieses Repo

Was hier veroeffentlicht wird, ist ausschliesslich das **leere Template**.
[`tools/pre-commit-check.sh`](../tools/pre-commit-check.sh) prueft vor jedem Commit auf echte
Notizen, Zugangsdatenmuster, konkrete Pfade und Mailadressen.

Als Hook einhaengen:

```bash
ln -sf ../../tools/pre-commit-check.sh .git/hooks/pre-commit
```

Und eine Warnung aus der Erfahrung: **Eine Stichwortsuche allein reicht nie.** In einem JWT
steht der Inhalt base64-kodiert - kein Klartext-Grep der Welt findet ihn. Deshalb prueft das
Skript zusaetzlich auf Credential-Muster. Was in Bildern steht, findet es ebenfalls nicht:
Screenshots muessen mit dem Auge geprueft werden.
