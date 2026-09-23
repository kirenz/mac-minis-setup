#!/usr/bin/env bash
# Richtet Ollama erst auf dem ersten Mini ein und danach auf allen anderen.
set -euo pipefail
cd "$(dirname "$0")/ansible"

if ! command -v ansible-playbook >/dev/null; then
  echo "Ansible ist nicht installiert, ich installiere es mit Homebrew."
  brew install ansible
fi

if grep -q "=TODO" inventory.ini; then
  echo "Bitte zuerst Hostnamen und Konto in ansible/inventory.ini eintragen."
  exit 1
fi

echo "Verbindung zu den Minis prüfen ..."
ansible minis -m ping -o

read -r -s -p "sudo-Passwort für die Minis: " PW
echo
pwfile=$(mktemp)
trap 'rm -f "$pwfile"' EXIT
chmod 600 "$pwfile"
printf '%s' "$PW" > "$pwfile"

first=$(ansible minis --list-hosts | sed -n 2p | xargs)

echo "Einrichtung auf $first ..."
ansible-playbook site.yml --limit "$first" --become-password-file "$pwfile"
ansible-playbook status.yml --limit "$first"

read -r -p "Passt das? Dann richte ich jetzt alle anderen ein (j/n): " answer
if [[ "$answer" != "j" ]]; then
  exit 0
fi

ansible-playbook site.yml --become-password-file "$pwfile"
ansible-playbook status.yml
