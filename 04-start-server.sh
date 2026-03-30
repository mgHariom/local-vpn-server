#!/bin/bash

# --- 1. Variables ---
USER_NAME="posiedon"
OVPN_DIR="/etc/openvpn/server"
CA_DIR="/home/$USER_NAME/projects/smarted/linux_vpn/openvpn-ca"

# --- 2. Root Check ---
if [ "$EUID" -ne 0 ]; then 
  echo "❌ Error: Please run as root (sudo)."
  exit 1
fi

# --- 3. Copy Files to System Directory ---
echo "📂 Moving certificates to $OVPN_DIR..."
mkdir -p "$OVPN_DIR"
cp "$CA_DIR/pki/ca.crt" "$OVPN_DIR/"
cp "$CA_DIR/pki/issued/server.crt" "$OVPN_DIR/"
cp "$CA_DIR/pki/private/server.key" "$OVPN_DIR/"
cp "$CA_DIR/pki/dh.pem" "$OVPN_DIR/"

# --- 4. Create Server Config (The "Lock") ---
echo "📝 Generating server.conf..."
cat <<EOF > "$OVPN_DIR/server.conf"
port 1194
proto udp
dev tun
ca $OVPN_DIR/ca.crt
cert $OVPN_DIR/server.crt
key $OVPN_DIR/server.key
dh $OVPN_DIR/dh.pem
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-GCM
persist-key
persist-tun
verb 3
EOF

# --- 5. Enable IP Forwarding (The "Bridge") ---
echo "🌉 Enabling IP Forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

# --- 6. Firewall Rules (NAT) ---
# We find your active internet interface automatically
EXT_IF=$(ip route | grep default | awk '{print $5}')
echo "🛡️  Setting up NAT on interface: $EXT_IF"
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$EXT_IF" -j MASQUERADE

# --- 7. Start the Service (Manual Foreground Mode) ---
echo "🚀 Launching OpenVPN Server in Foreground..."
echo "Press Ctrl+C to stop the server"

# We 'cd' into the folder first to ensure the config can find the .crt files
cd "$OVPN_DIR" || exit
sudo openvpn --config server.conf
