# Mac Minis im Labor 016a: Ollama

Mit diesem Setup läuft auf den Mac Minis Ollama als Dienst. Wir nutzen es für zwei Dinge:

- **KI in der Verwaltung:** Die n8n-Instanzen auf der VM `ki-in-der-verwaltung` nutzen zwei Minis im Dauerbetrieb, damit vertrauliche Daten im Haus bleiben.
- **Demo zur International Week (24.11.2026):** KI-Agenten erstellen auf mehreren Minis live Texte und ein Kampagnenbild.

## Was eingerichtet wird

- Ollama über Homebrew, als LaunchDaemon (`de.hdm.ollama`). Er läuft auch ohne angemeldeten Nutzer und startet nach Updates und Neustarts von selbst.
- Die Sprachmodelle `qwen3.8:27b`, `qwen3.6:35b-a3b` und `qwen3-embedding:0.6b` sowie das Bildmodell `x/z-image-turbo` in `/Users/Shared/ai-models/ollama`. Die Bilderzeugung ist in Ollama auf dem Mac noch experimentell.
- Ollama ist auf Port 11434 erreichbar. Ein Modell wird nach 30 Minuten ohne Anfrage aus dem Speicher entladen, damit die Gruppen im Labor davon nichts merken.
- Auf den Minis in der Gruppe `dauerbetrieb` (in `ansible/inventory.ini`) wird der Ruhezustand ausgeschaltet. Nach einem Stromausfall starten sie neu.
- Falls noch die alte Ollama.app installiert ist, wird sie entfernt, weil sie denselben Port belegt. Die Modelle bleiben erhalten.

## Was du vorher brauchst

- SSH-Zugriff auf die Minis (HdM-Netz oder VPN) mit einem Admin-Konto, das sudo darf. Das braucht es nur für die Einrichtung.
- Homebrew auf den Minis, installiert mit genau diesem Konto.
- Ollama hat selbst keine Zugangskontrolle. Deshalb bitte Port 11434 einschränken:
  - Minis im Dauerbetrieb: nur für die VM `ki-in-der-verwaltung` (141.62.116.2)
  - alle anderen Minis: nur im Labornetz

Für spätere neue Modelle reicht ein normales Konto ohne Admin-Rechte. `ollama pull` lädt über den laufenden Dienst, dafür braucht es kein sudo.

## Einrichten

1. Repo klonen:

   ```bash
   git clone https://github.com/kirenz/mac-minis-setup.git && cd mac-minis-setup
   ```

2. In `ansible/inventory.ini` die Hostnamen und das Konto eintragen. Unter `[dauerbetrieb]` stehen die beiden Minis für die VM, bei Bedarf andere eintragen.

3. Skript starten:

   ```bash
   ./setup.sh
   ```

Das Skript installiert bei Bedarf Ansible, prüft die Verbindung zu allen Minis, fragt einmal nach dem sudo-Passwort und richtet zuerst mini01 ein. Danach zeigt es dir den Status. Wenn der passt, bestätigst du, und es macht mit den restlichen Minis weiter.

Du kannst das Skript jederzeit noch mal laufen lassen, es ändert nur, was fehlt.

## Später

Status aller Minis (Dienst, Modelle, Ruhezustand):

```bash
cd ansible && ansible-playbook status.yml
```

Für ein anderes Modell die Liste `ollama_models` in `ansible/group_vars/minis.yml` anpassen und `./setup.sh` erneut starten.

Die alte Anleitung für die manuelle Einrichtung der Data-Science-Tools steht in [manuelle-einrichtung.md](manuelle-einrichtung.md).
