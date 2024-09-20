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

echo -e "\n\n"
echo -e "Enter verus wallet (e.g. RUWXbSRWEmjKpXEM2MoFch9ZprTzouBCN1)"
printf "%s" "Input wallet: "
read WALLET
echo -e "Enter miner pool (e.g. stratum+tcp://eu.luckpool.net:3956)"
printf "%s" "Input pool: "
read MINERPOOL
echo -e "Enter miner name (e.g. VERUSMINER)"
printf "%s" "Input name: "
read MINERNAME

# Validate threat input
while true; do
    echo -e "Enter amount of miner threat (e.g. 2, max: $(nproc))"
    printf "%s" "Input threat: "
    read THREAT
    
    # Check if input is a number and within valid range
    if [[ "$THREAT" =~ ^[0-9]+$ ]] && [ "$THREAT" -le "$(nproc)" ]; then
        break
    else
        echo "Invalid input. Please enter a number between 1 and $(nproc)."
    fi
done

# Validate hybrid mode input
while true; do
    printf "%s" "Use hybrid mode (y/n): "
    read ISHYBRID
    
    if [[ "$ISHYBRID" == "y" || "$ISHYBRID" == "n" ]]; then
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done


PASS="x"
if [ "$ISHYBRID" == "y" ] || [ "$ISHYBRID" = "Y" ];  then
	PASS="hybrid"
fi

echo -e "\n\nDetecting system architecture..."
SYSVER="$(uname -m)"
echo -e "Your system architecture is ${SYSVER}."

echo -e "\nInstalling required library..."
sudo apt -qq update > /dev/null 2>&1
sudo apt install -qq systemd git wget curl libomp-dev jq htop -y > /dev/null 2>&1
if [ "$SYSVER" == "x86_64" ]; then
	sudo apt install -qq libssl-dev -y > /dev/null 2>&1
else
	wget -q http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.1n-0+deb11u5_arm64.deb
	sudo dpkg -i --quiet libssl1.1_1.1.1n-0+deb11u5_arm64.deb
	rm libssl1.1_1.1.1n-0+deb11u5_arm64.deb
fi
echo "Required library installed successfully."

echo -e "\nDownloading latest Oink70 ccminer..."
RELEASE_INFO=$(curl --silent "https://api.github.com/repos/Oink70/ccminer-verus/releases/latest")
MINERVER=$(echo "$RELEASE_INFO" | jq -r '.tag_name')
echo "Detected ${MINERVER} version, start downloading..."
declare -a FILENAMES
declare -a DOWNLOAD_URLS
while IFS= read -r line; do
    if [[ "$SYSVER" == "x86_64" ]] && [[ "$line" == *"Ubuntu"* ]]; then
        FILENAMES+=("$(echo "$line" | cut -d ' ' -f 1)")
        DOWNLOAD_URLS+=("$(echo "$line" | cut -d ' ' -f 2)")
        break
    elif [[ "$line" == *"ARM"* ]]; then
        FILENAMES+=("$(echo "$line" | cut -d ' ' -f 1)")
        DOWNLOAD_URLS+=("$(echo "$line" | cut -d ' ' -f 2)")
        break
    fi
done < <(echo "$RELEASE_INFO" | jq -r '.assets[] | "\(.name) \(.browser_download_url)"')
echo "File Name: ${FILENAMES[0]}"
echo "Download URL: ${DOWNLOAD_URLS[0]}"
wget -q "${DOWNLOAD_URLS[0]}"
sudo mv ${FILENAMES[0]} ccminer
sudo chmod +x ccminer
echo "ccminer downloaded successfully."

echo -e "\nStart configuring ccminer verus..."
echo -e "Configuring ccminer verus config..."
CURRENTDIR=$(pwd)
echo "#!/usr/bin/env bash" > mining.sh
echo "$CURRENTDIR/ccminer -a verus -o $MINERPOOL -u $WALLET.$MINERNAME -p $PASS -t $THREAT" >> mining.sh
sudo chmod +x mining.sh

echo -e "Configuring ccminer autostart with systemctl..."
echo -e "[Unit]\nDescription=Verus CCMINER\nAfter=network.target\n\n[Service]\nExecStart=$CURRENTDIR/mining.sh\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/mining.service
sudo systemctl daemon-reload
sudo systemctl enable mining.service
sudo systemctl start mining.service
echo -e "ccminer verus configured successfully."

echo -e "\nYou can check by this command :"
echo -e "- htop (for check verus miner is already running or not by check cpu usage and ccminer process)"
echo -e "- systemctl status (for check autostart is configured or not by find mining.service)"