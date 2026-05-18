#!/usr/bin/env bash
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 user@host [user@host ...]" >&2
  exit 1
fi

for target in "$@"; do
  echo "Installing obridle on $target"
  scp obridle obridle-help.txt "$target:/tmp/"
  ssh -t "$target" 'sudo install -m 755 /tmp/obridle /usr/local/bin/obridle && sudo install -m 644 /tmp/obridle-help.txt /usr/local/share/obridle-help.txt && obridle version'
done
