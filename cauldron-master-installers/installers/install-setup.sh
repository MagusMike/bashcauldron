#!/usr/bin/env bash

######################################################################
#
# INSTALLATION OF REQUIRED SOFTWARE FOR NEW MACBOOKS
#
######################################################################
#
# This will start via com.wellframe.setup.plist daemon - which should start at enrollment complete
#
###### variables and arrays
#
jamfpid=$(ps acx | grep jamf | awk '{print $5}' | head -n 1)
enrollmentTimeout=120
timeoutCounter=0

app_array=(protect slack chrome drive openvpn zoom)
dock=$(ps acx | grep Dock | awk '{print $1}' | head -n 1|  cut -c 1-5)
finder=$(ps acx | grep Finder | awk '{print $1}' | head -n 1 | cut -c 1-5)
directory="/private/tmp/enrollment"
icon="${directory}/logo4.png"
timeout1="60"
loggedInUser=$(dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p')
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
windowType="utility"
button1="START"
description="Hi $loggedInUser, your new macbook is setting up some applications and configurations which will run in the background after this message closes

If you require assistance, please contact IT by email at it@wellframe.com"
title="Welcome to Wellframe"
alignDescription="left" 
alignHeading="left"
alignCountdown="center"
iconSize="250"
### second set of JAMFhelper
jamfHelper2="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
title2="Preparing Spell Ingredients"
heading2="IT WIzard casts: Restart"
description2=" $loggedInUser please select Reboot to finish configuration

The MacBook will auto reboot in 5 minutes without the selection"
button2="Reboot"
timeout2="300"
defaultButton="1"

#### check that someone is logged in and ready to kick off our setup script

until [[ -f /var/db/.AppleDiagnosticsSetupDone ]]; 
do
	echo "Waiting for someone to complete Setup Assistant."
	sleep 2
done

until [[ -f /var/log/jamf.log ]]
do
	if [[ $timeoutCounter -ge $enrollmentTimeout ]];
	then
		echo "Gave up waiting for the jamf log to appear."
		exit 1
	else
		echo "Waiting for the jamf log to appear. Timeout counter: \${timeoutCounter} of ${enrollmentTimeout}."
		((timeoutCounter++))
		sleep 1
	fi
done

until ( /usr/bin/grep -q enrollmentComplete /var/log/jamf.log )
do
	if [[ $timeoutCounter -ge $enrollmentTimeout ]];
	then
		echo "Gave up waiting for enrollment to complete."
		exit 1
	else
		echo "Waiting for jamf enrollment to complete: Timeout counter: ${timeoutCounter} of ${enrollmentTimeout}."
		((timeoutCounter++))
		sleep 1
	fi
done

until [[ ${jamfpid} > 0 ]]; 
do
  echo "jamf process found starting setup"
  sleep 2
done

###### Create directory and grab icon image from specified URL and place into /tmp

if [[ ! -d "${directory}" ]]; then
  echo "making directory"
  mkdir "${directory}"
else
  echo "directory exists"
fi

/usr/bin/curl -s -o ${directory}/logo4.png https://pbs.twimg.com/profile_images/939197801182896128/hV12uUUs_400x400.jpg

######## system found Dock is running which means a user is logged on.

if [[ "${dock}" > 0 ]] && [[ "${finder}" > 0 ]]; then
  echo "Logon successful, starting requests"
  sleep 5
else
  echo "logon unsuccesful, check logs"
  sleep 5
fi

###### JAMF Helper window as it appears for targeted computers

sleep 20

userChoice=$("$jamfHelper" -windowType "$windowType" -lockHUD -title "$title" -timeout "${timeout1}" -defaultButton "$defaultButton" -countdown -icon "$icon" -description "$description" -alignCountdown "$alignCountdown" -alignDescription "$alignDescription" -alignHeading "$alignHeading" -button1 "$button1")

if [ "$userChoice" == "0" ]; then
    echo "User selected START"
elif [ "$userChoice" == "2" ]; then
    echo "Timeout was reached, starting now..."
fi

######## statement to run installation through array while prompting users via display text about a new installation

for app in "${app_array[@]}"; do
  jamf policy -event install-$app
  echo "installing $app"
  osascript -e 'display notification "Applications starting install... " with title "Requests running... " subtitle "Processing new installation "'
done

######echo "installing ${app_array[0]}" 
######echo "installing ${app_array[1]}"
######echo "installing ${app_array[2]}"
######echo "installing ${app_array[3]}"
######echo "installing ${app_array[4]}"
######echo "installing ${app_array[5]}"

######check for all installations to be completed and add icons to the Dock

if [[ -e /Applications/zoom.us.app ]] && [[ -e /Applications/Openvpn\ Connect ]]; then
  echo "opening app and setting dock shortcut"
  open "/Applications/Google Chrome.app"
  open /Applications/zoom.us.app
  open /Applications/Slack.app
  open "/Applications/OpenVPN Connect/OpenVPN Connect.app"
  sleep 5
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Google Chrome.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>";
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Self Service.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>";
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/OpenVPN Connect/OpenVPN Connect.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>";
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Slack.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>";
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/zoom.us.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"; killall Dock
else
  echo "applications not found in /Applications/"
  exit 1
fi

echo "All done"

echo "JAMF logs to see installation success or failure"

######## user input for restart to finish configurations, installs, and removal of media

userChoice2=$("$jamfHelper2" -windowType "$windowType" -lockHUD -timeout "${timeout2}" -countdown -title "$title2" -heading "$heading2" -timeout "$timeout2" -defaultButton "$defaultButton" -icon "$icon" -iconSize "$iconSize"  -description "$description2" -alignDescription "$alignDescription" -alignCountdown "$alignCountdown" -alignHeading "$alignHeading" -button1 "$button2")

if [ "$userChoice2" == "0" ]; then
  echo "User selected Reboot"
      if [[ -d "${directory}" ]]; then
        echo "starting removal media"
        rm -rf "${directory}"
        sleep 5      
      else
        echo "directory and media missing, could not remove daemon and directories, review logs"      
      fi
  osascript -e 'tell application "System Events" to restart'
elif [ "$userChoice2" == "2" ]; then
  echo "Timeout was reached, now exiting"
      if [[ -d "${directory}" ]]; then
        echo "starting removal media"
        rm -rf "${directory}"
        sleep 5
      else
        echo "directory and media missing, could not remove daemon and directories, review logs"
      fi
  osascript -e 'tell application "System Events" to restart'
fi

######set bootToWindowsAlert to "Restart"
######set bootToWindowsConfirm to "finish configurations by selecting Restart"
######display alert bootToWindowsAlert message bootToWindowsConfirm as critical buttons {"Restart"} default button "Restart"
######tell application "System Events" to restart