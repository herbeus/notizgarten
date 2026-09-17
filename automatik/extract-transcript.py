#!/usr/bin/env python3
"""extract-transcript.py <transkript.jsonl> <ziel.txt> [SEIT] [BIS]

SEIT/BIS im Format "YYYY-MM-DD HH:MM:SS" (lokale Zeit): nur Nachrichten in diesem Fenster.
Eine Session-Datei kann sich ueber Tage ziehen - ohne Fenster laese der Agent Altes noch einmal.

Reduziert ein Claude-Code-Transkript auf das, was ein Leser braucht: die Eingaben des
Nutzers und die Antworten des Agenten, je Zeile mit Zeitstempel. Werkzeugaufrufe,
Dateiinhalte, Diffs und Systemmeldungen fallen weg - das sind typischerweise 95 % der Datei.

Warum das der Runner macht und nicht der Agent: Ein Agent, der 17 MB rohes JSONL liest, um
0,7 MB Text zu finden, hat sein Turn-Budget aufgebraucht, bevor er zum Denken kommt.
Portabel: nur Standardbibliothek, laeuft auf macOS-Python 3.9 und neuer.
"""
import json, sys, os
from datetime import datetime, timezone

MAX_CHARS_PER_FILE = 250_000   # Obergrenze je Datei; danach wird abgeschnitten und vermerkt

def ts_local(s):
    """ISO-Zeitstempel (UTC) -> 'YYYY-MM-DD HH:MM' in lokaler Zeit."""
    try:
        dt = datetime.fromisoformat(s.replace('Z', '+00:00'))
        return dt.astimezone().strftime('%Y-%m-%d %H:%M')
    except Exception:
        return '????-??-?? ??:??'

def text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for b in content:
            if isinstance(b, dict) and b.get('type') == 'text':
                parts.append(b.get('text', ''))
        return '\n'.join(parts)
    return ''

# Eigene Laeufe erkennen: die Prompts von Abendlese, Wochenreview und Gaertner beginnen so.
# Ein Lauf, der seine eigene Ernte als Quelle liest, dreht sich im Kreis.
OWN_RUN_MARKERS = ('Du bist der Chronist meines Second-Brain-Vaults',
                   'Du erstellst das Wochenreview fuer mein Second-Brain-Vault',
                   'Du bist der Gaertner meines Second-Brain-Vaults')

def main(src, dst, since=None, until=None):
    lines = []
    skipped = 0
    first = last = None
    for raw in open(src, encoding='utf-8', errors='replace'):
        try:
            d = json.loads(raw)
        except Exception:
            continue
        role = d.get('type')
        if role not in ('user', 'assistant'):
            continue
        t = text_of(d.get('message', {}).get('content'))
        t = t.strip()
        if not t:
            continue
        # Werkzeug-Ergebnisse tarnen sich als user-Nachricht; die haben keinen Nutzen hier
        if role == 'user' and (t.startswith('<') and t.endswith('>')):
            continue
        ts = ts_local(d.get('timestamp', ''))
        if (since and ts < since) or (until and ts > until):
            skipped += 1
            continue
        first = first or ts
        last = ts
        tag = 'USER' if role == 'user' else 'AGENT'
        if role == 'user' and any(t.startswith(m) for m in OWN_RUN_MARKERS):
            print(f'   eigener Lauf, uebersprungen: {os.path.basename(src)}')
            return
        lines.append(f'[{ts}] {tag}: {t}')
    body = '\n\n'.join(lines)
    cut = ''
    if len(body) > MAX_CHARS_PER_FILE:
        body = body[:MAX_CHARS_PER_FILE]
        cut = f'\n\n[... abgeschnitten bei {MAX_CHARS_PER_FILE} Zeichen ...]'
    header = (f'# Quelle: {src}\n'
              f'# Zeitraum: {first} bis {last}\n'
              f'# Nachrichten: {len(lines)} (ausserhalb des Zeitraums uebersprungen: {skipped})\n'
              f'# Hinweis: nur Nutzer-Eingaben und Agenten-Antworten; Werkzeugausgaben entfernt.\n\n')
    os.makedirs(os.path.dirname(dst) or '.', exist_ok=True)
    with open(dst, 'w', encoding='utf-8') as f:
        f.write(header + body + cut + '\n')
    print(f'{len(lines):5d} msgs  {first} .. {last}  {os.path.basename(dst)}')

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print(__doc__); sys.exit(2)
    since = sys.argv[3][:16] if len(sys.argv) > 3 and sys.argv[3] else None
    until = sys.argv[4][:16] if len(sys.argv) > 4 and sys.argv[4] else None
    main(sys.argv[1], sys.argv[2], since, until)
    # Leere Extrakte (nichts im Zeitraum) wieder entfernen - der Agent soll sie gar nicht sehen
    try:
        if open(sys.argv[2], encoding='utf-8').read().count('] USER:') + open(sys.argv[2], encoding='utf-8').read().count('] AGENT:') == 0:
            os.remove(sys.argv[2]); print('   leer im Zeitraum, entfernt')
    except Exception:
        pass
