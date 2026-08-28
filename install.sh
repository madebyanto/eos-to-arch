#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OS_RELEASE_SRC="${SCRIPT_DIR}/os/os-release"
OS_RELEASE_DST="/etc/os-release"
OS_RELEASE_BAK="/etc/os-release.bak"

ICON_SVG_SRC="${SCRIPT_DIR}/assets/scalable/arch.svg"
ICON_48_SRC="${SCRIPT_DIR}/assets/48x48/arch.png"
ICON_256_SRC="${SCRIPT_DIR}/assets/256x256/arch.png"

ICON_SVG_DST="/usr/share/icons/hicolor/scalable/apps/arch.svg"
ICON_48_DST="/usr/share/icons/hicolor/48x48/apps/arch.png"
ICON_256_DST="/usr/share/icons/hicolor/256x256/apps/arch.png"

ICON_THEME_DIR="/usr/share/icons/hicolor"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

err() {
    echo -e "${RED}[ERROR]${RESET} $*" >&2
}

info() {
    echo -e "${CYAN}[INFO]${RESET}  $*"
}

ok() {
    echo -e "${GREEN}[OK]${RESET}    $*"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET}  $*"
}

if [[ "${EUID}" -ne 0 ]]; then
    err "This script must be run as root (e.g. sudo ./install.sh)."
    exit 1
fi

info "Checking current distribution..."
if [[ ! -f "${OS_RELEASE_DST}" ]]; then
    err "File ${OS_RELEASE_DST} not found."
    exit 1
fi

source "${OS_RELEASE_DST}"

if [[ "${ID:-}" != "endeavouros" ]]; then
    err "This system does not appear to be EndeavourOS (ID='${ID:-unknown}')."
    err "This script is intended to run only on EndeavourOS."
    exit 1
fi

ok "EndeavourOS detected (ID=${ID}, VERSION_ID=${VERSION_ID:-n/a})."

info "Checking required project files..."
MISSING=0
for f in "${OS_RELEASE_SRC}" "${ICON_SVG_SRC}" "${ICON_48_SRC}" "${ICON_256_SRC}"; do
    if [[ ! -f "${f}" ]]; then
        err "Required file not found: ${f}"
        MISSING=1
    fi
done
if [[ "${MISSING}" -eq 1 ]]; then
    err "One or more required project files are missing. Aborting."
    exit 1
fi
ok "All required project files found."

info "Backing up ${OS_RELEASE_DST} to ${OS_RELEASE_BAK}..."
if cp "${OS_RELEASE_DST}" "${OS_RELEASE_BAK}"; then
    ok "Backup saved to ${OS_RELEASE_BAK}."
else
    err "Failed to create backup of ${OS_RELEASE_DST}."
    exit 1
fi

info "Replacing ${OS_RELEASE_DST} with custom Arch Linux version..."
if cp "${OS_RELEASE_SRC}" "${OS_RELEASE_DST}"; then
    chmod 644 "${OS_RELEASE_DST}"
    ok "${OS_RELEASE_DST} updated successfully."
else
    err "Failed to copy ${OS_RELEASE_SRC} to ${OS_RELEASE_DST}."
    exit 1
fi

info "Installing Arch Linux icons..."

for dir in \
    "/usr/share/icons/hicolor/scalable/apps" \
    "/usr/share/icons/hicolor/48x48/apps" \
    "/usr/share/icons/hicolor/256x256/apps"
do
    if [[ ! -d "${dir}" ]]; then
        info "Creating directory: ${dir}"
        mkdir -p "${dir}"
    fi
done

install_icon() {
    local src="$1"
    local dst="$2"
    if cp "${src}" "${dst}"; then
        chmod 644 "${dst}"
        ok "Installed: ${dst}"
    else
        err "Failed to install icon: ${src} -> ${dst}"
        exit 1
    fi
}

install_icon "${ICON_SVG_SRC}" "${ICON_SVG_DST}"
install_icon "${ICON_48_SRC}"  "${ICON_48_DST}"
install_icon "${ICON_256_SRC}" "${ICON_256_DST}"

info "Updating icon cache..."
if command -v gtk-update-icon-cache &>/dev/null; then
    if gtk-update-icon-cache -f -t "${ICON_THEME_DIR}" 2>/dev/null; then
        ok "Icon cache updated successfully."
    else
        warn "gtk-update-icon-cache returned a non-zero exit code. Icons may still work correctly."
    fi
else
    warn "gtk-update-icon-cache not found. Skipping icon cache update."
fi

echo
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}${GREEN}  Conversion to Arch Linux completed successfully!${RESET}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo
echo -e "  ${BOLD}Summary of changes:${RESET}"
echo -e "  • Original os-release backed up  → ${OS_RELEASE_BAK}"
echo -e "  • New os-release installed        → ${OS_RELEASE_DST}"
echo -e "  • Scalable SVG icon installed     → ${ICON_SVG_DST}"
echo -e "  • 48x48 PNG icon installed        → ${ICON_48_DST}"
echo -e "  • 256x256 PNG icon installed      → ${ICON_256_DST}"
echo
echo -e "  ${YELLOW}A logout/reboot may be needed for all changes to take effect.${RESET}"
echo