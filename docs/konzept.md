# Konzept

Warum das Vault so aufgebaut ist, wie es aufgebaut ist.

## Drei Methoden, die sich ergaenzen

Kein einzelnes System deckt alles ab. Deshalb sind hier drei kombiniert, jedes fuer eine
andere Frage:

**PARA** beantwortet *"Was muss ich tun?"* - Projekte, Bereiche, Ressourcen, Archiv. Sortiert
nach **Handlungsdruck**, nicht nach Thema. Eine Notiz ueber Steuern liegt im Projekt
"Steuererklaerung 2026", solange die laeuft, und wandert danach ins Archiv.

**Zettelkasten** beantwortet *"Was weiss ich?"* - atomare, verlinkte Notizen in `03-Notizen`.
Zeitlos. Eine Idee pro Notiz, in eigenen Worten, mindestens ein Link. Der Wert entsteht nicht
in der einzelnen Notiz, sondern zwischen ihnen.

**MOCs** (Maps of Content) beantworten *"Wie haengt das zusammen?"* - kuratierte Landkarten.
Kein Inhaltsverzeichnis: eine MOC, die alles auflistet, ist ein Dateiexplorer mit Extraschritt.

## Ordner, Tags und MOCs

Der haeufigste Anfaengerfehler ist, alle drei fuer dasselbe zu benutzen.

| Werkzeug | Frage | Regel |
|---|---|---|
| **Ordner** | Wo lebt es? | Genau **ein** Zuhause. Keine Kopien. |
| **Tags** | Worum geht es? | Beliebig viele. Immer gleich geschrieben. |
| **MOCs** | Wie haengt es zusammen? | Kuratiert, nicht vollstaendig. |

Faustregel: Wenn du dich fragst, ob etwas in `01-Projekte` oder `02-Bereiche` gehoert - hat es
ein Ende, ist es ein Projekt. Hat es keines, ist es ein Bereich. "Wohnung renovieren" ist ein
Projekt, "Haushalt" ist ein Bereich.

## Die Trennung Beruf und Privates

`08-Arbeit/` ist bewusst ein eigener Ast, kein Tag. Drei Gruende:

1. **Verschiedene Halbwertszeiten.** Berufliches Wissen veraltet mit dem Job, privates nicht.
2. **Verschiedene Leser.** Berufliches teilst du vielleicht mit Kollegen, den Rest nie.
3. **Verschiedene Eigentuemer.** Ein Vertrag kann enden und verlangen, dass berufliche Inhalte
   verschwinden. Dann muss in einem Griff klar sein, was das ist. Ein Tag quer durch das ganze
   Vault waere dafuer unbrauchbar.

Halte die Grenze auch dann sauber, wenn eine Notiz thematisch in beide passt. Im Zweifel: die
private Fassung in `03-Notizen`, die berufliche in `08-Arbeit/Wissen`, gegenseitig verlinkt.

## Der Rhythmus: CODE

1. **Capture** - alles nach `00-Inbox`. Muss unter zehn Sekunden dauern, sonst passiert es nicht.
2. **Organize** - einmal pro Woche: verschieben, verlinken oder loeschen.
3. **Distill** - Wichtiges in eigenen Worten nach `03-Notizen`.
4. **Express** - aus verlinkten Notizen entsteht Output.

Der dritte Schritt ist der, den fast alle auslassen, und der einzige, der aus Sammlung Wissen
macht. Ein Vault ohne Distill ist ein Lesezeichen-Ordner.

## Wo der Agent hineinpasst

Die drei Schritte, an denen ein KI-Agent tatsaechlich hilft, sind **Distill** und **Organize** -
also genau die unbeliebten. Capture ist in zehn Sekunden erledigt, Express ist Deine Arbeit.

Der Agent liest also, was in Gespraechen entstanden ist, und verdichtet es zu Notizen. Er raeumt
auf und meldet Verfall. Er legt keine Formulare an und plant nicht Deinen Tag - beides hat sich
als wertlos erwiesen, siehe [`automatik.md`](automatik.md).

## Warum die `CLAUDE.md` im Vault liegt

