# Einrichtung auf macOS

## 1. Wohin das Vault gehoert

Nutzt du iCloud fuer den Sync, gehoert das Vault in den **Obsidian-eigenen iCloud-Container**,
nicht in "iCloud Drive/Dokumente":

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/MeinVault/
```

Der Weg hat zwei Vorteile: Obsidian mobil findet das Vault dort von selbst, und der Ordner ist
von Apples Dateioptimierung ausgenommen - Notizen werden also nicht aus Platzgruenden
ausgelagert.

Nutzt du Obsidian Sync, Syncthing oder Git, ist der Ort frei waehlbar, zum Beispiel
`~/Documents/MeinVault`.

```bash
git clone <dieses-repo> ~/mega-brain
mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
cp -r ~/mega-brain/vault-template ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MeinVault
```

## 2. Obsidian

1. [Obsidian](https://obsidian.md) installieren
2. *Open folder as vault* -> den erstellten Ordner waehlen
3. Die mitgelieferte `.obsidian/`-Konfiguration ist bereits gesetzt: neue Notizen nach
   `00-Inbox`, Anhaenge nach `06-Anhaenge`, Vorlagen aus `05-Vorlagen`, Tagesnotizen nach
   `Tagebuch`
4. Community-Plugins von Hand installieren (Einstellungen -> Community plugins):
   **Dataview**, **Templater**, **Calendar**, **Smart Connections**

Ohne Dataview bleiben die Abfragen in `Home.md` als Codeblock stehen - das ist der haeufigste
"das funktioniert nicht"-Moment.

## 3. `Home.md` fuellen

Die `<< ... >>`-Leerstellen ersetzen. Lieber drei gepflegte Bereiche anlegen als sieben leere -
leere Bereichsnotizen sind genau die Sorte Struktur, die spaeter niemand benutzt.

## 4. Automatik (optional)

```bash
mkdir -p ~/.config/mega-brain
cp ~/mega-brain/automatik/config.example ~/.config/mega-brain/config
$EDITOR ~/.config/mega-brain/config      # VAULT-Pfad eintragen
~/mega-brain/automatik/macos/install.sh
```

Erst von Hand testen, bevor ein Timer laeuft:

```bash
~/mega-brain/automatik/runner.sh destillat
```

### Zwei macOS-Eigenheiten

**Festplattenvollzugriff.** Liegt das Vault in iCloud, braucht das ausfuehrende Programm die
Berechtigung *Festplattenvollzugriff* (Systemeinstellungen -> Datenschutz & Sicherheit).
Fehlt sie, scheitert der Lauf mit `Operation not permitted` - **ohne Nachfrage und ohne
Dialog**. Fuege dort Dein Terminal-Programm hinzu und starte es neu.

**Schlafender Mac.** launchd holt einen verpassten Lauf nach dem Aufwachen nach, aber nur
einmal - nicht fuer jeden ausgefallenen Tag. Bei einem Rechner, der abends zugeklappt wird,
lohnt eine fruehere Startzeit.

## 5. Pruefen

```bash
launchctl list | grep megabrain
tail -20 ~/.local/state/mega-brain/run.log
```

Nach zwei Wochen einmal nachsehen, ob tatsaechlich etwas entsteht. Laeuft die Automatik zwar,
produziert aber nichts Brauchbares, ist das ein Befund - siehe [`automatik.md`](automatik.md).

## Entfernen

```bash
~/mega-brain/automatik/macos/uninstall.sh
```
