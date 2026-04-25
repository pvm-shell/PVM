#!/usr/bin/env sh

set -e

PVM_DIR="${PVM_DIR:-$HOME/.pvm}"
REPO_URL="https://github.com/pvm-shell/PVM.git"

echo "Installing PVM..."

if [ -d "$PVM_DIR" ]; then
  echo "PVM already exists at $PVM_DIR"
else
  git clone "$REPO_URL" "$PVM_DIR"
fi

mkdir -p "$PVM_DIR/versions"

PROFILE="${PROFILE:-$HOME/.profile}"

if [ -f "$HOME/.bashrc" ]; then
  PROFILE="$HOME/.bashrc"
fi

if [ -f "$HOME/.zshrc" ]; then
  PROFILE="$HOME/.zshrc"
fi

if ! grep -q 'PVM_DIR' "$PROFILE" 2>/dev/null; then
  {
    echo ''
    echo 'export PVM_DIR="$HOME/.pvm"'
    echo '[ -s "$PVM_DIR/pvm.sh" ] && . "$PVM_DIR/pvm.sh"'
  } >> "$PROFILE"
fi

echo "PVM installed successfully."
echo "Restart your terminal or run:"
echo ". \"$PVM_DIR/pvm.sh\""
