#! /usr/bin/env zsh
#
# settings for os x, inspired by various sources:
#
# https://github.com/mathiasbynens/dotfiles
# http://www.nsa.gov/ia/_files/factsheets/macosx_10_6_hardeningtips.pdf
# http://images.apple.com/support/security/guides/docs/SnowLjopard_Security_Config_v10.6.pdf
#
# Copyright (C) 2012-2014 nilsonholger@hyve.org
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

function osx_debug {
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true
defaults write com.apple.Safari IncludeDebugMenu -bool true
defaults write com.apple.addressbook ABShowDebugMenu -bool true
defaults write com.apple.iCal IncludeDebugMenu -bool true
}

function osx_disk {
sudo pmset -a sms 0 # sudden motion sensor off for SSD
sudo pmset -a hibernatemode 0 # no ram to disk backup for sleep
sudo rm /var/vm/sleepimage
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist # swapoff
}

function osx_dock {
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.25
defaults write com.apple.dock dashboard-in-overlay -bool true
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock orientation -string left
defaults write com.apple.dock show-process-indicators -bool false
defaults write com.apple.dock showhidden -bool true
defaults write com.apple.dock tilesize -int 30
}

function osx_finder {
chflags nohidden ~/Library
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # no .DS_Store on network volumes
defaults write com.apple.finder AppleShowAllExtensions -bool true
#defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/dk/"
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool true
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool false
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool false
}

function osx_general {
defaults write -g AppleScrollerPagingBehavior -int 1 # scroll bar: jump to clicked spot
defaults write -g NSTableViewDefaultSizeMode -int 1 # sidebar icon size: small
defaults write -g NSQuitAlwaysKeepsWindows -bool true # resume windows
#defaults write -g NSDisableAutomaticTermination -bool true # sudden termination
defaults write -g AppleShowAllExtensions -bool true # show all extensions
defaults write -g ShowMountedServersOnDesktop -bool true # desktop: show servers
defaults write -g ShowStatusBar -bool true # finder: show status bar
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1 # tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -int 1
defaults write com.apple.dock showAppExposeGestureEnabled -bool true # trackpad: enable app expose
defaults write com.apple.menuextra.clock IsAnalog -bool true # analog clock
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName # more verbose clock icon
sudo scutil --set ComputerName "mbp"
sudo scutil --set HostName "mbp.hyve.org"
sudo scutil --set LocalHostName "mbp"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "mbp"
defaults write NSGlobalDomain AppleLanguages -array "en" "de"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
defaults write "Apple Global Domain" AppleInterfaceStyle -string Dark
#TODO checkout systemsetup
}

function osx_homebrew {
[ ! -r /usr/bin/clang ] && echo "Please download command line tools for Xcode (https://developer.apple.com/downloads/index.action) first!" && git
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update
brew doctor
brew install git gnupg ddclient pass
cp /usr/local/share/doc/ddclient/sample-etc_ddclient.conf /usr/local/etc/ddclient/ddclient.conf
cat << EOF > /tmp/org.ddclient.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>org.ddclient</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/local/sbin/ddclient</string>
    <string>-file</string>
    <string>/usr/local/etc/ddclient/ddclient.conf</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>WatchPaths</key>
  <array>
    <string>/usr/local/etc/ddclient</string>
  </array>
  <key>WorkingDirectory</key>
  <string>/usr/local/etc/ddclient</string>
</dict>
</plist>
EOF
sudo mv /tmp/org.ddclient.plist /Library/LaunchDaemons/org.ddclient.plist
sudo chown -v root:wheel /Library/LaunchDaemons/org.ddclient.plist
sudo chmod a+r /Library/LaunchDaemons/org.ddclient.plist
sudo launchctl load -w /Library/LaunchDaemons/org.ddclient.plist
}

function osx_itunes {
defaults write com.apple.iTunes disableGeniusSidebar -bool true
defaults write com.apple.iTunes disablePing -bool true
defaults write com.apple.iTunes disablePingSidebar -bool true
defaults write com.apple.iTunes disableRadio -bool true
defaults write com.apple.iTunes show-store-link-arrows -bool false
}

function osx_keyboard {
defaults write -g AppleKeyboardUIMode -int 3 # full keyboard access
defaults write -g ApplePressAndHoldEnabled -bool false # favor key repeat
defaults write com.apple.BezelServices kDim -bool true # keyboard illumination
defaults write com.apple.BezelServices kDimTime -int 300 # dim after 5 minutes
}

function osx_noatime {
sudo mkdir -p /usr/local/bin
sudo chmod -R g=rwX,o=rX /usr/local/
sudo touch /usr/local/bin/remount_noatime
sudo chmod g=rwX /usr/local/bin/remount_noatime
sudo cat << EOF > /usr/local/bin/remount_noatime
#!/bin/bash
/sbin/mount -uwo noatime,nodev,nobrowse /dev/disk1
EOF
sudo chmod g-w /usr/local/bin/remount_noatime
sudo chown root:staff /usr/local/bin/remount_noatime
sudo chmod a+rx /usr/local/bin/remount_noatime
sudo defaults write com.apple.loginwindow LoginHook /usr/local/bin/remount_noatime
}

function osx_power {
sudo pmset -b displaysleep 5
sudo pmset -c displaysleep 20
sudo pmset -c sleep 0
}

function osx_reset {
find ~/Library/Application\ Support/Dock -name "*.db" -maxdepth 1 -delete
}

