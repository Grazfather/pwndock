# PwnDock

This is an attempt at a faster, easier-to-setup version of [pwnvm](https://github.com/OpenToAllCTF/pwnvm). You should not clone this repo! Use `grazfather/pwndock:latest` in your Dockerfile to grab the latest (and avoid building).

## Setup
1. Install Docker: `brew cask install docker` on OSX. You can figure it out on Linux.
2. Clone [this OTHER repo](https://github.com/Grazfather/mypwndock).
3. Add your customizations to the _Dockerfile_, and the other scripts if you desire, for example, to use a different name.
4. Build: `./build`

## Running it
Management: `start`, `stop`, `connect`
