# Einrichtung auf Windows (und WSL)

Auf Windows gibt es eine Besonderheit: Vault und Automatik leben oft in **zwei Welten**.
Obsidian laeuft nativ unter Windows, der Agent meist in WSL. Beide meinen dieselben Dateien,
sprechen sie aber verschieden an.

## 1. Wohin das Vault gehoert

Mit **iCloud fuer Windows**:

```
C:\Users\<benutzer>\iCloudDrive\iCloud~md~obsidian\MeinVault
```

Aus WSL ist derselbe Ordner erreichbar als:

```
/mnt/c/Users/<benutzer>/iCloudDrive/iCloud~md~obsidian/MeinVault
```

Beachte, dass sich der Pfad vom Mac unterscheidet: Windows haengt das `Documents` nicht an.
Ein Vault, das auf beiden Rechnern liegt, hat also **zwei verschiedene Pfade fuer denselben
Inhalt**. Trage in der Konfiguration jeweils den lokalen ein.

Ohne iCloud tut es jeder Ordner, zum Beispiel `C:\Users\<benutzer>\Documents\MeinVault`.

```bash
# aus WSL heraus
git clone <dieses-repo> ~/zettelgarten
cp -r ~/zettelgarten/vault-template "/mnt/c/Users/<benutzer>/iCloudDrive/iCloud~md~obsidian/MeinVault"
```

## 2. Obsidian

Obsidian **fuer Windows** installieren, nicht in WSL - eine Linux-GUI in WSL bringt hier nur
Aerger mit Dateirechten und Schriftdarstellung. Dann *Open folder as vault* und den Ordner
unter `C:\` waehlen.

Community-Plugins wie ueblich: erst den eingeschraenkten Modus ausschalten, dann **Dataview**,
**Templater**, **Calendar**, **Smart Connections**. Templater braucht `05-Vorlagen` zusaetzlich
in seinen eigenen Einstellungen.

## 3. Automatik in WSL

```bash
mkdir -p ~/.config/zettelgarten
cp ~/zettelgarten/automatik/config.example ~/.config/zettelgarten/config
$EDITOR ~/.config/zettelgarten/config
```

In der Konfiguration den `/mnt/c/...`-Pfad eintragen, nicht den Windows-Pfad mit Backslashes.

```bash
~/zettelgarten/automatik/runner.sh destillat --dry-run   # Prompt und Rechte ansehen
~/zettelgarten/automatik/runner.sh destillat             # von Hand testen
~/zettelgarten/automatik/linux/install.sh                # dann Timer einrichten
```

Der Klon darf auch woanders liegen; `install.sh` traegt den echten Pfad in die Units ein.

### WSL-Eigenheiten

**systemd muss an sein.** Ohne systemd gibt es keine User-Timer. Pruefen mit
`systemctl --user list-timers`. Fehlt es, in `/etc/wsl.conf` ergaenzen und WSL neu starten:

```ini
[boot]
systemd=true
```

```powershell
wsl --shutdown
```

**Die WSL laeuft nicht durch.** Wird kein WSL-Fenster geoeffnet, laeuft auch kein Timer.
`Persistent=true` in den mitgelieferten Units sorgt dafuer, dass ein verpasster Lauf beim
naechsten Start nachgeholt wird - aber nur einer, nicht jeder ausgefallene Tag. Wer WSL nur
sporadisch oeffnet, sollte den Lauf besser von Hand anstossen.

**Dateizugriff ueber `/mnt/c` ist langsam.** Fuer ein Vault mit einigen hundert Notizen ist das
egal. Faellt es doch auf, hilft ein Lauf mit engerem Suchraum statt eines Umzugs.

**Benachrichtigungen** laufen ueber die Windows-Seite; `notify.sh` erkennt WSL selbst und ruft
PowerShell auf. Verpasste Toasts stehen im Info-Center.

## 4. Pruefen

```bash
systemctl --user list-timers 'zettelgarten-*'
tail -20 ~/.local/state/zettelgarten/run.log
```

## Ohne WSL

Geht auch: Der Runner ist ein Bash-Skript und laeuft unter Git Bash. Statt systemd nimmt man
dann die **Aufgabenplanung** von Windows und laesst sie
`"C:\Program Files\Git\bin\bash.exe" -lc "~/zettelgarten/automatik/runner.sh destillat"`
ausfuehren. Getestet ist dieser Weg hier nicht - die Timer-Units sind der gepflegte Pfad.
