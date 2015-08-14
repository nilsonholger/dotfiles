#! /bin/zsh
_CONFIG="$HOME/.config/minidlna/minidlna.conf"
_PID="$HOME/.config/minidlna/minidlnad.pid"

case $1 in
	stop) killall minidlnad;;
	start|reload|*)
		[ -f "${_PID}" ] && $0 stop
		minidlnad -v -f "${_CONFIG}" -P "${_PID}" -R;;
esac

tail -n 5 minidlna.log
