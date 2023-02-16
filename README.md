# My WSL2 dev environment scripts

Run `setupdev.ps1` elevated to begin setup.

This script will enable Hyper-V, reboot, then start up the `_apps.ps1` script.

### _apps.ps1
1. Installs VSCode, NodeJS LTS, and Git.
2. Sets up Ubuntu 22.04 in WSL2.
3. Runs the linux portion by executing `setupwsl.h` inside the Ubuntu WSL2 intance.