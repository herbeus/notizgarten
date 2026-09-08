# Agent-Betrieb

Wie die `CLAUDE.md` im Vault-Root funktioniert und wie man sie anpasst.

## Was diese Datei ist

Eine Betriebsanleitung, die ein Agent beim Betreten des Ordners liest. Sie ist der Unterschied
zwischen einem Agenten, der Dein Vault **liest**, und einem, der es **pflegt**.

Ohne sie passiert Folgendes: Der Agent beantwortet Deine Frage aus dem, was er gerade findet,
und legt nichts ab. Beim naechsten Mal faengt er von vorne an. Das Vault waechst nicht mit.

Mit ihr weiss er, wo etwas hingehoert, in welchem Format, was er nicht anfassen darf - und
vor allem, wann er **nichts** tun soll.

## Warum sie im Vault liegt, nicht im Setup-Repo

Damit sie mit dem Vault reist. Wer den Ordner verbindet, bekommt die Regeln mit, ohne dass
jemand daran denken muss. Und ein Agent, der im Vault arbeitet, findet sie dort von selbst -
so wie eine README im Repo.

## Die drei Regeln, die schwerer wiegen als der Rest

Sie stehen ganz oben in der Datei, und das ist Absicht:

**A. Schreibe nichts Leeres.** Nie eine Notiz anlegen, nur weil ein Zeitplan es sagt.
**B. Wiederhole nichts, was schon dasteht.** Unveraendertes wird gezaehlt, nicht ausgebreitet.
**C. Ernte, statt Formulare zu verteilen.** Rueckblickend arbeiten.

Diese drei sind nicht theoretisch. Sie sind die Antwort auf einen konkret gescheiterten ersten
Versuch - 32 leere Tagesnotizen und vier Reviews, die sich selbst abschrieben. Die Geschichte
steht in [`automatik.md`](automatik.md). Wer sie streicht, baut den Fehler nach.

## Was Du anpassen musst

In der ausgelieferten Fassung sind zwei Stellen mit `<< ... >>` markiert:

**Berufliche Konventionen.** Branch- und Commit-Format, Review-Ablauf, Sprache, was ohne
Rueckfrage passieren darf. Trage sie ein - oder besser: schreibe sie in **eine** Notiz und
verlinke sie von hier. Zwei ausformulierte Fassungen laufen garantiert auseinander.

**Der Name der Arbeits-MOC.** `MOC - Arbeit` ist ein Platzhalter. Benennst Du sie um, ziehe
die Verweise in `CLAUDE.md` und den `.info.md`-Dateien nach.

## Was Du ergaenzen kannst

- **Ansprache und Ton.** Manche wollen knappe Stichpunkte, andere ganze Saetze.
- **Sprache.** Die Vorlage ist deutsch. Wenn Notizen deutsch, Code aber englisch sein soll,
  schreib genau das hinein.
- **Zeichenkonventionen.** Wenn Du bestimmte Sonderzeichen nicht magst - Gedankenstriche,
  typografische Pfeile - schreib es hin. Ein Agent haelt sich daran, aber nur wenn er es weiss.
- **Wiederkehrende Fragen.** Beantwortest Du dem Agenten dieselbe Frage zum dritten Mal,
  gehoert die Antwort in die Datei.

## Was Du nicht hineinschreiben solltest

- **Zugangsdaten.** Nie, auch nicht als Beispiel. Siehe [`sicherheit.md`](sicherheit.md).
- **Inhalte.** Die Datei ist eine Anleitung, kein Wissensspeicher. Wissen gehoert in Notizen.
- **Regeln, die anderswo schon stehen.** Verweisen statt kopieren.

## Wie Du merkst, dass sie wirkt

Ein guter Test nach ein paar Wochen: Frag den Agenten etwas, das er nur aus dem Vault wissen
kann, und sieh nach, ob er danach **von selbst** eine Notiz anlegt oder ergaenzt. Tut er das
nicht, wird die Datei entweder nicht gelesen, oder Regel 2 steht zu vage darin.

Zweiter Test: Lass einen Destillat-Lauf an einem Tag laufen, an dem nichts passiert ist. Legt
er trotzdem eine Datei an, ist Regel A nicht deutlich genug.

## Andere Agenten

Die Datei heisst `CLAUDE.md`, weil Claude Code sie unter diesem Namen automatisch liest.
Andere Werkzeuge erwarten andere Namen. Statt den Inhalt zu kopieren - was zu zwei Fassungen
fuehrt - lege einen Symlink an:

```bash
cd /pfad/zum/vault
ln -s CLAUDE.md AGENTS.md
```

So bleibt es eine Datei mit mehreren Namen.
