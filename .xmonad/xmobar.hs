Config {
	font = "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*"
	, lowerOnStart = True
	, commands = [
		Run StdinReader
		, Run MultiCpu ["-L","60","-H","90","-n","yellow","-h","red","-t","<autobar>"] 10
		, Run Com "/sbin/ifconfig" ["wlan0","|","awk","'/inet / {print $2}'"] "ip" 100
		, Run Com "/sbin/ifconfig" ["wlan0","|","grep","-q","associated","&&","echo","@","||","echo"] "carrier" 100
		, Run Com "/sbin/ifconfig" ["wlan0","|","grep","ssid","|","sed","-e","'s/ channel.*//'","-e","'s/.*ssid //'"] "ssid" 100
		, Run Com "netstat" ["-h","-w1","-q1","|","awk","'NR>2 {print $4\\"B|\\" $7\\"B\\"}'"] "net" 10
		, Run Com "vmstat" ["-h","|","awk","'NR>2 {print $5}'"] "mem" 50
		, Run Com "/sbin/zpool" ["list","|","awk","'/zroot/{print $4}'"] "zpool" 100
		, Run Com "/sbin/sysctl" ["-n","hw.acpi.thermal.tz0.temperature"] "tz" 100
		, Run Com "/sbin/sysctl" ["-n","hw.acpi.battery.life"] "bat" 100
		, Run Kbd [("us(dvp)", "DV"), ("us(alt-intl)", "US")]
		, Run Date "%Y-%m-%d %H:%M" "date" 10
	]
		, sepChar = "$"
		, alignSep = "}{"
		, template = "$StdinReader$}<fc=#333333><action=urxvt -e htop>$multicpu$</action></fc>{<fc=#765400><action=urxvt -e systat -netstat><$net$></action></fc> <fc=#987600><action=wifimgr>$ip$$carrier$$ssid$</action></fc> <fc=#ba9800><action=urxvt -e systat -vmstat>m:$mem$</action> <action=urxvt -e systat -iostat>z:$zpool$</action> $tz$ $bat$%</fc> <fc=#cb6500>$kbd$</fc> <fc=#fe3200><action=xclock>$date$</action></fc>"
}
