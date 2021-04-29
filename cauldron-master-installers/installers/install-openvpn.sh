#!/bin/bash

arch=$(/usr/bin/arch)
openvpn_url="https://openvpn.net/downloads/openvpn-connect-v3-macos.dmg"
directory="/private/tmp/OpenVPN"
arch_name="$(uname -m)"
app="/Applications/OpenVPN Connect"

### directory search

if [ -d "${directory}" ]; then
    echo "${directory} exists" 
else
    echo "Error: ${directory} does not exist yet"
    mkdir /private/tmp/OpenVPN
fi

### download and install media based on arch type 

if [ "${arch_name}" = "x86_64" ]; then
    if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
        echo "Running on Rosetta 2"
    else
        echo "Running on native Intel"
        if [ ! -e "${app}" ]; then
        # change directory to make this the working directory
          cd /private/tmp/OpenVPN
        # download the installer package and name it for the linkID
          /usr/bin/curl -JL "${openvpn_url}" -o "openvpn.dmg"
        # install the package
          hdiutil attach /private/tmp/OpenVPN/openvpn.dmg -nobrowse 
          echo ""
          sudo installer -verboseR -pkg /Volumes/OpenVPN\ Connect/OpenVPN_Connect*.pkg -target /
          echo ""
          sleep 30
          echo ""
          hdiutil eject /Volumes/OpenVPN\ Connect 
          echo "installation complete"
        else
          echo "Installation ERROR - Application files found without installation"
            if [ -e "${app}" ]; then
              echo "clean up files and resources"
              rm -Rf /private/tmp/OpenVPN
            else
              echo "nothing to clean up"
              exit 0
            fi
        fi
    fi 
elif [ "${arch_name}" = "arm64" ]; then
    echo "Running on ARM"
    # is this an ARM Mac?
      if [ "$arch" == "arm64" ]; then
    # is rosetta 2 installed?
        if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
          echo "Rosetta installed"
            if [ ! -e "${app}" ]; then
          # change directory to make this the working directory
              echo "moving directorys to start installation process"
              cd /private/tmp/OpenVPN
          # download the installer package and name it for the linkID
              /usr/bin/curl -JL "${openvpn_url}" -o "openvpn.dmg"
          # install the package
              hdiutil attach /private/tmp/OpenVPN/openvpn.dmg -nobrowse 
              echo ""
              sudo installer -verboseR -pkg /Volumes/OpenVPN\ Connect/OpenVPN_Connect*.pkg -target /
              echo ""
              sleep 30
              echo ""
              hdiutil eject /Volumes/OpenVPN\ Connect 
              echo "installation complete"
            else
              echo "Installation ERROR - Application files found without installation"
                if [ -e "${app}" ]; then
                  echo "clean up files and resources"
                  rm -Rf /private/tmp/OpenVPN
                else
                  echo "nothing to clean up"
                  exit 0
                fi
            fi
        else
          echo "Rosetta missing"
        fi
      else
        echo "BEEP ZZZZ BEEP ::::ineligible:::: ZZZZZ BEEP"
      fi 
 else
    echo "Unknown architecture: ${arch_name}"
    exit 1
fi

### Check for logs in JAMF

echo "Check installation logs in JAMF"
exit 0