# PVM - Python Version Manager

<p align="center">
  <img src="https://github.com/user-attachments/assets/b042f9b9-fc0a-49e4-8173-d12706c96aff" alt="PVM Banner" width="100%">
</p>

<h1 align="center">PVM</h1>

<p align="center">
  <strong>Python Version Manager</strong><br>
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

It focuses on Python versions, executables, `pip`, virtual environments, and project-based version control via `.pvmrc`.

Works across Linux, macOS, and Windows using WSL.

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

### System Python

PVM can detect and use the Python version already installed on your system.

```sh
pvm system
```

Example output:
```text
System Python: Python 3.12.4
Path: /usr/bin/python3
```

To switch back to the system Python:
```sh
pvm use system
```

---

## .pvmrc

```sh
echo "3.12" > .pvmrc
pvm use
```

If the version is not installed:

```sh
pvm install
```

---

## Virtual Environments

```sh
pvm venv .venv
. .venv/bin/activate
```

Specific version:

```sh
pvm venv 3.12 .venv
```

---

## Manual Install

```sh
git clone https://github.com/pvm-shell/PVM.git ~/.pvm
cd ~/.pvm
. ./pvm.sh
```

Add to your shell config:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && . "$PVM_DIR/pvm.sh"
```

---

## Environment Variables

```sh
PVM_DIR
PVM_BIN
PVM_INC
PVM_VERSION
PVM_RC_VERSION
```

---

## Compatibility Notes

The following environment variables may affect Python version switching:

```sh
PYTHONHOME
PYTHONPATH
PIP_PREFIX
PIP_TARGET
VIRTUAL_ENV
```

If needed:

```sh
deactivate
pvm use 3.12
```

---

## Uninstall

```sh
pvm deactivate
rm -rf ~/.pvm
```

---

## Project Status

Early development.

---

## License

MIT License. See [LICENSE](./LICENSE).
