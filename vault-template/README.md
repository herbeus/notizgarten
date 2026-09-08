# Mega Brain - Vault

Ein einsatzbereites Obsidian-Vault nach **PARA (Aktion) + Zettelkasten (Wissen) + MOCs (Navigation)**.

Dieses Vault ist die Vorlage aus dem Setup-Repo `mega-brain`. Die ausfuehrliche Anleitung
(Einrichtung auf macOS, Windows und iOS, Automatik, Sicherheit) steht dort in `docs/`.

## In 5 Minuten startklar

1. **Obsidian installieren** (kostenlos): <https://obsidian.md>
2. *Open folder as vault* -> diesen Ordner waehlen.
3. Die mitgelieferte `.obsidian/`-Konfiguration setzt bereits:
   - neue Notizen landen in `00-Inbox`
   - Anhaenge in `06-Anhaenge`
   - Vorlagenordner `05-Vorlagen`
   - Tagesnotizen in `Tagebuch` mit der Vorlage `Tagesnotiz`
4. **Community-Plugins** installieren (Einstellungen -> Community plugins). Bei fuenf ist Schluss:
   - **Dataview** - die Listen in `Home.md` und den Bereichsnotizen brauchen es
   - **Templater** - maechtigere Vorlagen
   - **Calendar** - Tagesnotizen per Klick
   - **Smart Connections** - semantische Suche lokal, ohne API-Key
5. `Home.md` oeffnen und die `<< ... >>`-Leerstellen fuellen.

## Die Ordner

| Ordner | Inhalt | Frage |
|---|---|---|
| `00-Inbox` | Alles Neue, unsortiert | "Spaeter verarbeiten" |
| `01-Projekte` | Vorhaben mit Ziel und Deadline | "Was muss ich TUN?" |
| `02-Bereiche` | Laufende Verantwortungen ohne Enddatum | "Worum kuemmere ich mich dauerhaft?" |
| `03-Notizen` | Permanente, atomare Wissensnotizen | "Was DENKE oder WEISS ich?" |
| `04-Ressourcen` | Referenzmaterial, Literaturnotizen | "Was koennte nuetzlich sein?" |
| `05-Vorlagen` | Templates | - |
| `06-Anhaenge` | Bilder, PDFs | - |
| `07-Archiv` | Erledigtes, Inaktives | "Aus dem Weg, aber auffindbar" |
| `08-Arbeit` | Beruflicher Ast, strikt getrennt | "Was gehoert dem Job?" |
| `Tagebuch` | Tagesnotizen `YYYY-MM-DD` | - |

**Faustregel:** Ordner beantworten *"wo lebt es?"* - genau ein Zuhause. **Tags** beantworten
*"worum geht es?"* - beliebig viele. **MOCs** beantworten *"wie haengt es zusammen?"*.

In jedem Ordner liegt eine `.info.md`, die den Zweck erklaert. Die ist fuer dich und fuer den
Agenten gedacht - stehen lassen.

## Der Rhythmus (CODE)

1. **Capture** - alles nach `00-Inbox`. Regel: unter 10 Sekunden, oder es passiert nicht.
2. **Organize** - einmal pro Woche Inbox leeren: verschieben, verlinken oder loeschen.
3. **Distill** - Wichtiges in EIGENEN WORTEN nach `03-Notizen`. Eine Idee pro Notiz, mindestens ein Link.
4. **Express** - aus verlinkten Notizen entsteht Output.

## Die Datei, die den Unterschied macht

`CLAUDE.md` im Vault-Root ist die Betriebsanleitung fuer einen KI-Agenten. Sie entscheidet, ob
das Vault nur gelesen oder tatsaechlich gepflegt wird. Die drei wichtigsten Regeln darin:

- **Schreibe nichts Leeres.** Kein Formular auf Vorrat.
- **Wiederhole nichts, was schon dasteht.** Unveraendertes wird gezaehlt, nicht ausgebreitet.
- **Ernte, statt Formulare zu verteilen.** Rueckblickend arbeiten, nicht vorausschauend.

Warum diese drei so prominent stehen, steht in `docs/automatik.md` des Setup-Repos.

## Die 7 Todsuenden

1. **Sammelwahn** - Haben ist nicht Verstehen. Schreib in eigenen Worten.
2. **System-Basteln als Prokrastination** - erst Notizen, dann Feintuning.
3. **Copy-Paste-Friedhof** - nur speichern, was du wirklich brauchst.
4. **Inbox-Zero-Stress** - Notizen duerfen liegen. Zeit ist ein Filter.
5. **Tool-Hopping** - 30 bis 90 Tage committen, dann erst urteilen.
6. **Ablage statt Verlinkung** - verlinke grosszuegig.
7. **Plugin-Overload** - maximal fuenf.

## Wartung

- **Woechentlich:** Inbox leeren, aktive Projekte pruefen (15 Minuten).
- **Zufallsbesuch:** ab und zu eine zufaellige Notiz oeffnen, fehlende Links ergaenzen.
- **Input zu Output etwa 5:1** - pro fuenf Captures ein Stueck eigener Output.
