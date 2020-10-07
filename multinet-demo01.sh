#!/bin/bash

# this script lists servers and reports their status

SERVER_FILE='/vagrant/servers'

if [[ ! -e "${SERVER_FILE}" ]]
then
  echo "cannot open ${SERVER_FILE}" >&2
  exit 1
fi

for SERVER in $(cat ${SERVER_FILE})
do
  echo "pinging ${SERVER}"
  ping -c 2 ${SERVER} &> /dev/null
  if [[ "${?}" -ne 0 ]]
  then
    echo "${SERVER} down"
  else
    echo "${SERVER} up"
  fi
done


