# Mobil: Capture unterwegs

Der wichtigste Ordner unterwegs ist `00-Inbox`, und der wichtigste Satz aus dem Konzept ist:
**unter zehn Sekunden, oder es passiert nicht.**

Dieses Kapitel hat mehr Gewicht, als es zunaechst scheint. In der ersten Fassung dieses Setups
blieb das Feld "Schnell-Capture" in **allen 32 Tagesnotizen leer** - nicht, weil es nichts zu
notieren gab, sondern weil zum Zeitpunkt des Gedankens kein Weg ins Vault fuehrte. Der Gedanke
landete stattdessen in einer Chat-App, einer Notiz-App, einer Mail an sich selbst.

## Obsidian mobil

Liegt das Vault in einem Cloud-Ordner, holt die App es ohne weiteres Zutun:

- **iOS/iPadOS mit iCloud:** Obsidian aus dem App Store, beim ersten Start
  *"Vault aus iCloud"* waehlen. Vaults im Obsidian-eigenen iCloud-Container tauchen dort von
  selbst auf - das ist der Grund fuer den Pfad in [`setup-macos.md`](setup-macos.md).
- **Android:** iCloud faellt aus. Hier funktionieren Obsidian Sync, Syncthing oder ein
  Git-basierter Sync.

Erster Sync dauert einen Moment, danach laeuft es im Hintergrund.

## Damit es wirklich unter zehn Sekunden bleibt

- **Widget auf den Homescreen.** Obsidian bringt eines mit, das direkt eine neue Notiz oeffnet.
- **Kurzbefehl / Shortcut.** Auf iOS laesst sich ein Kurzbefehl bauen, der Text an eine Datei
  in `00-Inbox` anhaengt - ohne die App sichtbar zu oeffnen. Auf die Rueckseite des Geraets
  legen oder ins Kontrollzentrum.
- **Teilen-Menue.** Ein Link, der spaeter interessant wird, geht per Teilen direkt nach
  `00-Inbox`.
- **Diktieren statt tippen.** Unterwegs ist Sprache schneller. Rechtschreibung ist egal - die
  Notiz wird ohnehin beim Wochenreview angefasst.

## Was mobil nicht funktioniert

**Die Automatik.** Die Laeufe brauchen eine Kommandozeile und laufen nur auf einem Rechner.
Das ist kein Mangel: Destillieren gehoert an den Schreibtisch, Capture ans Handy.

**Chats aus der Mobile-App landen nicht automatisch im Vault.** Ausfuehrlich mit Begruendung
in [`grenzen.md`](grenzen.md). Kurz: Ein Connector verbindet sich aus der Cloud des Anbieters
zu einem Server im Internet, nicht zu einer App auf Deinem Geraet - und die Sandbox mobiler
Betriebssysteme verbietet den Zugriff ohnehin.

Praktische Konsequenz: **Was Du festhalten willst, schreibst Du direkt in Obsidian, nicht in
einen Chat.** Ein Chat auf dem Handy ist oft Capture, das im falschen System landet - und dort
bleibt es dann auch.

## Konflikte

Cloud-Sync und zwei Geraete, die dieselbe Notiz anfassen, erzeugen gelegentlich Konfliktkopien.
Damit das selten passiert:

- Auf dem Handy moeglichst **neue** Notizen anlegen statt bestehende zu bearbeiten.
- Die App schliessen, bevor Du am Rechner weiterarbeitest - der Sync braucht einen Moment.
- Dateiwiederherstellung in Obsidian einschalten (Einstellungen -> Dateiwiederherstellung),
  dann ist ein Fehlgriff reparierbar.
