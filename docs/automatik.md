# Automatik

Was regelmaessig laufen soll, warum es so und nicht anders zugeschnitten ist, und was in der
ersten Fassung schiefging.

Der letzte Punkt zuerst, weil ohne ihn der Rest wie Willkuer aussieht.

## Was vorher nicht funktioniert hat

Die erste Fassung dieses Setups hatte zwei geplante Tasks: morgens eine Tagesnotiz anlegen,
sonntags ein Wochenreview. Beide liefen zuverlaessig. Trotzdem wurde das System nach sechs
Wochen aufgegeben. Die Zahlen aus dem Nachlauf:

**32 Tagesnotizen, lueckenlos ueber sechs Wochen. 31 davon praktisch identisch:**

| Abschnitt | Inhalt an 31 von 32 Tagen |
|---|---|
| Termine heute | "keine Termine" |
| Fokus heute | dieselben drei aktiven Projekte, aus einer Dataview-Abfrage |
| Aufgaben | leer |
| Was mir auffiel | leer |
| Schnell-Capture | leer |
| Verlinkt | leer |

Eines der drei taeglich wiederholten "Fokus"-Projekte war das Demo-Projekt aus der
Ersteinrichtung, das seit Wochen ins Archiv gehoert haette. Es stand jeden Morgen brav da,
inklusive Hinweis auf die ueberfaellige Deadline.

**Die eine Ausnahme ist der Beweis, was gefehlt hat.** An genau einem Tag standen 16 echte
Kalendertermine in der Notiz, ueber den ganzen Tag verteilt. Dieser Tag war konkret und
nuetzlich. An 31 anderen Tagen "keine Termine" - und dass jemand 31 Tage am Stueck keinen
einzigen Termin hat, ist unplausibel. Der Kalenderzugriff hat also fast nie geliefert, und
ohne ihn blieb dem Task nichts uebrig, als das Template hinzulegen.

**Die vier Wochenreviews waren inhaltlich gut** - sie haben scharf diagnostiziert, mitgezaehlt
und Muster erkannt. Eines schrieb ueber das eigene System:

> "Diese Woche im Vault faktisch keine Bewegung. Der Vault sammelt, es fliesst aber nichts
> zurueck (Capture-Felder leer)."

Und im Log: *"Nichts geaendert seit letzter Woche - einzige veraenderte Datei war der letzte
Review selbst."*

Genau daraus entstand der zweite Fehler: Dieselbe Tabelle mit denselben offenen Punkten stand
**wortgleich in vier aufeinanderfolgenden Reviews**, weil nichts passiert war. Der Review hatte
nichts Neues zu essen und hat deshalb das Alte noch einmal aufgetischt. Beim vierten Mal liest
das niemand mehr.

### Die Diagnose

**Fehler 1: falsche Richtung.** Die Automatik lief *morgens* und legte ein *leeres Formular* hin.
Das ist keine Arbeit fuer den Nutzer, das ist eine Bringschuld an ihn. Sechs Wochen nicht
eingeloest, dann fallen gelassen. Ein Agent, der schreibt, wo er lesen sollte.

**Fehler 2: keine Datenquelle.** Das Vault war die einzige Quelle, und im Vault stand nichts
Neues. Ein System, das nur sich selbst beobachtet, hat nach kurzer Zeit nichts mehr zu sagen.

**Fehler 3: keine Bremse gegen Wiederholung.** Nichts hinderte den Review daran, den
unveraenderten Stand jedes Mal komplett neu auszuformulieren.

### Der Gegenbeweis

Im selben Vault waechst ein anderer Ast seit Monaten zuverlaessig: berufliche Wissensnotizen,
die aus Transkripten von Coding-Sessions destilliert werden. Zwoelf der zuletzt geaenderten
Dateien stammen alle aus dieser Richtung.

**Destillation aus echten Gespraechen liefert. Selbstbeobachtung des Vaults lieferte nicht.**
Darauf ist die neue Fassung gebaut.

## Die drei Regeln

