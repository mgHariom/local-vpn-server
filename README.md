# 🛡️ Automated Linux VPN Suite

An end-to-end automation toolkit for deploying a secure OpenVPN environment on Linux. This project replaces manual configuration with a modular, script-based infrastructure, allowing for "one-click" deployment of a private VPN tunnel.

> [!NOTE]
> The keys used in the /vpn_configs directory is only for example purposes. The key is not valid as the server is not running
---

## 🚀 Project Overview

This suite automates the entire lifecycle of a Virtual Private Network, from initializing a Private Key Infrastructure (PKI) to managing firewall NAT rules. It is designed for developers and network enthusiasts who need a rapid, reproducible, and secure way to establish encrypted tunnels.



### Key Features
* **Zero-Interactive PKI:** Fully automated Certificate Authority (CA) setup.
* **Modular Design:** Separate scripts for keys, configs, and networking.
* **Smart NAT Routing:** Automatically detects active network interfaces to set up IPTables.
* **One-Command Execution:** A Master Script to orchestrate the entire stack.

---

## 📂 Project Structure

| File | Description |
| :--- | :--- |
| `01-init-pki.sh` | Initializes the Easy-RSA PKI and builds the Master CA. |
| `02-gen-keys.sh` | Generates unique RSA keys and certificates for specific clients. |
| `03-make-config.sh` | Stitches CA, Certs, and Keys into a portable `.ovpn` file. |
| `04-server-start.sh` | Configures IP forwarding, NAT rules, and starts the VPN server. |
| `run-project.sh` | **The Wrapper:** Orchestrates all scripts and starts the tunnel. |

---

## 🛠️ Installation & Setup

### 1. Prerequisites
Ensure you are running a Linux distribution (Tested on Parrot OS/Debian) and have `sudo` privileges.

### 2. Clone and Prepare
```bash
git clone [https://github.com/yourusername/local-vpn-server.git](https://github.com/yourusername/local-vpn-server.git)
cd local-vpn-server
chmod +x *.sh

