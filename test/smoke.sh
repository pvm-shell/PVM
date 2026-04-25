#!/bin/sh
# smoke.sh - Smoke tests for PVM

echo "Running smoke tests..."
pvm help || exit 1
pvm current || exit 1
echo "Tests passed!"
