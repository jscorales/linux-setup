#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

CWD=$(pwd)

# Keyrings dir
KEYRINGS_DIR=/usr/share/keyrings
KEYRINGS_FILENAME_SUFFIX=archive-keyring.gpg
# Sources list dir
APT_SOURCES_DIR=/etc/apt/sources.list.d

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

add_repositories() {
  printf "Adding Repositories"

  # VSCode
  keyrings_filename="microsoft-${KEYRINGS_FILENAME_SUFFIX}"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc |
    sudo gpg --dearmor -o "${KEYRINGS_DIR}/${keyrings_filename}"
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] https://packages.microsoft.com/repos/vscode stable main" |
    sudo tee "${APT_SOURCES_DIR}/vscode.list"

  # Sublime Text
  keyrings_filename="sublime-text-${KEYRINGS_FILENAME_SUFFIX}"
  curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg |
    sudo gpg --dearmor -o "${KEYRINGS_DIR}/${keyrings_filename}"
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] https://download.sublimetext.com/ apt/stable/" |
    sudo tee "${APT_SOURCES_DIR}/sublime-text.list"

  # Brave Browser
  keyrings_filename="brave-browser-${KEYRINGS_FILENAME_SUFFIX}"
  curl -fsSLo "${KEYRINGS_DIR}/${keyrings_filename}" https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] https://brave-browser-apt-release.s3.brave.com/ stable main" |
    sudo tee "${APT_SOURCES_DIR}/brave-browser-release.list"

  # DBeaver
  keyrings_filename="dbeaver-${KEYRINGS_FILENAME_SUFFIX}"
  wget -O - https://dbeaver.io/debs/dbeaver.gpg.key |
    sudo gpg --dearmor -o "${KEYRINGS_DIR}/${keyrings_filename}"
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] https://dbeaver.io/debs/dbeaver-ce /" |
    sudo tee "${APT_SOURCES_DIR}/dbeaver.list"

  # Spotify
  keyrings_filename="spotify-${KEYRINGS_FILENAME_SUFFIX}"
  curl -fsSL https://download.spotify.com/debian/pubkey_0D811D58.gpg |
    sudo gpg --dearmor -o "${KEYRINGS_DIR}/${keyrings_filename}"
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] http://repository.spotify.com stable non-free" |
    sudo tee "${APT_SOURCES_DIR}/spotify.list"

  # Plex Media Server
  keyrings_filename="plexmediaserver-${KEYRINGS_FILENAME_SUFFIX}"
  curl -fsSL https://downloads.plex.tv/plex-keys/PlexSign.key |
    sudo gpg --dearmor -o "${KEYRINGS_DIR}/${keyrings_filename}"
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] https://downloads.plex.tv/repo/deb public main" |
    sudo tee "${APT_SOURCES_DIR}/plexmediaserver.list"

  # Docker
  keyrings_filename="docker-${KEYRINGS_FILENAME_SUFFIX}"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    sudo gpg --dearmor -o "${KEYRINGS_DIR}/${keyrings_filename}"
  echo "deb [arch=amd64 signed-by=${KEYRINGS_DIR}/${keyrings_filename}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |
    sudo tee "${APT_SOURCES_DIR}/docker-release.list"

  apt update
}

# Install dependencies
apt install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  wget -y

add_repositories

# Zsh
printf "${YELLOW}Installing Zsh${NC}\n"
sleep $delay_after_message
apt install zsh -y
sleep 2
chsh -s /bin/zsh

# NVM
printf "${YELLOW}Installing NVM${NC}\n"
sleep $delay_after_message
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | zsh

# Node 12
printf "${YELLOW}Installing Node 12${NC}\n"
sleep $delay_after_message
. /home/${target_user}/.zshrc && nvm install 12

# Git
printf "${YELLOW}Installing Git${NC}\n"
sleep $delay_after_message
apt install git -y

# Vim
printf "${YELLOW}Installing Vim${NC}\n"
sleep $delay_after_message
apt install vim -y

# Tilix
printf "${YELLOW}Installing Tilix (terminal)${NC}\n"
sleep $delay_after_message
apt install tilix -y

# VSCode
printf "${YELLOW}Installing VSCode${NC}\n"
sleep $delay_after_message
apt install code -y

# Sublime Text
printf "${YELLOW}Installing Sublime Text${NC}\n"
sleep $delay_after_message
apt install sublime-text -y

# Monitoring Libs
printf "${YELLOW}Installing Monitoring Libs${NC}\n"
sleep $delay_after_message
apt install gir1.2-gtop-2.0 lm-sensors -y

# Brave Browser
printf "${YELLOW}Installing Brave Browser${NC}\n"
sleep $delay_after_message
apt install brave-browser -y

# Chrome Gnome Shell
printf "${YELLOW}Installing Chrome Gnome Shell${NC}\n"
sleep $delay_after_message
apt install chrome-gnome-shell -y

# Gnome tweak tool
printf "${YELLOW}Installing gnome-tweak-tool${NC}\n"
sleep $delay_after_message
apt install gnome-tweak-tool -y

# Docker
printf "${YELLOW}Installing Docker ${NC}\n"
sleep $delay_after_message
apt install docker-ce docker-ce-cli containerd.io -y

# Docker Compose
printf "${YELLOW}Installing Docker Compose${NC}\n"
sleep $delay_after_message
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Docker user group
usermod -aG docker $USER
# Copy docker daemon config
cp ./docker/daemon.json /etc/docker/daemon.json

# Slack
printf "${YELLOW}Installing Slack${NC}\n"
wget -qO slack-desktop.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-4.19.2-amd64.deb
sudo apt install ./slack-desktop.deb -y
rm ./slack-desktop.deb

# DBeaver
printf "${YELLOW}Installing DBeaver ${NC}\n"
sleep $delay_after_message
apt install dbeaver-ce -y

# Postman
printf "${YELLOW}Installing Postman ${NC}\n"
sleep $delay_after_message
wget -O postman.tar.gz https://dl.pstmn.io/download/latest/linux64
tar -xzf ./postman.tar.gz
mv Postman /usr/share/postman
# Copy Postman desktop entry
cp ./postman/postman.desktop /usr/share/applications/postman.desktop
rm ./postman.tar.gz

# Gnote
printf "${YELLOW}Installing Gnote ${NC}\n"
sleep $delay_after_message
apt install gnote -y

# Flameshot
printf "${YELLOW}Installing Flameshot ${NC}\n"
sleep $delay_after_message
apt install flameshot -y

# htop
printf "${YELLOW}Installing htop ${NC}\n"
sleep $delay_after_message
apt install htop -y

# dconf editor
printf "${YELLOW}Installing dconf editor ${NC}\n"
sleep $delay_after_message
apt install dconf-editor -y

# Pulse UI
printf "${YELLOW}Installing Pulse UI ${NC}\n"
sleep $delay_after_message
apt install ./pulse/Pulse-linux-9.1r11.0-64bit.deb -y

# Spotify
printf "${YELLOW}Installing Spotify ${NC}\n"
sleep $delay_after_message
apt install spotify-client -y

# Plex Media Server
printf "${YELLOW}Installing Plex Media Server ${NC}\n"
sleep $delay_after_message
apt install plexmediaserver -y
# sudo chown -R plex: /media/data/Media

# Steam
printf "${YELLOW}Installing Steam ${NC}\n"
sleep $delay_after_message
apt install steam -y
