#!/bin/bash

# --- 1. Variables ---
# IMPORTANT: Change 'posiedon' to your actual Linux username
CA_DIR="/home/posiedon/projects/smarted/linux_vpn/openvpn-ca"
CLIENT_NAME=$1

# --- 2. Validation ---
if [ -z "$CLIENT_NAME" ]; then
    echo "❌ Usage: sudo ./02-gen-keys.sh [client_name]"
    echo "Example: sudo ./02-gen-keys.sh laptop"
    exit 1
fi

cd "$CA_DIR" || { echo "❌ Directory not found!"; exit 1; }

# --- 3. Generate Server Keys (Only if they don't exist) ---
if [ ! -f "pki/issued/server.crt" ]; then
    echo "📡 Generating Server Keys for the first time..."
    ./easyrsa --batch gen-req server nopass
    ./easyrsa --batch sign-req server server
    ./easyrsa --batch gen-dh
else
    echo "ℹ️ Server keys already exist. Skipping..."
fi

# --- 4. Generate Unique Client Keys ---
echo "🔑 Generating keys for client: $CLIENT_NAME..."
./easyrsa --batch gen-req "$CLIENT_NAME" nopass
./easyrsa --batch sign-req client "$CLIENT_NAME"

echo "✅ Done! Keys for '$CLIENT_NAME' are in the pki/ folder."
