#!/usr/bin/env bash
set -euo pipefail

sudo install -m 755 obridle /usr/local/bin/obridle
sudo install -m 644 obridle-help.txt /usr/local/share/obridle-help.txt

echo "Installed:"
obridle version
