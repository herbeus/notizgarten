# Reproduktions-Prompt

Diesen Text an einen KI-Agenten mit Dateizugriff geben (Claude Code, Copilot CLI oder
vergleichbar). Er richtet das Vault ein und stellt die Rueckfragen, die er stellen muss.

Vorher ausfuellen: die drei Angaben im Abschnitt "Mein Kontext". Alles andere kann der Agent
erfragen.

---

## Prompt

Du richtest mir ein persoenliches Second-Brain-Vault fuer Obsidian ein. Arbeite in kleinen
Schritten und frage nach, wenn eine Entscheidung meine ist.

### Mein Kontext

- **Vault-Ort:** << absoluter Pfad, wohin das Vault soll >>
- **Betriebssystem:** << macOS / Windows / Linux / WSL >>
- **Sync ueber:** << iCloud / Obsidian Sync / Syncthing / Git / gar nicht >>

### Was ich will

Ein Vault nach PARA (Aktion) + Zettelkasten (Wissen) + MOCs (Navigation), das ein KI-Agent
aktiv mitpflegt - nicht nur liest. Deutschsprachig. Beruf und Privates strikt getrennt.

### Schritt 1: Struktur anlegen

Lege im Vault-Ort an:

```
00-Inbox/  01-Projekte/  02-Bereiche/  03-Notizen/  04-Ressourcen/
05-Vorlagen/  06-Anhaenge/  07-Archiv/  08-Arbeit/{Projekte,Wissen}/  Tagebuch/
```

In jeden Ordner eine `.info.md` mit ein bis zwei Saetzen, was dort lebt und was nicht.
Diese Dateien sind fuer mich und fuer dich - du liest sie spaeter, um zu entscheiden,
wohin etwas gehoert.

### Schritt 2: Vorlagen

Sieben Vorlagen nach `05-Vorlagen/`: Tagesnotiz, Wochenreview, Projektnotiz,
Permanente-Notiz, Literaturnotiz, MOC, Bereich.

Frontmatter-Konvention: immer `typ`, `erstellt: YYYY-MM-DD`, `tags` als Inline-Array.
Projekte zusaetzlich `status` und `deadline`, Bereiche `status: aktiv`.

**Wichtig bei der Tagesnotiz:** Sie muss so gebaut sein, dass sie **rueckblickend** gefuellt
wird, nicht morgens auf Vorrat. Abschnitte also "Was heute passiert ist", "Was ich gelernt
habe", "Schnell-Capture", "Verlinkt" - keine leeren Planungsfelder.

**Wichtig beim Wochenreview:** Es braucht einen Abschnitt "Unveraendert offen", der Punkte
nur **zaehlt** statt sie auszubreiten. Verlinke darin keine Bereichsnotizen, die es noch nicht
gibt - tote Links im Template sind schlimmer als eine Leerstelle.

### Schritt 3: Die Betriebsanleitung

Lege `CLAUDE.md` im Vault-Root an. Das ist die wichtigste Datei: Sie steuert, wie du selbst
und jeder kuenftige Agent mit dem Vault umgeht. Sie muss enthalten:

1. Grundregeln: erst orientieren, Neues festhalten, eine Idee pro Notiz, richtiger Ort,
   grosszuegig verlinken, **nie Zugangsdaten im Klartext**
2. Die Ordnerstruktur mit Erklaerung
3. Tag- und Frontmatter-Konvention
4. Was du nie eigenmaechtig tust: nichts loeschen, nichts verschieben, keine Dateinamen mit `/`
5. **Die drei Regeln gegen Leerlauf** - woertlich, ganz oben:
   - **A. Schreibe nichts Leeres.** Nie eine Notiz anlegen, nur weil ein Zeitplan es sagt.
     Gibt es nichts zu berichten, ist das Ergebnis: keine Datei.
   - **B. Wiederhole nichts, was schon dasteht.** Unveraendertes wird gezaehlt, nicht
     ausgebreitet.
   - **C. Ernte, statt Formulare zu verteilen.** Rueckblickend arbeiten.

Diese drei sind nicht verhandelbar. Sie stammen aus einem gescheiterten ersten Versuch, bei dem
eine Morgen-Automatik sechs Wochen lang leere Formulare anlegte, bis das System aufgegeben wurde.

Fuer meine beruflichen Konventionen laesst du eine markierte Leerstelle - ich fuelle sie selbst.
Formuliere Regeln nur an einer Stelle aus, sonst laufen die Fassungen auseinander.

### Schritt 4: Einstieg und Obsidian-Konfiguration

- `Home.md` als schlanker Einstiegspunkt, mit Dataview-Abfragen fuer aktive Projekte und
  zuletzt bearbeitete Notizen. Bereichsverlinkungen als Leerstelle lassen.
- `08-Arbeit/MOC - Arbeit.md` als Landkarte des beruflichen Asts.
- `.obsidian/`: neue Notizen nach `00-Inbox`, Anhaenge nach `06-Anhaenge`,
  Vorlagenordner `05-Vorlagen`, Tagesnotizen nach `Tagebuch`.
- Nenne mir am Ende die vier Community-Plugins, die ich von Hand installieren muss
  (Dataview, Templater, Calendar, Smart Connections) - die kannst du nicht fuer mich installieren.

### Schritt 5: Automatik vorschlagen, nicht einrichten

Erklaere mir drei Laeufe und frage, welche ich will:

1. **Abendlese, taeglich** - liest die Transkripte meiner Agenten-Sessions des Tages und
   haelt fest, was dauerhaft nuetzlich ist. War nichts, wird nichts geschrieben.
2. **Wochenreview, sonntags** - Bestandsaufnahme mit der Anti-Wiederholungs-Regel.
3. **Gaertner, monatlich** - kaputte Links, verwaiste Notizen, veraltete Statusangaben.
   Meldet nur.

Richte einen Timer erst ein, wenn ich zustimme, und sage mir vorher, was er ausfuehren wird.

### Regeln fuer dich waehrend der Einrichtung

- **Lege keine Beispielnotizen an.** Kein Demo-Projekt, keine Musternotiz. Solche Dateien
  bleiben monatelang liegen und tauchen in jeder Abfrage als aktives Projekt auf.
- **Erfinde keine Inhalte fuer mich.** Leerstellen deutlich markieren, statt sie plausibel
  zu fuellen.
- **Frag nach**, bevor du etwas ausserhalb des Vault-Ordners anfasst.
- Am Ende: Zusammenfassung, was angelegt wurde, und eine kurze Liste, was ich selbst tun muss.
