# Mac minis - KI & Data Science Setup


## 0) Pre-Reqs

- **Xcode Command Line Tools**  
  `xcode-select --install`

- **Homebrew** – Install siehe https://brew.sh/

---

## 1) Fast Track (empfohlen): Brewfile verwenden

1) Brewfile lokal speichern (siehe `Brewfile` unten).  
2) Ausführen:
```bash
brew bundle --file=./Brewfile
````

> Danach ggf. Terminal neu starten.

---

## 2) Node/JS: nvm, pnpm, Yarn, Bun

```bash
# nvm installieren (offizielles Script)
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
# Shell neu laden, dann:
nvm install --lts
node -v && npm -v

# Paketmanager
corepack enable   # aktiviert pnpm/yarn-Verwaltung über Corepack
pnpm -v || npm i -g pnpm
yarn -v || corepack prepare yarn@stable --activate

# Bun (optional)
brew tap oven-sh/bun
brew install bun
bun -v
```

Links: [nvm](https://github.com/nvm-sh/nvm) · [pnpm](https://pnpm.io/installation) · [Yarn/Corepack](https://yarnpkg.com/corepack) · [Bun](https://bun.com/get)

---

## 3) Python: **uv-first** (statt pip)

* Installer/Docs: [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/)
* Homebrew: `brew install uv`

### Quickstart

```bash
# Neues Projekt
uv init my-project
cd my-project
uv venv
source .venv/bin/activate

# Pakete später je Kurs/Projekt:
uv add jupyterlab numpy pandas polars pyarrow scipy scikit-learn matplotlib plotly altair
# (weitere Libs projektweise hinzufügen)
```

---

## 4) Lokale LLMs (Apple Silicon)

* **LM Studio:** [https://lmstudio.ai/download](https://lmstudio.ai/download)
* **Ollama (neue App):** [https://ollama.com/download/mac](https://ollama.com/download/mac)

  * Brew (GUI-App): `brew install --cask ollama-app`
* **Apple MLX:** [https://github.com/ml-explore/mlx](https://github.com/ml-explore/mlx)
* **llama.cpp:** [https://github.com/ggerganov/llama.cpp](https://github.com/ggerganov/llama.cpp)
* **llama-cpp-python:** [https://github.com/abetlen/llama-cpp-python](https://github.com/abetlen/llama-cpp-python)

### Gemeinsame Model-Verzeichnisse (spart SSD/Traffic)

```bash
sudo mkdir -p /Users/Shared/ai-models/{ollama,lmstudio,huggingface}
sudo chmod -R 2775 /Users/Shared/ai-models

# Zsh (systemweit in /etc/zshrc oder pro User in ~/.zshrc):
export OLLAMA_MODELS=/Users/Shared/ai-models/ollama
export LM_STUDIO_DATA_DIR=/Users/Shared/ai-models/lmstudio
export HF_HOME=/Users/Shared/ai-models/huggingface
```

**Mini-Tests**

```bash
# Ollama (nach App-Start oder Daemon):
ollama run llama3.2:3b-instruct
```

---

## 5) Datenbanken & Vector

### PostgreSQL + pgvector

* Download/Info: [https://www.postgresql.org/download/macosx/](https://www.postgresql.org/download/macosx/)
* pgvector: [https://github.com/pgvector/pgvector](https://github.com/pgvector/pgvector)

```bash
brew install postgresql@16 pgvector
brew services start postgresql@16

