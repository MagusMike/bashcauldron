#!/bin/bash
#
# ERASE AND INSTALL with checks and interaction prompts
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# USER VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

adminuser="wellframeit"

adminpass="$5"

installerversion="11.2.3"

parameter7="$7"

parameter8="$8"

parameter9="$9"

loggedInUser=$(dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p')
directory="/private/tmp/eni"
## Icon to be used for userDialog
icon="${directory}/logo4.png"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
windowType="utility"
button1="START"
button2="QUIT"
## Title to be used for userDialog
description="Hi $loggedInUser, You are choosing to erase and install the current version of macOS
Please choose to continue or quit."
## Title to be used for userDialog (only applies to Utility Window)
title="Erase and Install"
alignDescription="left" 
alignHeading="left"
alignCountdown="center"
iconSize="250"
description2="Hi $loggedInUser, You must download media in order to continue, this can take between 30 and 45 minutes to complete. 
Please Select START to continue the process or QUIT to end now."
## Title to be used for userDialog (only applies to Utility Window)
title2="Download Media Required"

## Amount of time (in seconds) to allow a user to connect to AC power before moving on
## If null or 0, then the user will not have the opportunity to connect to AC power
acPowerWaitTimer="90"

## Declare the sysRequirementErrors array
declare -a sysRequirementErrors=()

## The startossinstall log file path
osinstallLogfile="/var/log/startosinstall.log"

##Get Current User
currentUser=$(/bin/echo 'show State:/Users/ConsoleUser' | /usr/sbin/scutil | /usr/bin/awk '/Name / { print $3 }')

## Check if FileVault Enabled
fvStatus=$( /usr/bin/fdesetup status | /usr/bin/head -1 )

### application version
appcheck="/Applications/Install macOS Big Sur.app"

## The startossinstall command option array
declare -a startosinstallOptions=()

media_wait_timer="45"


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# FUNCTIONS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

validate_free_space() {
    local diskInfoPlist freeSpace requiredDiskSpaceSizeGB

    diskInfoPlist=$(/usr/sbin/diskutil info -plist /)
    ## 10.13.4 or later, diskutil info command output changes key from 'AvailableSpace' to 'Free Space' about disk space.
    ## 10.15.0 or later, diskutil info command output changes key from 'APFSContainerFree' to 'Free Space' about disk space.
    freeSpace=$(
    /usr/libexec/PlistBuddy -c "Print :APFSContainerFree" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :FreeSpace" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null || /usr/libexec/PlistBuddy -c "Print :AvailableSpace" /dev/stdin <<< "$diskInfoPlist" 2>/dev/null
    )

    ## Check if free space > 15GB (install 10.13), 20GB (install 10.14+) or 35GB (install 11.0)
    requiredDiskSpaceSizeGB=35

#   requiredDiskSpaceSizeGB=$([ "$installerMajor" -ge 14 ] && /bin/echo "20" || /bin/echo "15")
    if [[ ${freeSpace%.*} -ge $(( requiredDiskSpaceSizeGB * 1000 * 1000 * 1000 )) ]]; then
        echo "Disk Check: OK - ${freeSpace%.*} Bytes Free Space Detected" >> $osinstallLogfile 2>&1 &
    else
        sysRequirementErrors+=("Has at least ${requiredDiskSpaceSizeGB}GB of Free Space")
        echo "Disk Check: ERROR - ${freeSpace%.*} Bytes Free Space Detected" >> $osinstallLogfile 2>&1 &
    fi
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SYSTEM CHECKS
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

### Directory check for icon download
if [[ ! -d "${directory}" ]]; then
  echo "making directory"
  mkdir "${directory}"
else
  echo "directory exists"
fi

### Icon download from /usr/bin/curl and our company logo
/usr/bin/curl -s -o ${directory}/logo4.png https://pbs.twimg.com/profile_images/939197801182896128/hV12uUUs_400x400.jpg

### Check for installer.app or download a new one from softwareupdate --fetch-full-installer --full-installer-version $installerversion
validate_free_space
osascript -e 'display notification "Free space check complete" with title "Erase and Install"'
sleep 3

if [[ ! -e $appcheck ]]; then
  echo 'download required to continue'
  ### User input to double check the erase and install options
    userChoice2=$("$jamfHelper" -windowType "$windowType" -lockHUD -title "$title2" -defaultButton "$defaultButton" -icon "$icon" -description "$description2" -alignCountdown "$alignCountdown" -alignDescription "$alignDescription" -alignHeading "$alignHeading" -button1 "$button1" -button2 "$button2")

    if [ "$userChoice2" == "0" ]; then
    echo "User selected START" >> $osinstallLogfile 2>&1 &
    elif [ "$userChoice2" == "2" ]; then
    echo "User selected to QUIT, exiting now." >> $osinstallLogfile 2>&1 &
    exit 1
    fi
  echo 'starting download process - call trigger initialized'
  osascript -e 'display dialog "Please dont power off your machine or disconnect your internet connection while attempting to download media" buttons {"OK"} default button 1 '
  sleep 3
  softwareupdate --fetch-full-installer --full-installer-version ${installerversion}
else
  echo 'installation media found'
fi

osascript -e 'display notification "application now available " with title "Erase and Install"'
sleep 2
killall jamfHelper

echo "installation about to start... "


## Loop for "acPowerWaitTimer" seconds until either AC Power is detected or the timer is up
echo "Waiting for AC power check"
while [[ "$acPowerWaitTimer" -lt "90" ]]; do
    if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
        echo "Power Check: OK - AC Power Detected"
    else
        echo "opening prompt to alert user of AC Power Error "
        /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType "$windowType" -title "Waiting for AC Power Connection" -icon "$icon" -description "Please connect your computer to power using an AC power adapter. This process will continue once AC power is detected."
    fi
    sleep 2
    ((acPowerWaitTimer--))
    done

if /usr/bin/pmset -g ps | /usr/bin/grep "AC Power" > /dev/null ; then
    echo "Power Check: OK - AC Power Detected"
else
    echo "AC Power Error - killing process and exiting... "
    killall jamfHelper 
    exit 1
fi

killall jamfHelper 

### User input to double check the erase and install options
userChoice=$("$jamfHelper" -windowType "$windowType" -lockHUD -title "$title" -defaultButton "$defaultButton" -icon "$icon" -description "$description" -alignCountdown "$alignCountdown" -alignDescription "$alignDescription" -alignHeading "$alignHeading" -button1 "$button1" -button2 "$button2")

if [ "$userChoice" == "0" ]; then
    echo "User selected START" >> $osinstallLogfile 2>&1 &
elif [ "$userChoice" == "2" ]; then
    echo "User selected to QUIT, exiting now." >> $osinstallLogfile 2>&1 &
    exit 1
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# APPLICATION
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## Set required startosinstall options
startosinstallOptions+=(
"--agreetolicense"
"--nointeraction"
"--eraseinstall"
"--user ${adminuser}"
"--stdinpass "
)

echo "startOS Options set"

echo "All set, starting install"

## Begin Upgrade
osascript -e 'display notification "starting erase and install " with title "Erase and Install"'
echo "Running a command as echo $adminpass | /Applications/Install macOS Big Sur.app/Contents/Resources/startosinstall ${startosinstallOptions[*]}'..." >> $osinstallLogfile 2>&1 &
echo $adminpass | /Applications/Install\ macOS\ Big\ Sur.app/Contents/Resources/startosinstall ${startosinstallOptions[*]} 

/bin/sleep 3

exit 0