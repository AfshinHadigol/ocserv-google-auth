#!/bin/bash

# Prompt for username
read -p "Enter username: " username

# Prompt for password (and hide input)
read -s -p "Enter password: " password
echo # Move to a new line after password input

# Create the user with adduser
sudo adduser --force-badname --gecos "" --disabled-password $username



# Set the password with chpasswd
echo "$username:$password" | sudo chpasswd

# Print a success message
echo "User $username created with password $password"

## Generating Google Authenticator codes for the entered username
sudo -u $username google-authenticator -t -d --no-rate-limit --force -w 5