createdb labtest
psql labtest -c 'CREATE EXTENSION IF NOT EXISTS vector;'
```

### DuckDB

* [https://duckdb.org/docs/installation/](https://duckdb.org/docs/installation/)

```bash
brew install duckdb
duckdb --version
```

### Qdrant (Vector DB)

* [https://qdrant.tech/documentation/guides/installation/](https://qdrant.tech/documentation/guides/installation/)

```bash
brew install qdrant
qdrant --version
```

### Meilisearch (optional)

* [https://www.meilisearch.com/docs/learn/self\_hosted/install\_meilisearch\_locally](https://www.meilisearch.com/docs/learn/self_hosted/install_meilisearch_locally)

```bash
brew install meilisearch
meilisearch --version
```

### GUIs

* **pgAdmin 4:** `brew install --cask pgadmin4` · [https://www.pgadmin.org/download/pgadmin-4-macos/](https://www.pgadmin.org/download/pgadmin-4-macos/)
* **DBeaver:** `brew install --cask dbeaver-community` · [https://dbeaver.io/download/](https://dbeaver.io/download/)
* **DB Browser for SQLite:** `brew install --cask db-browser-for-sqlite` · [https://sqlitebrowser.org/dl/](https://sqlitebrowser.org/dl/)

### MongoDB + Compass

* Server Download: [https://www.mongodb.com/try/download/community](https://www.mongodb.com/try/download/community)
* Homebrew Tap: `brew tap mongodb/brew`

```bash
brew install mongodb-community
brew services start mongodb-community
```

* Compass GUI: `brew install --cask mongodb-compass` · [https://www.mongodb.com/try/download/compass](https://www.mongodb.com/try/download/compass)

### MySQL + Workbench

* Server: [https://dev.mysql.com/downloads/mysql/](https://dev.mysql.com/downloads/mysql/)

```bash
brew install mysql
brew services start mysql
```

* Workbench GUI: `brew install --cask mysqlworkbench` · [https://dev.mysql.com/downloads/workbench/](https://dev.mysql.com/downloads/workbench/)

---

## 6) Docker Desktop, Cloud & Publishing

* **Docker Desktop (Apple Silicon):** [https://docs.docker.com/desktop/setup/install/mac-install/](https://docs.docker.com/desktop/setup/install/mac-install/)

  > Hinweis: Lizenzbedingungen für Unternehmen beachten.
* **Google Cloud SDK:** `brew install --cask google-cloud-sdk` · [https://cloud.google.com/sdk/docs/install](https://cloud.google.com/sdk/docs/install)
* **Quarto CLI:** `brew install --cask quarto` · [https://quarto.org/docs/download/](https://quarto.org/docs/download/)

---

## 7) PowerShell auf macOS

* Install: `brew install --cask powershell`
  Docs: [https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-macos](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-macos)
* Start im Terminal: `pwsh`
* VS Code → *Terminal: Select Default Profile* → **PowerShell** (optional)

---

## 8) VS Code (Essentials)

* Download: [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
* Extensions: Python, Jupyter, Pylance, Prettier, ESLint

---

## 9) Quick Checks

```bash
# Brew & tools
brew -v && git --version && gh --version && code -v
uv --version && python3 -V
node -v && pnpm -v && yarn -v && bun -v
docker --version
pwsh -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()'
```

---

## Quellen (Auswahl)

* Homebrew: [https://brew.sh/](https://brew.sh/)
* VS Code: [https://code.visualstudio.com/download](https://code.visualstudio.com/download)
* GitHub CLI: [https://cli.github.com/](https://cli.github.com/)
* PowerShell (macOS): [https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos)
* LM Studio: [https://lmstudio.ai/download](https://lmstudio.ai/download)
* Ollama (macOS): [https://ollama.com/download/mac](https://ollama.com/download/mac)
* MLX: [https://github.com/ml-explore/mlx](https://github.com/ml-explore/mlx)
* PostgreSQL (macOS): [https://www.postgresql.org/download/macosx/](https://www.postgresql.org/download/macosx/) · pgvector: [https://github.com/pgvector/pgvector](https://github.com/pgvector/pgvector)
* DuckDB: [https://duckdb.org/docs/installation/](https://duckdb.org/docs/installation/)
* Qdrant: [https://qdrant.tech/documentation/guides/installation/](https://qdrant.tech/documentation/guides/installation/)
* Meilisearch: [https://www.meilisearch.com/docs/learn/self\_hosted/install\_meilisearch\_locally](https://www.meilisearch.com/docs/learn/self_hosted/install_meilisearch_locally)
* MongoDB Community: [https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-os-x/) · Compass: [https://www.mongodb.com/try/download/compass](https://www.mongodb.com/try/download/compass)
* MySQL: [https://dev.mysql.com/downloads/mysql/](https://dev.mysql.com/downloads/mysql/) · Workbench: [https://dev.mysql.com/downloads/workbench/](https://dev.mysql.com/downloads/workbench/)
* Docker Desktop (Mac): [https://docs.docker.com/desktop/setup/install/mac-install/](https://docs.docker.com/desktop/setup/install/mac-install/)
* Quarto: [https://quarto.org/docs/download/](https://quarto.org/docs/download/)
* uv: [https://docs.astral.sh/uv/](https://docs.astral.sh/uv/) · Install via Homebrew: `brew install uv`

````

```ruby
# Brewfile (für `brew bundle`)
tap "homebrew/cask"
tap "mongodb/brew"
tap "oven-sh/bun"

brew "git"
brew "gh"
brew "wget"
brew "uv"
brew "nvm"
brew "pnpm"
brew "yarn"
brew "duckdb"
brew "postgresql@16"
brew "pgvector"
brew "qdrant"
brew "meilisearch"
brew "mysql"
brew "mongodb-community"
brew "bun"

cask "iterm2"
cask "visual-studio-code"
cask "google-cloud-sdk"
cask "dbeaver-community"
cask "pgadmin4"
cask "db-browser-for-sqlite"
cask "docker"              # Docker Desktop
cask "lm-studio"
cask "ollama-app"          # neue offizielle App
cask "quarto"
cask "mongodb-compass"
cask "mysqlworkbench"
cask "powershell"
````

Wenn du willst, packe ich dir daraus noch ein **einzeiliges Setup-Skript** (inkl. Anlegen der Model-Cache-Verzeichnisse und `brew bundle`-Run) – oder ich passe die README in Ton/Farben an euer GitHub-Org-Styleguide.
