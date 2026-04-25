# DESIGN.md

## Architecture

PVM is a shell-based Python version manager.

Core components:

- `pvm.sh` → CLI entrypoint
- `install.sh` → installer
- `versions/` → installed Python versions
- `cache/` → downloaded archives
- `alias/` → version aliases

## Flow

1. User runs command
2. Command parsed in `pvm.sh`
3. Version resolved
4. PATH updated
5. Python executed

## Principles

- Simple
- Transparent
- POSIX-first
- No magic behavior
