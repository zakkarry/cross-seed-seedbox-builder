#!/bin/bash
#
# Cross-seed install script by zakkarry (https://github.com/zakkarry)
# Installs cross-seed on legacy OS and shared seedbox environments
# Supports stable, master, nightly, and legacy branches
#
# Issues: https://github.com/zakkarry/cross-seed-seedbox-builder/issues
# Discord: https://discord.gg/jpbUFzS5Wb

set -euo pipefail

# Configuration
readonly CS_GIT_DIR="$HOME/.xs-git"
readonly PACKAGE_JSON="$CS_GIT_DIR/package.json"
readonly BASHRC="$HOME/.bashrc"
readonly ALIAS_URL="https://raw.githubusercontent.com/zakkarry/cross-seed-seedbox-builder/refs/heads/master/alias.rc"

INSTALL_BRANCH="stable"

# Utility functions
log() { echo "$@"; }
# shellcheck disable=SC2145
error() { echo "Error: $@" >&2; exit 1; }
confirm() { 
    local prompt="${1:-Continue?}"
    read -p "$prompt (y/n): " -r
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Dependency checking
check_dependencies() {
    local missing=()
    
    # Check for python/python3
    if ! command -v python >/dev/null 2>&1 && ! command -v python3 >/dev/null 2>&1; then
        missing+=("python or python3")
    fi
    
    # Check other dependencies
    for cmd in git npm node curl; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing dependencies: ${missing[*]}. Please reference the README for installation instructions."
    fi
}

# Version management
get_local_version() {
    [[ -f "$PACKAGE_JSON" ]] && sed -n '3s/.*"\([^"]\+\)".*/v\1/p' "$PACKAGE_JSON" || echo "N/A"
}

get_remote_version() {
    local endpoint="${1:-latest}"
    local url="https://api.github.com/repos/cross-seed/cross-seed/releases"
    [[ "$endpoint" == "latest" ]] && url+="/latest"
    
    curl -s "$url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | head -n 1 ||
        error "Failed to fetch version from GitHub"
}

get_stable_version() {
    cd "$CS_GIT_DIR" && git tag --sort=-v:refname | grep -v '-' | head -n 1
}

# OS detection and branch selection
detect_os_and_select_branch() {
    if [[ ! -f /etc/os-release ]]; then
        log "OS release file not found. Attempting to reinstall base-files...you may be prompted to enter sudo password..."
        echo
        sudo apt-get install --reinstall base-files || true
        [[ ! -f /etc/os-release ]] && log "Warning: Could not detect OS version, proceeding with default."
        echo
    fi
    
    local version_id
    version_id=$(grep -oP '(?<=^VERSION_ID=)"?\K[0-9]+' /etc/os-release 2>/dev/null || echo "11")
    
    if [[ "$version_id" == "10" ]]; then
        log "Detected Debian 10 (legacy). Only legacy installation available."
        echo
        select_option "legacy" "uninstall"
    elif [[ "$version_id" -gt 10 ]]; then
        log "Please select an option:"
        select_option "stable" "master" "nightly" "uninstall"
        echo
    else
        error "Unsupported OS version detected."
    fi
    
    log "Detected OS version ($version_id). Installing cross-seed branch: $INSTALL_BRANCH"
}

select_option() {
    local options=("$@")
    local i=1
    echo
    for option in "${options[@]}"; do
        case "$option" in
            "stable") echo "$i) stable (default/recommended latest stable release)" ;;
            "master") echo "$i) master (latest including pre-releases)" ;;
            "nightly") echo "$i) nightly (considered experimental!)" ;;
            "legacy") echo "$i) legacy (only available option with Debian <11)" ;;
            "uninstall") echo "$i) uninstall (remove cross-seed entirely)" ;;
        esac
        ((i++))
    done
    
    read -p "Enter your choice [1]: " -r choice
    choice=${choice:-1}
    echo
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#options[@]} ]]; then
        INSTALL_BRANCH="${options[$((choice-1))]}"
    else
        log "Invalid option. Using default: ${options[0]}"
        INSTALL_BRANCH="${options[0]}"
    fi
    echo
    [[ "$INSTALL_BRANCH" == "uninstall" ]] && uninstall_cross_seed
    log "You selected: $INSTALL_BRANCH"
    echo
}

# Cleanup functions
cleanup_legacy() {
    rm -rf "$HOME/.cs-ultra"
}

