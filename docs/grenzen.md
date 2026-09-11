# Grenzen

Was mit diesem Aufbau bewusst nicht geht, warum, und was stattdessen funktioniert.

Dieses Kapitel ist absichtlich da. Ein Setup-Repo, das nur den Erfolgspfad zeigt, laesst dich
Stunden in Sackgassen laufen, die jemand vor dir schon abgeschritten hat.

## Chats aus der Web- und Mobile-App landen nicht automatisch im Vault

Das Abendlese liest **lokale** Transkripte - die Dateien, die ein Agent auf deinem Rechner
ablegt. Gespraeche, die du im Browser oder auf dem Handy fuehrst, liegen serverseitig und sind
davon nicht erfasst.

### Warum kein Connector hilft

Naheliegender Gedanke: einen Connector einrichten, der die Notiz-App auf dem Handy erreicht.
Das geht nicht, und zwar aus einem strukturellen Grund:

Ein Connector verbindet sich **nicht mit Apps auf deinem Geraet**. Er wird **aus der Cloud des
Anbieters heraus zu einem Server im Internet** aufgebaut. Die Notiz-App auf deinem Handy ist
kein Server im Internet. Dazu kommt die Sandbox mobiler Betriebssysteme: keine App liest den
Datencontainer einer anderen.

Das ist keine Luecke, die noch geschlossen wird. Der Weg existiert nicht.

### Warum ein eigener MCP-Server das Problem nur verschiebt

Ein selbst gebauter Remote-MCP-Server laesst sich als Connector einbinden und funktioniert auch
in der Mobile-App. Bedingung: er muss **aus dem oeffentlichen Internet erreichbar** sein - hinter
VPN oder Firewall geht es nicht. Und er braucht Zugriff auf die Vault-Dateien. Damit stellt sich
sofort die Frage, wo er laeuft und woher er das Vault kennt:

| Weg | Verfuegbarkeit | Preis |
|---|---|---|
| Vault als Git-Repo statt Cloud-Sync, Server klont es | 24/7 | Sync-Modell umbauen, Merge-Konflikte auf dem Handy, Vault liegt auf einem Remote |
| Server auf dem eigenen Rechner plus Tunnel | nur wenn der Rechner laeuft | nachts aus, also Gespraech verloren |
| Kleiner Dauerlaeufer (VPS, Einplatinenrechner) | 24/7 | das Vault muss trotzdem dorthin, also zurueck zu Zeile eins |

**Der eigentliche Blocker ist der Sync, nicht das Protokoll.** Liegt dein Vault in einem
Hersteller-Cloud-Container ohne offene API, kann ein Server im Internet es schlicht nicht sehen.
Jeder Weg beginnt damit, den Sync umzubauen.

Und in allen Faellen steht am Ende ein oeffentlich erreichbarer Endpunkt mit **Schreibzugriff auf
ein Vault**, in dem Gesundheit, Finanzen und Namen von Angehoerigen stehen. Absicherbar, ja.
Aber es ist echte Angriffsflaeche fuer einen Komfortgewinn.

### Der Datenexport als Ausweg - und warum er selten getragen wird

Anbieter bieten in der Regel einen Datenexport aus den Kontoeinstellungen an. Der ist
kontobezogen, umfasst also auch die Gespraeche vom Handy. Die Praxis dagegen:

- auszuloesen nur am Rechner, nicht mobil
- Download-Link kommt per Mail und laeuft nach kurzer Zeit ab
- **kein Trigger per Schnittstelle** - das Ausloesen bleibt Handarbeit
- der Export ist **immer vollstaendig, nie inkrementell**. Ohne einen Stand-Marker mit den
  bereits verarbeiteten Gespraechen destilliert der Agent beim zweiten Mal alles noch einmal -
  und du hast exakt die Wiederholung zurueck, gegen die Regel B geschrieben wurde
- der Export enthaelt **alles**, auch die Gespraeche ueber Gesundheit und Geld. Die Datei darf
  nicht in einem gesyncten Ordner liegen bleiben

Machbar ist das. Aber ein monatlicher Handgriff mit Mail, Download, Entpacken und Aufraeumen
wird nach dem zweiten Mal nicht mehr gemacht. Das ist dieselbe Sorte Bringschuld, die schon die
leeren Tagesnotizen erledigt hat.

### Was stattdessen funktioniert

**Fuer Capture unterwegs: Obsidian mobil.** Liegt das Vault in einem Cloud-Ordner, holt die
mobile App es ohne weiteres Zutun. Der Gedanke landet dann **direkt in `00-Inbox`** - kein Chat,
kein Export, kein Server, kein Connector.

Das schliesst nebenbei genau die Luecke, die in allen 32 leeren Tagesnotizen sichtbar war:
"Schnell-Capture" blieb leer, weil zum Zeitpunkt des Gedankens kein Weg ins Vault fuehrte.
Ein Chat auf dem Handy ist oft Capture, das im falschen System landet.

**Fuer alles andere: die lokalen Sessions.** Dort entsteht ohnehin die Substanz, und dort
funktioniert die Automatik vollstaendig.

**Die ehrliche Empfehlung:** diese Grenze annehmen. Der Aufwand fuer die Alternativen steht in
keinem Verhaeltnis zum Ertrag, und jede davon oeffnet ein Sicherheitsthema.

## Kein automatischer Zugriff auf Kalender ohne Anbindung

Siehe [`automatik.md`](automatik.md), Abschnitt "Der Kalender". Kurz: optional halten, nie zur
tragenden Saeule machen, und nach zwei Wochen pruefen, ob wirklich Daten ankommen.

## Der Agent aendert nichts eigenmaechtig

Loeschen und Verschieben bleiben menschliche Entscheidungen. Der Gaertner meldet nur. Das ist
keine technische Grenze, sondern eine gewollte: ein Vault, dem du nicht mehr traust, weil Dinge
verschwinden, ist wertlos.

## Zwei Wahrheiten fuer dieselbe Regel

Wenn du Konventionen sowohl im Vault als auch anderswo ausformulierst - in einem Konfig-Repo,
einer Team-Doku, einer zweiten Notiz - laufen die Fassungen auseinander. Nicht vielleicht,
sondern sicher, und du merkst es erst, wenn du der falschen folgst.

Formuliere jede Regel an **genau einer** Stelle aus und verlinke von ueberall sonst dorthin.
Die Vorlagen in diesem Repo sind entsprechend gebaut: `CLAUDE.md` und `MOC - Arbeit` haben an
den betreffenden Stellen eine Leerstelle mit Verweis statt einer Kopie.
