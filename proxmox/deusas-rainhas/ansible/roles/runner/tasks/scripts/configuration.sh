#!/bin/bash
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
reset='\033[0m'

echo -e " - [${yellow}INFO${reset}]  Configuring GitHub Runner..."
./config.sh --url "$ORG_URL" --token "$ORG_TOKEN"
echo -e " - [${yellow}INFO${reset}]  Configuring GitHub Actions runner as SERVICE..."
sudo ./svc.sh install
sudo ./svc.sh start
echo -e " - [${green}OK${reset}]    GitHub Actions runner configured successfully."
