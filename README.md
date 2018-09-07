# PwnDock

This is an attempt at a faster, easier-to-setup version of [pwnvm](https://github.com/OpenToAllCTF/pwnvm).

## Setup
1. Install Docker: `brew cask install docker` on OSX. You can figure it out on Linux.
2. Replace the Dockerfile with your customizations, basing off of `grazfather/pwndock:latest`. See [here](https://github.com/Grazfather/mypwndock/blob/master/Dockerfile) for an example.
3. Build: `./build`

## Running it
Management: `start`, `stop`, `connect`
