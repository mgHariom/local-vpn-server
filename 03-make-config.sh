#!/bin/bash

# --- 1. Variables (Match your setup) ---
USER_NAME="posiedon"
CA_DIR="/home/$USER_NAME/projects/smarted/linux_vpn/openvpn-ca"
OUTPUT_DIR="/home/$USER_NAME/projects/smarted/local-vpn-server/vpn_configs"
CLIENT_NAME=$1

# --- 2. Validation ---
if [ -z "$CLIENT_NAME" ]; then
    echo "❌ Usage: sudo ./03-make-config.sh [client_name]"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# --- 3. Path Variables for the Keys ---
CA_FILE="$CA_DIR/pki/ca.crt"
CERT_FILE="$CA_DIR/pki/issued/$CLIENT_NAME.crt"
KEY_FILE="$CA_DIR/pki/private/$CLIENT_NAME.key"

# Check if keys actually exist before trying to read them
if [[ ! -f "$CA_FILE" || ! -f "$CERT_FILE" || ! -f "$KEY_FILE" ]]; then
    echo "❌ Error: Keys for '$CLIENT_NAME' not found in PKI folder!"
    exit 1
fi

# --- 4. The "Stitching" Process ---
echo "🏗️  Building $CLIENT_NAME.ovpn..."

{
    echo "client"
    echo "dev tun"
    echo "proto udp"
    echo "remote 127.0.0.1 1194"
    echo "resolv-retry infinite"
    echo "nobind"
    echo "persist-key"
    echo "persist-tun"
    echo "remote-cert-tls server"
    echo "cipher AES-256-GCM"
    echo "verb 3"

    echo "<ca>"
    cat "$CA_FILE"
    echo "</ca>"

    echo "<cert>"
    # We use sed to only grab the actual certificate block, skipping the header text
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' < "$CERT_FILE"
    echo "</cert>"

    echo "<key>"
    cat "$KEY_FILE"
    echo "</key>"
} > "$OUTPUT_DIR/$CLIENT_NAME.ovpn"

chown $USER_NAME:$USER_NAME "$OUTPUT_DIR/$CLIENT_NAME.ovpn"
echo "✅ Done! Your config is at: $OUTPUT_DIR/$CLIENT_NAME.ovpn"
