# Ultra.cc cross-seed installation script

<div align="center">

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/zakkarry/ultraxs.svg)](https://github.com/zakkarry/ultraxs/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/zakkarry/ultraxs.svg)](https://github.com/zakkarry/ultraxs/pulls)
[![GitHub stars](https://img.shields.io/github/stars/zakkarry/ultraxs.svg)](https://github.com/zakkarry/ultraxs/stargazers)
[![Support](https://img.shields.io/badge/buy%20me-coffee-tan)](https://tip.ary.dev)

</div>

## I'm on a updated debian server, do I still need to use this script to update/install?

### NEW ANNOUNCEMENT

Yes, this script streamlines the procedure and requirements for cross-seed into one command. There are unique aspects to
shared seedbox environments that are handled automatically.

The script has been updated to account for the updated OS servers and the old style, and will handle both appropriately.

Simply run this script as you always have, and it will take care of the rest.

## This is awesome, can I donate/tip you for this?

Please do. https://tip.ary.dev for my buymeacoffee.

## What is it?

This is cross-seed-legacy (originally ultra.cc cross-seed installation script) - you simply set `chmod +x install_legacy_xs.sh`
and run the script to install or update your instance of cross-seed.

## How do I use this?

This is a quote from ultra.cc on [their Discord](https://discord.com/channels/427913240316477443/427914848702038026/1320729360700932190) - this should work on all shared seedbox environments in the same way. If you have issues, visit the
cross-seed discord for support or open an issue.

### Versions of the following software need to be explicitly followed!

> You can now install the latest version of cross-seed by:
>
> - Installing the latest version of [Node **LTS (22.x)**](https://docs.ultra.cc/books/unofficial-language-installers-3AK/page/install-nodejs): `bash <(wget -qO- https://scripts.ultra.cc/util-v2/LanguageInstaller/Node-Installer/main.sh)`
>
> - Install **v3.10 or above** version of [Python](https://docs.ultra.cc/books/unofficial-language-installers-3AK/page/install-python-using-pyenv): `bash <(wget -qO- https://scripts.ultra.cc/util-v2/LanguageInstaller/Python-Installer/main.sh)`
>
> Then, with thanks to the dev from cross-seed, zakkarry, who has created a custom script:
>
> - Install cross seed with `bash <(wget -qO- https://raw.githubusercontent.com/zakkarry/cross-seed-legacyOS/refs/heads/master/install_legacy_xs.sh)`

### Notes on required versions

- If you have previously installed the wrong versions, rerun the scripts to uninstall and reinstall
- If you use a different version of node with nvm already, simply use `nvm install 22` and `nvm use 22` to add v22.x LTS

## How do I update?

If you've already installed using this script, simply run it again to update.
When it detects an instance from this script installed, it will check the versions and prompt you to update.

## I have a feature or idea!

Please make a issue here on github, describe your issue or feature request in detail.

## I have found a bug!

Please make a github issue and describe the steps to reproduce this bug.
