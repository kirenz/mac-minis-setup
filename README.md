# Mac Minis im Labor 016a: Ollama

Mit diesem Setup laufen lokale KI-Modelle (Ollama) auf den Mac Minis im Labor 016a. Wir nutzen sie für zwei Dinge:

- **Projekt KI in der Verwaltung (bis Februar 2027):** Die n8n-Instanzen auf der VM `ki-in-der-verwaltung` nutzen zwei Minis im Dauerbetrieb. Es ist eine Evaluation im Studierendenprojekt mit Mock-Daten, keine Produktivumgebung und keine echten Verwaltungs- oder Personendaten.
- **Demo zur International Week (24.11.2026):** KI-Agenten erstellen auf sechs Minis live Texte und ein Kampagnenbild. Dabei werden nur öffentliche Infos über die HdM verwendet.

## Wer macht was

- **IT:** Einrichtung, Updates und Rückbau mit dem Admin-Konto. Nur dafür braucht es Admin-Rechte.
- **Jan:** ein normales Konto mit SSH, ohne Admin-Rechte. Damit lädt er bei Bedarf neue Modelle nach und hält die Minis am Demotag wach.

## Was eingerichtet wird

- **Ollama** über Homebrew, als LaunchDaemon (`de.hdm.ollama`). Er läuft unter dem eigenen Dienstkonto `_ollama` ohne Login und ohne Admin-Rechte, auch ohne angemeldeten Nutzer und nach Neustarts. Ollama ist nur lokal auf dem Mini erreichbar (`127.0.0.1:11434`), die Cloud-Funktionen von Ollama sind ausgeschaltet.
- **Proxy mit Zugangstoken** (Caddy, LaunchDaemon `de.hdm.ollama-proxy`) auf Port 11435. Von außen geht jede Anfrage über diesen Proxy:
  - ohne gültiges Token: abgewiesen (401)
  - Modelle laden, löschen oder verändern: über das Netz immer gesperrt (403), auch mit Token
- **Modelle** in `/Users/Shared/ai-models/ollama`, beschreibbar nur für das Dienstkonto:
  - Dauerbetrieb (mini01, mini02): `qwen3.8:27b` und `qwen3-embedding:0.6b`, zusammen ca. 19 GB
  - alle anderen: zusätzlich `qwen3.6:35b-a3b` und das Bildmodell `x/z-image-turbo` (in Ollama auf dem Mac noch experimentell), zusammen ca. 55 GB
- **Speicher:** Auf den Labor-Minis ist immer nur ein Modell geladen. Nach 30 Minuten ohne Anfrage gibt Ollama den Speicher wieder frei.
- **Dauerbetrieb:** Auf mini01 und mini02 wird der Ruhezustand ausgeschaltet, nach einem Stromausfall starten sie neu. Die bisherigen Einstellungen werden vorher gesichert.
- **Logs** in `/var/log/ollama.log` und `/var/log/ollama-proxy.log`, mit Rotation.
- Eine alte Ollama.app wird entfernt, weil sie denselben Port belegt.

## Netzwerk (bitte auf IT-Seite einstellen)

Das Token schützt den Proxy. Zusätzlich empfehle ich, den Zugriff im Netz einzuschränken:

- **mini01 und mini02:** Port 11435 nur von der VM `ki-in-der-verwaltung` (141.62.116.2) erreichbar. Dafür braucht es eine Freigabe vom Netz der VM ins Labornetz, nur für diesen Port.
- **alle anderen Minis:** Port 11435 nur aus dem Labornetz.
- Die macOS-Firewall kann nicht nach Absender-IP filtern. Die Regel gehört also an Switch oder Router, oder in den Paketfilter (`pf`) des Macs.

Ollama selbst (Port 11434) ist von außen gar nicht erreichbar. Wer direkt an einem Mini angemeldet ist, kann Ollama lokal nutzen. Auf den Labor-Minis gilt das auch für Studierende. Das ist für die Evaluation vertretbar, weil auf den Minis keine Daten liegen und ein erneuter Lauf von `./setup.sh` den Sollzustand wiederherstellt.

## Was du vorher brauchst

