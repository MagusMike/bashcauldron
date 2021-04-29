#!/bin/bash

intel=$(sysctl -a | grep machdep.cpu.vendor | awk '{print $2}' | cut -c 8-12)
slack="Slack"
vendorDMG="slack.dmg"
slackarm_url="https://slack.com/ssb/download-osx-silicon"
slackintel_url="https://slack.com/ssb/download-osx"
directory="/private/tmp/slack"
arch_name="$(uname -m)"
app="/Applications/Slack.app"
pid=$(ps acx | grep Slack | awk '{print $5}' | sort -u)

### directory search

if [ -d "${directory}" ]; then
    echo "${directory} exists" 
else
    echo "Error: ${directory} does not exist yet"
    mkdir ${directory}
fi

### Check for installation and processes before we start
if [ -e $app ]; then
  echo "Slack processes detected"
    if [[ $pid == $slack ]]; then
      echo "Slack is running and needs to be killed"
      kill -9 $(pgrep Slack)
      echo "Killing processes"
    else
      echo "Slack is not running"
    fi
else
  echo "no Slack processes detected"
fi

if [ -e $app ]; then
  echo "Slack insallation detected"
  echo "Removing application and files"
  rm -Rf $app
  sleep 10
else
  echo "no Slack installation detected"
fi

### Check that the files are gone and the CPU matches installation media
if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
    else
        echo "Running on native Intel"
        if [[ $intel == "Intel"  ]] && [[ ! -e "${app}" ]]; then
          echo "setup starting"
          # change directory to make this the working directory
          cd ${directory}
          # download the installer package and name it for the linkID
          /usr/bin/curl -JL "${slackintel_url}" -o "${vendorDMG}"
          # install the package
          hdiutil attach ${directory}/${vendorDMG} -nobrowse 
          echo ""
          cp -a -f /Volumes/Slack.app/Slack.app /Applications/
          echo ""
          sleep 20
          echo ""
          open /Applications/Slack.app
          sleep 5
          echo ""
          pkill -x Slack
          echo ""
          sleep 2
          hdiutil eject /Volumes/Slack.app
          echo "installation complete"
        else
          echo "There was something wrong with installation steps"
        fi
    fi 
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
      if [ ! -e "${app}" ]; then
        echo "setup starting"
        # change directory to make this the working directory
        cd ${directory}
        # download the installer package and name it for the linkID
        /usr/bin/curl -JL "${slackarm_url}" -o "${vendorDMG}"
        # install the package
        hdiutil attach ${directory}/${vendorDMG} -nobrowse 
        echo ""
        cp -a -f /Volumes/Slack.app/Slack.app /Applications/
        echo ""
        sleep 20
        echo ""
        open /Applications/Slack.app
        sleep 5
        echo ""
        pkill -x Slack
        echo ""
        sleep 2
        hdiutil eject /Volumes/Slack.app
        echo "installation complete"
      else
        echo "There was something wrong with installation steps"
      fi
else
    echo "Unknown architecture: ${arch_name}"
fi

### Check for resources and files left over

if [ -d /Volumes/Slack ]; then
  echo "detach attached dmg file"
  hdiutil detach /Volumes/Slack
else
  echo "no disk attached"
fi

if [ -d $directory ]; then
  echo "${directory} exists, cleanup starting"
  rm -Rf ${directory}
else
  echo "${directory} does not exist, completion imminent"
fi

### Check for logs in JAMF

echo "Check installation logs in JAMF"
exit 0