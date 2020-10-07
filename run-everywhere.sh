#!/bin/bash

# execute commands on remote servers  using the server file

# execute the command as the user executing the script

SERVER_LIST='/vagrant/servers'

SSH_OPTIONS='-o ConnectTimeout=2'

usage() {
  # display the usage and exit
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
  echo ' Executes COMMAND as a single command on every server.'
  echo "   -f FILE  Use FILE for the list of servers. Defualt ${SERVER_LIST}" >&2
  echo '   -n       Dry run mode.  Display the COMMAND that would have been executed and exit.' >&2
  echo '   -s       Execute the COMMAND using sudo on the remote server.' >&2
  echo '   -v       Verbose mode. Displays the server name before executing COMMAND.' >&2
  exit 1
}

if [[ "${UID}" -eq 0 ]]
then
        echo "Do NOT use sudo to run this script"
        usage
fi

# allow the user to override defualt file and execute on their own selected file of servers/hosts\
# allow a dry run to happen before you execute the commands
# run commands with sudo on remote machines
# enable verbose mode as an option
# provide a usage statement about errors and options
# error message on servers that failed
# exit completed with status 0

while getopts f:nsv OPTION
do
  case ${OPTION} in
    f) SERVER_LIST="${OPTARG}" ;;
    n) DRY_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage ;;
  esac
done

shift "$(( OPTIND -1 ))"

if [[ "${#}" -lt 1 ]]
then
  usage
fi

# anything that remains is the command
COMMAND="${@}"


if [[ ! -e "${SERVER_LIST}" ]]
then
  echo "cannot open ${SERVER_LIST}" >&2
  exit 1
fi

EXIT_STATUS='0'

for SERVER in $(cat ${SERVER_LIST})
do
  if [[ "${VERBOSE}" = 'true' ]]
  then 
    echo "${SERVER}"
  fi
  
  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"

  # if it is a dry run dont execute anything just echo it
  if [[ "$DRY_RUN" = 'true' ]]
  then
    echo "DRY RUN ${SSH_COMMAND}"
  else
    ${SSH_COMMAND}
    SSH_EXIT_STATUS="${?}"


    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
    then
      EXIT_STATUS="${SSH_EXIT_STATUS}"
      echo "Execution on ${SERVER} failed" >&2
    fi
  fi
done

exit ${EXIT_STATUS}