Aus den drei Fehlern folgen die drei Regeln, die in `CLAUDE.md` ganz oben stehen:

**A. Schreibe nichts Leeres.** Gibt es nichts zu berichten, wird keine Datei angelegt. Das ist
ein Erfolg, kein Fehlschlag. Ein leerer Ordner ist ehrlicher als 32 leere Formulare.

**B. Wiederhole nichts, was schon dasteht.** Unveraendertes wird gezaehlt, nicht ausgebreitet:
"Inbox: 4. Durchgang unveraendert" statt der Liste zum vierten Mal. Ab dem dritten Mal nicht
mehr auflisten, sondern die Frage stellen, ob das ueberhaupt noch ein Ziel ist.

**C. Ernte, statt Formulare zu verteilen.** Rueckblickend arbeiten. Eine gefuellte Notiz am
Abend schlaegt eine leere am Morgen.

## Die drei Laeufe

### 1. Abend-Destillat (taeglich)

**Wann:** abends, wenn der Arbeitstag gelaufen ist.
**Quelle:** die Transkripte der Agenten-Sessions des Tages.
**Prompt:** [`prompts/abend-destillat.md`](../prompts/abend-destillat.md)

Liest, was heute besprochen wurde, und haelt fest, was dauerhaft nuetzlich ist - als neue
Wissensnotiz, als Ergaenzung an einer bestehenden, oder als Tagesnotiz, die dann **gefuellt**
entsteht.

War heute nichts dabei, wird **nichts geschrieben**. Kein Platzhalter, keine Datei, kein
"heute keine Erkenntnisse". Stille ist ein gueltiges Ergebnis.

### 2. Wochenreview (sonntags)

**Wann:** sonntags.
**Quelle:** Vault-Aenderungen der Woche, die Transkripte der Woche, optional Git-Aktivitaet.
**Prompt:** [`prompts/wochenreview.md`](../prompts/wochenreview.md)

Das Format der alten Reviews war gut und bleibt. Neu sind zwei Dinge: eine breitere Datenbasis,
damit es etwas zu berichten gibt, und die Anti-Wiederholungs-Regel, damit es nicht zur Kopie
seiner selbst wird.

### 3. Gaertner (monatlich)

**Wann:** einmal im Monat.
**Prompt:** [`prompts/gaertner.md`](../prompts/gaertner.md)

Sucht kaputte Wikilinks, verwaiste Notizen, Notizen ohne einen einzigen Link, Statusangaben
aelter als sechs Monate, Dubletten. **Meldet nur, aendert nichts** - Aufraeumen bleibt eine
menschliche Entscheidung.

## Einrichtung

Timer und Runner-Skripte liegen in [`../automatik/`](../automatik/):

- **Linux und WSL:** systemd-user-Timer, siehe [`automatik/linux/`](../automatik/linux/)
- **macOS:** launchd, siehe [`automatik/macos/`](../automatik/macos/)

Beide rufen denselben Runner auf, der den Agenten headless mit dem passenden Prompt startet.
`runner.sh <lauf> --dry-run` zeigt vorher, was genau passieren wuerde: der fertige Prompt,
die Rechte, der Aufruf. Wochenreviews landen in `Tagebuch/Wochenreview/`, Gaertner-Reports
in `07-Archiv/Gaertner/`.

## Der Kalender

Bewusst **optional**. In der ersten Fassung hing der ganze Tages-Task an ihm, und als er nicht
lieferte, blieb nur das leere Formular uebrig. Jetzt gilt: ist ein Kalender angebunden,
bereichert er das Destillat. Ist keiner da, funktioniert alles trotzdem.

Wenn du einen anbindest, pruefe nach zwei Wochen stichprobenartig, ob wirklich Termine
ankommen. "Keine Termine" an fuenf Werktagen hintereinander ist ein Defekt, kein Befund.

## Grenzen

Was mit diesem Aufbau bewusst **nicht** geht - Chats aus der Web- und Mobile-App zum Beispiel -
steht in [`grenzen.md`](grenzen.md), mitsamt Begruendung und dem, was stattdessen funktioniert.
