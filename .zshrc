##########
# .zshrc #
##########

############
# settings #
############

### set fpath, load completion system, set style
[ -d ~/.zsh/osx-zsh-completions ] && fpath=(~/.zsh/osx-zsh-completions/ $fpath)
[ -d /usr/share/zsh/site-functions ] && fpath=(/usr/share/zsh/site-functions $fpath)
[ -d /usr/local/share/zsh/site-functions ] && fpath=(/usr/local/share/zsh/site-functions $fpath)
[ ! -d ~/.zsh/compdump ] && mkdir -p ~/.zsh/compdump
autoload -Uz compinit && compinit -d ~/.zsh/compdump/$HOST
zstyle :compinstall filename '~/.zshrc'
zstyle ":completion:*" auto-description "<%d>"
zstyle ":completion:*" completer _expand _complete _correct _approximate
zstyle ':completion:*' format "%U%F{green}[%d]%u%b%f"
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select
zstyle ':completion:*' special-dirs true
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'
zstyle ':completion:*:messages' format "%B%U%F{red}%d%u%b%f"
zstyle ':completion:*:warnings' format "%F{red}[%d]%f"

### colors
autoload -U colors && colors

### history
HISTFILE=~/.histfile
HISTSIZE=32676
SAVEHIST=32676
setopt extendedhistory histignorealldups histignorespace histnostore histreduceblanks histsavenodups histverify incappendhistory sharehistory
bindkey -v
bindkey '^r' history-incremental-pattern-search-backward
bindkey '^f' history-incremental-pattern-search-forward

### dirs and expansion
setopt autopushd extendedglob pushdignoredups
setopt brace_ccl correct_all nobgnice notify prompt_subst nobeep

### arrow key behaviour
bindkey -M viins "$terminfo[cuu1]" up-line-or-history
bindkey -M viins "$terminfo[kcuu1]" up-line-or-history
bindkey -M viins "$terminfo[kcud1]" down-line-or-history

### alias
alias dud="du -d1 | sort -n | awk '{print \$2}' | xargs du -hd0"
alias duh='du -hxd1 | sort -h'
alias dvorak='setxkbmap -layout us; sleep 0.1; setxkbmap -model pc104 -layout us,us,de -variant dvp,,nodeadkeys -option lv3:ralt_switch'
alias gen-pass='dd if=/dev/random bs=1024 count=1 2>/dev/null| strings | LC_CTYPE=C tr -d "\n"'
alias scpr='rsync --partial --progress --rsh=ssh'
alias vi='vim'

### exports
export CLICOLOR="yes"
export EDITOR="vim"
export GPG_TTY=$(tty) # announce tty to pinentry
export LESS_TERMCAP_mb=$'\E[01;31m'    # mode blink
export LESS_TERMCAP_md=$'\E[01;31m'    # mode bold
export LESS_TERMCAP_me=$'\E[0m'        # mode end
export LESS_TERMCAP_se=$'\E[0m'        # stand-out end
export LESS_TERMCAP_so=$'\E[01;44;33m' # stand-out
export LESS_TERMCAP_ue=$'\E[0m'        # underline end
export LESS_TERMCAP_us=$'\E[01;32m'    # underline start
export LSCOLORS=cxfxexdxCxegedabagacad # directory: green, sockets: blue, executable: bold green
export LS_COLORS='di=32'
export MAKEFLAGS="-j`sysctl -n hw.ncpu 2> /dev/null || nproc --all || grep -c '^processor' /proc/cpuinfo`"
[[ ! $PATH =~ /usr/local/sbin ]] && export PATH="/usr/local/sbin:$PATH"
export XLIB_SKIP_ARGB_VISUALS=1

### dev stuff
ulimit -c unlimited
umask 077

##########
# prompt #
##########

### battery status
_BATTERY_STATUS=''

