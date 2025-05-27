# Ultra.cc cross-seed installation script

<div align="center">

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/zakkarry/ultraxs.svg)](https://github.com/zakkarry/ultraxs/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/zakkarry/ultraxs.svg)](https://github.com/zakkarry/ultraxs/pulls)
[![GitHub stars](https://img.shields.io/github/stars/zakkarry/ultraxs.svg)](https://github.com/zakkarry/ultraxs/stargazers)
[![Support](https://img.shields.io/badge/buy%20me-coffee-tan)](https://tip.ary.dev)

</div>

## I'm on a updated debian server, do I still need to use this script to update/install?

You can, this script builds the repository for cross-seed from source and sets certain environmental variables
that are commonly needed for share environments - such as those in shared seedboxes. If you do not have access
to npm, node, or python at a system level then you will probably need to utilize this script and follow the instructions
below. It's very simple.

### NEW ANNOUNCEMENT

Yes, this script streamlines the procedure and requirements for cross-seed into one command. There are unique aspects to
shared seedbox environments that are handled automatically.

The script has been updated to account for the updated OS servers and the old style, and will handle both appropriately.

Simply run this script as you always have, if you've used this before, and it will take care of the rest.

## What is it?

This is cs-source-build (originally ultra.cc cross-seed installation script (ultraxs)). After installing the prerequisites listed below in [this](#versions-of-the-following-software-need-to-be-explicitly-followed) section, you simply run `bash <(wget -qO- https://raw.githubusercontent.com/zakkarry/cross-seed-source-build/refs/heads/master/install_shared_env_xs.sh)`
and run the script to install or update your instance of cross-seed.

## This is my first time, what do I do?

If you have any issues, feel free to come visit us [at our discord](https://discord.gg/jpbUFzS5Wb).

### Versions of the following software need to be explicitly followed!

These scripts are being use courtesy of ultra.cc - they are easy 1-2 step scripts to select a version on pyenv (Python version management) and nvm (Node version manager) to install prior, so you
will have control of your own instances of python and node.js in your user directory. This may override your system-level versions of node nad python, so you may want to consult your seedbox provider or try and run the commands `node --version` or `python --version` prior to starting to see what versions you have.

For this, you will want **Python 3.10** or above, and we recommend **Node.js v22 LTS**.

> You can now install the latest version of cross-seed by:
>
> - Installing the latest version of [Node **LTS (22.x)**](https://docs.ultra.cc/books/unofficial-language-installers-3AK/page/install-nodejs): `bash <(wget -qO- https://scripts.ultra.cc/util-v2/LanguageInstaller/Node-Installer/main.sh)`
>
> - Install **v3.10 or above** version of [**Python**](https://docs.ultra.cc/books/unofficial-language-installers-3AK/page/install-python-using-pyenv): `bash <(wget -qO- https://scripts.ultra.cc/util-v2/LanguageInstaller/Python-Installer/main.sh)`
>
> - **Exit your SSH session and log back in (restarting the terminal session and loading the new "environment")**
>
> - Install cross seed with `bash <(wget -qO- https://raw.githubusercontent.com/zakkarry/cross-seed-source-build/refs/heads/master/install_shared_env_xs.sh)` - **Be aware of the different available versions you are prompted to install.**

### Notes on required versions

- If you have previously installed the wrong versions, you can simply rerun the scripts to uninstall and reinstall
- If you use a different version of node with nvm already, simply use `nvm install 22` and `nvm use 22` to add v22.x LTS

## How do I update?

If you've already installed using this script, simply run it again to update.
When it detects an instance from this script installed, it will check the versions and prompt you to update.

## I have a feature or idea!

Please make a issue here on github, describe your issue or feature request in detail.

## I have found a bug!

Please make a github issue and describe the steps to reproduce this bug.
