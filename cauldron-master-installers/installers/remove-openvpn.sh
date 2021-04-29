#!/usr/bin/env bash
SECONDS_SINCE_EPOCH="$(date +%s)"
LOG="/tmp/openvpn-connect-uninstall-$SECONDS_SINCE_EPOCH.log"
rm -rf $LOG
exec > $LOG 2>&1


AGENT_FRAMEWORK="/Library/Frameworks/OpenVPNConnect.framework"
AGENT_DAEMON_PLIST="/Library/LaunchDaemons/org.openvpn.client.plist"

HELPER_FRAMEWORK="/Library/Frameworks/OVPNHelper.framework"
HELPER_DAEMON_PLIST="/Library/LaunchDaemons/org.openvpn.helper.plist"

APP="/Applications/OpenVPN Connect"
APP_SUPP=~/Library/"Application Support"/"OpenVPN Connect"

CACHES=~/Library/"Saved Application State"/"org.openvpn.client.app.savedState"
PREFS1=~/Library/"Preferences"/"org.openvpn.client.app.helper.plist"
PREFS2=~/Library/"Preferences"/"org.openvpn.client.app.plist"
LOGS=~/Library/"Logs"/"OpenVPN Connect"

APP_LINK="/Applications/OpenVPN Connect.app"


# close app
echo "Closing app..."
open -n "/Applications/OpenVPN Connect/OpenVPN Connect.app" --args --quit
sleep 2


echo "Services:"
launchctl list | grep openvpn
echo ""
echo "Daemon property lists:"
ls /Library/LaunchDaemons | grep openvpn
echo ""


echo "Stopping client backend..."
launchctl unload $AGENT_DAEMON_PLIST
launchctl stop org.openvpn.client
launchctl unload $HELPER_DAEMON_PLIST
launchctl stop org.openvpn.helper
echo ""

echo "Services:"
launchctl list | grep openvpn
echo ""
echo "Daemon property lists:"
ls /Library/LaunchDaemons | grep openvpn
echo ""


# remove everything, but preserve daemon to unload it on next install
rm -rf "$APP" "$APP_SUPP" "$AGENT_FRAMEWORK" "$HELPER_FRAMEWORK" "$CACHES" "$PREFS1" "$PREFS2" "$LOGS" "$APP_LINK"
echo ""

echo "uninstall finished"
