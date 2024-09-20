# Verus Miner Setup Script

This Bash script automates the installation and configuration of the Verus miner (ccminer) on a Linux system. It sets up the necessary libraries, downloads the latest ccminer release, and configures it to run as a service.

### Tested
- Armbian 24 server

### Usage
- Clone the repository or download the script:
   ```bash
   git clone https://github.com/codev911/verus_autoinstall.git
   ```
- Enter to cloned repository directory:
   ```bash
   cd verus_autoinstall
   ```
- Make the script executable:
   ```bash
   chmod +x install_verus_armbian.sh
   ```
- Run this script as root, (or login as root without sudo):
   ```bash
   sudo bash install_verus_armbian.sh
   ```
- Follow script steps depend on your ccminer config

### Demo Usage
<img src="https://i.imgur.com/q9Pp4st.gif" style="width: 100%; height: auto;" />
