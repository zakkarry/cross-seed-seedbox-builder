#!/bin/bash
#
# This cross-seed install script is written by zakkarry (https://github.com/zakkarry)
# a cross-seed dev working to bring cross-seed to legacy OS's which do not have support
# for proper glibc or other compiling libraries.
#
# There is also (if supported by your OS) the option to install the master or nightly branch
# if you do not have the capabilities to do so via Docker or npm due to permissions, etc
#
# If you find any problems or would like to make any suggestions, you can make a
# GitHub issue on the repository for this script at https://github.com/zakkarry/cross-seed-legacy

# Define the directory to check
CS_GIT_DIR="$HOME/.xs-git"
PACKAGE_JSON="$CS_GIT_DIR/package.json"
INSTALL_BRANCH="stable"

# Function to parse the version from package.json
get_local_version() {
  if [ -f "$PACKAGE_JSON" ]; then
    sed -n '3s/.*"\([^"]\+\)".*/v\1/p' "$PACKAGE_JSON"
  else
    echo "N/A"
  fi
}

check_dependencies() {
    for cmd in git npm node curl python; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Error: $cmd is required but not installed."
            echo "Please reference the README on the GitHub repository for instructions on installation or contact cross-seed support."
            exit 1
        fi
    done
}

get_os_version() {
  if [ ! -f /etc/os-release ]; then
    echo "Error: Cannot detect OS version. /etc/os-release not found."
    echo "Proceeding with normal installation type. If you encounter issues contact cross-seed support."
    VERSION_ID="11"
  else
    VERSION_ID=$(grep -oP '(?<=^VERSION_ID=)"?\K[0-9]+' /etc/os-release)
    if [[ "$VERSION_ID" == "10" ]]; then
        INSTALL_BRANCH="legacy"
    elif [[ "$VERSION_ID" -gt 10 ]]; then
        INSTALL_BRANCH="stable"
        echo "Please select an option:"
        echo "1) stable (default/recommended latest stable release)"
        echo "2) master (latest including pre-releases)"
        echo "3) nightly (considered experimental!)"
        # shellcheck disable=SC2162
        read -p "Enter your choice [1]: " choice

        # Process the selection
        case $choice in
            3)
                INSTALL_BRANCH="nightly"
                ;;
            2)
                INSTALL_BRANCH="master"
                ;;
            1)
                INSTALL_BRANCH="stable"
                ;;
            *)
                echo "Invalid option. Using default: stable"
                INSTALL_BRANCH="stable"
                ;;
        esac

        echo "You selected: $INSTALL_BRANCH"
    else
        echo "Unsupported OS version detected. Contact Support. Exiting."
        exit 1
    fi
    echo
    echo "Detected OS version successfully. Proceeding installation for cross-seed branch: $INSTALL_BRANCH"
  fi
}

# Function to get the latest version from GitHub
get_latest_version_remote() {
  if ! curl -s https://api.github.com/repos/cross-seed/cross-seed/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'; then
    echo "Error: Failed to fetch latest version from GitHub"
    exit 1
  fi
}

get_last_version_remote() {
  if ! curl -s https://api.github.com/repos/cross-seed/cross-seed/releases | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | head -n 1; then
    echo "Error: Failed to fetch releases from GitHub"
    exit 1
  fi
}

get_stable_version() {
    cd "$CS_GIT_DIR" || exit 1
    git tag --sort=-v:refname | grep -v '-' | head -n 1
}

cleanup_all_old_dirs() {
    rm -rf "$HOME/.cs-ultra"
    rm -rf "$CS_GIT_DIR"
}

cleanup_old_dirs() {
    rm -rf "$HOME/.cs-ultra"
}

# Function to set up alias for cross-seed daemon
setup_alias() {
  ALIAS_CMD="alias cross-seed=\"NODE_OPTIONS=--disable-wasm-trap-handler NODE_VERSION=22 node $CS_GIT_DIR/dist/cmd.js\""
  if ! grep -Fxq "$ALIAS_CMD" "$HOME/.bashrc"; then
    echo "$ALIAS_CMD" >>"$HOME/.bashrc"
    echo "Alias 'cross-seed' added. Please restart your shell or run 'source ~/.bashrc' before attempting to start cross-seed."
  else
    echo "Alias 'cross-seed' is already set up. You may run cross-seed now."
  fi
  echo
}

check_dependencies
get_os_version

# Main logic
if [ -d "$HOME/.cs-ultra" ]; then
    echo
    echo "Detected previous installation of ultra.cc cross-seed script..."
    echo "Now purging source directory for legacy script (re)installation."
    echo
    cleanup_old_dirs
fi

