#!/bin/bash

# Goal: generates a list of random passwords

# A random number
PASSWORD="${RANDOM}"
echo "${PASSWORD}"

# More passwords
PASSWORD="${RANDOM}${RANDOM}${RANDOM}"
echo "${PASSWORD}"

# passwords are dates
PASSWORD=$(date +%s)
echo "${PASSWORD}"

# more passowrds
PASSWORD=$(date +%s%D%b)
echo "${PASSWORD}"

# more passwords
PASSWORD=$(date +%s | sha256sum | head -c10)
echo "${PASSWORD}"

# randomness
PASSWORD=$(date +%s%N | sha256sum | head -c12)
echo "${PASSWORD}"

# one more
SPECIAL_CHARACTER=$(echo '~!@#$%^&*()_+' | fold -w1 | shuf | head -c1)
echo "${PASSWORD}${SPECIAL_CHARACTER}"

