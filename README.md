# cross-seed Shared Environment (seedbox) installation script

<div align="center">

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/zakkarry/cross-seed-seedbox-builder.svg)](https://github.com/zakkarry/cross-seed-seedbox-builder/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/zakkarry/cross-seed-seedbox-builder.svg)](https://github.com/zakkarry/cross-seed-seedbox-builder/pulls)
[![GitHub stars](https://img.shields.io/github/stars/zakkarry/cross-seed-seedbox-builder.svg)](https://github.com/zakkarry/cross-seed-seedbox-builder/stargazers)
[![Support](https://img.shields.io/badge/buy%20me-coffee-tan)](https://tip.ary.dev)
[![Sponsor on GitHub](https://img.shields.io/github/sponsors/zakkarry)](https://github.com/sponsors/zakkarry/)

</div>

## I'm on a updated Debian server (11 or above) or Ubuntu, do I still need to use this script to update/install?

You can and may need to if you are in a shared seedbox environment, this script builds cross-seed from the source repository
and sets certain environmental variables in the `cross-seed` alias that are commonly needed for share environments - such as seedboxes.
If you do not have access to the system level npm, node, or python then you will probably need to utilize this script and follow the instructions
below (preqrequisites for usage) - It's very simple.

### NEW ANNOUNCEMENT

Yes, this script streamlines the procedure and requirements for cross-seed into one command after installing the pre-requiresites (pyenv and nvm/node). There are unique aspects to
shared seedbox environments that are handled automatically.

The script has been updated to account for the updated OS servers as well as the legacy debian versions, and should handle all conditions appropriately.

If you've ran the "ultra.cc" version before, simply make sure you are on the correct versions of node (22 LTS) and python (`pyenv global 3.10` or above - if you are using another version of python in pyenv simply run `pyenv install 3.10` and then use the previous `pyenv global 3.10` command before executing the cross-seed script) then run this script as you always have if you've used this before successfully, and it will take care of everything automatically.

## What is it?

This is cross-seed-source-build (originally ultra.cc cross-seed installation script (ultraxs)). After installing the prerequisites listed below in [this](#versions-of-the-following-software-need-to-be-explicitly-followed) section, you simply run `bash <(wget -qO- https://raw.githubusercontent.com/zakkarry/cross-seed-source-build/refs/heads/master/install_shared_env_xs.sh)`
and you can then always just re-run the script to install a different version or update your instance of cross-seed.

## This is my first time, what do I do?

Follo wthe instructions below in order, and make sure you choose the correct versions. If you have any issues, feel free to come visit us [at our discord](https://discord.gg/jpbUFzS5Wb).

### Versions of the following software need to be explicitly followed!

These scripts are provided courtesy of ultra.cc - they are easy 1-2 step scripts to select a version on pyenv (Python version management) and nvm (Node version manager) to install prior to using the cross-seed build script. You will have control of your own instances of python and node.js in your user directory. This may override your system-level versions of node nad python, so you may want to consult your seedbox provider or try and run the commands `node --version` or `python --version` prior to starting to see what versions you have and if they are possible to use, however most shared seedbox providers do not allow these applications to be managed at a user level and it really can't hurt to just install pyenv and nvm yourself using the scripts below.

Even though they are ultra.cc's scripts, they have been confirmed to work on other providers. If you have any issues, check your seedbox providers documentation pages first to see if they provide scripts or instructions of their own for installing your own version of python and node.

For this, you will want **Python 3.10** or above, and **Node.js v22 LTS**.

> You will need to do the following steps in order listed below, installing the versions noted in each command:
>
> - Installing the latest version of [Node **LTS (22.x)**](https://docs.ultra.cc/books/unofficial-language-installers-3AK/page/install-nodejs):
>
>   `bash <(wget -qO- https://scripts.ultra.cc/util-v2/LanguageInstaller/Node-Installer/main.sh)`
>
> - Install **v3.10 or above** (recommended to run 3.10 unless you have reason to need a different version) of [**Python**](https://docs.ultra.cc/books/unofficial-language-installers-3AK/page/install-python-using-pyenv):
>
>   `bash <(wget -qO- https://scripts.ultra.cc/util-v2/LanguageInstaller/Python-Installer/main.sh)`
>
> - **Exit your SSH session and log back in (or restart the terminal session to load the new "environment" containing python and node commands)**
>
> - Install cross seed with the source building script
>
>   `bash <(wget -qO- https://raw.githubusercontent.com/zakkarry/cross-seed-source-build/refs/heads/master/install_shared_env_xs.sh)`
>
> **Be aware of the different available versions you are prompted to install. Descriptions of each version are described in the prompts**

### Notes on required versions

- If you have previously installed any wrong versions, you can simply rerun the scripts to uninstall and reinstall
- If you use a different version of node with nvm already or selected the wrong version, simply use `nvm install 22` and `nvm use 22` to add **v22.x LTS**

## How do I update?

If you've already installed cross-seed successfully using this script, simply run it again to update.
When you select a version, it detects an instance from this script has been installed and it will check for new versions and prompt you to update.

## I have a feature or idea!

Please make a issue here on github, describe your issue or feature request in detail.

## I have found a bug!

Please make a github issue and describe the steps to reproduce this bug.
