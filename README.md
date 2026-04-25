# PVM - Python Version Manager

Python Version Manager - POSIX-compliant shell script to manage multiple active Python versions.

## Table of Contents

* [Intro](#intro)
* [About](#about)
* [Installing and Updating](#installing-and-updating)

  * [Install & Update Script](#install--update-script)
  * [Additional Notes](#additional-notes)
  * [Installing in Docker](#installing-in-docker)
  * [Troubleshooting on Linux](#troubleshooting-on-linux)
  * [Troubleshooting on macOS](#troubleshooting-on-macos)
  * [Verify Installation](#verify-installation)
  * [Important Notes](#important-notes)
  * [Git Install](#git-install)
  * [Manual Install](#manual-install)
  * [Manual Upgrade](#manual-upgrade)
* [Usage](#usage)

  * [Installing Python Versions](#installing-python-versions)
  * [Using Python Versions](#using-python-versions)
  * [Running Commands](#running-commands)
  * [Aliases](#aliases)
  * [System Version of Python](#system-version-of-python)
  * [Listing Versions](#listing-versions)
  * [Set Default Python Version](#set-default-python-version)
  * [Use a Mirror of Python Builds](#use-a-mirror-of-python-builds)
  * [.pvmrc](#pvmrc)
  * [Virtual Environments](#virtual-environments)
* [Deeper Shell Integration](#deeper-shell-integration)

  * [Calling pvm use automatically in a directory with a .pvmrc file](#calling-pvm-use-automatically-in-a-directory-with-a-pvmrc-file)
* [Environment Variables](#environment-variables)
* [Bash Completion](#bash-completion)
* [Compatibility Issues](#compatibility-issues)
* [Uninstalling / Removal](#uninstalling--removal)
* [Docker For Development Environment](#docker-for-development-environment)
* [Problems](#problems)
* [License](#license)

## Intro

`pvm` allows you to quickly install and use different versions of Python via the command line.

Example:

```sh
$ pvm install 3.12
Now using Python 3.12.8
$ python -V
Python 3.12.8

$ pvm use 3.11
Now using Python 3.11.11
$ python -V
Python 3.11.11

$ pvm use 3.10
Now using Python 3.10.16
$ python -V
Python 3.10.16
```

Simple as that.

## About

`pvm` is a version manager for Python, designed to be installed per-user and invoked per-shell. `pvm` works on POSIX-compliant shells such as `sh`, `dash`, `ksh`, `zsh`, and `bash`, especially on Unix, Linux, macOS, and Windows WSL.

`pvm` is inspired by tools like `nvm`, but focuses on Python versions, Python executables, `pip`, and per-project Python selection through `.pvmrc` files.

## Installing and Updating

### Install & Update Script

To install or update `pvm`, run the install script. You may either download and run the script manually, or use one of the following commands:

```sh
curl -o- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | bash
```

or:

```sh
wget -qO- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | bash
```

Running either command downloads the installer and runs it. The script clones the `pvm` repository to `~/.pvm`, and attempts to add the source lines below to the correct shell profile file, such as `~/.bashrc`, `~/.bash_profile`, `~/.zshrc`, or `~/.profile`.

```sh
export PVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.pvm" || printf %s "${XDG_CONFIG_HOME}/pvm")"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh" # This loads pvm
```

If the install script updates the wrong profile file, set the `PROFILE` environment variable to the desired profile path and rerun the installer.

Example:

```sh
PROFILE="$HOME/.zshrc" curl -o- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | bash
```

### Additional Notes

If the environment variable `XDG_CONFIG_HOME` is present, `pvm` will place its files there.

You can add `--no-use` to postpone automatically using the default Python version until you manually run `pvm use`:

```sh
export PVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.pvm" || printf %s "${XDG_CONFIG_HOME}/pvm")"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh" --no-use # This loads pvm without auto-using the default version
```

You can customize the install source, install directory, profile file, and default Python version using these environment variables:

```sh
PVM_SOURCE
PVM_DIR
PROFILE
PYTHON_VERSION
```

Example:

```sh
curl -o- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | PVM_DIR="$HOME/.local/share/pvm" bash
```

The installer can use `git`, `curl`, or `wget`, whichever is available.

To prevent the installer from editing your shell config, run:

```sh
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | bash'
```

## Installing in Docker

When invoking `bash` as a non-interactive shell, such as in a Docker container, regular profile files are usually not sourced. To use `pvm`, `python`, and `pip` normally, you can specify the special `BASH_ENV` variable.

```dockerfile
FROM ubuntu:latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV BASH_ENV "${HOME}/.bash_env"
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

RUN apt update && apt install -y curl git build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev tk-dev

RUN curl -o- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo "3.12" > .pvmrc
RUN pvm install
```

More robust CI/CD example:

```dockerfile
FROM ubuntu:latest
ARG PYTHON_VERSION=3.12

RUN apt update && apt install -y curl git build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev tk-dev

RUN curl -o- https://raw.githubusercontent.com/pvm-sh/pvm/v0.1.0/install.sh | bash

ENV PVM_DIR=/root/.pvm
RUN bash -c "source $PVM_DIR/pvm.sh && pvm install $PYTHON_VERSION"

ENTRYPOINT ["bash", "-c", "source $PVM_DIR/pvm.sh && exec \"$@\"", "--"]
CMD ["/bin/bash"]
```

Build with a custom Python version:

```sh
docker build -t pvmimage --build-arg PYTHON_VERSION=3.11 .
```

Run interactively:

```sh
docker run --rm -it pvmimage
```

Check versions:

```sh
python -V
pip -V
pvm -v
```

## Troubleshooting on Linux

After running the install script, if you get:

```sh
pvm: command not found
```

or see no output from:

```sh
command -v pvm
```

close your current terminal and open a new one.

Alternatively, run one of the following commands:

```sh
# bash
source ~/.bashrc

# zsh
source ~/.zshrc

# ksh / sh
. ~/.profile
```

These commands should load the `pvm` command into your shell.

## Troubleshooting on macOS

If `pvm` is not found after installation, one of these may be the reason:

* Since macOS uses `zsh` by default, `~/.zshrc` may not exist. Create it with:

```sh
touch ~/.zshrc
```

Then rerun the installer.

* If you use `bash`, your system may not have `~/.bash_profile` or `~/.bashrc`. Create one of them:

```sh
touch ~/.bash_profile
# or
touch ~/.bashrc
```

Then rerun the installer.

* You may need to manually add this snippet to your shell profile:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"
```

Then reload your shell:

```sh
source ~/.zshrc
# or
source ~/.bashrc
```

### macOS Build Dependencies

Some Python versions may need to be compiled from source. On macOS, install Xcode Command Line Tools:

```sh
xcode-select --install
```

For optional Python build dependencies, Homebrew can be used:

```sh
brew install openssl readline sqlite3 xz zlib tcl-tk
```

## Verify Installation

To verify that `pvm` has been installed:

```sh
command -v pvm
```

This should output:

```sh
pvm
```

Please note that `which pvm` may not work in all shells, because `pvm` can be loaded as a shell function rather than as a standalone executable.

## Important Notes

If your system does not have a prebuilt Python binary available, `pvm` may need to build Python from source.

For Debian/Ubuntu based systems, common dependencies are:

```sh
sudo apt update
sudo apt install -y build-essential curl git libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev libffi-dev liblzma-dev tk-dev
```

For Fedora:

```sh
sudo dnf install -y gcc make patch zlib-devel bzip2 bzip2-devel readline-devel \
  sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel
```

For Arch Linux:

```sh
sudo pacman -S --needed base-devel openssl zlib xz tk sqlite readline bzip2 libffi
```

For Alpine Linux:

```sh
apk add --no-cache bash curl git build-base openssl-dev zlib-dev bzip2-dev \
  readline-dev sqlite-dev libffi-dev xz-dev tk-dev
```

`pvm` does not require `sudo` to install Python versions under your user account.

## Git Install

If you have `git` installed:

```sh
git clone https://github.com/pvm-sh/pvm.git ~/.pvm
cd ~/.pvm
git checkout v0.1.0
. ./pvm.sh
```

Add the following lines to your shell profile:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh" # This loads pvm
[ -s "$PVM_DIR/bash_completion" ] && \. "$PVM_DIR/bash_completion" # This loads pvm bash_completion
```

## Manual Install

For a fully manual install:

```sh
export PVM_DIR="$HOME/.pvm" && (
  git clone https://github.com/pvm-sh/pvm.git "$PVM_DIR"
  cd "$PVM_DIR"
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$PVM_DIR/pvm.sh"
```

Then add this to your shell profile:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"
[ -s "$PVM_DIR/bash_completion" ] && \. "$PVM_DIR/bash_completion"
```

## Manual Upgrade

For manual upgrade with `git`:

```sh
(
  cd "$PVM_DIR"
  git fetch --tags origin
  git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
) && \. "$PVM_DIR/pvm.sh"
```

## Usage

### Installing Python Versions

To download, build, and install the latest stable Python release:

```sh
pvm install python
```

To install a specific version:

```sh
pvm install 3.12.8
pvm install 3.11.11
pvm install 3.10.16
```

To install the latest patch release for a minor version:

```sh
pvm install 3.12
pvm install 3.11
pvm install 3.10
```

The first version installed becomes the default. New shells will start with the default version unless configured otherwise.

### Using Python Versions

Use an installed version:

```sh
pvm use 3.12
```

Check the active Python version:

```sh
python -V
pvm current
```

Use the default version:

```sh
pvm use default
```

Use the version specified in a `.pvmrc` file:

```sh
pvm use
```

### Running Commands

Run Python with a specific version:

```sh
pvm run 3.12 --version
```

Run a Python command:

```sh
pvm run 3.12 -c "import sys; print(sys.version)"
```

Run an arbitrary command in a subshell with the desired Python version:

```sh
pvm exec 3.11 python -m pip --version
```

Get the path to the Python executable:

```sh
pvm which 3.12
```

Example output:

```sh
/home/user/.pvm/versions/python/3.12.8/bin/python
```

### Aliases

Set an alias:

```sh
pvm alias my_alias 3.12.8
```

Use the alias:

```sh
pvm use my_alias
```

Remove an alias:

```sh
pvm unalias my_alias
```

Special aliases:

```sh
python   # latest stable Python version
stable   # latest stable Python version
system   # system-installed Python
```

Set the default version:

```sh
pvm alias default 3.12
```

### System Version of Python

If you want to use the system-installed Python:

```sh
pvm use system
```

Run the system Python:

```sh
pvm run system --version
```

### Listing Versions

List installed versions:

```sh
pvm ls
```

List available versions:

```sh
pvm ls-remote
```

List available versions matching a minor version:

```sh
pvm ls-remote 3.12
```

### Set Default Python Version

To set a default Python version for new shells:

```sh
pvm alias default python
```

or:

```sh
pvm alias default 3.12
```

or:

```sh
pvm alias default 3.12.8
```

### Use a Mirror of Python Builds

To use a mirror for Python source archives or binary builds, set `PVM_PYTHON_ORG_MIRROR`:

```sh
export PVM_PYTHON_ORG_MIRROR=https://www.python.org/ftp/python
pvm install 3.12.8
```

You can also pass it inline:

```sh
PVM_PYTHON_ORG_MIRROR=https://www.python.org/ftp/python pvm install 3.11.11
```

If your organization hosts internal Python builds, point the mirror variable to that internal URL.

### .pvmrc

You can create a `.pvmrc` file containing a Python version number or alias in the project root directory.

Example:

```sh
echo "3.12" > .pvmrc
```

Then run:

```sh
pvm use
```

Example output:

```sh
Found '/path/to/project/.pvmrc' with version <3.12>
Now using Python 3.12.8
```

If the version is not installed, run:

```sh
pvm install
```

Example output:

```sh
Found '/path/to/project/.pvmrc' with version <3.12>
Downloading and installing Python 3.12.8...
Now using Python 3.12.8
```

`pvm use`, `pvm install`, `pvm exec`, `pvm run`, and `pvm which` will use the version specified in `.pvmrc` if no version is supplied on the command line.

`pvm` will search upward from the current directory to find a `.pvmrc` file. This means running `pvm use` in a subdirectory will still use the `.pvmrc` from the project root.

The contents of `.pvmrc` should contain one version or alias followed by a newline.

Valid examples:

```txt
3.12
3.12.8
stable
python
default
```

Comments are allowed:

```txt
3.12 # project Python version
```

Blank lines and leading/trailing whitespace are ignored.

### Virtual Environments

`pvm` manages Python versions. It can also help create virtual environments using the active Python version.

Create a virtual environment:

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

Remove the virtual environment manually:

```sh
rm -rf .venv
```

`pvm` does not replace `venv`, `virtualenv`, `pip`, `pipx`, `poetry`, `uv`, or `pipenv`. It focuses on selecting and managing Python runtimes.

## Deeper Shell Integration

### Calling pvm use automatically in a directory with a .pvmrc file

You can configure your shell to automatically run `pvm use` when entering a directory containing a `.pvmrc` file.

### bash

Put this at the end of your `~/.bashrc` after `pvm` initialization:

```sh
cdpvm() {
  command cd "$@" || return $?

  pvm_path="$(pvm_find_up .pvmrc | command tr -d '\n')"

  if [ -z "$pvm_path" ]; then
    default_version="$(pvm version default 2>/dev/null)"

    if [ "$default_version" = "N/A" ] || [ -z "$default_version" ]; then
      pvm alias default python
      default_version="$(pvm version default)"
    fi

    if [ "$(pvm current)" != "$default_version" ]; then
      pvm use default
    fi
  elif [ -s "${pvm_path}/.pvmrc" ] && [ -r "${pvm_path}/.pvmrc" ]; then
    pvm_version="$(cat "${pvm_path}/.pvmrc")"
    resolved_pvm_version="$(pvm version "$pvm_version")"

    if [ "$resolved_pvm_version" = "N/A" ]; then
      pvm install "$pvm_version"
    elif [ "$(pvm current)" != "$resolved_pvm_version" ]; then
      pvm use "$pvm_version"
    fi
  fi
}

alias cd='cdpvm'
cdpvm "$PWD" || exit
```

### zsh

Put this into your `~/.zshrc` after `pvm` initialization:

```sh
autoload -U add-zsh-hook

load-pvmrc() {
  local pvmrc_path
  pvmrc_path="$(pvm_find_pvmrc)"

  if [ -n "$pvmrc_path" ]; then
    local pvmrc_python_version
    pvmrc_python_version="$(pvm version "$(cat "${pvmrc_path}")")"

    if [ "$pvmrc_python_version" = "N/A" ]; then
      pvm install
    elif [ "$pvmrc_python_version" != "$(pvm version)" ]; then
      pvm use
    fi
  elif [ -n "$(PWD=$OLDPWD pvm_find_pvmrc)" ] && [ "$(pvm version)" != "$(pvm version default)" ]; then
    echo "Reverting to pvm default version"
    pvm use default
  fi
}

add-zsh-hook chpwd load-pvmrc
load-pvmrc
```

After saving the file, reload the configuration:

```sh
source ~/.zshrc
```

## Environment Variables

`pvm` exposes the following environment variables:

```sh
PVM_DIR      # pvm installation directory
PVM_BIN      # bin directory for the active Python version
PVM_INC      # include directory for the active Python version
PVM_VERSION  # currently active Python version
PVM_RC_VERSION # version read from .pvmrc if used
```

`pvm` modifies `PATH` when changing versions.

If present, it may also update variables such as:

```sh
MANPATH
PYTHONPATH
```

`PYTHONPATH` should usually not be set globally unless you know exactly why you need it.

## Bash Completion

To activate bash completion, source `bash_completion`:

```sh
[[ -r $PVM_DIR/bash_completion ]] && \. $PVM_DIR/bash_completion
```

Put this line below the `pvm.sh` source line in your shell profile:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"
[[ -r "$PVM_DIR/bash_completion" ]] && \. "$PVM_DIR/bash_completion"
```

Example completions:

```sh
pvm <TAB>
```

Commands:

```txt
alias
cache
current
deactivate
exec
help
install
list
list-remote
ls
ls-remote
run
unalias
uninstall
unload
use
version
version-remote
venv
which
```

## Compatibility Issues

`pvm` may encounter problems when non-default Python environment settings are present.

Common problematic environment variables:

```sh
PYTHONHOME
PYTHONPATH
PIP_PREFIX
PIP_TARGET
VIRTUAL_ENV
```

If you are inside an active virtual environment, deactivate it before switching Python versions:

```sh
deactivate
pvm use 3.12
```

If `python` still points to the wrong version, check your `PATH`:

```sh
echo "$PATH"
command -v python
command -v python3
```

Make sure the active `pvm` version appears before system Python paths.

## Uninstalling / Removal

### Manual Uninstall

To remove `pvm` manually, run:

```sh
pvm_dir="${PVM_DIR:-~/.pvm}"
pvm unload
rm -rf "$pvm_dir"
```

Then edit your shell profile file, such as `~/.bashrc`, `~/.bash_profile`, `~/.zshrc`, or `~/.profile`, and remove these lines:

```sh
export PVM_DIR="$HOME/.pvm"
[ -s "$PVM_DIR/pvm.sh" ] && \. "$PVM_DIR/pvm.sh"
[[ -r "$PVM_DIR/bash_completion" ]] && \. "$PVM_DIR/bash_completion"
```

Restart your terminal.

## Docker For Development Environment

To make development and testing easier, you can create a Docker image for `pvm` development:

```dockerfile
FROM ubuntu:22.04

RUN apt update && apt install -y bash curl git make shellcheck build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
  libffi-dev liblzma-dev tk-dev

WORKDIR /root/.pvm
COPY . /root/.pvm

CMD ["bash"]
```

Build it:

```sh
docker build -t pvm-dev .
```

Run it:

```sh
docker run --rm -it pvm-dev
```

Inside the container:

```sh
. ./pvm.sh
pvm install 3.12
pvm use 3.12
python -V
```

## Problems

If installation fails, clear the cache and try again:

```sh
pvm cache clear
pvm install 3.12
```

If Python fails to build from source, verify that system dependencies are installed.

If `pip` is missing after installing Python, run:

```sh
python -m ensurepip --upgrade
python -m pip install --upgrade pip setuptools wheel
```

If a command uses the wrong Python version:

```sh
pvm current
command -v python
command -v pip
echo "$PATH"
```

If you are using a virtual environment, deactivate it first:

```sh
deactivate
pvm use 3.12
```

## Project Support

Only the latest version of `pvm` is supported.

## License

MIT License.

## Copyright notice

Copyright PVM contributors.
