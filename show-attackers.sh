#!/bin/bash

# show failed login attempts by failed attempts

# geoiplookup will be the command used in this script

# this will produce an output to CSV 

LIMIT='10'
LOG_FILE="${1}"

if [[ ! -e "${LOG_FILE}" ]]
then
  echo "cannot open log file ${LOG_FILE}" >&2
  exit 1
fi

# display CSV header
echo 'Count,IP,Location'

# Loop through generated data

grep Failed syslog-sample | awk '{print $(NF -3)}' | sort | uniq -c | sort -nr | while read COUNT IP 
do
  if [[ "${COUNT}" -gt "${LIMIT}" ]]
  then
    LOCATION=$(geoiplookup ${IP} | awk -F ', ' '{print $2}')
    echo "${COUNT},${IP},${LOCATION}"
  fi
done
exit 0

