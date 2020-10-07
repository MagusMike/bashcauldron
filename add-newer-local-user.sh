#!/bin/bash

#Make sure the script is being executed with superuser privileges.
if [[ "${UID}" -ne 0 ]]
then
        echo "You need sudo or root privilege to run this script"i >&2
        exit 1
fi

# Get the username (login).
if [[ "${#}" -lt 1 ]]
then
        echo "Usage: ${0} USERNAME [COMMENT]..." >&2
        echo 'Create an account on the local system with the name of the USER_NAME and a comments field of COMMENT' >&2
        exit 1
fi
# Parameters
USERNAME="${1}"

shift
COMMENT="${@}"

# Random password.
SPECIAL_CHARACTER=$(echo '~!@#$%^&*()_+' | fold -w1 | shuf | head -c1)
PASSWORD=$(date +%s%N | sha256sum | head -c12)

# Create the user with the password.
useradd -c "${COMMENT}" -m ${USERNAME} &> /dev/null

# Check to see if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then
        echo 'the account could not be created' >&2
        exit 1
fi

# Set the password.
echo ${PASSWORD}${SPECIAL_CHARACTER} | passwd --stdin ${USERNAME} &> /dev/null

# Check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then
        echo 'The account was not setup properly' >&2
        exit 1
fi

# Force password change on first login.
passwd -e ${USERNAME} &> /dev/null

# Display the username, password, and the host where the user was created.
echo
echo 'username:'
echo ${USERNAME}
echo
echo 'description:'
echo "${COMMENT}"
echo
echo 'password:'
echo ${PASSWORD}${SPECIAL_CHARACTER}
echo
echo 'hostname:'
echo ${HOSTNAME}

exit 0

