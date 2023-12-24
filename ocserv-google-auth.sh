a
#!/bin/bash
  
# Update package list
sudo apt update

# Remove libpam-cap if installed
sudo apt-get remove libpam-cap

# Install mailutils
echo "postfix postfix/mailname string mail.kianiranian.com" | sudo debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | sudo debconf-set-selections
sudo apt-get install -y mailutils


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
ipv4-network = 192.168.99.0
ipv4-netmask = 255.255.255.0
dns = 8.8.8.8
#route = 0.0.0.0
max-clients = 10
max-same-clients = 2
keepalive = 32400
cookie-timeout = 60
device = evpn
config-per-user = /etc/ocserv/config-per-user/
EOF

# Creating config-per-user direcotry 
mkdir -p /etc/ocserv/config-per-user/


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
echo "Follow the instructions to set up Google Authenticator:"
google-authenticator

# Provide user instructions
echo "Configuration complete. Install and configure Google Authenticator on your client devices."
echo "Scan the QR code or enter the secret key when prompted by ocserv."
echo "Save the emergency scratch codes in case of device loss."
