#!/usr/bin/env bash
# notify.sh <titel> <nachricht> - Benachrichtigung auf dem jeweiligen System.
#
# Erkennt macOS, WSL und Linux mit Desktop. Findet sich kein Weg, ist das kein Fehler:
# der Lauf steht ohnehin im Log.
#
# Uebergabe ueber Umgebungsvariablen statt String-Interpolation - sonst laesst sich ueber eine
# Nachricht mit Anfuehrungszeichen fremder Code in AppleScript oder PowerShell einschleusen.
set -u

export MB_TITLE="${1:-Mega Brain}"
export MB_MSG="${2:-}"

case "$(uname -s)" in
  Darwin)
    /usr/bin/osascript -e 'display notification (system attribute "MB_MSG") with title (system attribute "MB_TITLE")' >/dev/null 2>&1
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      # WSL: Toast ueber die Windows-Seite. WSLENV reicht die Variablen hinueber.
      export WSLENV="${WSLENV:+$WSLENV:}MB_TITLE/w:MB_MSG/w"
      PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
      [ -x "$PS" ] && "$PS" -NoProfile -Command '
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
$x=[Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02)
$t=$x.GetElementsByTagName("text")
$t.Item(0).InnerText=$env:MB_TITLE
$t.Item(1).InnerText=$env:MB_MSG
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("mega-brain").Show([Windows.UI.Notifications.ToastNotification]::new($x))
' >/dev/null 2>&1
    else
      command -v notify-send >/dev/null 2>&1 && notify-send "$MB_TITLE" "$MB_MSG" >/dev/null 2>&1
    fi
    ;;
esac

exit 0