Sie koennte auch im Setup-Repo stehen. Sie liegt aber **im Vault**, weil sie mit dem Vault
reisen muss: Wer den Ordner verbindet, bekommt die Regeln mit, ohne dass jemand daran denken
muss. Und weil ein Agent, der im Vault arbeitet, sie dort von selbst findet.

Das ist derselbe Gedanke wie eine README im Repo, nur fuer Wissen statt fuer Code.

## Eine Regel, ein Ort

Die groesste Gefahr in einem gewachsenen Wissenssystem ist nicht Chaos, sondern **zwei
Fassungen derselben Regel**. Sie laufen auseinander, und du merkst es erst, wenn du der
falschen folgst.

Deshalb: Jede Konvention wird an **genau einer** Stelle ausformuliert. Ueberall sonst steht
ein Verweis. Die Vorlagen hier sind entsprechend gebaut - `CLAUDE.md` und `MOC - Arbeit` haben
an den betreffenden Stellen eine markierte Leerstelle statt einer Kopie.

## Was klein bleiben soll

- **Maximal fuenf Plugins.** Jedes weitere ist Wartung, keine Faehigkeit.
- **Wenige, immer gleich geschriebene Tags.** Zwanzig Tags mit je einer Notiz sind kein System.
- **Schlanke MOCs und ein schlankes Home.** Kuratieren heisst weglassen.
- **Kein Demo-Inhalt.** Beispielnotizen aus der Einrichtung bleiben monatelang liegen und
  tauchen in jeder Abfrage als aktives Projekt auf. Genau das ist hier passiert - ein
  Demo-Projekt stand sechs Wochen lang jeden Morgen im Tagesfokus.

## Woher das kommt

Nichts an der Struktur ist hier erfunden. Die Bausteine haben Urheber, und wer eines der
Konzepte wirklich verstehen will, liest besser das Original als diese Zusammenfassung.

| Baustein | Quelle |
|---|---|
| **PARA** (`01` bis `07`) | Tiago Forte, [The PARA Method](https://fortelabs.com/blog/para/) - sortieren nach Handlungsdruck, nicht nach Thema. Fuer die Umsetzung in Obsidian: [How to Implement PARA in Your Favorite Notetaking App](https://fortelabs.com/blog/how-to-implement-para-in-your-favorite-notetaking-app/) |
| **CODE** (Capture, Organize, Distill, Express) | Ebenfalls Forte, aus dem Buch *Building a Second Brain*. Ohne das Buch am besten erklaert bei [Workflowy: Build a second brain](https://workflowy.com/help/build-a-second-brain/) |
| **Zettelkasten** (`03-Notizen`) | Sascha Fast und Christian Tietze, [Introduction to the Zettelkasten Method](https://zettelkasten.de/introduction/). Dazu Luhmanns Originalessay von 1981, [Communicating with Slip Boxes](https://luhmann.surge.sh/communicating-with-slip-boxes) - danach versteht man, warum "mindestens ein Link" keine Kosmetik ist |
| **Eine Idee pro Notiz** | Andy Matuschak, [Evergreen notes should be atomic](https://notes.andymatuschak.org/Evergreen_notes?stackedNotes=z4Rrmh17vMBbauEGnFPTZSK3UmdsGExLRfZz1). Sein Notizsystem ist selbst das Beispiel |
| **MOCs** (`Home.md`, `MOC - Arbeit`) | Nick Milo, [LYT Blog: Maps](https://blog.linkingyourthinking.com/maps/). Von ihm stammt der Begriff, und die Regel, dass MOCs entstehen, wenn man sie braucht, nicht vorab |
| **Garten statt Archiv** (der Name, der Gaertner-Lauf) | Maggie Appleton, [A Brief History & Ethos of the Digital Garden](https://maggieappleton.com/garden-history) - wachsen, verfallen, pflegen statt publizieren |
| **`CLAUDE.md` als Betriebsanleitung** | Claude-Code-Doku, [How Claude remembers your project](https://code.claude.com/docs/en/memory) - warum die Datei im Vault-Root liegt und von selbst geladen wird |

Was **nicht** aus einer dieser Quellen stammt, sind die drei Regeln gegen Leerlauf in der
`CLAUDE.md`. Die kommen aus dem Scheitern der ersten Fassung, beschrieben in
[`automatik.md`](automatik.md).
