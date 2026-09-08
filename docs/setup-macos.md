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
git clone <dieses-repo> ~/zettelgarten
mkdir -p ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents
cp -r ~/zettelgarten/vault-template ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MeinVault
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
mkdir -p ~/.config/zettelgarten
cp ~/zettelgarten/automatik/config.example ~/.config/zettelgarten/config
$EDITOR ~/.config/zettelgarten/config      # VAULT-Pfad eintragen
~/zettelgarten/automatik/macos/install.sh
```

Erst von Hand testen, bevor ein Timer laeuft:

```bash
~/zettelgarten/automatik/runner.sh destillat
```

### Drei macOS-Eigenheiten

**Festplattenvollzugriff (TCC).** Liegt das Vault in iCloud, braucht das ausfuehrende Programm
die Berechtigung *Festplattenvollzugriff* (Systemeinstellungen -> Datenschutz & Sicherheit).
Fehlt sie, scheitert der Zugriff mit `Operation not permitted` - **ohne Nachfrage und ohne
Dialog**, also auch ohne Hinweis darauf, was eigentlich fehlt.

Geprueft auf macOS 26.5, und die Grenze verlaeuft genau hier:

| Pfad | ohne Zusatzrechte |
|---|---|
| `~` und `~/.claude` | lesbar |
| `~/Documents`, `~/Desktop` | verweigert |
| `~/Library/Mobile Documents` (iCloud) | verweigert |

Testen laesst sich das in einem Befehl, aus dem Programm heraus, das spaeter den Lauf startet:

```bash
ls ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MeinVault
```

**Ueber SSH gibt es diese Rechte gar nicht.** Eine Anmeldung per `ssh` bekommt keine
TCC-Freigaben, unabhaengig davon, was im Terminal am Geraet erlaubt ist. Das ist beim Testen
sogar nuetzlich: Legst Du das Testvault ins Home (`~/vault-test`), kann ein Lauf ueber SSH das
echte Vault in iCloud **technisch nicht erreichen**. Sicherer als jede Absprache.

**Der Agent laeuft ueber SSH ueberhaupt nicht - und das ist keine Fehlkonfiguration.**
Claude Code legt seine Anmeldung auf macOS im **Login-Keychain** ab, nicht als Datei
(`~/.claude/.credentials.json` gibt es dort nicht). Eine SSH-Sitzung darf den Keychain nicht
entsperren; der Zugriff endet mit `User interaction is not allowed`, der Agent meldet
`Not logged in - Please run /login`, obwohl er in der grafischen Sitzung laengst angemeldet ist.

Praktische Folge, und die ist wichtig fuer den Betrieb:

| | Mechanik testen | echter Agentenlauf |
|---|---|---|
| ueber SSH | geht | **geht nicht** (Keychain) |
| Terminal am Geraet | geht | geht |
| launchd-User-Agent | geht | geht (laeuft in der grafischen Sitzung) |

Deshalb ist launchd der richtige Weg fuer den Betrieb - und deshalb muss der erste echte
Testlauf in einem Terminal-Fenster **am Mac** stattfinden, nicht aus der Ferne.
Es sind zwei getrennte Freigaben noetig: der Keychain kommt ueber die grafische Sitzung,
der iCloud-Zugriff ueber den Festplattenvollzugriff.

**Kein Homebrew, kein `timeout`.** Auf einem frischen macOS fehlen die GNU-Coreutils. Der Runner
faengt das ab und laeuft dann ohne Zeitlimit, gebremst nur durch `--max-turns`. Wer ein hartes
Limit will, installiert `coreutils` - der Runner nutzt `timeout`, sobald es da ist.

Ebenso liegt der Agent oft in `~/.local/bin` und ist im **nicht-interaktiven** PATH unsichtbar.
Der Runner ergaenzt den Pfad selbst; wer eigene Skripte baut, muss daran denken.

**Schlafender Mac.** launchd holt einen verpassten Lauf nach dem Aufwachen nach, aber nur
einmal - nicht fuer jeden ausgefallenen Tag. Bei einem Rechner, der abends zugeklappt wird,
lohnt eine fruehere Startzeit.

## 5. Erster Testlauf, ohne Risiko fuers echte Vault

Der Trick: **Quelle echt lassen, Ziel faelschen.** Das Testvault liegt im Home, das echte in
iCloud bleibt unangetastet. Am Mac, in einem Terminal-Fenster (nicht ueber SSH - siehe oben):

```bash
# 1. Testvault aus dem leeren Template
rm -rf ~/vault-test && cp -R ~/zettelgarten/vault-template ~/vault-test

# 2. Config zeigt auf das Testvault
mkdir -p ~/.config/zettelgarten ~/.local/state/zettelgarten
cat > ~/.config/zettelgarten/config <<'CONF'
VAULT="$HOME/vault-test"
PROMPT_DIR="$HOME/zettelgarten/prompts"
TRANSCRIPTS="$HOME/.claude/projects"
AGENT="claude"
LOG="$HOME/.local/state/zettelgarten/run.log"
NOTIFY=0
CONF

# 3. Lauf
~/zettelgarten/automatik/runner.sh destillat

# 4. Was ist entstanden?
find ~/vault-test -type f -newer ~/.config/zettelgarten/config
tail -20 ~/.local/state/zettelgarten/run.log
```

Erst wenn Dir gefaellt, was dabei herauskommt, zeigt die Config auf das echte Vault. Und auch
dann lohnt sich der Vergleich: Statt direkt loszulassen, einmal eine **Kopie** des echten
Vaults als Ziel nehmen und danach

```bash
diff -rq ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MeinVault ~/vault-test
```

Das zeigt genau, was der Lauf mit dem Original getan haette - bevor er es tut.

Vorher in Obsidian die **Dateiwiederherstellung** einschalten und die Aufbewahrung hochsetzen.
Das ist das Netz fuer den Tag, an dem es doch ans echte Vault geht.

## 6. Pruefen

```bash
launchctl list | grep zettelgarten
tail -20 ~/.local/state/zettelgarten/run.log
```

Nach zwei Wochen einmal nachsehen, ob tatsaechlich etwas entsteht. Laeuft die Automatik zwar,
produziert aber nichts Brauchbares, ist das ein Befund - siehe [`automatik.md`](automatik.md).

## Entfernen

```bash
~/zettelgarten/automatik/macos/uninstall.sh
```
