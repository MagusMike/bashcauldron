#!/bin/bash

#### kick off script for install package 

# Variables for script
agent="/Library/LaunchDaemons/com.cylance.agent_service.plist"
intel_url="https://zoom.us/client/latest/ZoomInstallerIT.pkg"
arm_url="https://zoom.us/client/latest/Zoom.pkg?archType=arm64"
arch_name="$(uname -m)"
arch=$(/usr/bin/arch)

#### Run a check for application installation

if [ -e "/Applications/Cylance" ]; 
then
  echo “Application found”
  exit 0
else
  echo “Not Installed.”
fi
 
if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
        ## change to directory with package and files
        cd /private/tmp/protect
        ## kick off echo/cat of key to token files
        echo "find token key:  "
        cat /private/tmp/protect/Cylancekey.txt
        cat /private/tmp/protect/Cylancekey.txt >cyagent_install_token
        ## start package installer
        installer -pkg CylancePROTECT.pkg -target /
        sleep 30
    else
        ## change to directory with package and files
        cd /private/tmp/protect
        ## kick off echo/cat of key to token files
        echo "find token key:  "
        cat /private/tmp/protect/Cylancekey.txt
        cat /private/tmp/protect/Cylancekey.txt >cyagent_install_token
        ## start package installer
        installer -pkg CylancePROTECT.pkg -target /
        sleep 30
    fi 
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
    # is this an ARM Mac?
        if [ "$arch" == "arm64" ]; then
        # is rosetta 2 installed?
            if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
            echo "rosetta installed, installation running... "
            ## change to directory with package and files
            cd /private/tmp/protect
            ## kick off echo/cat of key to token files
            echo "find token key:  "
            cat /private/tmp/protect/Cylancekey.txt
            cat /private/tmp/protect/Cylancekey.txt >cyagent_install_token
            ## start package installer
            installer -pkg CylancePROTECT.pkg -target /
            sleep 30
            else
            echo "rosetta missing, attempting installation of Rosetta and Application"
            softwareupdate --install-rosetta --agree-to-license
            sleep 5
            ## change to directory with package and files
            cd /private/tmp/protect
            ## kick off echo/cat of key to token files
            echo "find token key:  "
            cat /private/tmp/protect/Cylancekey.txt
            cat /private/tmp/protect/Cylancekey.txt >cyagent_install_token
            ## start package installer
            installer -pkg CylancePROTECT.pkg -target /
            sleep 30
            fi
        else
        echo "ineligible, check logs for more information"
        exit 1
        fi 
else
    echo "Unknown architecture: ${arch_name}"
    exit 1
fi

## Check for application 
if [ -d /Applications/Cylance ]; then
echo 'cylance protect folder exists checking for process or agent '
  if [[ -f ${agent} ]]; then
        echo "cylance protect agent plist file found"
  fi
else
    echo "cylance protect agent plist file not found"
fi

### end output
echo 'check log files for more information'
exit 0