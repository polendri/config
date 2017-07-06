System and application configuration for my servers and workstations.

# Usage

Note that this repo uses Git submodules (for Vim plugins), so when cloning this repository use
the `--recursive` option in order to clone submodules as well.

# Contents

## Systems

Contains configurations specific to individual systems. Currently they're all running
[NixOS](https://nixos.org/), so aside from application preferences these files are basically
complete definitions of my system setups.

### psh-server

Home server running NixOS, OpenSSH, Syncthing, Radicale, Transmission, Samba and other services.

### psh-xps13

My personal laptop workstation, running NixOS and KDE 5.

## Dotfiles

Various configuration dotfiles for applications I use regularly across many systems. These can
be used by creating symlinks to them in your home directory on the system.

