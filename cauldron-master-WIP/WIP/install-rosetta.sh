#!/bin/bash

### Variables
arch=$(/usr/bin/arch)
processor=$(/usr/sbin/sysctl -n machdep.cpu.brand_string | grep -o "Intel")
rosetta=$(softwareupdate --install-rosetta --agree-to-license)

#### is this an ARM Mac?
if [ "$arch" == "arm64" ]; then
    # is rosetta 2 installed?
    if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
        echo "Rosetta installation detected"
    else
    # attempt to install missing softwareupdate rosetta translation tool
        echo "missing, attempting to install now."
        ${rosetta}
        sleep 5
        if [[ $? -eq 0 ]]; then
        	echo "Rosetta has been successfully installed."
        else
        	echo "Rosetta installation failed!"
        	exitcode=1
        fi
    fi
else
	# Check processor on exit to make sure data matches outcome of script
    if [[ -n "${processor}" ]]; then
    echo "${processor} processor installed. No need to install Rosetta."
    echo "ineligible"
    fi
fi 


echo "exiting script, check logs"
exit 0