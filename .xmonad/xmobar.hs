Config {
	font = "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*"
	, lowerOnStart = True
	, commands = [
		Run StdinReader
		, Run MultiCpu ["-L","60","-H","90","-n","yellow","-h","red","-t","<autobar>"] 10
		, Run Com "/sbin/ifconfig" ["wlan0","|","awk","'/ssid/{print $2}'"] "ssid" 100
		, Run Com "netstat" ["-h","-w1","-q1","|","awk","'NR>2 {print $4\\"B|\\" $7\\"B\\"}'"] "net" 10
		, Run Com "vmstat" ["-h","|","awk","'NR>2 {print $5}'"] "mem" 50
		, Run Com "/sbin/zpool" ["list","|","awk","'/zroot/{print $4}'"] "zpool" 100
		, Run Com "/sbin/sysctl" ["-n","hw.acpi.thermal.tz0.temperature"] "tz" 100
		, Run Kbd [("us(dvp)", "DV"), ("us(alt-intl)", "US")]
		, Run Date "%Y-%m-%d %H:%M" "date" 10
	]
		, sepChar = "%"
		, alignSep = "}{"
		, template = "%StdinReader%}<fc=#333333><action=urxvt -e htop>%multicpu%</action></fc>{<fc=#765400><%net%></fc> <fc=#987600><action=wifimgr>%ssid%</action></fc> <fc=#ba9800>m:%mem% z:%zpool% %tz%</fc> <fc=#cb6500>%kbd%</fc> <fc=#fe3200><action=xclock>%date%</action></fc>"
}
