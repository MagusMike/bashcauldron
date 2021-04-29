#!/bin/bash

# is this an ARM Mac?
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
    # is rosetta 2 installed?
    if [[ -f "/Library/Apple/System/Library/LaunchDaemons/com.apple.oahd.plist" ]]; then
        echo "installed"
    else
        echo "missing"
    fi
else
    echo "ineligible"
fi 