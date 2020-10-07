#!/bin/bash

# Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
	echo "You need sudo or root privilege to run this script"
 	exit 1
fi

# Get the username (login).
read -p 'Enter username to create: ' USERNAME

# Get the real name (contents for the description field).
read -p 'Enter real name or comments for account description: ' COMMENT

# Get the password.
read -p 'Enter password to use for account: ' PASSWORD

# Create the user with the password.
useradd -c "${COMMNET}" -m ${USERNAME}

# Check to see if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then
	echo 'the account could not be created'
	exit 1
fi 

# Set the password.
echo ${PASSWORD} | passwd --stdin ${USERNAME}

# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
	echo 'The account was not setup properly'
	exit 1
fi

# Force password change on first login.
passwd -e ${USERNAME}

# Display the username, password, and the host where the user was created.
echo
echo 'username:'
echo ${USERNAME}
echo
echo 'description:'
echo "${COMMENT}"
echo
echo 'password:'
echo ${PASSWORD}
echo
echo 'hostname:'
echo ${HOSTNAME}

exit 0

