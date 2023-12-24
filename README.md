# ocserv-google-auth
integrate ocserv and google authenticator
# Setting Up ocserv with Google Authenticator for Multi-Factor Authentication

## Overview

This guide provides step-by-step instructions on setting up ocserv (OpenConnect VPN Server) with Google Authenticator for multi-factor authentication on a Debian-based system. The script automates the installation and configuration process, enhancing the security of your VPN server.

**Note:** Ensure that you have sudo privileges to execute the commands.

## Prerequisites

- A Debian-based system (e.g., Ubuntu)
- Internet access for package installation
- Basic knowledge of the Linux command line

## Installation

0. **Backup Config file**
   ```bash
   sudo cp /etc/ocserv/ocserv.conf /etc/ocserv/ocserv.conf.backup
1. **Update Package List:**
   ```bash
   sudo apt update
2. **Remove Unnecessary Package:**
   ```bash
   sudo apt-get remove libpam-cap
3. **Install Necessary Packages:**
   ```bash
   sudo apt install -y ocserv libpam-google-authenticator
4. **Configure ocserv:**
   ```bash
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
   ipv4-network = 192.168.12.0
   ipv4-netmask = 255.255.255.0
   dns = 8.8.8.8
   dns = 1.1.1.1
   max-clients = 10
   max-same-clients = 2
   keepalive = 32400
   cookie-timeout = 60
   device = evpn
   config-per-user = /etc/ocserv/config-per-user/
   use-occtl = true
   EOF
5. **Create 'config-per-user' Directory:**
   ```bash
   mkdir -p /etc/ocserv/config-per-user/
6. **Enable IP Forwarding:**
   ```bash
   echo 1 > /proc/sys/net/ipv4/ip_forward
   echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
   sudo sysctl -p
7. **Restart ocserv:**
   ```bash
   sudo systemctl restart ocserv


## Google Authenticator Configuration

1. **Update PAM Configuration:**
   ```bash
   sudo sed -i '/@include common-auth/a auth required pam_google_authenticator.so' /etc/pam.d/ocserv
2. **Restart ocserv:**
   ```bash
   sudo systemctl restart ocserv
3. **Generate and Distribute Keys and QR Codes:**
   ```bash
   echo "Follow the instructions to set up Google Authenticator:"
   #sudo -u $username google-authenticator -t -d --no-rate-limit --force -w 5
4. **Provide User Instructions:**
   ```bash
   echo "Configuration complete. Install and configure Google Authenticator on your client devices."
   echo "Scan the QR code or enter the secret key when prompted by ocserv."
   echo "Save the emergency scratch codes in case of device loss."

## Conclusion

Your ocserv VPN server is now configured with Google Authenticator for enhanced security. Users can connect using multi-factor authentication for a more secure VPN experience.

## User Creation
- This script automates the process of 
- creating a new user 
- granting sudo privileges 
- setting a password
- configuring Google Authenticator
- and creating an ocserv configuration for VPN access. 

## Example user creation

** ./script.sh username password ip_address **


**The script will generate a QR code and 5 emergency scratch codes .**
```bash
   if [ $(id -u) -ne 0 ]; then
     echo "Please run this script with sudo"
     exit 1
   fi

   # Check if the script is given four arguments
   if [ $# -ne 3 ]; then
     echo "Please provide a username, password ,ip address "
     exit 2
   fi
 
   # Assign the arguments to variables
   username=$1
   password=$2
   ip=$3
   # Create the user with adduser
   sudo adduser --force-badname --gecos "" --disabled-password $username

   # set user mod to no-login
   usermod --shell /usr/sbin/nologin $username

   # Set the password with chpasswd
   echo "$username:$password" | sudo chpasswd

   # Print a success message 
   echo "User $username created with password $password"



   sudo -u $username google-authenticator -t -d --no-rate-limit --force -w 5 

   rm -rf /etc/ocserv/config-per-user/$username
   touch /etc/ocserv/config-per-user/$username


   sudo tee /etc/ocserv/config-per-user/$username <<EOF
   route = 10.10.10.0/24
   tunnel-all-dns = true
   dns = 8.8.8.8
   dns = 1.1.1.1
   #ipv4-address = 192.168.99.232 #example ip address
   #ipv4-netmask = 255.255.255.0 #example subnetmask
   ipv4-network = $ip
   ipv4-netmask = 255.255.255.0
   EOF




