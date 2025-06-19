#!/usr/bin/env bash
# Simple helper to install Python dependencies for the FinOps toolkit
set -e

if ! command -v python3 >/dev/null; then
  echo "python3 is required but not found" >&2
  exit 1
fi

# Use pip associated with python3
PYTHON="$(command -v python3)"
PIP="$PYTHON -m pip"

# Upgrade pip and install requirements
$PIP install --upgrade pip >/dev/null
$PIP install -r requirements.txt
$PIP install -e . >/dev/null

echo "Dependencies installed"
