Config {
	font = "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*"
	, lowerOnStart = True
	, commands = [
		Run StdinReader
		, Run MultiCpu ["-L","60","-H","90","-n","yellow","-h","red","-t","<autobar>"] 10
		, Run DynNetwork ["-t","<rx>|<tx>","-S","True"] 10
		, Run Wireless "wlan0" ["-t","<essid>"] 100
		, Run Memory ["-t","<free>"] 100
		, Run DiskU [("/", "<free>")] [] 100
		, Run BatteryP ["BAT1"] ["-t","<timeleft>@<left>"] 100
		, Run Kbd [("us(dvp)", "DV"), ("us(alt-intl)", "US")]
		, Run Date "%Y-%m-%d %H:%M" "date" 100
	]
		, sepChar = "$"
		, alignSep = "}{"
		, template = "$StdinReader$}<fc=#333333><action=urxvt -e htop>$multicpu$</action></fc>{<fc=#765400><action=urxvt -e echo>$dynnetwork$</action></fc> <fc=#987600><action=nm-connection-editor>$wlan0wi$</action></fc> <fc=#ba9800><action=urxvt -e htop>$memory$M</action>|<action=urxvt -e echo>$disku$</action> $battery$%</fc> <fc=#cb6500>$kbd$</fc> <fc=#fe3200><action=xclock>$date$</action></fc>"
}