### battery status prompt
function _battery_status {
local _CHARGE=$1 _INDICATOR _STATE=$2 _TIME=$3 _COLOR="%F{green}" i
[[ ${_CHARGE} -le 40 ]] && _COLOR="%F{yellow}" # warning
[[ ${_CHARGE} -le 10 ]] && _COLOR="%F{red}"  # critical
[[ "${_STATE}" == (#i)charging* ]] && _COLOR="%F{cyan}" # charging
for ((i=0; i<(_CHARGE+9)/20; i++)); do _INDICATOR+='❚'; done # per 20% charge (starts at ...-9, e.g. 11%, 31%, ...)
[[ $((_CHARGE%20)) -le 10 && $((_CHARGE%20)) -gt 0 ]] && _INDICATOR+='❙' # for ...+1% -- ...+10% (e.g. 1%-10%, 21%-30%, ...)
for ((i=${#_INDICATOR}; i<5; i++)); do _INDICATOR+=' '; done # fill
_BATTERY_STATUS="${_COLOR}${_TIME}【${_INDICATOR}】%f" # update prompt indicator
}

### architectures
function _unix_battery_status {
_BATTERY_STATUS=''
local _SYS='/sys/class/power_supply/BAT0/'
local _STATUS=`cat $_SYS/status` _TIME
[[ ! $_STATUS =~ (Disc|C)harging ]] && return
local _CURRENT=`cat $_SYS/current_now &>/dev/null`
_TIME=$((`cat $_SYS/charge_now`*60.0/${_CURRENT:-1000000000}))
if [ "${_CURRENT}" ]; then _TIME="`printf "%d:%.2d" $((_TIME/60)) $((_TIME%60))`"
else _TIME="`cat $_SYS/capacity`⧗"; fi
_battery_status `cat $_SYS/capacity` $_STATUS "${_TIME}"
}
function _osx_battery_status {
_BATTERY_STATUS=''
local -a _STATUS
_STATUS=(`pmset -g batt | tail -n +2`) # get info from pmset
[[ "${_STATUS[4]}" =~ .*charging.* ]] || return # only continue when (dis-)charging
_battery_status ${_STATUS[3]/\%;} ${_STATUS[4]} ${_STATUS[5]/\(no}
}

### git status
if autoload -Uz vcs_info; then
	#zstyle ':vcs_info:*+*:*' debug true
	zstyle ":vcs_info:*" enable git
	#zstyle ":vcs_info:(git*):*" check-for-staged-changes true # faster, but only shows staged changes
	zstyle ":vcs_info:(git*):*" check-for-changes true # slower, but shows un-/staged changes

	local _info="%c%u%m %F{cyan}%b:%r"
	zstyle ":vcs_info:*" stagedstr "%F{green}±"
	zstyle ":vcs_info:*" unstagedstr "%F{yellow}±"
	zstyle ":vcs_info:git*" formats "$_info"
	zstyle ":vcs_info:git*" actionformats "$_info%F{red}[%a]"
	zstyle ':vcs_info:git*+set-message:*' hooks git-misc

	function +vi-git-misc() {
		local _TMP _MISC
		_TMP=$([ `git rev-parse --is-inside-work-tree` = "true" ] && git status --porcelain --branch)
		[[ $_TMP =~ UU ]] && _MISC+="%F{red}ø"
		[[ -s "${hook_com[base]}/.git/refs/stash" ]] && _MISC+="%F{magenta}%}±"
		[[ $_TMP =~ \\?\\? ]] && _MISC+="%F{red}±"
		[[ $_TMP =~ ahead ]] && _MISC+="%F{green}@${${_TMP/*ahead }/[,\]]*}"
		[[ $_TMP =~ behind ]] && _MISC+="%F{red}@${${_TMP/*behind }/\]*}"
		hook_com[misc]+="$_MISC"
	}

	function precmd() {
		vcs_info
	}
fi

# kerberos ticket/credentials state
_KRB_STATE=''

# kerberos state prompt
function _kerberos_state {
	# TODO call `date +%s` once, do arithmetics in zsh, use zsh to parse klist output?
	# TODO separate krenew/kinit and state output
	# TODO call this (limited to krenew) periodically in background
	# TODO improve time limits and make configurable
	# TODO instead of [KRB...] show remaining minutes until expiration
	_KRB_STATE=''
	local _KLIST=`klist 2>&1` _LIFETIME='0' _RENEWABLE='0' _KRB_RETURN='' _KRB_REALM=''
	_LIFETIME=`echo "${_KLIST}" | awk '
				/krbtgt\/.*@/ {
					date="date +%s --date=\""$3" "$4"\""
					date | getline lifetime
					"date +%s" | getline current
					print lifetime-current
					exit
				}'`
	_RENEWABLE=`echo "${_KLIST}" | awk '
				/renew until/ {
					date="date +%s --date=\""$3" "$4"\""
					date | getline lifetime
					"date +%s" | getline current
					print lifetime-current
					exit
				}'`

	# possible TICKET issues
	if [[ "${_KLIST}" =~ 'No credentials cache found' ]]; then # TICKET: no credentials cache found
		_KRB_STATE="%F{red}%B[~KRB"
	elif [ "${_LIFETIME}" -lt 0 ]; then # TICKET: expired
		{ _KRB_RETURN=$(kinit 2>&1 1>&3); } 3>&1; exec 3>&- # capture only stderr
		[ $? -eq 0 ] && _KRB_STATE='' || _KRB_STATE="%F{red}%B[!KRB"
	elif [ "${_LIFETIME}" -lt 3600 ]; then # TICKET: lifetime < 1h
		_KRB_RETURN=$(krenew 2>&1)
		[ $? -eq 0 ] && _KRB_STATE='' || _KRB_STATE="%F{yellow}%B[KRB"
	fi
	if [ "${_RENEWABLE}" -lt 10800 ]; then # TICKET: renewable lifetime < 3h
		{ _KRB_RETURN=$(kinit 2>&1 1>&3); } 3>&1; exec 3>&- # capture only stderr
		[ $? -eq 0 ] && _KRB_STATE='' || _KRB_STATE="%F{red}%B[~KRB"
		# TODO edge case: kinit failed but ticket still valid
	fi

	# kinit/krenew issues
	if [[ "${_KRB_RETURN}" =~ 'Cannot contact any KDC for realm ' ]]; then
		_KRB_REALM=$(echo ${_KRB_RETURN} | cut -d\' -f2)
		_KRB_STATE+="%F{red}%B~KDC:${_KRB_REALM}"
	fi

	# close _KRB_STATE
	[ "${_KRB_STATE}" ] && _KRB_STATE+="]%b"

	: # always return 0
}

### prompts
PROMPT='${_KRB_STATE}'
[ -n "$SSH_CONNECTION" ] && PROMPT+='%F{red}%m ' # host if not local
PROMPT+='%F{green}%.' # pwd
PROMPT+='%(?..%F{red}%B[%?]%b)' # return code
PROMPT+='%F{yellow}%#%(2L.%B+%b.)' # shell status
PROMPT+='%(1j.%F{yellow}[%j].)' # background jobs
PROMPT+=' %f%b' # reset colors

RPROMPT='${vcs_info_msg_0_} ' # git status
RPROMPT+='$_BATTERY_STATUS%F{cyan}%T%f' # battery status and time
LISTPROMPT=''
SPROMPT="%F{yellow}%R %F{white}%b-> %F{green}%r %F{white}%b? [aeNy]%f "

############
# periodic #
############
PERIOD=60
[ -d /sys/class/power_supply/BAT0 ] && periodic_functions+=(_unix_battery_status) # (=> unix/linux)
hash pmset 2> /dev/null && periodic_functions+=(_osx_battery_status) # (=> apple/OSX)
[ -f /etc/krb5.conf ] && periodic_functions+=(_kerberos_state)

#############
# functions #
#############

### brew orphans
function brew {
case $1 in
	orphans)
		local _LEAVES=$(brew leaves)
		comm -2 -3 <(brew list) <((echo ${_LEAVES}; brew deps --union ${=_LEAVES}) | sort -u);;
	*)
		command brew $*;;
esac
}

### coffee/cafe break
function cafe {
local _COLS=$[(COLUMNS-14)/4]
while true
do
	dd if=/dev/urandom bs=$[_COLS*2048] count=1 2>/dev/null
	sleep 0.25
done | (hexdump -e "\"%08_ax  \" $_COLS/1 \"%02x \" \"  |\" $_COLS/1 \"%_p\" \"|\\n\" " | grep --color=always -E "ca f(f e)?e")
}

### files [DIR] [DEPTH]
function files {
find ${1:-.} -maxdepth ${2:-2} -type d | while read _DIR
do
	echo `find $_DIR -type f | wc -l`\|$_DIR
done | sort -nr | column -t -s"|"
}

### git-generate-commit
function git-generate-commit {
_STAT=`git diff --cached --numstat | awk '{print $3$4$5":+"$1"-"$2; }'`
git ci --allow-empty -m "[`hostname -s`] ${_STAT}"
}

### gpg-tar <COMMAND> <FILE> [ARGS...]
function gpg-tar {
export COPYFILE_DISABLE=true # undocumented tar environment variable to prevent storing extended attributes
_AR=$2
_DIR=${2/.txz.gpg}
_GPGD="gpg --quiet --decrypt"
_GPGE="gpg --encrypt --recipient hyve"
_TAR="tar --create --verbose --xz --exclude='._*' --file -"
_UNTAR="tar --extract --file -"

case $1 in
	encrypt)
		eval "$_TAR --cd $_DIR . | $_GPGE --output $_AR.txz.gpg";;
	decrypt)
		eval "mkdir $_DIR && $_GPGD $_AR | $_UNTAR --cd $_DIR"; rmdir $_DIR &> /dev/null;;
	add)
		shift; shift
		eval "$_GPGD $_AR | $_TAR @- $* | $_GPGE --output $_AR.new"
		du -h $_AR; du -h $_AR.new
		echo -n "Replace archive? [yN] "
		read _COPY
		[ "$_COPY" = "y" ] && mv $_AR.new $_AR
		;;
	extract)
		[ $3 ] && eval "$_GPGD $_AR | $_UNTAR \"$3\"" || gpg-tar decrypt $_AR;;
	list)
		eval $_GPGD $_AR | tar --list --file - | sort;;
	repair)
		mv "$_AR"{,.old}; eval "$_GPGD $_AR.old | $_GPGE --output ${_AR/.old}";;
	*)
		echo "usage: $0 <command> <archive|folder> [file]"
		echo
		echo "<commands>:"
		echo "  encrypt <folder>"
		echo "  [decrypt|list|repair] <archive>"
		echo "  [add|extract] <archive> <file>"
