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
#

# Define the directory to check
CS_GIT_DIR="$HOME/.xs-git"
PACKAGE_JSON="$CS_GIT_DIR/package.json"
INSTALL_BRANCH="master"

# Function to parse the version from package.json
get_local_version() {
  if [ -f "$PACKAGE_JSON" ]; then
    sed -n '3s/.*"\([^"]\+\)".*/v\1/p' "$PACKAGE_JSON"
  #  sed -n '3s/.*"\([^"]\+\)".*/\1/p' "$PACKAGE_JSON"
  else
    echo "N/A"
  fi
}

get_os_version() {
  VERSION_ID=$(grep -oP '(?<=^VERSION_ID=)"?\K[0-9]+' /etc/os-release)
  if [[ "$VERSION_ID" == "10" ]]; then
      INSTALL_BRANCH="legacy"
  elif [[ "$VERSION_ID" -gt 10 ]]; then
      INSTALL_BRANCH="master"
      echo "Please select an option:"
      echo "1) master (default - includes pre-release)"
      echo "2) nightly (considered experimental!)"
      read -p "Enter your choice [1]: " choice

      # Process the selection
      case $choice in
          2)
              INSTALL_BRANCH="nightly"
              ;;
          1|"")
              INSTALL_BRANCH="master"
              ;;
          *)
              echo "Invalid option. Using default: master"
              INSTALL_BRANCH="master"
              ;;
      esac

      echo "You selected: $INSTALL_BRANCH"
  else
      echo "Unsupported OS version detected. Contact Support. Exiting."
      exit 1
  fi
  echo
  echo "Detected OS version successfully. Switching to branch: $INSTALL_BRANCH"

}
# Function to get the latest version from GitHub
get_latest_version() {
  curl -s https://api.github.com/repos/cross-seed/cross-seed/releases/latest |
    grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}
cleanup_old_dirs() {
    rm -rf "$HOME/.cs-ultra"
    rm -rf "$CS_GIT_DIR"
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
get_os_version
# Main logic
if [ -d "$HOME/.cs-ultra" ] || [ -d "$CS_GIT_DIR" ]; then
  echo
  echo "Detected previous ultra.cc installation of cross-seed...purging remnants."
  echo
  cleanup_old_dirs
  #local_version=$(get_local_version)
  #echo "Local version: $local_version"

  # shellcheck disable=SC2162
  read -p "Do you want to reinstall with the updated script? " choice

  if [ "$choice" == "y" ]; then
    latest_version=$(get_latest_version)
    

    echo "Latest version: $latest_version"
    echo
    if [ "$local_version" == "N/A" ]; then
      echo "Critical files are missing or previous install was detected. Full reinstallation is necessary."
      # shellcheck disable=SC2162
      read -p "Do you want to reinstall? (y/n): " reinstall_choice
      echo
      if [ "$reinstall_choice" == "y" ]; then
        echo "Reinstalling..."
        echo
        cleanup_old_dirs
        git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR"
        cd "$CS_GIT_DIR" || exit
        git checkout $INSTALL_BRANCH
        npm install .
        echo
        echo "Transpiling cross-seed..."
        npm run build
        echo "Reinstallation complete."
        echo
        setup_alias
      else
        echo "Reinstallation canceled."
      fi
    elif [ "$local_version" != "$latest_version" ]; then
      # shellcheck disable=SC2162
      read -p "A new version is available. Do you want to update? (y/n): " update_choice
      if [ "$update_choice" == "y" ]; then
        echo "Updating to version $latest_version..."
        echo
        cleanup_old_dirs
        git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR"
        cd "$CS_GIT_DIR" || exit
        git checkout $INSTALL_BRANCH
        npm install .
        echo
        echo "Transpiling cross-seed..."
        npm run build
        echo "Update complete."
        echo
        setup_alias
      else
        echo "Update canceled."
      fi
    else
      echo "You are already on the latest version."
    fi
  else
    echo "Exiting."
    exit 0
  fi
else
  echo "Directory $CS_GIT_DIR does not exist."
  # shellcheck disable=SC2162
  read -p "Do you want to install? (y/n): " install_choice
  echo
  if [ "$install_choice" == "y" ]; then
    echo "Installing..."
    git clone https://github.com/cross-seed/cross-seed.git "$CS_GIT_DIR"
    cd "$CS_GIT_DIR" || exit
    git checkout $INSTALL_BRANCH
    npm install .
    echo
    echo "Transpiling cross-seed..."
    npm run build
    echo "Installation complete."
    echo
    setup_alias
  else
    echo "Exiting."
    exit 0
  fi
fi
