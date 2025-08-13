#!/usr/bin/env bash
set -euo pipefail

python -m pip install --upgrade pip
pip install -r requirements.txt

echo
echo "Installed plugins:"
sigma plugin list --plugin-type backend || true
sigma plugin list --plugin-type pipeline || true