esac
}

# kerberos aware tmux
which krenew &> /dev/null && function tmux {
local _tmux=$(which -a tmux | awk '/^\// { print; exit; }')
if [ -z "$*" ]; then
	if klist -s; then
		krenew -biL -- /usr/bin/zsh -c "cd $HOME; $_tmux new -d && while tmux ls &>/dev/null; do sleep 60; done";
		sleep 1;
		tmux attach
	else
		echo -e "\e[1;31mNO VALID KERBEROS TICKET!"
	fi
else
	$_tmux $*
fi
}

### pdf compress <FILE> <IMAGE_DPI>
function pdfcompress {
DPI=${2:-720}
gs -dCompatibilityLevel=1.4 -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH \
	-dDownsampleColorImages=true \
	-dDownsampleGrayImages=true \
	-dDownsampleMonoImages=true \
	-dColorImageResolution=$DPI \
	-dGrayImageResolution=$DPI \
	-dMonoImageResolution=$DPI \
	-sOutputFile=${1/.pdf/-small.pdf} $1
}

### scp two hop <FILE|USER@ORIGIN:PATH> <USER@JUMP_HOST> <FILE|USER@TARGET:PATH>
function scp2h {
[[ ( -z $1 || -z $2 || -z $3 ) ]] && echo 'usage: scp2h <FILE|USER@ORIGIN:PATH> <USER@JUMP_HOST> <FILE|USER@TARGET:PATH>' && return
scp -r -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand="ssh $2 nc %h %p" $1 $3
}

