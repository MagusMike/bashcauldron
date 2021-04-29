#!/bin/zsh

#### Check for installation of Zoom, update or install based off of arch type.

# Set the User Agent string for use with curl
userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

# Get the latest version of Reader available from Zoom page.
latestver=`/usr/bin/curl -s -A "$userAgent" https://zoom.us/download | grep 'ZoomInstallerIT.pkg' | awk -F'/' '{print $3}'`

# Get the version number of the currently-installed Zoom, if any.
currentinstalledver=`/usr/bin/defaults read /Applications/zoom.us.app/Contents/Info CFBundleVersion | sed -e 's/0 //g' -e 's/(//g' -e 's/)//g'`

# Variables for script
intel_url="https://zoom.us/client/latest/ZoomInstallerIT.pkg"
arm_url="https://zoom.us/client/latest/Zoom.pkg?archType=arm64"
arch_name="$(uname -m)"

if [ -e "/Applications/zoom.us.app" ]; 
then
  echo “Checking versioning.”
else
  echo “Not Installed.”
fi
 
if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
    else
        echo "Running on native Intel"
        if [ ${latestver} = ${currentinstalledver} ]; then
          echo “Version is up to date.”
          exit 0  
        else
        # change directory to /private/tmp to make this the working directory
          cd /private/tmp/
        # download the installer package and name it for the linkID
          /usr/bin/curl -JL "$intel_url" -o "Zoom.pkg"
        # install the package
          /usr/sbin/installer -pkg "Zoom.pkg" -target /
        # remove the installer package when done
          /bin/rm -f "Zoom.pkg"
          echo “Installation updated”
        fi
    fi 
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
    if [ ${latestver} = ${currentinstalledver} ]; then
      echo “Version is up to date.”
      exit 0  
    else
    # change directory to /private/tmp to make this the working directory
      cd /private/tmp/
    # download the installer package and name it for the linkID
      /usr/bin/curl -JL "$arm_url" -o "Zoom.pkg"
    # install the package
      /usr/sbin/installer -pkg "Zoom.pkg" -target /
    # remove the installer package when done
      /bin/rm -f "Zoom.pkg"
      echo “Installation updated”
    fi
else
    echo "Unknown architecture: ${arch_name}"
    exit 1
fi

echo "All done"