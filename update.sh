#!/usr/bin/env bash
set -Eeuo pipefail

# Safely update the checkout without replacing the private local bots.json.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/bots.json"
VENV_PYTHON="${SCRIPT_DIR}/venv/bin/python"
CONFIG_BACKUP=""

restore_config() {
    if [[ -n "${CONFIG_BACKUP}" && -f "${CONFIG_BACKUP}" ]]; then
        cp -p -- "${CONFIG_BACKUP}" "${CONFIG_FILE}"
        chmod 600 "${CONFIG_FILE}"
        rm -f -- "${CONFIG_BACKUP}"
        CONFIG_BACKUP=""
    fi
}

cleanup() {
    restore_config
}
trap cleanup EXIT

if ! git -C "${SCRIPT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This folder is not a Git checkout."
    exit 1
fi

if [[ ! -x "${VENV_PYTHON}" ]]; then
    echo "Python virtual environment not found."
    echo "Run ./install.sh first."
    exit 1
fi

if [[ -f "${CONFIG_FILE}" ]]; then
    CONFIG_BACKUP="$(mktemp "${TMPDIR:-/tmp}/discord-radio-bots-config.XXXXXX")"
    chmod 600 "${CONFIG_BACKUP}"
    cp -p -- "${CONFIG_FILE}" "${CONFIG_BACKUP}"
    echo "Private bots.json safely backed up for the update."
fi

echo "Fetching the latest GitHub changes..."
git -C "${SCRIPT_DIR}" pull --ff-only

# Restore the private configuration before dependency checks or service restart.
restore_config
trap - EXIT

echo "Updating Python dependencies..."
"${VENV_PYTHON}" -m pip install -r "${SCRIPT_DIR}/requirements.txt"

echo "Checking Python syntax..."
"${VENV_PYTHON}" -m py_compile "${SCRIPT_DIR}/main.py" "${SCRIPT_DIR}/configure.py"

echo "Restarting Discord Radio Bots..."
sudo systemctl restart discord-radio.service
sudo systemctl --no-pager --full status discord-radio.service

echo
echo "Update complete. Your private bots.json was preserved."
