#!/bin/zsh

#### Check for installation of Zoom, update or install based off of arch type.

# Set the User Agent string for use with curl
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

# Get the latest version of Reader available from Zoom page.
latestver=`/usr/bin/curl -s -A "$userAgent" https://zoom.us/download | grep 'ZoomInstallerIT.pkg' | awk -F'/' '{print $3}'`

# Get the version number of the currently-installed Zoom, if any.
currentinstalledver=`/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info CFBundleVersion | sed -e 's/0 //g' -e 's/(//g' -e 's/)//g'`

# Variables for script
app="Microsoft Edge.app"
intel_url="https://officecdn-microsoft-com.akamaized.net/pr/03adf619-38c6-4249-95ff-4a01c0ffc962/MacAutoupdate/MicrosoftEdge-88.0.705.81.pkg" 
arm_url="https://officecdn-microsoft-com.akamaized.net/pr/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/MicrosoftEdge-88.0.705.81.pkg" 
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
      cd /private/tmp/
      # download the installer package and name it for the linkID
      /usr/bin/curl -JL "$intel_url" -o "edge.pkg"
      # install the package
      /usr/sbin/installer -pkg "edge.pkg" -target /
      # remove the installer package when done
      /bin/rm -f "edge.pkg"
      echo “Installation updated”
    fi
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
    # change directory to /private/tmp to make this the working directory
      cd /private/tmp/
    # download the installer package and name it for the linkID
      /usr/bin/curl -JL "$arm_url" -o "edge.pkg"
    # install the package
      /usr/sbin/installer -pkg "edge.pkg" -target /
    # remove the installer package when done
      /bin/rm -f "edge.pkg"
      echo “Installation updated”
else
    echo "Unknown architecture: ${arch_name}"
    exit 0
fi

###### adding shortcut 

defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Microsoft Edge.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
killall Dock

####### - exit codes

exit 0 # SUCCESS