#!/bin/bash

vendorDMG="firefox.dmg"
firefox_url="https://download.mozilla.org/?product=firefox-latest-ssl&os=osx&lang=en-US"
directory="/private/tmp/firefox"
app="/Applications/Firefox.app"
pid=$(ps acx | grep "Firefox" | awk '{print $1}' | head -n 1)

### directory search

if [ -d "${directory}" ]; then
    echo "${directory} exists" 
else
    echo "Error: ${directory} does not exist yet"
    mkdir ${directory}
fi

sleep 2

if [ -e "${app}" ]; then
  echo "Firefox insallation detected"
  echo "Removing application and files"
  if [[ $pid > 0 ]]; then
    echo "killing processes"
    kill -9 $(pgrep "Firefox")
  else
    echo "Firefox not running"
  fi
  rm -Rf "${app}"
  sleep 15
else
  echo "no Firefox installation detected"
fi

### Check that the files are gone and the CPU matches installation media
if [ ! -e "${app}" ]; then
  echo "setup starting"
  # change directory to make this the working directory
  cd ${directory}
  # download the installer package and name it for the linkID
  /usr/bin/curl -JL "${firefox_url}" -o "${vendorDMG}"
  # install the package
  hdiutil attach ${directory}/${vendorDMG} -nobrowse 
  echo ""
  cp -a -f "/Volumes/Firefox/Firefox.app" /Applications/
  echo ""
  sleep 25
  echo ""
  hdiutil detach -force "/Volumes/Firefox"
  echo "installation complete"
  sleep 2
  open /Applications/Firefox.app
  echo ""
  sleep 8
  kill -9 $(pgrep "Firefox")
  echo ""
else
  echo "There was something wrong with installation steps"
  echo "removing media and files"
fi

### Check for resources and files left over

if [ -e "/Volumes/Firefox" ]; then
  echo "detach attached dmg file"
  hdiutil detach -force "/Volumes/Firefox"
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







mkdir ~/jamf_temp
cd ~/jamf_temp

# Installing Firefox
curl -L -o Firefox.dmg "http://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US"
hdiutil mount -nobrowse Firefox.dmg
cp -R "/Volumes/Firefox/Firefox.app" /Applications
hdiutil unmount "/Volumes/Firefox"
rm Firefox.dmg


#!/bin/bash
#Automatically downloads latest Firefox package and installs
#Created 6-2-2020 by Shaquir Tannis
#Influenced by https://www.jamf.com/jamf-nation/discussions/35211/updates-to-google-chrome-deployment-for-macos#responseChild200000

programDownloadUrl=$(curl "$4" -s -L -I -o /dev/null -w '%{url_effective}')
pkgName=$(printf "%s" "${programDownloadUrl[@]}" | sed 's@.*/@@' | sed 's/%20/-/g')
programPkgPath="/tmp/$pkgName"
logfile="/Library/Logs/ScriptInstaller.log"

/bin/echo "--" >> ${logfile}
/bin/echo "`date`: Downloading program." >> ${logfile}
#Downloads file
/usr/bin/curl -L -o "$programPkgPath" "$programDownloadUrl"
/bin/echo "`date`: Installing $pkgName..." >> ${logfile}
#Install PKG
cd /tmp
/usr/sbin/installer -pkg "$pkgName" -target /
/bin/sleep 10
/bin/echo "`date`: Deleting package installer." >> ${logfile}
#Remove package if it still exists
if test -f "$programPkgPath"; then
    /bin/rm "$programPkgPath"
else
    echo "$programPkgPath does not exist."
fi