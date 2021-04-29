#!/bin/bash

### install open vpn client from DMG file

hdiutil attach /Users/magus/Downloads/openvpn-connect-3.2.6.3136_signed.dmg

sudo installer -verboseR -pkg OpenVPN_Connect_3_2_6\(3136\)_Installer_signed.pkg -target /

if [[ -e /Applications/OpenVPN ]]

hdiutil eject /Volumes/OpenVPN\ Connect
