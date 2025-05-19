#!/bin/bash

# fail on errors
set -e

# this fixes .ssh and .gnupg directory permissions
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.gnupg -type f -exec chmod 600 {} \;
chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub

sudo apt install qbittorrent git vlc

# onedrive for linux
echo 'deb http://download.opensuse.org/repositories/home:/obs_mhogomchungu/Debian_12/ /' | sudo tee /etc/apt/sources.list.d/home:obs_mhogomchungu.list
curl -fsSL https://download.opensuse.org/repositories/home:obs_mhogomchungu/Debian_12/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_obs_mhogomchungu.gpg > /dev/null
sudo apt update
sudo apt install media-downloader

systemctl enable onedrive@ian.service
systemctl start onedrive@ian.service
