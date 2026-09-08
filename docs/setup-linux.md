# Einrichtung auf Linux

Linux ist der einfachste Fall: keine TCC-Freigaben, kein Keychain, GNU-coreutils sind da.
Die Timer laufen als systemd-User-Units. WSL ist ein Sonderfall und steht in
[`setup-windows.md`](setup-windows.md).

## 1. Wohin das Vault gehoert

Ein beliebiger Ordner im Home, zum Beispiel `~/MeinVault`. iCloud gibt es hier nicht; fuer
mehrere Geraete bleiben **Obsidian Sync**, **Syncthing** oder ein **Git-Repo**. Syncthing ist der
uebliche Weg zu Android.

```bash
git clone <dieses-repo> ~/zettelgarten
cp -r ~/zettelgarten/vault-template ~/MeinVault
```

Der Klon muss nicht in `~/zettelgarten` liegen; `install.sh` traegt den echten Pfad ein.

## 2. Obsidian

1. [Obsidian](https://obsidian.md) installieren: AppImage, `.deb`, Snap oder Flatpak.
   **Flatpak:** die Sandbox sieht standardmaessig nur das Home. Liegt das Vault woanders
   (zweite Platte, `/srv`), den Pfad mit Flatseal oder `flatpak override --filesystem=...`
   freigeben, sonst findet Obsidian den Ordner nicht.
2. *Open folder as vault* -> `~/MeinVault`
3. Die mitgelieferte `.obsidian/`-Konfiguration ist bereits gesetzt: neue Notizen nach
   `00-Inbox`, Anhaenge nach `06-Anhaenge`, Vorlagen aus `05-Vorlagen`, Tagesnotizen nach
   `Tagebuch`
4. Community-Plugins von Hand installieren (Einstellungen -> Community plugins). Ein frisches
   Vault startet im **eingeschraenkten Modus** - den zuerst ausschalten. Dann **Dataview**,
   **Templater**, **Calendar**, **Smart Connections**.
5. Templater braucht `05-Vorlagen` zusaetzlich in seinen **eigenen** Einstellungen; die
   mitgelieferte Konfiguration deckt nur das Core-Plugin ab.

## 3. `Home.md` fuellen

Die `<< ... >>`-Leerstellen ersetzen. Lieber drei gepflegte Bereiche als sieben leere.

## 4. Automatik (optional)

```bash
mkdir -p ~/.config/zettelgarten
cp ~/zettelgarten/automatik/config.example ~/.config/zettelgarten/config
$EDITOR ~/.config/zettelgarten/config      # VAULT-Pfad eintragen
```

Erst ansehen, dann von Hand testen, dann Timer:

```bash
~/zettelgarten/automatik/runner.sh destillat --dry-run   # Prompt, Rechte, Aufruf - startet nichts
~/zettelgarten/automatik/runner.sh destillat
~/zettelgarten/automatik/linux/install.sh
```

### Drei Linux-Eigenheiten

**Der Agent laeuft headless, auch ohne Keychain.** Claude Code legt seine Anmeldung unter
Linux als Datei ab (`~/.claude/.credentials.json`). Ein Timer-Lauf findet sie ohne grafische
Sitzung - anders als auf dem Mac. Ueber SSH testen geht deshalb hier.

**Timer laufen nur, solange dein User-Manager laeuft.** Der startet mit der Anmeldung und
endet mit der Abmeldung. Auf einem Rechner, an dem du abends abgemeldet bist, bleibt der
Destillat-Lauf aus. Abhilfe:

```bash
loginctl enable-linger "$USER"
```

Dann laeuft der User-Manager ab dem Boot, unabhaengig von der Anmeldung. `Persistent=true` in
den Units holt einen verpassten Lauf beim naechsten Start nach - aber nur einen, nicht jeden
ausgefallenen Tag.

**Benachrichtigungen brauchen die Desktop-Sitzung.** `notify.sh` ruft `notify-send`, und das
braucht die D-Bus-Adresse der Sitzung. Moderne Desktops reichen sie an den User-Manager
weiter; fehlt sie, kommt keine Meldung, aber der Lauf steht trotzdem im Log. Pruefen:

```bash
systemctl --user show-environment | grep DBUS_SESSION_BUS_ADDRESS
```

Fehlt die Zeile, in der Sitzung einmal `systemctl --user import-environment DBUS_SESSION_BUS_ADDRESS`
ausfuehren, oder `NOTIFY=0` setzen und aufs Log vertrauen.

## 5. Erster Testlauf, ohne Risiko fuers echte Vault

Quelle echt lassen, Ziel faelschen:

```bash
rm -rf ~/vault-test && cp -r ~/zettelgarten/vault-template ~/vault-test
mkdir -p ~/.config/zettelgarten ~/.local/state/zettelgarten
cat > ~/.config/zettelgarten/config <<'CONF'
VAULT="$HOME/vault-test"
TRANSCRIPTS="$HOME/.claude/projects"
LOG="$HOME/.local/state/zettelgarten/run.log"
NOTIFY=0
CONF
~/zettelgarten/automatik/runner.sh destillat
find ~/vault-test -type f -newer ~/.config/zettelgarten/config
tail -20 ~/.local/state/zettelgarten/run.log
```

Erst wenn Dir gefaellt, was dabei herauskommt, zeigt die Config auf das echte Vault. Vorher in
Obsidian die **Dateiwiederherstellung** einschalten.

## 6. Pruefen

```bash
systemctl --user list-timers 'zettelgarten-*'
journalctl --user -u zettelgarten-destillat.service -n 30
tail -20 ~/.local/state/zettelgarten/run.log
```

Nach zwei Wochen einmal nachsehen, ob tatsaechlich etwas entsteht. Laeuft die Automatik zwar,
produziert aber nichts Brauchbares, ist das ein Befund - siehe [`automatik.md`](automatik.md).

## Entfernen

```bash
~/zettelgarten/automatik/linux/uninstall.sh
```
