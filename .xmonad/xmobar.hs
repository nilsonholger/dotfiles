Config {
	font = "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*"
	, lowerOnStart = True
	, commands = [
		Run StdinReader
		, Run MultiCpu ["-L","20","-H","90","-n","green","-h","red","-t","<autobar>"] 10
		, Run Com "/sbin/ifconfig" ["wlan0","|","awk","'/ssid/{print $2}'"] "ssid" 100
		, Run Com "netstat" ["-h","-w1","-q1","|","awk","'NR>2 {print $4\\"|\\" $7}'"] "net" 10
		, Run Com "vmstat" ["-h","|","awk","'NR>2 {print $5}'"] "mem" 50
		, Run Com "/sbin/zpool" ["list","|","awk","'/zroot/{print $4}'"] "zpool" 100
		, Run Kbd [("us(dvp)", "DV"), ("us(alt-intl)", "US")]
		, Run Date "%Y-%m-%d %H:%M" "date" 10
	]
		, sepChar = "%"
		, alignSep = "}{"
		, template = "%StdinReader%}<action=urxvt -e htop>%multicpu%</action>{<%net%> <action=wifimgr>%ssid%</action> m:%mem% z:%zpool% %kbd% <fc=#ee3a00><action=xclock>%date%</action></fc>"
}