if [ -d "$CS_GIT_DIR" ]; then
  # EXISTING INSTALLATION LOGIC
  local_version=$(get_local_version)
  echo "Local version detected: $local_version"
  echo
  # shellcheck disable=SC2162
  read -p "Do you want to reinstall/replace your local version with the selected version ($INSTALL_BRANCH) of cross-seed? (y/n): " choice
  
  if [ "$choice" == "y" ]; then
    if [ "$INSTALL_BRANCH" == "master" ]; then
      latest_version=$(get_last_version_remote)
    else
      latest_version=$(get_latest_version_remote)
    fi
    echo "Latest version: $latest_version"
    echo
    
    if [ "$local_version" == "N/A" ]; then
      echo "Critical files are missing or corrupted/faulty install has been detected."
      echo "Full reinstallation is necessary."
      echo
      # shellcheck disable=SC2162
      read -p "Do you want to proceed? (y/n): " reinstall_choice
      echo
      if [ "$reinstall_choice" == "y" ]; then
        echo "Reinstalling..."
        echo
        cleanup_all_old_dirs
        if ! git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR"; then
          echo "Error: Failed to clone repository. Check your internet connection."
          exit 1
        fi
        cd "$CS_GIT_DIR" || exit 1
        echo "$INSTALL_BRANCH"
        if [ "$INSTALL_BRANCH" == "stable" ]; then
          INSTALL_BRANCH="${INSTALL_BRANCH/stable/$(get_stable_version)}"
        fi
        echo "$INSTALL_BRANCH"
        if ! git checkout "$INSTALL_BRANCH"; then
          echo "Error: Failed to checkout branch $INSTALL_BRANCH"
          exit 1
        fi
        if [ "$INSTALL_BRANCH" == "legacy" ]; then
          sed -i 's/"better-sqlite3": "\^11\.5\.0",/"better-sqlite3": "^9.4.0",/' "$PACKAGE_JSON"
        fi
        if ! npm install .; then
            echo "Error: npm install failed. Check your Node.js installation. The README on the GitHub repository contains installation instructions for nvm if you need them."
            exit 1
        fi
        echo
        echo "Transpiling cross-seed..."
        if ! npm run build; then
          echo "Error: Build failed"
          exit 1
        fi
        echo "Reinstallation complete."
        echo
        setup_alias
        exit 0
      else
        echo "Reinstallation canceled."
        exit 0
      fi
    elif [ "$local_version" != "$latest_version" ]; then
      echo "A different version than your local has been selected or is available."
      # shellcheck disable=SC2162
      read -p "Do you want to (re)install/update? (y/n): " update_choice
      if [ "$update_choice" == "y" ]; then
        echo "Installing selected version ($INSTALL_BRANCH): $latest_version"
        echo
        cleanup_all_old_dirs
        if ! git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR"; then
          echo "Error: Failed to clone repository. Check your internet connection."
          exit 1
        fi
        cd "$CS_GIT_DIR" || exit 1
        echo "$INSTALL_BRANCH"
        if [ "$INSTALL_BRANCH" == "stable" ]; then
          INSTALL_BRANCH="${INSTALL_BRANCH/stable/$(get_stable_version)}"
        fi
        echo "$INSTALL_BRANCH"
        if ! git checkout "$INSTALL_BRANCH"; then
          echo "Error: Failed to checkout branch $INSTALL_BRANCH"
          exit 1
        fi
        if [ "$INSTALL_BRANCH" == "legacy" ]; then
          sed -i 's/"better-sqlite3": "\^11\.5\.0",/"better-sqlite3": "^9.4.0",/' "$PACKAGE_JSON"
        fi
        if ! npm install .; then
            echo "Error: npm install failed. Check your Node.js installation. The README on the GitHub repository contains installation instructions for nvm if you need them."
            exit 1
        fi
        echo
        echo "Transpiling cross-seed..."
        if ! npm run build; then
          echo "Error: Build failed"
          exit 1
        fi
        echo "Update complete."
        echo
        setup_alias
        exit 0
      else
        echo "Update canceled."
        exit 0
      fi
    else
      echo "You are already on the selected version."
      echo
      echo "If you NEED to reinstall for some reason, delete the directory $CS_GIT_DIR and run the script again."
      echo
      exit 0
    fi
  else
    echo "Exiting."
    exit 0
  fi
else
  # FRESH INSTALLATION LOGIC
  echo "Local installation not present."
  echo
  # shellcheck disable=SC2162
  read -p "Do you want to install the selected version ($INSTALL_BRANCH) of cross-seed? (y/n): " choice
  
  if [ "$choice" == "y" ]; then
    echo "Directory $CS_GIT_DIR does not exist. The cross-seed repository will be cloned to this directory."
    echo
    # shellcheck disable=SC2162
    read -p "Do you want to install? (y/n): " install_choice
    echo
    if [ "$install_choice" == "y" ]; then
      echo "Installing..."
      if ! git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR"; then
        echo "Error: Failed to clone repository. Check your internet connection."
        exit 1
      fi
      cd "$CS_GIT_DIR" || exit 1
      echo "$INSTALL_BRANCH"
      if [ "$INSTALL_BRANCH" == "stable" ]; then
        INSTALL_BRANCH="${INSTALL_BRANCH/stable/$(get_stable_version)}"
      fi
      echo "$INSTALL_BRANCH"
      if ! git checkout "$INSTALL_BRANCH"; then
        echo "Error: Failed to checkout branch $INSTALL_BRANCH"
        exit 1
      fi
      if [ "$INSTALL_BRANCH" == "legacy" ]; then
        sed -i 's/"better-sqlite3": "\^11\.5\.0",/"better-sqlite3": "^9.4.0",/' "$PACKAGE_JSON"
      fi
      if ! npm install .; then
          echo "Error: npm install failed. Check your Node.js installation. The README on the GitHub repository contains installation instructions for nvm if you need them."
          exit 1
      fi
      echo
      echo "Transpiling cross-seed..."
      if ! npm run build; then
        echo "Error: Build failed"
        exit 1
      fi
      echo "Installation complete."
      echo
      setup_alias
      exit 0
    else
      echo "Exiting."
      exit 0
    fi
  else
    echo "Exiting."
    exit 0
  fi
fi