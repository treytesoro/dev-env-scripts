#!/bin/bash

echo #
read -p "*****************************************************************************
*  !Warning!                                                                *
*                                                                           *
*  This script will attempt to set up a WSL2 only Docker host environment.  *
*  It will set your iptables to legacy mode and remove any Docker Desktop   *
*  remnance.                                                                *
*                                                                           *
*  If you have not already done so, please uninstall Docker Desktop if      *
*  it is still installed prior to running this script.                      *
*****************************************************************************

Are you sure? (Y/N): " -n 1 -r

echo #

if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff

	echo "Adding you sudoers no password list..."
	echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$USER-for-sudo-password"

	printf "\n[user]\ndefault = $USER\n" | sudo tee -a /etc/wsl.conf
	
	echo "Removing any residual Docker components"
	sudo apt -y remove docker docker-engine docker.io containerd runc > /dev/null 2>&1
	echo "Installing pre-requisites"
	sudo apt -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2 > /dev/null 2>&1

	# select legacy
	# sudo update-alternatives --config iptables
	echo "Setting iptables to legacy mode (required by our Docker configuration)"
	sudo update-alternatives --set iptables $(update-alternatives --list iptables | grep "legacy") > /dev/null 2>&1

 	# load release variables into current environment
	. /etc/os-release

	echo "Downloading docker..."
	curl -fsSL https://download.docker.com/linux/${ID}/gpg | sudo tee /etc/apt/trusted.gpg.d/docker.asc > /dev/null 2>&1
	echo "deb [arch=amd64] https://download.docker.com/linux/${ID} ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null 2>&1
	sudo apt -y update > /dev/null 2>&1
	sudo apt -y install docker-ce docker-ce-cli containerd.io > /dev/null 2>&1

	echo "Adding you to docker group"
	sudo usermod -aG docker $USER > /dev/null 2>&1
	
	## Get NodeJS v20.11
	echo "Installing NodeJS v20.11..."
	sudo apt-get install curl > /dev/null 2>&1
	curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash - > /dev/null 2>&1
	sudo apt-get install nodejs > /dev/null 2>&1
	
	echo "Installing OpenSSH server..."
	sudo apt-get -y install openssh-server > /dev/null 2>&1
	
	## update .profile
	cat  >> ~/.profile <<'EOF'
if ! [[ $(sudo service ssh status | grep "sshd is running") ]]; then
    sudo service ssh start
fi

if ! [[ $(ps -a | grep "dockerd") ]]; then
    echo "Starting docker daemon";
    nohup sudo -b /usr/bin/dockerd > /dev/null 2>&1
fi

EOF

fi

echo "Done"
