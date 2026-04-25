<p align="center">
  <img src="https://github.com/user-attachments/assets/b042f9b9-fc0a-49e4-8173-d12706c96aff" alt="PVM Banner">
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/82753fa9-d51d-48e2-ba52-5c4f1e78826f" alt="PVM Logo" width="180">
</p>

<h1 align="center">PVM - Python Version Manager</h1>

<p align="center">
  POSIX-compliant shell script to manage multiple active Python versions.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="License">
  <img src="https://img.shields.io/badge/shell-POSIX-green" alt="Shell">
  <img src="https://img.shields.io/badge/status-active-success" alt="Status">
</p>

---

## Intro

`pvm` allows you to quickly install, switch, and manage multiple Python versions from the command line.

```sh
$ pvm install 3.12
Now using Python 3.12.8
$ python -V
Python 3.12.8

$ pvm use 3.11
Now using Python 3.11.11
$ python -V
Python 3.11.11
```

Simple, fast, and flexible.

---

## Why PVM?

- Lightweight and POSIX-compliant
- No dependency on Python itself
- Works across shells: `sh`, `bash`, `zsh`, `dash`, `ksh`
- Inspired by `nvm`, but built specifically for Python
- Per-project version management with `.pvmrc`
- Clean and minimal design

---

## About

`pvm` is a Python version manager designed to be installed per-user and used per-shell.

It focuses on Python versions, Python executables, `pip`, virtual environments, and per-project Python selection through `.pvmrc` files.

`pvm` works on POSIX-compliant shells across Linux, macOS, and Windows WSL.

---

## Quick Install

```sh
curl -o- https://raw.githubusercontent.com/pvm-shell/PVM/main/install.sh | bash
```

or:

```sh
wget -qO- https://raw.githubusercontent.com/pvm-shell/PVM/main/install.sh | bash
```

---

## Usage

### Install Python

```sh
pvm install 3.12
pvm install 3.11
pvm install 3.10
```

### Use Python Version

```sh
pvm use 3.12
```

### Show Current Version

```sh
pvm current
python -V
```

### List Versions

```sh
pvm ls
pvm ls-remote
```

### Set Default Version

```sh
pvm alias default 3.12
```

### Run Command With Version

```sh
pvm run 3.12 --version
```

```sh
pvm exec 3.12 python -m pip --version
```

---

## .pvmrc

Create a `.pvmrc` file in your project:

```sh
echo "3.12" > .pvmrc
```

Then use it:

```sh
pvm use
```

If the version is not installed:

```sh
pvm install
```

This enables per-project Python version management.

---

## Virtual Environments

Create a virtual environment with the active Python version:

```sh
pvm venv .venv
```

Activate it:

```sh
. .venv/bin/activate
```

Create a virtual environment with a specific Python version:

```sh
pvm venv 3.12 .venv
```

`pvm` does not replace `venv`, `virtualenv`, `pip`, `pipx`, `poetry`, `uv`, or `pipenv`.

It focuses on selecting and managing Python runtimes.

---

## Manual Install

```sh
git clone https://github.com/pvm-shell/PVM.git ~/.pvm
cd ~/.pvm
. ./pvm.sh
```

Add this to your shell profile:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && . "$PVM_DIR/pvm.sh"
```

For bash completion:

```sh
[ -s "$PVM_DIR/bash_completion" ] && . "$PVM_DIR/bash_completion"
```

---

## Environment Variables

`pvm` uses the following environment variables:

```sh
PVM_DIR
PVM_BIN
PVM_INC
PVM_VERSION
PVM_RC_VERSION
```

`pvm` modifies `PATH` when switching Python versions.

---

## Compatibility Notes

Some Python environment variables may conflict with version switching:

```sh
PYTHONHOME
PYTHONPATH
PIP_PREFIX
PIP_TARGET
VIRTUAL_ENV
```

If you are inside a virtual environment, deactivate it before switching versions:

```sh
deactivate
pvm use 3.12
```

---

## Uninstall

```sh
pvm unload
rm -rf ~/.pvm
```

Then remove these lines from your shell profile:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && . "$PVM_DIR/pvm.sh"
```

---

## Project Status

PVM is currently in early development.

The goal is to provide a lightweight, POSIX-first Python version manager inspired by `nvm`.

---

## License

MIT License. See [LICENSE](./LICENSE) for details.

---

## Copyright

Copyright PVM contributors.
