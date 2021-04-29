#!/bin/bash

#### Check for installation of Zoom, update or install based off of arch type.

# Set the User Agent string for use with curl
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

# Variables for script
directory="/private/tmp"
vendorDMG="googledrive.dmg"
app="Google Drive.app"
googledrive_url="https://dl.google.com/drive-file-stream/GoogleDrive.dmg"
#intel_url="" 
#arm_url="" 
arch_name="$(uname -m)"

if [ -e "/Applications/${app}" ]; 
then
  echo "$app located, check for updates - exiting installation"
  exit 0 
else
  echo "$app not located, continue to install"
fi
 
if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
      echo "Running on Rosetta 2"
      exit 0
    else
      echo "Running on native Intel"
      # change directory to /private/tmp to make this the working directory
      cd "${directory}"
      # download the installer package and name it for the linkID
      /usr/bin/curl -JL "$googledrive_url" -o "${vendorDMG}"
      # install the package
      hdiutil attach "${directory}/${vendorDMG}" -nobrowse
      /usr/sbin/installer -pkg "/Volumes/Install Google Drive/GoogleDrive.pkg" -target /
      echo "Installation complete"
    fi
elif [ "${arch_name}" = "arm64" ]; then
  echo "Running on ARM"
  # change directory to /private/tmp to make this the working directory
  #cd "${directory}"
  # download the installer package and name it for the linkID
  #/usr/bin/curl -JL "$googledrive_url" -o "${vendorDMG}"
  # install the package
  #hdiutil attach "${directory}/${vendorDMG}" -nobrowse
  #/usr/sbin/installer -pkg "/Volumes/Install\ Google\ Drive/GoogleDrive.pkg" -target /
  #echo "Installation complete"
  echo "Google Drive does not work with ARM"
  exit 0
else
    echo "Unknown architecture: ${arch_name}"
    exit 0
fi

### Check for resources and files left over

if [ -e "/Volumes/Install Google Drive" ]; then
  echo "detach attached dmg file"
  hdiutil detach -force "/Volumes/Install Google Drive"
else
  echo "no disk attached"
fi

if [[ -e "${directory}/${vendorDMG}" ]]; then
  echo "${directory}/${vendorDMG} exists, cleanup starting"
  rm -Rf "${directory}/${vendorDMG}"
else
  echo "${directory}/${vendorDMG} does not exist, completion imminent"
fi

### Check for logs in JAMF

echo "Check installation logs in JAMF"

exit 0