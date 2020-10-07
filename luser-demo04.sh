#!/bin/bash

#This script will create a local account
# You will be prompted for the account name and password

# Ask for the username
read -p 'Enter the username to create: ' USER_NAME

# Ask for real name
read -p 'Enter the name of the person who this account is for: ' COMMENT

# Ask for password
read -p 'Enter the password to use for the account: ' PASSWORD

# create user
useradd -c "${COMMENT}" -m ${USER_NAME}

# Set the password for the user
echo ${PASSWORD} | passwd --stdin ${USER_NAME}

# Force password change on login
passwd -e ${USER_NAME}