### scp tar <SRC> [SRC2...] <DST>
function scptar {
local SRC="ssh ${1/:*} \"tar cf - ${${@#*:}% *}\""
local DST="ssh \"${@[$#]/:*}\" \"tar xvf - -C ./${@[$#]/*:}\""
if [ ! -e "$1" ]; then
	if [ ! -e "$@[$#]" ]; then
		eval "$SRC | $DST"
	else
		eval "$SRC | tar xvf - -C ./$@[$#]"
	fi
else
	eval "tar cf - ${@:1:#-1} | $DST"
fi
}

### ssh-kill-masters
function ssh-kill-masters {
	for master in $HOME/.ssh/master/*(N); do
		if ssh -O check -p ${master//*:} ${${master##*/}%:*} >& /dev/null; then
			echo "EXIT  -> ${master##*/}"
			ssh -O exit -p ${master//*:} ${${master##*/}%:*} >& /dev/null
		else
			echo "PURGE -> ${master##*/}"
			rm -f ${master}
		fi
	done
}

### hyve <on|off>
function hyve {
	case $1 in
		on) mkdir -m 777 ~/hyve; sshfs hyve: ~/hyve;;
		off) fusermount -u ~/hyve &> /dev/null || umount ~/hyve; rmdir ~/hyve;;
		"") [ -d ~/hyve ] && hyve off || hyve on;;
	esac
}

