#!/bin/bash
# ==============================================================================
# Water AI — Linux Installer Script
# ==============================================================================
#
# This script is executed by the makeself .run self-extracting installer.
# It installs the Water AI application with:
#   - Binary and launcher in /opt/Water/
#   - Desktop entry in ~/.local/share/applications/
#   - Icons in ~/.local/share/icons/hicolor/
#   - Mesa software renderer fallback libraries
#
# Usage: This script is called automatically by the .run installer.
#        It can also be run manually from the extracted directory.
#
# ==============================================================================

set -euo pipefail

APP_NAME="Water"
APP_ID="ai.water.app"
INSTALL_DIR="/opt/${APP_NAME}"
ICON_DIR="${HOME}/.local/share/icons/hicolor"
DESKTOP_DIR="${HOME}/.local/share/applications"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Colors for output --------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# --- Validate extracted contents ----------------------------------------------
info "Validating installer contents..."

REQUIRED_FILES=(
    "bin/${APP_NAME}"
    "${APP_NAME}"
    "icons/logo.png"
    "icons/logo-only.png"
    "icons/vscode.png"
)

for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "${SCRIPT_DIR}/${f}" ]; then
        error "Missing required file: ${f}"
        error "The installer archive appears to be incomplete."
        exit 1
    fi
done

info "All required files present."

# --- Install application ------------------------------------------------------
info "Installing ${APP_NAME} to ${INSTALL_DIR}..."

# Create install directory (needs sudo for /opt)
if [ -w "$(dirname "${INSTALL_DIR}")" ]; then
    mkdir -p "${INSTALL_DIR}/bin" "${INSTALL_DIR}/lib/dri" "${INSTALL_DIR}/icons"
else
    sudo mkdir -p "${INSTALL_DIR}/bin" "${INSTALL_DIR}/lib/dri" "${INSTALL_DIR}/icons"
fi

# Copy binary
if [ -w "${INSTALL_DIR}" ]; then
    cp "${SCRIPT_DIR}/bin/${APP_NAME}" "${INSTALL_DIR}/bin/${APP_NAME}"
    chmod +x "${INSTALL_DIR}/bin/${APP_NAME}"
else
    sudo cp "${SCRIPT_DIR}/bin/${APP_NAME}" "${INSTALL_DIR}/bin/${APP_NAME}"
    sudo chmod +x "${INSTALL_DIR}/bin/${APP_NAME}"
fi

# Copy launcher script
if [ -w "${INSTALL_DIR}" ]; then
    cp "${SCRIPT_DIR}/${APP_NAME}" "${INSTALL_DIR}/${APP_NAME}"
    chmod +x "${INSTALL_DIR}/${APP_NAME}"
else
    sudo cp "${SCRIPT_DIR}/${APP_NAME}" "${INSTALL_DIR}/${APP_NAME}"
    sudo chmod +x "${INSTALL_DIR}/${APP_NAME}"
fi

# Copy icons
for icon in logo.png logo-only.png vscode.png; do
    if [ -w "${INSTALL_DIR}" ]; then
        cp "${SCRIPT_DIR}/icons/${icon}" "${INSTALL_DIR}/icons/${icon}"
    else
        sudo cp "${SCRIPT_DIR}/icons/${icon}" "${INSTALL_DIR}/icons/${icon}"
    fi
done

# Copy Mesa software renderer libraries (if present)
if [ -d "${SCRIPT_DIR}/lib" ]; then
    if [ -w "${INSTALL_DIR}" ]; then
        cp -a "${SCRIPT_DIR}/lib/"* "${INSTALL_DIR}/lib/" 2>/dev/null || true
    else
        sudo cp -a "${SCRIPT_DIR}/lib/"* "${INSTALL_DIR}/lib/" 2>/dev/null || true
    fi
    info "Mesa software renderer libraries installed."
fi

info "Application files installed to ${INSTALL_DIR}"

# --- Install icons to XDG icon directories ------------------------------------
info "Installing desktop icons..."

mkdir -p "${ICON_DIR}/48x48/apps"
mkdir -p "${ICON_DIR}/128x128/apps"
mkdir -p "${ICON_DIR}/256x256/apps"
mkdir -p "${ICON_DIR}/scalable/apps"

# Use logo-only.png as the app icon (it's the icon without text)
for size_dir in 48x48 128x128 256x256; do
    cp "${SCRIPT_DIR}/icons/logo-only.png" "${ICON_DIR}/${size_dir}/apps/${APP_ID}.png"
done

# Also install to a generic location for fallback
cp "${SCRIPT_DIR}/icons/logo-only.png" "${ICON_DIR}/scalable/apps/${APP_ID}.png"

# Update icon cache if available
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t "${ICON_DIR}" 2>/dev/null || true
fi

info "Icons installed to ${ICON_DIR}"

# --- Create .desktop file ----------------------------------------------------
info "Creating desktop entry..."

mkdir -p "${DESKTOP_DIR}"

cat > "${DESKTOP_DIR}/${APP_ID}.desktop" << EOF
[Desktop Entry]
Type=Application
Name=${APP_NAME}
Comment=Water AI Assistant
Exec=${INSTALL_DIR}/${APP_NAME} %U
Icon=${APP_ID}
Terminal=false
Categories=Development;Utility;
StartupNotify=true
StartupWMClass=${APP_NAME}
MimeType=x-scheme-handler/water;
EOF

# Validate the desktop file if desktop-file-validate is available
if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "${DESKTOP_DIR}/${APP_ID}.desktop" 2>/dev/null || true
fi

# Update desktop database if available
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${DESKTOP_DIR}" 2>/dev/null || true
fi

info "Desktop entry created at ${DESKTOP_DIR}/${APP_ID}.desktop"

# --- Create symlink in /usr/local/bin for PATH access -------------------------
SYMLINK_PATH="/usr/local/bin/water"
if [ -w "$(dirname "${SYMLINK_PATH}")" ]; then
    ln -sf "${INSTALL_DIR}/${APP_NAME}" "${SYMLINK_PATH}"
    info "Symlink created: ${SYMLINK_PATH} -> ${INSTALL_DIR}/${APP_NAME}"
elif command -v sudo >/dev/null 2>&1; then
    sudo ln -sf "${INSTALL_DIR}/${APP_NAME}" "${SYMLINK_PATH}" 2>/dev/null || \
        warn "Could not create symlink at ${SYMLINK_PATH} (run with sudo for PATH access)"
else
    warn "Could not create symlink at ${SYMLINK_PATH} (no sudo available)"
fi

# --- Done ---------------------------------------------------------------------
echo ""
info "╔══════════════════════════════════════════════════════════════╗"
info "║           ${APP_NAME} AI installed successfully!                  ║"
info "╠══════════════════════════════════════════════════════════════╣"
info "║  Install location: ${INSTALL_DIR}"
info "║  Launch from:      Application menu or run 'water' in terminal"
info "║  Desktop entry:    ${DESKTOP_DIR}/${APP_ID}.desktop"
info "╚══════════════════════════════════════════════════════════════╝"
echo ""
