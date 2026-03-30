#!/bin/bash

# --- 1. Settings ---
# Ensure these match your actual folder paths
PROJECT_DIR="/home/posiedon/projects/smarted/local-vpn-server"
CLIENT_NAME=${1:-client1}

# --- 2. Root Check ---
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Error: This master script must be run with sudo."
  exit 1
fi

cd "$PROJECT_DIR" || exit

echo "------------------------------------------"
echo "🚀 STARTING FULL VPN AUTOMATION PROJECT"
echo "------------------------------------------"

# --- 3. Run the Stages ---
echo "📦 Step 1: Initializing PKI..."
./01-init-pki.sh

echo "🔑 Step 2: Generating Keys for $CLIENT_NAME..."
./02-gen-keys.sh "$CLIENT_NAME"

echo "🏗️  Step 3: Creating Client Config..."
./03-make-config.sh "$CLIENT_NAME"

echo "🛡️  Step 4: Setting up Firewall & Starting Server..."
# We run the server script in the background (&) so the script can continue
./04-start-server.sh &

# Give the server 3 seconds to "wake up"
sleep 3

echo "------------------------------------------"
echo "📡 ATTEMPTING CLIENT CONNECTION..."
echo "------------------------------------------"

# --- 4. Launch the Client ---
# This is the manual command that worked for you earlier
CONFIG_FILE="/home/posiedon/projects/smarted/local-vpn-server/vpn_configs/$CLIENT_NAME.ovpn"
openvpn --config "$CONFIG_FILE"