### unisel <target> [path]
function unisel {
	_TARGET=${1:-${HOST/.*}}
	_BASE=$(cat ~/.unison/${_TARGET}.prf | awk 'NR==1 {print $3}')
	_DIR=${PWD}/$2
	unison ${_TARGET} -ignore "Path {,.}*" -ignorenot "Path ${_DIR/${_BASE}\//}"
}

### doi2bib <doi>
function doi2bib {
	curl -s -L -H "Accept: text/bibliography; style=bibtex" http://dx.doi.org/"$*" | sed -e "s/\(\@\S*,\)/\1\n/" -e "s/\}, /\},\n /g"
}

### lookup <host|ip>
function lookup {
	curl -s https://ipgeolocation.io/ip-location/${1} | grep 'code style' | html2text
}

########################
# completion functions #
########################

### fzf based git branch local search
function fzf-git-local-branch() {
	local _BRANCH
	_BRANCH=$(git --no-pager branch --list -vv | fzf | awk '!/\*/ {printf "%s ", $1}')
	LBUFFER+="${_BRANCH}"
	bindkey '^I' fzf-completion
}
zle -N fzf-git-local-branch

### fzf based git branch remote search
function fzf-git-remote-branch() {
	local _BRANCH
	_BRANCH=$(git --no-pager branch --list --remote -vv | fzf | awk '!/\*/ {sub("^[^/]*/", "", $1); printf "%s ", $1}')
	LBUFFER+="${_BRANCH}"
	bindkey '^I' fzf-completion
}
zle -N fzf-git-remote-branch

# auto-complete for 'git co{l,r} '
function _git-col() { bindkey '^I' fzf-git-local-branch }
function _git-cor() { bindkey '^I' fzf-git-remote-branch }

#########
# local #
#########

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# .local dir
if [ -d $HOME/.local ]; then
	[[ ! $PATH =~ $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"
fi

# .cabal dir
if [ -d $HOME/.cabal ]; then
	[[ ! $PATH =~ $HOME/.cabal/bin ]] && export PATH="$HOME/.cabal/bin:$PATH"
fi

# local dir
if [ -d $HOME/local ]; then
	_LOCAL="$HOME/local"
	_PATH="$PATH"

	[[ ! $PATH =~ $_LOCAL/bin ]] && _PATH="$_LOCAL/bin:$PATH"
	_LIB="$_LOCAL/lib64:$_LOCAL/lib32:$_LOCAL/lib"

	[ -d $_LOCAL/android ] && [[ ! $PATH =~ $_LOCAL/android/tools ]] && _PATH="$_PATH:$_LOCAL/android/tools:$_LOCAL/android/platform-tools:$_LOCAL/android/ndk"
	[ -d $_LOCAL/libexec/git-core/ ] && export GIT_EXEC_PATH="$_LOCAL/libexec/git-core"

	export PATH=$_PATH
	export LIBRARY_PATH="$_LIB"
	[ $VENDOR = "apple" ] && export DYLD_LIBRARY_PATH="$_LIB"
	export LD_LIBRARY_PATH="$_LIB"
	export LD_RUN_PATH="$_LIB"
	export C_INCLUDE_PATH="$_LOCAL/include"
	export CPLUS_INCLUDE_PATH="$_LOCAL/include"
	export PKG_CONFIG_PATH="$_LOCAL/lib/pkgconfig"

	unset _LOCAL _PATH _LIB
fi

# freebsd
if [ -d /boot/kernel ]; then
	hash xhost &> /dev/null && xhost +local: > /dev/null # fix for ssh with X forwarding
	[[ $HOST =~ hyve ]] && [ -z $TMUX ] && tmux a && exit # auto attach
fi

# ubuntu
if [ -z "${OSTYPE/linux*}" ]; then
	ls --color &> /dev/null && alias ls='ls --color'
	function xsudo() { # or use gksudo
		xhost +si:localuser:root
		sudo $*
		xhost -si:localuser:root
	}
	alias gnome-control-center="env XDG_CURRENT_DESKTOP=ubuntu:GNOME gnome-control-center"
fi
