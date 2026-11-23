#!/usr/bin/env bash
set -euo pipefail

# Ensure a Conda environment is active
if [[ -z "${CONDA_PREFIX:-}" ]]; then
    echo "ERROR: No active Conda environment."
    exit 1
fi

echo "Installing pyads into: $CONDA_PREFIX"

# Install Python and pip using the configured Conda channels
conda install -y python pip

# Install pyads and its Python dependencies
python -m pip install --upgrade pyads

# Verify installation
python - <<'PY'
import sys
import pyads

print(f"Python: {sys.executable}")
print(f"pyads version: {getattr(pyads, '__version__', 'unknown')}")
print("pyads installation successful.")
PY

echo "Installation complete."
