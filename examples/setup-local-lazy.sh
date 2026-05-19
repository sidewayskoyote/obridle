#!/usr/bin/env bash
set -euo pipefail
cat <<'WARN'
OBRIDLE EXPERIMENTAL LAZY SETUP

This helper is for testing convenience. It is not required.

It may ask to run sudo commands to:
  - install rsync, openssh-client, and jq on apt-based systems
  - install obridle into /usr/local/bin
  - install obridle-help.txt into /usr/local/share
  - add your current user to the ollama group

Read this script before running it on a machine you care about.
It does not intentionally change Ollama model files.
WARN
printf '
Continue? [y/N] '
read -r ans
case "$ans" in y|Y|yes|YES) ;; *) echo "Cancelled."; exit 0 ;; esac
if command -v apt >/dev/null 2>&1; then
  missing=""
  for cmd in rsync ssh jq; do command -v "$cmd" >/dev/null 2>&1 || missing="$missing $cmd"; done
  if [ -n "$missing" ]; then
    echo "Missing commands:$missing"
    echo "Will run: sudo apt install rsync openssh-client jq"
    printf 'Install dependencies now? [y/N] '
    read -r dep_ans
    case "$dep_ans" in y|Y|yes|YES) sudo apt update; sudo apt install rsync openssh-client jq ;; *) echo "Skipping dependency install." ;; esac
  fi
else
  echo "apt not found. Install rsync, openssh-client, and jq with your system package manager."
fi
if [ -f ./obridle ] && [ -f ./obridle-help.txt ]; then
  echo "Will install obridle to /usr/local/bin and help to /usr/local/share."
  printf 'Install files now with sudo? [y/N] '
  read -r install_ans
  case "$install_ans" in y|Y|yes|YES) sudo install -m 755 obridle /usr/local/bin/obridle; sudo install -m 644 obridle-help.txt /usr/local/share/obridle-help.txt ;; *) echo "Skipping install." ;; esac
else
  echo "Run this from the repo directory containing ./obridle and ./obridle-help.txt."
fi
if getent group ollama >/dev/null 2>&1; then
  if groups | grep -qw ollama; then echo "Current shell is already in the ollama group."; else
    echo "Will add current user ($USER) to group: ollama"
    printf 'Run sudo usermod -aG ollama "$USER"? [y/N] '
    read -r group_ans
    case "$group_ans" in y|Y|yes|YES) sudo usermod -aG ollama "$USER"; echo "Group added. Log out/in, reboot, or run: newgrp ollama" ;; *) echo "Skipping group change." ;; esac
  fi
else
  echo "Group 'ollama' not found. Is Ollama installed on this host?"
fi
echo
echo "Try:"
echo "  obridle version"
echo "  obridle doctor"
