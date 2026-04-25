#!/bin/sh
# PVM - Python Version Manager
# POSIX-compliant shell script to manage Python versions.

# Default PVM_DIR if not set
: "${PVM_DIR:="$HOME/.pvm"}"

pvm_echo() {
  printf "pvm: %s\n" "$1"
}

pvm_error() {
  printf "pvm: error: %s\n" "$1" >&2
}

pvm_ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

pvm_strip_path() {
  # Remove all PVM-related paths from PATH
  # This is a bit tricky in POSIX shell without sed/awk, but we might use them as they are usually available
  # However, let's try to keep it simple.
  if [ -n "$PATH" ]; then
    PATH=$(printf "%s" "$PATH" | sed -e "s|:$PVM_DIR/versions/[^/]*/bin||g" -e "s|$PVM_DIR/versions/[^/]*/bin:||g" -e "s|$PVM_DIR/versions/[^/]*/bin||g")
    export PATH
  fi
}

pvm_resolve_version() {
  local version="$1"
  if [ -f "$PVM_DIR/alias/$version" ]; then
    cat "$PVM_DIR/alias/$version"
  else
    echo "$version"
  fi
}

pvm_download() {
  local url="$1"
  local output="$2"
  
  if command -v aria2c >/dev/null 2>&1; then
    aria2c -x 16 -s 16 -k 1M -o "$(basename "$output")" -d "$(dirname "$output")" "$url"
  elif command -v curl >/dev/null 2>&1; then
    curl -L -o "$output" "$url"
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$output" "$url"
  else
    pvm_error "No download tool found (aria2c, curl, or wget required)."
    return 1
  fi
}

pvm_help() {
  echo "PVM - Python Version Manager"
  echo
  echo "Usage:"
  echo "  pvm help                          Show this message"
  echo "  pvm version [--check]             Show version or check for updates"
  echo "  pvm verify <file> <hash>          Verify file integrity (SHA-256)"
  echo "  pvm install <version>             Install a Python version"
  echo "  pvm use <version>                 Use a Python version"
  echo "  pvm current                       Show the current Python version"
  echo "  pvm system                        Show the system Python version"
  echo "  pvm ls                            List installed versions"
  echo "  pvm ls-remote                     List available versions from python.org"
  echo "  pvm alias <name> <version>        Create an alias for a version"
  echo "  pvm unalias <name>                Remove an alias"
  echo "  pvm which <version>               Show the path to a version's executable"
  echo "  pvm run <version> -- <command>    Run a command within a version environment"
  echo "  pvm exec <version> -- <command>   Execute a command within a version environment"
  echo "  pvm venv <path>                   Create a virtualenv with the current version"
  echo "  pvm deactivate                    Remove PVM from PATH"
  echo "  pvm uninstall <version>           Remove a Python version"
  echo "  pvm cache clear                   Clear the download cache"
  echo
}

pvm_ls_remote() {
  pvm_echo "Fetching versions from python.org..."
  if command -v curl >/dev/null 2>&1; then
    curl -s https://www.python.org/ftp/python/ \
    | grep -Eo 'href="[0-9]+\.[0-9]+\.[0-9]+/' \
    | cut -d'"' -f2 \
    | tr -d '/'
  else
    pvm_error "curl is required for ls-remote."
  fi
}

pvm_ls() {
  if [ ! -d "$PVM_DIR/versions" ]; then
    pvm_echo "No versions installed."
    return
  fi
  ls "$PVM_DIR/versions"
}

pvm_current() {
  if [ -n "$PVM_VERSION" ]; then
    echo "$PVM_VERSION"
  else
    pvm_echo "No version currently in use."
  fi
}

pvm_system() {
  if command -v python3 >/dev/null 2>&1; then
    echo "System Python: $(python3 --version 2>&1)"
    echo "Path: $(command -v python3)"
  elif command -v python >/dev/null 2>&1; then
    echo "System Python: $(python --version 2>&1)"
    echo "Path: $(command -v python)"
  else
    echo "No system Python found."
    return 1
  fi
}

