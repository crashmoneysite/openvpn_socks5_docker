#!/bin/bash

# Step 1: Stop the firewall
echo "[*] Stopping firewall..."
sudo systemctl stop firewalld 2>/dev/null || sudo ufw disable 2>/dev/null

# Step 2: Install Warp Proxy
echo "[*] Installing Warp Proxy..."
bash <(curl -sSL https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh) -y

# Step 3: Install Xray Core
echo "[*] Installing Xray Core..."
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install

# Step 4: Download and set config.json
echo "[*] Configuring Xray..."
CONFIG_DIR="/usr/local/etc/xray"
CONFIG_FILE="$CONFIG_DIR/config.json"
CONFIG_URL="https://raw.githubusercontent.com/crashmoneysite/xray/refs/heads/main/config2.json"

sudo mkdir -p "$CONFIG_DIR"
curl -sSL "$CONFIG_URL" | sudo tee "$CONFIG_FILE" > /dev/null

# Step 5: Start, restart, and enable Xray
echo "[*] Starting Xray service..."
sudo systemctl start xray
sudo systemctl restart xray
sudo systemctl enable xray

echo "[*] Setup completed successfully."
