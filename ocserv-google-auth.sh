#!/bin/bash
  
# Update package list
sudo apt update -y

# Remove libpam-cap if installed
sudo apt-get remove libpam-cap -y

# Install necessary packages
sudo apt install -y ocserv libpam-google-authenticator

# Configure ocserv
sudo cp /etc/ocserv/ocserv.conf /etc/ocserv/ocserv.conf.backup

# Example ocserv.conf configuration
sudo tee /etc/ocserv/ocserv.conf <<EOF
auth = "pam[gid-min=1000]"
tcp-port = 443
udp-port = 443
run-as-user = nobody
run-as-group = nogroup
socket-file = /var/run/ocserv-socket
server-cert = /etc/ssl/certs/ssl-cert-snakeoil.pem
server-key = /etc/ssl/private/ssl-cert-snakeoil.key
ipv4-network = 192.168.49.0
ipv4-netmask = 255.255.255.0
dns = 8.8.8.8
route = 172.16.10.0/24
max-clients = 10
max-same-clients = 2
keepalive = 32400
device = evpn
use-occtl = true
EOF



# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Make the change persistent in sysctl.conf
echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf

# Apply the changes immediately
sudo sysctl -p

# Restart ocserv to apply changes
sudo systemctl restart ocserv

# Configure Google Authenticator for MFA
sudo sed -i '/@include common-auth/a auth required pam_google_authenticator.so' /etc/pam.d/ocserv

# Restart ocserv to apply changes
sudo systemctl restart ocserv

# Generate and distribute secret keys and QR codes for users
echo "Follow the instructions to set up Google Authenticator
for adding user to Google Authenticator do like this : sudo -u username google-authenticator"
