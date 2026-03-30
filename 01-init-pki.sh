#!/bin/bash

# --- 1. Variables ---
# We define these here so they are easy to change later
CA_DIR="/home/posiedon/projects/smarted/linux_vpn/openvpn-ca"
EASYRSA_PATH="/usr/share/easy-rsa"

# --- 2. Root Check ---
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Error: Please run this script with sudo."
  exit 1
fi

# --- 3. Installation ---
echo "Update and installing dependencies..."
apt update && apt install openvpn easy-rsa -y

# --- 4. Setup CA Directory ---
echo "Creating CA Workspace at $CA_DIR..."
mkdir -p "$CA_DIR"
cd "$CA_DIR" || exit

# Link Easy-RSA files into our workspace
ln -sf $EASYRSA_PATH/* .

# --- 5. Initialize PKI & Build CA ---
echo "Initializing PKI..."
./easyrsa init-pki

echo "Building Certificate Authority (CA)..."
# The --batch flag makes it non-interactive (no asking for confirmation)
# 'nopass' means we don't need a password for this project
./easyrsa --batch build-ca nopass

echo "✅ Part 1 Complete! CA is initialized."
echo "Your Master Certificate is at: $CA_DIR/pki/ca.crt"
