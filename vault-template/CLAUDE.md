# CLAUDE.md - Betriebsanleitung fuer dieses Vault

Dies ist ein persoenliches "Second Brain" (Obsidian-Vault). **Wenn dieser Ordner verbunden ist,
ist er die zentrale Wissens- und Aufgabenquelle. Lies und nutze ihn - bei jeder Sitzung.**

> Diese Datei steuert, wie ein KI-Agent mit dem Vault umgeht. Sie ist der Unterschied zwischen
> "ein Ordner voller Markdown" und einem System, das mitarbeitet. Passe sie an dich an -
> alles unter `<< ... >>` ist eine Leerstelle, die du fuellen musst.

## Grundregeln (immer befolgen)

1. **Zuerst orientieren.** Bei Aufgaben mit Bezug zu Leben, Wissen oder Aufgaben des Nutzers
   zuerst `Home.md` und die relevanten Dateien in `02-Bereiche/` und `03-Notizen/` lesen,
   bevor du antwortest.
2. **Neues festhalten.** Tauchen im Gespraech dauerhaft nuetzliche Infos, Entscheidungen, Ideen
   oder Aufgaben auf, lege oder aktualisiere die passende Notiz - nicht nur im Chat antworten.
3. **Eine Idee pro Notiz**, in eigenen Worten, mindestens ein `[[Wikilink]]`. Atomar und verlinkt.
4. **Richtiger Ort.** Ordner = "wo lebt es" (genau ein Zuhause), Tags = "worum geht es",
   MOCs = "wie haengt es zusammen".
5. **Wikilinks grosszuegig setzen**, damit der Graph waechst.
6. **Niemals Zugangsdaten im Klartext speichern** - keine Passwoerter, Tokens, PINs, Kontonummern,
   Seed-Phrasen. Die gehoeren in einen Passwortmanager. Auch nicht "nur kurz zum Merken".
   Siehe `docs/sicherheit.md` im Setup-Repo.
7. **Keine Rechts-, Finanz- oder Medizinberatung als Fakt ausgeben.** Notizen zu solchen Themen
   sind Gedaechtnisstuetzen, keine Auskunft.

## Die drei Regeln gegen Leerlauf

Diese drei sind aus Erfahrung entstanden und wiegen schwerer als alles andere. Ohne sie
produziert ein Agent Fleiss ohne Ertrag.

**A. Schreibe nichts Leeres.** Lege niemals eine Notiz an, nur weil ein Zeitplan es sagt.
Ein leeres Formular ist keine Hilfe, sondern eine Bringschuld an den Nutzer. Gibt es nichts
zu berichten, ist das Ergebnis: keine Datei. Das ist ein voller Erfolg, kein Fehlschlag.

**B. Wiederhole nichts, was schon dasteht.** Bevor du etwas schreibst, pruefe, ob es im Vault
schon steht. Wenn ja: ergaenzen oder korrigieren, nicht neu formulieren. Ein Punkt, der sich
seit dem letzten Mal nicht geaendert hat, wird **gezaehlt, nicht ausgebreitet**
("Inbox: 4. Durchgang unveraendert") - nicht die ganze Liste noch einmal.

**C. Ernte, statt Formulare zu verteilen.** Arbeite rueckblickend aus dem, was tatsaechlich
passiert ist, statt vorausschauend Platzhalter hinzulegen. Eine gefuellte Notiz am Abend
schlaegt eine leere am Morgen.

## Ordnerstruktur

- `00-Inbox/` - Eingang fuer alles Neue und Unsortierte. Standard-Speicherort.
- `01-Projekte/` - Vorhaben mit Ziel und Deadline (`typ: projekt`, `status: aktiv|pausiert|erledigt`).
- `02-Bereiche/` - laufende Lebensbereiche und Dashboards (`typ: bereich`).
- `03-Notizen/` - permanente atomare Wissensnotizen und MOCs.
- `04-Ressourcen/` - Referenz, Literaturnotizen.
- `05-Vorlagen/` - Templates.
- `06-Anhaenge/` - Bilder, PDFs.
- `07-Archiv/` - Erledigtes und Inaktives.
- `08-Arbeit/` - beruflicher Bereich, strikt getrennt vom Privaten: `Projekte/`, `Wissen/`,
  plus eigene MOC. Einstieg: `[[MOC - Arbeit]]`.
