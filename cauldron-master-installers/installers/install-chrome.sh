#!/bin/bash

vendorDMG="googlechrome.dmg"
googlechrome_url="https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"
directory="/private/tmp/chrome"
app="/Applications/Google Chrome.app"
pid=$(ps acx | grep "Google Chrome" | awk '{print $1}' | head -n 1)

### directory search

if [ -d "${directory}" ]; then
    echo "${directory} exists" 
else
    echo "Error: ${directory} does not exist yet"
    mkdir ${directory}
fi

sleep 2

if [ -e "${app}" ]; then
  echo "Chrome insallation detected"
  echo "Removing application and files"
  if [[ $pid > 0 ]]; then
    echo "killing processes"
    kill -9 $(pgrep "Google Chrome")
  else
    echo "Chrome not running"
  fi
  rm -Rf "${app}"
  sleep 15
else
  echo "no Chrome installation detected"
fi

### Check that the files are gone and the CPU matches installation media
if [ ! -e "${app}" ]; then
  echo "setup starting"
  # change directory to make this the working directory
  cd ${directory}
  # download the installer package and name it for the linkID
  /usr/bin/curl -JL "${googlechrome_url}" -o "${vendorDMG}"
  # install the package
  hdiutil attach ${directory}/${vendorDMG} -nobrowse 
  echo ""
  cp -a -f "/Volumes/Google Chrome/Google Chrome.app" /Applications/
  echo ""
  sleep 25
  echo ""
  hdiutil detach -force "/Volumes/Google Chrome"
  echo "installation complete"
  sleep 2
  open /Applications/Google\ Chrome.app
  echo ""
  sleep 8
  kill -9 $(pgrep "Google Chrome")
  echo ""
else
  echo "There was something wrong with installation steps"
  echo "removing media and files"
fi

### Check for resources and files left over

if [ -e "/Volumes/Google Chrome" ]; then
  echo "detach attached dmg file"
  hdiutil detach -force "/Volumes/Google Chrome"
else
  echo "no disk attached"
fi

if [ -d ${directory} ]; then
  echo "${directory} exists, cleanup starting"
  rm -Rf ${directory}
else
  echo "${directory} does not exist, completion imminent"
fi

### Check for logs in JAMF

echo "Check installation logs in JAMF"
exit 0