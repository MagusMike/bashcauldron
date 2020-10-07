#!/bin/bash

# give the ability to delete, disable, and archive users with arguments based on users

ARCHIVE_DIR='/archive'


usage() {
  # display the usage and exit
  echo "Usage: ${0} [-dra] USER [USERN]..." >&2
  echo 'disable a local linux account' >&2
  echo '  -d Deletes accounts instead of disabling them' >&2
  echo '  -r removes home directory associated with the account(s)' >&2
  echo '  -a creates an archive of the home directory associated with the account(s)' >&2
  exit 1
}


# select user to disable, archive or delete

# Run as root
if [[ "${UID}" -ne 0 ]]
then
  echo 'please run with sudo or as root' >&2
  exit 1
fi

# parse options
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER='true' ;;
    r) REMOVE_OPTION='-r' ;;
    a) ARCHIVE='true' ;;
    ?) usage ;;
  esac
done

shift "$(( OPTIND - 1 ))"

if [[ "${#}" -lt 1 ]]
then
  usage
fi

# loop through arguments
for USERNAME in "${@}"
do
  echo "Processing user: ${USERNAME}"

  # make sure the UID of the account is not under 1000
  USERID=$(id -u ${USERNAME})
  if [[ "${USERID}" -lt 1000 ]]
  then
    echo "refusing to remove ${USERNAME} account with UID ${USERID}" >&2
    exit 1
  fi

  # create an archive
  if [[ "${ARCHIVE}" = 'true' ]]
  then 
    # Make sure the ARCHIVE_DIR directory exists
    if [[ ! -d "${ARCHIVE_DIR}" ]]
    then
      echo "creating ${ARCHIVE_DIR} directory"
      mkdir -p ${ARCHIVE_DIR}
      if [[ "{?}" -ne 0 ]]
      then 
        echo 'the archive directory ${ARCHIVE_DIR} could not be created' >&2
        exit 1
      fi
    fi

    #  archive the users home directory and move it into ARCHIVE_FIR
    HOME_DIR="/home/${USERNAME}"
    ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
    if [[ -d "${HOME_DIR}" ]]
    then
      echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
      tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
      if [[ "${?}" -ne 0 ]]
      then
        echo "could not create ${ARCHIVE_FILE}." >&2
        exit 1
      fi
    else
      echo "${HOME_DIR} does not exist or is not a directory" >&2
      exit 1
    fi
  fi 

  if [[ "${DELETE_USER}" = 'true' ]]
  then 
    # delete the user
    userdel ${REMOVE_OPTION} ${USERNAME}

    # check to see if the userdel command succeeded
    # we dont want to tell the user that an account was deleted when it wasnt
    if [[ "${?}" -ne 0 ]]
    then
      echo "the account ${USERNAME} was not deleted" >&2
      exit 1
    fi
    echo "the account ${USERNAME} was deleted"
  else
    chage -E 0 ${USERNAME}

    # check to see if the chage command succeeded
    # we dont want to tell the user that an account was disabled when it wasnt

    if [[ "${?}" -ne 0 ]]
    then
      echo "the account ${USERNAME} was not disabled" >&2
      exit 1
    fi
    echo "the account ${USERNAME} was disabled"
  fi
done

exit 0
 
 

