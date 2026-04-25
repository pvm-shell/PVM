#!/usr/bin/env sh

PVM_DIR="${PVM_DIR:-$HOME/.pvm}"

pvm() {
  command="${1:-help}"
  shift 2>/dev/null || true

  case "$command" in
    help|-h|--help)
      echo "PVM - Python Version Manager"
      echo ""
      echo "Usage:"
      echo "  pvm help"
      echo "  pvm current"
      echo "  pvm ls"
      ;;
    current)
      python -V
      ;;
    ls|list)
      if [ -d "$PVM_DIR/versions" ]; then
        ls "$PVM_DIR/versions"
      else
        echo "No Python versions installed."
      fi
      ;;
    *)
      echo "pvm: unknown command: $command"
      echo "Run 'pvm help' for usage."
      return 1
      ;;
  esac
}
