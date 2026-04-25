#!/bin/sh
# release.sh - Release script placeholder

VERSION=$(grep "VERSION =" windows/pvm.go | cut -d'"' -f2)
echo "Releasing PVM version $VERSION..."
# Steps: tag git, build windows binary, etc.
