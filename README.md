# Obridle

A small LAN model manager for Ollama homelabs.

Ollama is great on one machine. Obridle is for the moment you have several Linux boxes, one slow internet connection, and no desire to download the same model again.

Obridle copies selected Ollama models between LAN hosts by following the model manifest and syncing only the blobs referenced by that manifest. It uses `ssh`, `rsync`, `jq`, and `ollama`.

## Status

`v0.1.1-draft` — early Bash draft. Useful enough to inspect, test carefully, and iterate.

## Non-goals

Obridle is not:

- a model registry
- a daemon
- a web UI
- a replacement for Ollama
- a Hugging Face / GGUF manager in v0.1

## Dependencies

On Debian/Ubuntu/Pop/Mint:

```bash
sudo apt install rsync openssh-client jq
```

You also need Ollama installed on hosts where you want to list, pull, remove, or run models.

## Install

From the repo directory:

```bash
sudo install -m 755 obridle /usr/local/bin/obridle
sudo install -m 644 obridle-help.txt /usr/local/share/obridle-help.txt
```


### Ollama store permissions

On many Linux installs, Ollama stores models under:

```text
/usr/share/ollama/.ollama/models
```

Obridle needs read access to manifests and blobs for selective copy/push.

Add your user to the `ollama` group:

```bash
sudo usermod -aG ollama "$USER"
```

Then log out/in, reboot, or run:

```bash
newgrp ollama
```

Check:

```bash
groups
test -r /usr/share/ollama/.ollama/models && echo readable
```

If permissions are damaged:

```bash
sudo chown -R ollama:ollama /usr/share/ollama/.ollama
sudo chmod -R g+rX /usr/share/ollama/.ollama
```

Or run directly while developing:

```bash
./obridle
```

## Quick start

Open the menu:

```bash
obridle
```

List local models:

```bash
obridle local
```

Copy a model from the configured master to the local host:

```bash
obridle copy dolphin-llama3:8b
```

Push a local model to the configured master:

```bash
obridle push qwen3:4b
```

Pull normally from the Ollama registry:

```bash
obridle pull gemma2:2b
```

Remove a local model through Ollama:

```bash
obridle rm wizard-vicuna-uncensored:30b
```

Show a help region:

```bash
obridle help config
obridle help storage
obridle help worker-prompt
```

## Config

v0.1 uses one config file:

```bash
~/.obridle-config
```

Example:

```bash
OBRIDLE_MODELS_DIR="/usr/share/ollama/.ollama/models"
OBRIDLE_STAGE_DIR="$HOME/.cache/obridle/stage"

OBRIDLE_MASTER_NAME="bigbrainz"
OBRIDLE_MASTER_USER="koyote"
OBRIDLE_MASTER_HOST="192.168.1.168"
OBRIDLE_MASTER_MODELS_DIR="/usr/share/ollama/.ollama/models"

OBRIDLE_HOSTS="
bigbrainz|koyote|192.168.1.168|/usr/share/ollama/.ollama/models|master RTX3060 12GB
brainz|koyote|192.168.1.170|/usr/share/ollama/.ollama/models|T1000 8GB
"
```

If no master is configured, Obridle asks for one only when a command needs it and offers to save it.

## Safety

Obridle v0.1:

- does not store passwords
- uses normal SSH and sudo prompts
- uses `ollama rm` for deletion
- does not manually delete shared Ollama blobs
- does not use `rsync --delete` by default
- stages transfers before installing into the real model store

## Default Linux Ollama model store

Most standard Linux Ollama installs use:

```text
/usr/share/ollama/.ollama/models
```

Inside are:

```text
manifests/
blobs/
```

Obridle copies the manifest and referenced blobs for a selected model.