function osx_safari {
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2 # thumbnails off
defaults write com.apple.Safari ProxiesInBookmarksBar "()"
}

function osx_security {
# TODO update for yosemite
# unneded daemons
#sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.blued.plist							#bluetooth
#sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.IIDCAssistant.plist					#iSight
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.nis.ypbind.plist						#NIS
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.racoon.plist							#VPN
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.RemoteDesktop.PrivilegeProxy.plist		#ARD
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.RFBEventHelper.plist					#ARD
#sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.UserNotificationCenter.plist			#User notifications
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.webdavfs_load_kext.plist				#WebDAV
sudo launchctl unload -w /System/Library/LaunchDaemons/org.postfix.master.plist							#email server
#sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.RemoteUI.plist							#Remote Control
# remove setuid and setgid
sudo chmod ug-s /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/MacOS/ARDAgent		#Apple Remote Desktop
sudo chmod ug-s /sbin/mount_nfs																			#NFS
sudo chmod ug-s /usr/bin/at																				#Job Scheduler
sudo chmod ug-s /usr/bin/atq																			#Job Scheduler
sudo chmod ug-s /usr/bin/atrm																			#Job Scheduler
sudo chmod ug-s /usr/bin/chpass																			#Change user info
sudo chmod ug-s /usr/bin/crontab																		#Job Scheduler
sudo chmod ug-s /usr/bin/ipcs																			#IPC statistics
sudo chmod ug-s /usr/bin/newgrp																			#Change Group
sudo chmod ug-s /usr/bin/procmail																		#Mail Processor
sudo chmod ug-s /usr/bin/wall																			#User Messaging
sudo chmod ug-s /usr/bin/write																			#User Messaging
sudo chmod ug-s /bin/rcp																				#Remote Access (Insecure)
sudo chmod ug-s /usr/bin/rlogin																			#Remote Access (Insecure)
sudo chmod ug-s /usr/bin/rsh																			#Remote Access (Insecure)
sudo chmod ug-s /usr/lib/sa/sadc																		#System Activity Reporting
#sudo chmod ug-s /usr/sbin/scselect																		#User-selectable Network Location
sudo chmod ug-s /usr/sbin/traceroute																	#Trace Network
sudo chmod ug-s /usr/sbin/traceroute6																	#Trace Network

#sudo defaults write /System/Library/LaunchDaemons/com.apple.mDNSResponder ProgramArguments -array-add "-NoMulticastAdvertisements" # Bonjour

#sudo mkidr /System/Library/Extensions-disabled
#sudo mv /System/Library/Extensions/IOFireWire* /System/Library/Extensions-disabled

sudo pmset -a destroyfvkeyonstandby 1 # clear file vault key on sleep
security set-keychain-settings -l # lock keychain on sleep
}

function osx_ssh {
cat << EOF > /tmp/ssh.plist.patch
--- ssh.plist
+++ ssh.plist
@@ -25,6 +25,11 @@
 				<string>sftp-ssh</string>
 			</array>
 		</dict>
+		<key>Alternate Listeners</key>
+		<dict>
+			<key>SockServiceName</key>
+			<string>119</string>
+		</dict>
 	</dict>
 	<key>inetdCompatibility</key>
 	<dict>
EOF
sudo patch -d/System/Library/LaunchDaemons/ ssh.plist /tmp/ssh.plist.patch
rm /tmp/ssh.plist.patch
sudo launchctl stop com.openssh.sshd
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load -wF /System/Library/LaunchDaemons/ssh.plist
}

function osx_symlinks {
sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/sbin/airport
}

function osx_timemachine {
#TODO after using external disk, rotation fails, use tmutil setdestination (requires root) to set ID (from tmutil destinationinfo)
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
sudo tmutil disable
sudo tmutil enablelocal
cat << EOF > ~/Library/LaunchAgents/org.hyve.tmutil.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>org.hyve.tmutil</string>
	<key>ProgramArguments</key>
	<array>
		<string>/bin/zsh</string>
		<string>-c</string>
		<string>/usr/bin/tmutil machinedirectory || sleep 10 &amp;&amp; /usr/bin/tmutil machinedirectory &amp;&amp; /usr/bin/tmutil startbackup --block --rotation || true</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartInterval</key>
	<integer3600</integer>
</dict>
</plist>
EOF
launchctl load -w ~/Library/LaunchAgents/org.hyve.tmutil.plist
}

function osx_visuals {
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true # expand save panel
defaults write -g PMPrintingExpandedStateForPrint -bool true # expand print panel
defaults write com.apple.screencapture disable-shadow -bool true
defaults write enable-spring-load-actions-on-all-items -bool true
#defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
}

function osx_user {
chsh -s /bin/zsh
}

case $1 in
	debug) osx_debug;;
	disk) osx_disk;;
	dock) osx_dock;;
	finder) osx_finder;;
	general) osx_general;;
	homebrew) osx_homebrew;;
	itunes) osx_itunes;;
	keyboard) osx_keyboard;;
	noatime) osx_noatime;;
	power) osx_power;;
	reset) osx_reset;;
	safari) osx_safari;;
	security) osx_security;;
	ssh) osx_ssh;;
	symlinks) osx_symlinks;;
	timemachine) osx_timemachine;;
	user) osx_user;;
	visuals) osx_visuals;;
	user) osx_user;;
	*) cat << EOF
usage: $0 <command>

commands:
    debug disk dock finder general homebrew itunes keyboard noatime power reset safari security ssh symlinks timemachine visuals user
EOF
	;;
esac
