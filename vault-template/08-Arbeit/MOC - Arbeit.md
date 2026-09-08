---
typ: moc
erstellt: 2026-01-01
tags: [moc, beruf]
---
# MOC - Arbeit

> Landkarte des beruflichen Asts. Kuratieren, nicht alles auflisten.
> Benenne diese Notiz gerne um (z.B. "MOC - <Firma oder Team>") und passe die Links in
> `CLAUDE.md` und den `.info.md`-Dateien an.

## Kontext
<< Wer, was, welches Umfeld. Zwei bis drei Saetze, damit ein Agent den Rahmen kennt. >>

## Konventionen
<< Auf die eine Notiz verlinken, in der die Arbeitskonventionen ausformuliert sind.
   Wichtig: nur an EINER Stelle ausformulieren, sonst laufen die Fassungen auseinander. >>
- [[]]

## Laufende Projekte
```dataview
TABLE status, deadline FROM "08-Arbeit/Projekte" WHERE status = "aktiv" SORT deadline ASC
```

## Wissen
```dataview
LIST FROM "08-Arbeit/Wissen" SORT file.mtime DESC LIMIT 15
```
