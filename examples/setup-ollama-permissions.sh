#!/usr/bin/env bash
set -euo pipefail
sudo usermod -aG ollama "$USER"
cat <<'MSG'
Added current user to the ollama group.

Log out/in, reboot, or run:
  newgrp ollama

Then check:
  groups
  test -r /usr/share/ollama/.ollama/models && echo readable
MSG