pvm_version() {
  local current_version="0.1.0-alpha"
  if [ "$1" = "--check" ]; then
    pvm_echo "Checking for PVM updates..."
    if ! command -v curl >/dev/null 2>&1; then
      pvm_error "curl is required for version check."
      return 1
    fi
    local latest_tag
    latest_tag=$(curl -s https://api.github.com/repos/pvm-shell/PVM/releases/latest | grep -Po '"tag_name": "\K[^"]*')
    if [ -z "$latest_tag" ]; then
      pvm_error "Could not fetch latest version from GitHub."
      return 1
    fi
    if [ "$latest_tag" != "v$current_version" ]; then
      pvm_echo "New version available: $latest_tag (Current: v$current_version)"
    else
      pvm_echo "PVM is up to date: $latest_tag"
    fi
  else
    echo "pvm v$current_version"
  fi
}

pvm_verify() {
  local file="$1"
  local expected="$2"
  if [ -z "$file" ] || [ -z "$expected" ]; then
    pvm_error "Usage: pvm verify <file> <hash>"
    return 1
  fi

  pvm_echo "Verifying $file..."
  local actual=""
  if command -v sha256sum >/dev/null 2>&1; then
    actual=$(sha256sum "$file" | cut -d' ' -f1)
  elif command -v openssl >/dev/null 2>&1; then
    actual=$(openssl dgst -sha256 "$file" | sed 's/.*= //')
  elif command -v shasum >/dev/null 2>&1; then
    actual=$(shasum -a 256 "$file" | cut -d' ' -f1)
  else
    pvm_error "No SHA-256 tool found (sha256sum, openssl, or shasum required)."
    return 1
  fi

  pvm_echo "Actual: $actual"
  pvm_echo "Expected: $expected"

  if [ "$actual" = "$expected" ]; then
    pvm_echo "✅ Verification SUCCESS: Hashes match!"
  else
    pvm_error "❌ Verification FAILED: Hashes do NOT match!"
    return 1
  fi
}

pvm_install() {
  local version="$1"
  if [ -z "$version" ]; then
    pvm_error "Version required."
    return 1
  fi

  local install_dir="$PVM_DIR/versions/$version"
  if [ -d "$install_dir" ]; then
    pvm_echo "Python $version is already installed."
    return 0
  fi

  pvm_ensure_dir "$PVM_DIR/cache"
  pvm_ensure_dir "$PVM_DIR/versions"

  local tarball="Python-$version.tgz"
  local url="https://www.python.org/ftp/python/$version/$tarball"
  local output="$PVM_DIR/cache/$tarball"

  pvm_echo "Downloading Python $version from $url..."
  if ! pvm_download "$url" "$output"; then
    return 1
  fi

  pvm_echo "Extracting Python $version..."
  local build_root="$PVM_DIR/cache/build"
  pvm_ensure_dir "$build_root"
  tar -xzf "$output" -C "$build_root"
  
  local build_dir="$build_root/Python-$version"

  pvm_echo "Building Python $version (this may take a while)..."
  (
    cd "$build_dir" || exit 1
    pvm_echo "Running ./configure..."
    ./configure --prefix="$install_dir" --enable-optimizations > pvm_build.log 2>&1
    
    local nproc_cmd
    if command -v nproc >/dev/null 2>&1; then nproc_cmd="nproc"; else nproc_cmd="echo 2"; fi
    
    pvm_echo "Running make..."
    make -j$($nproc_cmd) >> pvm_build.log 2>&1
    
    pvm_echo "Running make install..."
    make install >> pvm_build.log 2>&1
  )

  if [ -f "$install_dir/bin/python3" ] || [ -f "$install_dir/bin/python" ]; then
    pvm_echo "Successfully installed Python $version to $install_dir"
    # Clean up build dir
    rm -rf "$build_dir"
  else
    pvm_error "Installation failed. Check $build_dir/pvm_build.log for details."
    return 1
  fi
}

pvm_use() {
  local version="$1"
  
  if [ "$version" = "system" ]; then
    pvm_strip_path
    unset PVM_VERSION PVM_BIN
    pvm_echo "Now using system Python"
    pvm_system
    return 0
  fi

  if [ -z "$version" ]; then
    # Search for .pvmrc
    local dir="$PWD"
    while [ "$dir" != "/" ] && [ ! -f "$dir/.pvmrc" ]; do
      dir=$(dirname "$dir")
    done
    if [ -f "$dir/.pvmrc" ]; then
      version=$(cat "$dir/.pvmrc")
    else
      pvm_error "No version specified and no .pvmrc found."
      return 1
    fi
  fi

  local resolved=$(pvm_resolve_version "$version")
  local install_dir="$PVM_DIR/versions/$resolved"

  if [ ! -d "$install_dir" ]; then
    pvm_error "Python $resolved is not installed. Run 'pvm install $resolved' first."
    return 1
  fi

  pvm_strip_path
  export PVM_VERSION="$resolved"
  export PVM_BIN="$install_dir/bin"
  export PATH="$PVM_BIN:$PATH"
  pvm_echo "Now using Python $resolved"
}

pvm_alias() {
  local name="$1"
  local version="$2"
  if [ -z "$name" ] || [ -z "$version" ]; then
    pvm_error "Usage: pvm alias <name> <version>"
    return 1
  fi
  pvm_ensure_dir "$PVM_DIR/alias"
  echo "$version" > "$PVM_DIR/alias/$name"
  pvm_echo "Alias $name -> $version created."
}

pvm_unalias() {
  local name="$1"
  if [ -z "$name" ]; then
    pvm_error "Usage: pvm unalias <name>"
    return 1
  fi
  rm -f "$PVM_DIR/alias/$name"
  pvm_echo "Alias $name removed."
}

pvm_which() {
  local version="$1"
  if [ -z "$version" ]; then
    version="$PVM_VERSION"
  fi
  local resolved=$(pvm_resolve_version "$version")
  local bin="$PVM_DIR/versions/$resolved/bin/python3"
  if [ -f "$bin" ]; then
    echo "$bin"
  else
    pvm_error "Version $resolved not found."
    return 1
  fi
}

pvm_uninstall() {
  local version="$1"
  if [ -z "$version" ]; then
    pvm_error "Usage: pvm uninstall <version>"
    return 1
  fi
  local resolved=$(pvm_resolve_version "$version")
  rm -rf "$PVM_DIR/versions/$resolved"
  pvm_echo "Python $resolved uninstalled."
}

pvm_cache_clear() {
  rm -rf "$PVM_DIR/cache"/*
  pvm_echo "Cache cleared."
}

pvm() {
  local cmd="$1"
  shift

  case "$cmd" in
    help) pvm_help ;;
    version) pvm_version "$@" ;;
    verify) pvm_verify "$@" ;;
    install) pvm_install "$@" ;;
    use) pvm_use "$@" ;;
    current) pvm_current ;;
    system) pvm_system ;;
    ls) pvm_ls ;;
    ls-remote) pvm_ls_remote ;;
    alias) pvm_alias "$@" ;;
    unalias) pvm_unalias "$@" ;;
    which) pvm_which "$@" ;;
    uninstall) pvm_uninstall "$@" ;;
    cache) 
      if [ "$1" = "clear" ]; then
        pvm_cache_clear
      else
        pvm_error "Unknown cache command: $1"
      fi
      ;;
    deactivate) 
      pvm_strip_path
      unset PVM_VERSION PVM_BIN
      pvm_echo "PVM deactivated."
      ;;
    run|exec)
      local version="$1"
      shift
      if [ "$1" = "--" ]; then
        shift
      fi
      local resolved=$(pvm_resolve_version "$version")
      local bin="$PVM_DIR/versions/$resolved/bin"
      PATH="$bin:$PATH" "$@"
      ;;
    venv)
      if [ -z "$PVM_VERSION" ]; then
        pvm_error "No version in use. Run 'pvm use' first."
        return 1
      fi
      python3 -m venv "$@"
      ;;
    "") pvm_help ;;
    *) pvm_error "Unknown command: $cmd"; pvm_help; return 1 ;;
  esac
}
