---
typ: review
erstellt: {{date:YYYY-MM-DD}}
tags: [review]
---
# Wochenreview - {{date:YYYY-MM-DD}}

<!--
  ANTI-WIEDERHOLUNGS-REGEL (wichtigste Regel dieses Templates):
  Ein Punkt, der seit dem letzten Review unveraendert offen ist, wird GEZAEHLT,
  nicht neu ausformuliert. Also "Inbox: 4. Review unveraendert" statt der Liste noch einmal.
  Ab dem dritten Mal nicht mehr auflisten, sondern fragen, ob es ueberhaupt noch ein Ziel ist.
  Ohne diese Regel schreibt sich ein Review wortgleich ab, bis niemand mehr hinsieht.
-->

## Vorrang diese Woche
Hoechstens drei Punkte. Was wirklich brennt, nicht was auffaellt.
- 

## Bewegung seit dem letzten Review
Was hat sich tatsaechlich geaendert - neue Notizen, abgeschlossene Projekte, Entscheidungen.
Nichts gefunden ist ein Befund, kein Grund fuer Fuellmaterial.
- 

## Unveraendert offen
Nur zaehlen, nicht ausbreiten.
| Punkt | seit | Durchgang |
|---|---|---|
|  |  |  |

## Inbox
- [ ] Jede Notiz in `00-Inbox` verschieben, verlinken oder loeschen

## Aktive Projekte
```dataview
TABLE status, deadline FROM "01-Projekte" WHERE status = "aktiv" SORT deadline ASC
```
- [ ] Naechster Schritt je Projekt klar?
- [ ] Erledigtes nach `07-Archiv` (`status: erledigt`)

## Bereiche
<!--
  Hier die eigenen Bereichsnotizen aus 02-Bereiche verlinken, sobald sie existieren.
  Bewusst leer ausgeliefert - ein Template, das auf Notizen zeigt, die es nicht gibt,
  erzeugt nur tote Links. Gibt es noch keine: Abschnitt weglassen.
-->
- [ ] 

## Ziele
<!-- Zielnotiz verlinken, sobald es eine gibt. Sonst Abschnitt weglassen. -->
- [ ] 

## Reflexion
- **Was lief gut?**
- **Was hat mich aufgehalten?**
- **Fokus naechste Woche (1-3):**

## Log
- {{date:YYYY-MM-DD}}: Review erstellt.
