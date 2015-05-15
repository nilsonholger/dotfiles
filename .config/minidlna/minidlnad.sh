#! /bin/zsh
_CONFIG="$HOME/.config/minidlna/minidlna.conf"
_PID="$HOME/.config/minidlna/minidlnad.pid"

case $1 in
	stop) killall minidlnad;;
	start|reload|*)
		if [ ! -f "${_PID}" ]; then
			minidlnad -f "${_CONFIG}" -P "${_PID}"
		else
			minidlnad -v -f "${_CONFIG}" -R
		fi;;
esac

tail -n 5 minidlna.log
