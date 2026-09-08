---
typ: moc
erstellt: 2026-01-01
tags: [moc]
---
# Home

> Der zentrale Einstiegspunkt. Von hier springst du in alles. Halte ihn schlank.

## Schnellzugriff
- `00-Inbox` - alles Neue landet hier zuerst
- Heutige Tagesnotiz: Calendar-Plugin, oder Befehlspalette -> "today's daily note"
- << Zielnotiz verlinken, z.B. [[Ziele 2026]] >>

## Lebensbereiche
<< Fuer jeden Bereich eine Notiz in `02-Bereiche/` anlegen (Vorlage: Bereich) und hier verlinken.
   Uebliche Kandidaten: Beruf, Finanzen, Gesundheit, Beziehungen, Haushalt, Lernen, Reisen.
   Nicht alle auf einmal - lieber drei gepflegte als sieben leere. >>
- [[]]

## Wissens-MOCs
<< Landkarten, die zeigen, wie Notizen zusammenhaengen. Erst anlegen, wenn es genug
   zu verbinden gibt - eine MOC mit zwei Links ist eine Notiz. >>
- [[MOC - Arbeit]]

## Aktive Projekte
```dataview
TABLE status, deadline FROM "01-Projekte" WHERE status = "aktiv" SORT deadline ASC
```

## Zuletzt bearbeitete Notizen
```dataview
LIST FROM "03-Notizen" SORT file.mtime DESC LIMIT 10
```

## Automatik
Was regelmaessig laeuft, steht in `CLAUDE.md` und ausfuehrlich in `docs/automatik.md`
des Setup-Repos. Grundsatz: es wird geerntet, nicht auf Vorrat geschrieben.
