#! /usr/bin/env zsh
#
# settings for os x, taken from various sources:
#
# https://github.com/mathiasbynens/dotfiles
# http://www.nsa.gov/ia/_files/factsheets/macosx_10_6_hardeningtips.pdf
# http://www.nsa.gov/applications/links/notices.cfm?address=http://images.apple.com/support/security/guides/docs/SnowLeopard_Security_Config_v10.6.pdf
#
# Copyright (C) 2012 nilsonholger@hyve.org
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

function disk {
# turn of sudden motion sensor
sudo pmset -a sms 0
# set up login hook for noatime remount
sudo cat << EOF > /usr/local/bin/remount_noatime
#!/bin/bash
/sbin/mount -uwo noatime,nodev,nosuid,nobrowse /Users/$1
EOF
sudo chown root:staff /usr/local/bin/remount_noatime
sudo chmod a+rx /usr/local/bin/remount_noatime
sudo defaults write com.apple.loginwindow LoginHook /usr/local/bin/remount_noatime
# disable ram to disk backup in sleep mode (to enable set to 3)
sudo pmset -a hibernatemode 0
# optional remove image
sudo rm /var/vm/sleepimage
# disable swap/paging daemon
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.dynamic_pager.plist
# disable mobile backups
# sudo tmutil disablelocal
}

function finder {
# Automatically open a new Finder window when a volume is mounted
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Show the ~/Library folder
chflags nohidden ~/Library
# Show ALL files (including hidden directories and dotfiles)
# defaults write com.apple.Finder AppleShowAllFiles YES
}

function fix {
# Fix for the ancient UTF-8 bug in QuickLook (http://mths.be/bbo)
echo "0x08000100:0" > ~/.CFUserTextEncoding
}

function keyboard {
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
# Disable press-and-hold for keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
}

function reset {
# Reset Launchpad
rm ~/Library/Application\ Support/Dock/*.db
}

function safari {
# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2
# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeDebugMenu -bool true
# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"
}

function setup {
# os x trash
sudo gem install osx-trash
}

function security {
# os x softwareupdate
softwareupdate -i -a
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
sudo launchctl unload -w /System/Library/LaunchAgents/com.apple.RemoteDesktop.plist						#ARD
# remove setuid and setgid
sudo chmod ug-s /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/MacOS/ARDAgent		#Apple Remote Desktop
sudo chmod ug-s /System/Library/Printers/IOMs/LPRIOM.plugin/Contents/MacOS/LPRIOMHelper					#Printing
sudo chmod ug-s /sbin/mount_nfs																			#NFS
sudo chmod ug-s /usr/bin/at																				#Job Scheduler
sudo chmod ug-s /usr/bin/atq																			#Job Scheduler
sudo chmod ug-s /usr/bin/atrm																			#Job Scheduler
sudo chmod ug-s /usr/bin/chpass																			#Change user info
sudo chmod ug-s /usr/bin/crontab																		#Job Scheduler
sudo chmod ug-s /usr/bin/ipcs																			#IPC statistics
sudo chmod ug-s /usr/bin/newgrp																			#Change Group
sudo chmod ug-s /usr/bin/postdrop																		#Postfix Mail
sudo chmod ug-s /usr/bin/postqueue																		#Postfix Mail
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
# disable Bonjour Services
#sudo defaults write /System/Library/ LaunchDaemons/com.apple.mDNSResponder ProgramArguments -array-add "-NoMulticastAdvertisements"
# disable FireWire
sudo mkidr /System/Library/Extensions-disabled
sudo mv /System/Library/Extensions/IOFireWire* /System/Library/Extensions-disabled
# clear file vault password from memory
sudo pmset -a destroyfvkeyonstandby 1
}

function symlinks {
# link airport utility to /usr/sbin/
sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/sbin/airport
}

function visuals {
# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
# Expand print panel by default
defaults write -g PMPrintingExpandedStateForPrint -bool true
# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true
# Enable spring loading for all Dock items
defaults write enable-spring-load-actions-on-all-items -bool true
# Enable Dock Item transparency for hidden Applications
defaults write com.apple.dock showhidden -bool true
# Disable Dock Process Indicators
defaults write com.apple.dock show-process-indicators -bool false
# Disable window animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
}

case $1 in
	all) disk; finder; fix; keyboard; reset; safari; security; setup; symlinks; visuals;;
	disk) disk;;
	finder) finder;;
	fix) fix;;
	keyboard) keyboard;;
	reset) reset;;
	safari) safari;;
	security) security;;
	setup) setup;;
	symlinks) symlinks;;
	visuals) visuals;;
esac