- SSH-Zugriff auf die Minis (HdM-Netz oder VPN) mit einem Admin-Konto, das sudo darf.
- Homebrew auf den Minis, installiert mit genau diesem Konto.
- Auf jedem Mini mindestens ca. 70 GB freien Platz (Modelle plus Reserve). `status.yml` zeigt den freien Platz an.

## Einrichten

1. Repo klonen:

   ```bash
   git clone https://github.com/kirenz/mac-minis-setup.git && cd mac-minis-setup
   ```

2. In `ansible/inventory.ini` die Hostnamen und das Konto eintragen. Unter `[dauerbetrieb]` stehen die zwei Minis für die VM, unter `[demo]` die sechs für die Demo. Bei Bedarf andere Geräte eintragen.

3. Skript starten:

   ```bash
   ./setup.sh
   ```

Das Skript erzeugt beim ersten Lauf das Zugangstoken in `ansible/proxy-token`. Dann prüft es die Verbindung, fragt einmal nach dem sudo-Passwort und richtet zuerst einen Mini ein. Danach zeigt es den Status und bietet einen Abnahmetest an. Er erzeugt über den Proxy einen Text, ein Embedding und ein Bild und prüft die Sperren. Wenn alles passt, bestätigst du, und es macht mit den restlichen Minis weiter.

Das Skript kann jederzeit erneut laufen. Es ändert nur, was fehlt. Ollama und Caddy werden dabei nicht aktualisiert.

4. Das Token aus `ansible/proxy-token` bitte auf einem sicheren Weg an Jan schicken, nicht per Mail im Klartext. Es gehört nicht ins Repo.

## In n8n nutzen

- Credential „Ollama“ mit Base URL `http://<mini01>:11435` und dem Token im Feld „API Key“. Alle Ollama-Knoten in n8n (geprüft mit 2.42.6) schicken es als Bearer-Token mit.
- Für die VM `ki-in-der-verwaltung` legt `import-ollama-credential.sh` im Repo `ki-verwaltung-server` die Credentials an, `ollama-check.sh` prüft den Weg.
- Alternative: Credential „OpenAI“ mit Base URL `http://<mini01>:11435/v1` und dem Token als API-Key
- Bilder gibt es nur über `POST /v1/images/generations`, nicht über `/api/generate`

## Später

Status aller Minis (Dienst, Dienstkonto, Proxy, Modelle, Ruhezustand, Platte):

```bash
cd ansible && ansible-playbook status.yml --ask-become-pass
```

Abnahmetest auf einem Mini, zum Beispiel nach einem macOS-Update:

```bash
cd ansible && ansible-playbook test.yml --limit mini01
```

Neues Modell nachladen, mit dem normalen Konto per SSH auf dem Mini:

```bash
ollama pull <modell>
```

Dauerhaft auf allen Minis: die Liste `ollama_models` in `ansible/group_vars/minis.yml` (bzw. `dauerbetrieb.yml`) anpassen und `./setup.sh` erneut starten.

Ollama und Caddy bewusst aktualisieren, am besten erst auf einem Mini:

```bash
cd ansible && ansible-playbook site.yml --tags upgrade --limit mini01 --ask-become-pass
```

## Demo am 24.11.2026

1. Einschalten bzw. Wecken für Probetag und Demotag planen (IT, einmal je Termin):

   ```bash
   cd ansible && ansible-playbook demo.yml --tags termin -e 'demo_weckzeit="11/24/26 07:30:00"' --ask-become-pass
   ```

2. Am Morgen die Minis acht Stunden wach halten (Jan, normales Konto):

   ```bash
   cd ansible && ansible-playbook demo.yml -u <konto>
   ```

Danach gelten wieder die normalen Energieeinstellungen. Dauerhaft wird nichts verändert.

## Rückbau nach dem Projekt

```bash
cd ansible && ansible-playbook rueckbau.yml --ask-become-pass
```

Entfernt Dienste, Proxy, Modelle, Logs und das Dienstkonto. Die vorher gesicherten Energieeinstellungen von mini01 und mini02 zeigt das Playbook an. Sie werden von Hand wiederhergestellt.

Die alte Anleitung zu den Data-Science-Tools liegt in [archiv/manuelle-einrichtung.md](archiv/manuelle-einrichtung.md). Sie ist nicht Teil dieses Auftrags.