cleanup_all() {
    echo
    log "Removing all previous cross-seed installations..."
    rm -rf "$HOME/.cs-ultra" "$CS_GIT_DIR"
    pkill -f "$CS_GIT_DIR/dist/cmd.js" 2>/dev/null || true
    sed -i '/^cross-seed *()/,/^}/d; /^alias cross-seed=/d' "$BASHRC"
    echo
}

uninstall_cross_seed() {
    echo
    log "Starting uninstall procedure..."
    cleanup_all
    log "Cross-seed removed. Restart your shell or run 'source ~/.bashrc'"
    echo
    exit 0
}

# Installation functions
setup_alias() {
    echo
    log "Setting up cross-seed alias..."
    sed -i '/\.xs-git\|\.cs-ultra/d' "$BASHRC"
    
    if curl -fsSL "$ALIAS_URL" >> "$BASHRC"; then
        log "Successfully updated .bashrc"
        log "Run 'source ~/.bashrc' or restart your shell to apply changes"
        echo
    else
        error "Failed to download alias configuration"
    fi
}

install_cross_seed() {
    local target_branch="$1"
    
    log "Installing cross-seed ($target_branch)..."
    echo
    # Clone repository
    git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR" ||
        error "Failed to clone repository"
    
    cd "$CS_GIT_DIR"
    
    # Handle stable branch (convert to tag)
    if [[ "$target_branch" == "stable" ]]; then
        target_branch=$(get_stable_version)
    fi
    
    # Checkout target branch/tag
    git checkout "$target_branch" || error "Failed to checkout $target_branch"
    
    # Apply legacy compatibility fix
    if [[ "$target_branch" == "legacy" ]]; then
        sed -i 's/"better-sqlite3": "\^11\.5\.0",/"better-sqlite3": "^9.4.0",/' "$PACKAGE_JSON"
    fi
    echo
    # Install dependencies and build
    npm install . || error "npm install failed. Check Node.js installation."
    
    log "Transpiling cross-seed..."
    npm run build || error "Build failed"
    
    log "Installation complete."
    setup_alias
}

# Main installation logic
handle_existing_installation() {
    local local_version remote_version
    local_version=$(get_local_version)
    
    log "Local version detected: $local_version"
    echo
    # Handle corrupted installation
    if [[ "$local_version" == "N/A" ]]; then
        log "Critical files missing or corrupted installation detected."
        if confirm "Full reinstallation is necessary. Proceed?"; then
            echo "Proceeding with wipe and full reinstall..."
            cleanup_all
            install_cross_seed "$INSTALL_BRANCH"
        else
            log "Reinstallation canceled."
            exit 0
        fi
        return
    fi
    
    # Check for updates
    if confirm "c $INSTALL_BRANCH branch?"; then
        remote_version=$(get_remote_version "$([[ $INSTALL_BRANCH == "master" ]] && echo "all" || echo "latest")")
        log "Latest version: $remote_version"
        echo
        # Handle nightly branch
        if [[ "$INSTALL_BRANCH" == "nightly" ]]; then
            log "Nightly is experimental and requires full reinstallation!"
            echo

            if confirm "Install/update to nightly ($(get_remote_version))?"; then
                cleanup_all
                install_cross_seed "$INSTALL_BRANCH"
            elseW
                log "Nightly installation canceled."
                exit 0
            fi
            return
        fi
        
        # Check if update needed
        if [[ "$local_version" != "$remote_version" ]]; then
            echo
            if confirm "Update from $local_version to $remote_version?"; then
                cleanup_all
                install_cross_seed "$INSTALL_BRANCH"
            else
                log "Update canceled."
            fi
        else
            log "You are already on the latest version."
            log "To force reinstall, run with uninstall mode then reinstall."
        fi
    fi
}

handle_fresh_installation() {
    local version
    version=$(get_remote_version "$([[ $INSTALL_BRANCH == "master" ]] && echo "all" || echo "latest")")
    
    log "Local installation not present."
    if confirm "Install $INSTALL_BRANCH ($version) of cross-seed?"; then
        log "Repository will be cloned to $CS_GIT_DIR"
        if confirm "Proceed with installation?"; then
            install_cross_seed "$INSTALL_BRANCH"
        fi
    fi
}

# Main execution
main() {
    check_dependencies
    detect_os_and_select_branch
    
    # Clean up legacy installations
    [[ -d "$HOME/.cs-ultra" ]] && {
        log "Detected legacy installation. Cleaning up..."
        cleanup_legacy
    }
    
    # Handle existing or fresh installation
    if [[ -d "$CS_GIT_DIR" ]]; then
        handle_existing_installation
    else
        handle_fresh_installation
    fi
}

main "$@"