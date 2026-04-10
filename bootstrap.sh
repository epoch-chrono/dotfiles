#!/bin/sh
# ──────────────────────────────────────────────────
# bootstrap.sh — minimal bootstrap for dotfiles
# ──────────────────────────────────────────────────
# Installs the bare minimum to get chezmoi running:
#   1. System packages: git, curl, fish
#   2. chezmoi (official installer)
#   3. chezmoi init --apply (pulls repo, runs templates)
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/epoch-chrono/dotfiles/main/bootstrap.sh | sh
#
# After this, chezmoi's run_once_before scripts handle:
#   - mise (cross-platform toolchain manager)
#   - fisher + fish plugins
#   - post-setup (chsh, completions, etc.)
# ──────────────────────────────────────────────────
set -eu

DOTFILES_REPO="epoch-chrono"

info()  { printf '\033[0;34m[info]\033[0m  %s\n' "$1"; }
warn()  { printf '\033[0;33m[warn]\033[0m  %s\n' "$1"; }
error() { printf '\033[0;31m[error]\033[0m %s\n' "$1" >&2; exit 1; }

# ── Detect OS + package manager ───────────────────
install_system_packages() {
    info "Detecting package manager..."

    if [ -e /etc/NIXOS ]; then
        info "NixOS detected — skipping system packages (managed by nix flake)"
        return 0
    elif command -v apt-get >/dev/null 2>&1; then
        info "Debian/Ubuntu detected (apt)"
        sudo apt-get update -qq
        sudo apt-get install -y -qq git curl fish build-essential
    elif command -v dnf >/dev/null 2>&1; then
        info "Fedora/RHEL detected (dnf)"
        sudo dnf install -y -q git curl fish gcc make
    elif command -v apk >/dev/null 2>&1; then
        info "Alpine detected (apk)"
        sudo apk add --quiet git curl fish build-base
    elif command -v pacman >/dev/null 2>&1; then
        info "Arch detected (pacman)"
        sudo pacman -Sy --noconfirm --quiet git curl fish base-devel
    elif command -v brew >/dev/null 2>&1; then
        info "macOS/Homebrew detected"
        brew install git curl fish
    elif [ "$(uname -s)" = "Darwin" ]; then
        info "macOS detected — installing Homebrew first..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        brew install git curl fish
    else
        error "Unsupported OS or package manager. Install git, curl, and fish manually."
    fi
}

# ── Install chezmoi ───────────────────────────────
install_chezmoi() {
    if command -v chezmoi >/dev/null 2>&1; then
        info "chezmoi already installed: $(chezmoi --version)"
        return 0
    fi

    info "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
}

# ── Apply dotfiles ────────────────────────────────
apply_dotfiles() {
    info "Initializing dotfiles from github.com/${DOTFILES_REPO}/dotfiles..."
    chezmoi init --apply "$DOTFILES_REPO"
}

# ── Main ──────────────────────────────────────────
main() {
    info "Starting dotfiles bootstrap..."
    install_system_packages
    install_chezmoi
    apply_dotfiles
    info "Bootstrap complete. Restart your shell or run: exec fish -l"
}

main "$@"
