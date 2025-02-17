#!/bin/sh

# Connect bash RC
ln -s ~/Code/AC/dots/.bashrc ~/.bashrc
ln -s ~/Code/AC/dots/.gitconfig ~/.gitconfig
ln -s ~/Code/AC/dots/.gitignore ~/.gitignore

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install brew basic packages
brew install qlcolorcode qlmarkdown
brew install gh python deno jq ngrok exiftool

# Install databases
# Can be started via "brew services start mysql" (or stopped)
brew install sqlite mysql postgresql redis

# Install cloud clis
brew install awscli google-cloud-sdk
