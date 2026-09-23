
# Mac minis – KI & Data Science Setup

Zehn Mac Minis (M4 Pro, 64 GB) im Labor 016a. Sie laufen rund um die Uhr, werden zeitweise von Laborgruppen genutzt (oft nur als Zugang zu Servern) und dienen zusätzlich als **Ollama-Pool** für die Projekte auf dem HdM-Server. macOS-Updates macht die IT.

## Architektur

```
n8n (HdM-Server) ──► LiteLLM-Gateway (HdM-Server, Stufe 2) ──► mini01..mini10 (Ollama :11434)
```

- Jeder Mini hat dieselben Modelle im gemeinsamen Cache `/Users/Shared/ai-models`.
- Ollama läuft als LaunchDaemon (`de.hdm.ollama`), also auch ohne angemeldeten Nutzer und nach Neustarts.
- Modelle werden nach 30 Minuten Leerlauf entladen, damit Laborgruppen den Speicher haben. Die drei Modelle belegen zusammen rund 44 GB Platte pro Mini.
- Ollama hat keine Zugangskontrolle: Port 11434 soll nur vom HdM-Server aus erreichbar sein (mit der IT klären).

## Einrichtung mit Ansible (empfohlen)

Ansible läuft auf dem eigenen Rechner (Mac oder Linux) und steuert die Minis per SSH. Auf den Minis wird nichts zusätzlich installiert.

**Voraussetzungen**

- Zugriff aus dem HdM-Netz oder über VPN.
- Ein Admin-Konto auf jedem Mini mit SSH-Schlüssel (Entfernte Anmeldung aktiv) und sudo-Rechten.
- Homebrew unter `/opt/homebrew`, installiert von **diesem** Konto (Homebrew läuft nicht als root).
- Port 11434 ist vor Inbetriebnahme so gefiltert, dass nur der n8n-Server (kirenz.iuk.hdm-stuttgart.de) zugreifen kann. Ollama hat keine eigene Zugangskontrolle.

**Inventar ausfüllen** (`ansible/inventory.ini`), Beispiel:

```ini
[minis]
mini01 ansible_host=mini01.example.hdm-stuttgart.de

[minis:vars]
ansible_user=labadmin
```

```bash
brew install ansible
```

```bash
cd ansible && ansible minis -m ping
```

Erst einen Mini einrichten, dann alle (`-K` fragt das sudo-Passwort ab):

```bash
cd ansible && ansible-playbook site.yml -K --limit mini01
```

```bash
cd ansible && ansible-playbook site.yml -K
```

Nach dem ersten Mini prüfen, bevor alle folgen: `status.yml` muss für `mini01` `erreichbar: true` und die drei Modelle zeigen, und von einem anderen Rechner als dem n8n-Server darf Port 11434 nicht erreichbar sein.

Status des Pools (Erreichbarkeit, vorhandene und geladene Modelle):

```bash
cd ansible && ansible-playbook status.yml
```

Modelle ändern (nach der Ersteinrichtung): Liste `ollama_models` in `ansible/group_vars/minis.yml` anpassen, dann `ansible-playbook site.yml -K --tags models`.

---

# Manuelle Einrichtung (Referenz)



## 0) Vorbereitung

**Xcode Command Line Tools**
```bash
xcode-select --install
````

**Homebrew**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

---

## 1) Brewfile anlegen 

**Brewfile erzeugen (im aktuellen Ordner)**

```bash
cat > ./Brewfile <<'EOF'
tap "homebrew/cask"
tap "mongodb/brew"

brew "git"
brew "gh"
brew "wget"
brew "uv"
brew "postgresql@16"
brew "pgvector"
brew "qdrant"
brew "ollama"
brew "mysql"
brew "mongodb-community"

cask "iterm2"
cask "visual-studio-code"
cask "google-cloud-sdk"
cask "pgadmin4"
cask "db-browser-for-sqlite"
cask "docker" 
cask "lm-studio"
cask "quarto"
cask "mongodb-compass"
cask "mysqlworkbench"
cask "powershell"
EOF
```

**Brewfile installieren**

```bash
brew bundle --file=./Brewfile
```

---

## 2) Node/npm nvm

**nvm installieren**

```bash
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
```

**nvm in die Shell laden (sofort in aktueller Session)**

```bash
export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
```

**LTS-Node installieren & als Default setzen**

```bash
nvm install --lts
```

```bash
nvm alias default 'lts/*'
```

**Versionen prüfen**

```bash
node -v
```

```bash
npm -v
```

---

## 3) Gemeinsame Model-Caches (spart SSD/Traffic)

**Verzeichnisse anlegen & Rechte setzen**

```bash
sudo mkdir -p /Users/Shared/ai-models/{ollama,huggingface,lmstudio} && sudo chown -R root:staff /Users/Shared/ai-models && sudo chmod -R 2775 /Users/Shared/ai-models
```

**Env-Vars systemweit für Zsh setzen (Ollama/HF)**

```bash
sudo /bin/sh -c 'printf "\nexport OLLAMA_MODELS=/Users/Shared/ai-models/ollama\nexport HF_HOME=/Users/Shared/ai-models/huggingface\n" >> /etc/zshrc'
```

> Hinweis: **LM Studio** Pfad bitte in der App unter *Settings → Storage/Models* auf `/Users/Shared/ai-models/lmstudio` umstellen.

---

## 4) Dienste starten

**PostgreSQL**

```bash
brew services start postgresql@16
```

**Qdrant**

```bash
brew services start qdrant
```

**MongoDB Community**

```bash
brew services start mongodb-community
```

**MySQL**

```bash
brew services start mysql
```

---

## 5) Schnelle Funktionschecks

**uv**

```bash
uv --version
```

**Ollama (Modell nur ziehen, nicht interaktiv)**

```bash
ollama pull qwen3-embedding:0.6b
```

**PostgreSQL + pgvector**

```bash
createdb labtest && psql labtest -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

**Docker**

```bash
docker --version
```

**PowerShell**

```bash
pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
```

**Quarto**

```bash
quarto --version
```

---

## 6) VS Code

**VS Code starten**

```bash
open -a "Visual Studio Code"
```

**Extensions importieren**

[VS Code extensions (Profil von Jan Kirenz)](https://vscode.dev/profile/github/e0660f06e905a92816a8ca238337f902)



