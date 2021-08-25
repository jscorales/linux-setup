#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

CWD=$(pwd)

delay_after_message=3

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run with sudo (sudo -i)"
    exit 1
fi

read -p "Please enter your username: " target_user

if id -u "$target_user" >/dev/null 2>&1; then
    echo "User $target_user exists! Proceeding.. "
else
    echo 'The username you entered does not seem to exist.'
    exit 1
fi

# function to run command as non-root user
run_as_user() {
    sudo -u $target_user bash -c "$1"
}

apt update
apt install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common -y

# Docker
printf "${YELLOW}Installing Docker ${NC}\n"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install docker-ce docker-ce-cli containerd.io -y

# Docker Compose
printf "${YELLOW}Installing Docker ${NC}\n"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Docker user group
usermod -aG docker $USER
newgrp docker

# Copy docker daemon config
cp ./docker/daemon.json /etc/docker/daemon.json
