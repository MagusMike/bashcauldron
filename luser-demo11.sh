#!/bin/bash

# generate a password
# specify length with -l and special characters -s
# verbosity controlled output with -v

usage() {
  echo "Usage: ${0} [-vs] [-l LENGTH]" >&2
  echo 'Generate a random password'
  echo '   -l LENGTH Specify the password length'
  echo '   -S        Append a special character to the password'
  echo '   -v        Increase verbosity'
  exit 1

}

log() {
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${MESSAGE}"
  fi
}

# default password length
LENGTH=20

while getopts vl:s OPTION
do
  case ${OPTION} in
    v)
      VERBOSE='true'
      log 'Verbose mode on'
      ;;
    l)
      LENGTH="${OPTARG}"
      ;;
    s)
      USE_SPECIAL_CHARACTER='true'
      ;;
    ?)
      usage
      ;; 
  esac
done

log 'Generating a password'

PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c${LENGTH})

# append a special character if requested to do so

if [[ "${USE_SPECIAL_CHARACTER}" = 'true' ]]
then 
  log 'Selecting a random special character'
  SPECIAL_CHARACTER=$(echo '~!@#$%^&*()_+' | fold -w1 | shuf | head -c1)
  PASSWORD="${PASSWORD}${SPECIAL_CHARACTER}"
fi

log 'done'
log 'here is the password:'

# display the password
echo "${PASSWORD}"

exit 0