- `Tagebuch/` - Tagesnotizen `YYYY-MM-DD`.

**Warum die Trennung `08-Arbeit` gegen den Rest?** Beruf und Privates haben verschiedene
Halbwertszeiten, verschiedene Leser und im Zweifel verschiedene Eigentuemer. Ein Vertrag kann
enden und verlangen, dass berufliche Inhalte verschwinden - dann muss klar sein, was das ist.
Halte die Grenze sauber, auch wenn eine Notiz thematisch in beide passen wuerde.

## Bei beruflichen Aufgaben

<< Hier die eigenen Arbeitskonventionen eintragen oder auf eine Notiz verweisen:
   Branch- und Commit-Format, Review-Ablauf, Sprache von Code und Kommunikation,
   was ohne Rueckfrage passieren darf und was nicht.
   Empfehlung: die Regeln an genau EINER Stelle ausformulieren und hier nur verlinken -
   zwei Fassungen laufen garantiert auseinander. >>

## Tag-Konvention

- Typ: `#idee #person #buch #konzept #frage #projekt #bereich #moc`
- Kontext: `#beruf #finanzen #gesundheit #lernen #schreiben #leben #reisen`
- Status: `#offen #in-arbeit #erledigt`

Immer gleich schreiben, maximal drei Ebenen, lieber wenige gute als viele.

## Frontmatter-Felder

- Immer: `typ`, `erstellt: YYYY-MM-DD`, `tags`
- Projekte zusaetzlich: `status`, `deadline`
- Bereiche zusaetzlich: `status: aktiv`

Tags als Inline-Array: `tags: [idee, beruf]`.

## Wie ich (der Agent) das Vault aktiv nutze

- **Aufgabe verstehen, dann Vault konsultieren.** Vor Antworten zu Beruf, Finanzen, Gesundheit
  oder Plaenen die relevanten Bereichs- und Notizdateien lesen und einbeziehen.
- **Erfassen.** Neue To-dos in den passenden Bereich oder als Projekt; lose Gedanken nach `00-Inbox/`.
- **Verarbeiten.** Beim Wochenreview `00-Inbox/` leeren - jede Notiz verschieben, verlinken
  oder loeschen.
- **Verdichten.** Wichtige Erkenntnisse als permanente Notiz in `03-Notizen/`, in eigenen Worten.
- **Verknuepfen.** Neue Notizen mit bestehenden MOCs und Notizen verlinken.
- **Korrigieren.** Widerspricht etwas Neues einer bestehenden Notiz, wird die alte Stelle
  richtiggestellt - nicht eine zweite Notiz danebengelegt. Nur was belegt ist, und immer
  sichtbar vermerken.

## Was ich nie eigenmaechtig tue

- **Nichts loeschen.** Vorschlagen ja, ausfuehren nur auf Zuruf.
- **Nichts verschieben**, was der Nutzer bewusst abgelegt hat - erst fragen.
- **Keine Dateinamen mit `/`** vergeben; das erzeugt in Obsidian ungewollt Unterordner.
- **Private Inhalte nicht nach aussen tragen** - nicht in Repos, nicht in Tickets, nicht in
  Zusammenfassungen fuer Dritte.

## Wiederkehrende Automatik

Siehe `docs/automatik.md` und die Prompts in `prompts/` des Setup-Repos. Kurzfassung:

- **Taeglich abends: Abendlese.** Liest die Transkripte des Tages, haelt fest, was dauerhaft
  nuetzlich ist. War nichts, wird nichts geschrieben (Regel A).
- **Sonntags: Wochenreview.** Bestandsaufnahme mit der Anti-Wiederholungs-Regel (Regel B).
- **Monatlich: Gaertner.** Kaputte Wikilinks, verwaiste Notizen, veraltete Statusangaben.
  Meldet nur, aendert nichts.

## Pflege-Prinzipien

- Lieber wenige gute Notizen und Tags als viele.
- Home und MOCs schlank halten - kuratieren, nicht alles auflisten.
- Input zu Output etwa 5:1. Regelmaessig eigenen Output erzeugen, nicht nur sammeln.
