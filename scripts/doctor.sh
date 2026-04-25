#!/bin/sh
# pvm-doctor - Health check for PVM

echo "Checking PVM installation..."

if [ -z "$PVM_DIR" ]; then
  echo "✖ PVM_DIR is not set."
else
  echo "✔ PVM_DIR: $PVM_DIR"
fi

if command -v pvm >/dev/null 2>&1; then
  echo "✔ pvm command is available."
else
  echo "✖ pvm command not found."
fi

echo "Checking dependencies..."
for cmd in aria2c curl wget tar make gcc; do
  if command -v $cmd >/dev/null 2>&1; then
    echo "✔ $cmd is installed."
  else
    echo "⚠ $cmd is missing."
  fi
done
