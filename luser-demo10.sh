#!/bin/bash

# function called log for system log

log() {
#  local VERBOSE="${1}"
#  shift
# This function sends a message to syslog and to STDOUT if VERBOSE is true
  local MESSAGE="${@}"
  if [[ "${VERBOSE}" = 'true' ]]
  then
    echo "${MESSAGE}"
  fi
  logger -t luser-demo10.sh "${MESSAGE}"
}
backup_file() {
# this function creates a backup of a file and returns non zero status on error
  local FILE="${1}"
# Make sure the file exists
  if [[ -f "${FILE}" ]]
  then
    local BACKUP_FILE="/var/tmp/$(basename ${FILE}).$(date +%F-%N)"
    log "backing up ${FILE} to ${BACKUP_FILE}"
# the exit status of the function will be the exit status of the cp command
    cp -p ${FILE} ${BACKUP_FILE}
  else
# the file does not exist, so return a non zero exit status
    return 1
  fi
}

 readonly VERBOSE='true'
 log 'Hello'
 log 'This is fun'

backup_file '/etc/passwd'

# make a desision based on the exit status of the function

if [[ "${?}" -eq '0' ]]
then
  log 'file backup succeeded'
else
  log 'file backup failed'
  exit 1
fi

