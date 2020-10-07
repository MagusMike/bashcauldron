#!/bin/bash

# create a random wizard name from two different text files strung together
# wizard names following a standard of "Name" the "descriptor" 

read -p "enter your name to create your wizarding alter ego:  " names

if [[ -z "${names}" ]]
then
  echo "no input for first name, don't worry we can choose you a random"
  names=$(cat /home/magus/projects/names.txt | shuf -n 1)
fi

descriptors=$(cat /home/magus/projects/descriptor.txt | shuf -n 1)

echo "your wizard name is: ${names} the ${descriptors}"


