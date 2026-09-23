# Mac Minis im Labor 016a: Ollama

Mit diesem Setup läuft auf den zehn Mac Minis Ollama als Dienst. Die n8n-Instanzen auf meinem HdM-Server (kirenz.iuk.hdm-stuttgart.de) greifen darauf zu, damit wir in den Projekten mit vertraulichen Daten lokal arbeiten können.

## Was eingerichtet wird

- Ollama über Homebrew, als LaunchDaemon (`de.hdm.ollama`). Er läuft auch ohne angemeldeten Nutzer und startet nach Updates und Neustarts von selbst.
- Die Modelle `qwen3.6:35b-a3b`, `gemma4:31b` und `qwen3-embedding:0.6b` in `/Users/Shared/ai-models/ollama` (zusammen ca. 44 GB).
- Ollama ist auf Port 11434 erreichbar. Ein Modell wird nach 30 Minuten ohne Anfrage aus dem Speicher entladen, damit die Gruppen im Labor davon nichts merken.
- Falls noch die alte Ollama.app installiert ist, wird sie entfernt, weil sie denselben Port belegt. Die Modelle bleiben erhalten.

## Was du vorher brauchst

- SSH-Zugriff auf die Minis (HdM-Netz oder VPN) mit einem Admin-Konto, das sudo darf.
- Homebrew auf den Minis, installiert mit genau diesem Konto.
- Port 11434 bitte nur für meinen HdM-Server freigeben, Ollama hat selbst keine Zugangskontrolle.

## Einrichten

1. Repo klonen:

   ```bash
   git clone https://github.com/kirenz/mac-minis-setup.git && cd mac-minis-setup
   ```

2. In `ansible/inventory.ini` die Hostnamen und das Konto eintragen.

3. Skript starten:

   ```bash
   ./setup.sh
   ```

Das Skript installiert bei Bedarf Ansible, prüft die Verbindung zu allen Minis, fragt einmal nach dem sudo-Passwort und richtet zuerst mini01 ein. Danach zeigt es dir den Status. Wenn der passt, bestätigst du, und es macht mit den restlichen Minis weiter.

Du kannst das Skript jederzeit noch mal laufen lassen, es ändert nur, was fehlt.

## Später

Status aller Minis:

```bash
cd ansible && ansible-playbook status.yml
```

Für ein anderes Modell die Liste `ollama_models` in `ansible/group_vars/minis.yml` anpassen und `./setup.sh` erneut starten.

Die alte Anleitung für die manuelle Einrichtung der Data-Science-Tools steht in [manuelle-einrichtung.md](manuelle-einrichtung.md).
