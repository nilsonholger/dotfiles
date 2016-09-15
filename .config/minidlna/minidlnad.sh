#! /bin/zsh
_CONFIG="$HOME/.config/minidlna/minidlna.conf"
_PID="$HOME/.config/minidlna/minidlnad.pid"
_DB="$HOME/.config/minidlna/cache/files.db"

function _main() {
case $1 in
	reload) rm -f ${_DB}; _main stop; _main start;;
	stop) killall minidlnad;;
	start|*)
		[ -f "${_PID}" ] && _main stop
		minidlnad -v -f "${_CONFIG}" -P "${_PID}" -R
		;;
esac
}

_main $*

tail -n 5 minidlna.log
