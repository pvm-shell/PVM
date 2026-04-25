# Windows Implementation Plan - PVM

The Windows version of PVM will be a native Go application to ensure zero-dependency execution and proper integration with Windows environment variables and symlinks.

## Architecture

- **Root Directory**: `%LOCALAPPDATA%\pvm`
- **Versions**: `%LOCALAPPDATA%\pvm\versions\<version>`
- **Active Version**: Symlink (Junction) at `%LOCALAPPDATA%\pvm\current`
- **PATH**: `%LOCALAPPDATA%\pvm\current` added to User PATH registry.

## Go Module Structure (`/windows`)

```text
/windows/
  ├── main.go          # Entry point and command router
  ├── commands/        # Command implementations (install, use, etc.)
  ├── utils/           # Symlink, HTTP, and Registry helpers
  ├── pvm.cmd          # CLI Wrapper
  └── install.cmd      # Installer
```

## Logic Detail

### `pvm use <version>`
1. Validate version existence in `versions/`.
2. Delete existing `current` symlink/junction.
3. Create new junction `current` -> `versions/<version>`.
4. Ensure `current` is in User PATH.

### `pvm install <version>`
1. Download `python-<version>-embed-amd64.zip` from python.org.
2. Extract to `versions/<version>`.
3. Add a `python.exe` shim if necessary or ensure the embeddable zip is functional for general use.
   - *Note*: Embeddable Python requires some `.pth` file adjustments to include site-packages if pip is used.

## Configuration (`settings.txt`)

```ini
root: C:\Users\<User>\AppData\Local\pvm
path: C:\Users\<User>\AppData\Local\pvm\current
mirror: https://www.python.org/ftp/python/
```
