#!/bin/bash

# Demonstrate the use of the shift command and while loops

# Display the first 3 parameters
echo "Parameter 1: ${1}"
echo "Parameter 2: ${2}"
echo "Parameter 3: ${3}"
echo 

# Loop through all positional parameters
while [[ "${#}" -gt 0 ]]
do 
	echo "Number of parameters: ${#}"
	echo "Parameter 1: ${1}" 
	echo "Parameter 2: ${2}" 
	echo "Parameter 3: ${3}" 
	echo
	shift
done

