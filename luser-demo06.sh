#!/bin/bash

# This script generates a random password for each user specificed 

# Display what the user typed on the command line.
echo "You executed this command: ${0}"

# Display the path and filename of the script
echo "You used $(dirname ${0}) as the path to the $(basename ${0}) script"

# Tell user how many arguments they passed
# (inside the script they are parameters, outside they are arguments)
NUMBEROFPARAMETERS="${#}"
echo "You suppplied ${NUMBEROFPARAMETERS} argument(s) on the command line"

# Mark sure they at least supply one arguement
if [[ "${NUMBEROFPARAMETERS}" -lt 1 ]]
then
	echo "Usage: ${0} USER_NAME [USER_NAME]..."
	exit 1
fi

# Generate and display a password for each parameter
for USER_NAME in "${@}"
do
	PASSWORD=$(date +%s%N | sha256sum | head -c12)
	echo "${USER_NAME}: ${PASSWORD}"
done

