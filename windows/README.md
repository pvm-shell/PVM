# PVM for Windows

PVM for Windows provides a native Windows executable for managing multiple Python versions.

## Default Location

```text
%LOCALAPPDATA%\pvm
```

## Directory Structure

```text
pvm
├── pvm.exe
├── settings.txt
├── cache
├── alias
├── versions
└── current
```

## Commands

```powershell
pvm install 3.12.8
pvm use 3.12.8
pvm current
pvm list
pvm uninstall 3.12.8
pvm root
pvm mirror
pvm proxy
pvm version
```

## Notes

Windows support is implemented separately from the POSIX shell version.

* `pvm.sh` is used for Linux, macOS, and WSL.
* `windows/pvm.go` is used for native Windows.
