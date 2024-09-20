#!/usr/bin/env bash

clear

echo "               _             ___  _ _"
echo "  ___ ___   __| | _____   __/ _ \/ / |"
echo " / __/ _ \ / _  |/ _ \ \ / / (_) | | |"
echo "| (_| (_) | (_| |  __/\ V / \__, | | |"
echo " \___\___/ \__,_|\___| \_/    /_/|_|_|"

if [[ $EUID -ne 0 ]]; then
    echo -e "\nThis script must be run as root." 1>&2
    exit 1
fi

echo -e "\n\nUninstall ccminer autostart configuration..."
sudo systemctl stop mining.service
sudo systemctl disable mining.service
sudo rm /etc/systemd/system/mining.service
sudo systemctl daemon-reload
echo -e "ccminer verus autostart configuration removed successfully."

echo -e "\nUninstall configuring ccminer verus..."
sudo rm mining.sh
sudo rm ccminer
echo -e "ccminer verus removed successfully."

echo -e "\nYou can check by this command :"
echo -e "- htop (for check verus miner is already stopped or not by check cpu usage and ccminer process)"
echo -e "- systemctl status (for check autostart is uninstalled or not by find mining.service)"