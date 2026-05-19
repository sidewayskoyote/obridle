# Obridle

Copy selected Ollama models between LAN hosts without re-downloading them.

Obridle is a small Bash tool for homelab users running Ollama on more than one machine. It follows an Ollama model manifest and syncs only the blobs needed for that model over SSH/rsync.

Ollama is great on one machine. Obridle is for the moment you have several Linux boxes, one slow internet connection, and no desire to download the same model again.

## TL;DR

On each Ollama host:

```bash
sudo apt install rsync openssh-client jq
sudo usermod -aG ollama "$USER"
newgrp ollama
```

Install Obridle:

```bash
sudo install -m 755 obridle /usr/local/bin/obridle
sudo install -m 644 obridle-help.txt /usr/local/share/obridle-help.txt
```

Set up SSH between hosts:

```bash
ssh-copy-id user@master-host
ssh user@master-host 'ollama list'
```

Create or edit `~/.obridle-config`:

```bash
OBRIDLE_MODELS_DIR="/usr/share/ollama/.ollama/models"
OBRIDLE_STAGE_DIR="$HOME/.cache/obridle/stage"

OBRIDLE_MASTER_NAME="bigbrainz"
OBRIDLE_MASTER_USER="koyote"
OBRIDLE_MASTER_HOST="192.168.1.168"
OBRIDLE_MASTER_MODELS_DIR="/usr/share/ollama/.ollama/models"
```

Copy a model from master to local:

```bash
obridle copy mistral:7b-instruct-q4_K_M
```

Run a local check:

```bash
obridle doctor
```

Push a local model to master:

```bash
obridle push qwen2.5-coder:3b
```

## Status

`v0.1.3-draft` — early Bash draft. Useful enough to inspect, test carefully, and iterate.

## Scope

Core Obridle is small:

- list local/master models
- copy one selected model from master to local
- push one selected model from local to master
- pull/remove through Ollama
- show help and basic host tools

Optional helper features such as host/model maps, config sync, and strict one-way mirror mode may exist later, but they should stay subordinate to the core transfer workflow.

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

Run doctor:

```bash
obridle doctor
```

Show a help region:

```bash
obridle help config
obridle help storage
obridle help worker-prompt
```

## Optional setup helpers

The `examples/` directory contains copy/paste helper scripts.

The normal install path is still explicit:

```bash
sudo install -m 755 obridle /usr/local/bin/obridle
sudo install -m 644 obridle-help.txt /usr/local/share/obridle-help.txt
```

`examples/setup-local-lazy.sh` is intentionally marked experimental. It prints what it wants to do, asks before sudo actions, and is meant for testing convenience rather than blind production use.

For careful users, read the script first and run the individual commands yourself.

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

## License

MIT License. See [LICENSE](LICENSE).

## Roadmap

Near-term:

- doctor command polish
- example config and install snippets
- shellcheck pass
- host/model map polish
- config sync between known hosts

Later:

- strict one-way mirror mode: master → local
- profiles / desired model sets
- macOS testing and model-dir autodetection
- dry-run mode
- batch/sysadmin mode
- manual repair tools for broken Ollama stores
