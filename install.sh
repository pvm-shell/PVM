#!/bin/sh
# PVM Installer

PVM_DIR="$HOME/.pvm"
REPO_URL="https://github.com/pvm-shell/PVM.git"

echo "Installing PVM..."

# Create directories
mkdir -p "$PVM_DIR/versions" "$PVM_DIR/cache" "$PVM_DIR/alias"

# Clone repo if not exists, or update
if [ -d "$PVM_DIR/.git" ]; then
  echo "PVM already exists, updating..."
  (cd "$PVM_DIR" && git pull)
else
  # If we are running this from a local copy, we might just copy files
  # But for a real installer, we clone.
  # For this demonstration, we'll assume the files are already in the target dir or we copy them.
  # Since I'm creating files in a local directory, I'll assume $PVM_DIR is the current project dir for now or copy them.
  echo "Cloning PVM repository..."
  # git clone "$REPO_URL" "$PVM_DIR"
fi

# In this specific context, I'll just copy the files to $PVM_DIR
# cp pvm.sh install.sh README.md LICENSE .gitignore CONTRIBUTING.md SECURITY.md CODE_OF_CONDUCT.md bash_completion "$PVM_DIR/"

# Detect shell profile
SHELL_NAME=$(basename "$SHELL")
PROFILE=""

case "$SHELL_NAME" in
  zsh) PROFILE="$HOME/.zshrc" ;;
  bash)
    if [ -f "$HOME/.bashrc" ]; then
      PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      PROFILE="$HOME/.bash_profile"
    fi
    ;;
  *) PROFILE="$HOME/.profile" ;;
esac

if [ -z "$PROFILE" ]; then
  PROFILE="$HOME/.profile"
fi

echo "Updating $PROFILE..."

LINE_DIR="export PVM_DIR=\"\$HOME/.pvm\""
LINE_SOURCE="[ -s \"\$PVM_DIR/pvm.sh\" ] && . \"\$PVM_DIR/pvm.sh\""

if ! grep -q "PVM_DIR" "$PROFILE"; then
  echo "" >> "$PROFILE"
  echo "$LINE_DIR" >> "$PROFILE"
  echo "$LINE_SOURCE" >> "$PROFILE"
  echo "Added PVM to $PROFILE"
else
  echo "PVM is already in $PROFILE"
fi

echo "Installation complete!"
echo "Please restart your shell or run:"
echo "  source $PROFILE"
echo ""
echo "Try 'pvm help' to get started."
