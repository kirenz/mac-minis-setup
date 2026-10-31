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

if [[ ! -s proxy-token ]]; then
  echo "Ich erzeuge das Zugangstoken für den Proxy (ansible/proxy-token)."
  umask 077
  openssl rand -hex 32 > proxy-token
fi

echo "Verbindung zu den Minis prüfen (beim ersten Mal bitte die Host-Schlüssel bestätigen) ..."
ansible minis -m ping -o -f 1

read -r -s -p "sudo-Passwort für die Minis: " PW
echo
pwfile=$(mktemp)
trap 'rm -f "$pwfile"' EXIT
chmod 600 "$pwfile"
printf '%s' "$PW" > "$pwfile"

first=$(ansible minis --list-hosts | sed -n 2p | xargs)

echo "Einrichtung auf $first ..."
ansible-playbook site.yml --limit "$first" --become-password-file "$pwfile"
ansible-playbook status.yml --limit "$first" --become-password-file "$pwfile"

read -r -p "Abnahmetest auf $first laufen lassen? Dauert einige Minuten (j/n): " answer
if [[ "$answer" == "j" ]]; then
  ansible-playbook test.yml --limit "$first"
fi

read -r -p "Passt das? Dann richte ich jetzt alle anderen ein (j/n): " answer
if [[ "$answer" != "j" ]]; then
  exit 0
fi

ansible-playbook site.yml --become-password-file "$pwfile"
ansible-playbook status.yml --become-password-file "$pwfile"
