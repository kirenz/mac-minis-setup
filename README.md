
# Mac minis – KI & Data Science Setup


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
brew "mysql"
brew "mongodb-community"

cask "iterm2"
cask "visual-studio-code"
cask "google-cloud-sdk"
cask "pgadmin4"
cask "db-browser-for-sqlite"
cask "docker" 
cask "lm-studio"
cask "ollama" 
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
ollama pull llama3.2:3b-instruct
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



