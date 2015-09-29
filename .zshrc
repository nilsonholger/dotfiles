##########
# .zshrc #
##########

############
# settings #
############

### set fpath, load completion system, set style
[ -d ~/.zsh/osx-zsh-completions ] && fpath=(~/.zsh/osx-zsh-completions/ $fpath)
[ -d /usr/local/share/zsh/site-functions ] && fpath=(/usr/local/share/zsh/site-functions $fpath)
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
alias dud='du -hxd1 | sort -h'
alias dvorak='setxkbmap -model pc104 -layout us,us,de -variant dvp,,nodeadkeys -option lv3:ralt_switch'
[ -f ~/papers/index.wiki ] && alias papers='wiki ~/papers'
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
export MAKEFLAGS="-j`sysctl -n hw.ncpu 2> /dev/null || grep -c '^processor' /proc/cpuinfo`"
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
local _CHARGE=$1 _INDICATOR _STATE=$2 _TIME=$3
[[ ${_CHARGE} -gt  0 ]] && _COLOR="%F{red}"    # critical
[[ ${_CHARGE} -gt 20 ]] && _COLOR="%F{yellow}" # warning
[[ ${_CHARGE} -gt 40 ]] && _COLOR="%F{green}"  # ok
[ "${_STATE}" = "charging;" ] && _COLOR="%F{cyan}" # charging
for ((i=0; i<_CHARGE/20; i++)); do _INDICATOR+='❚'; done # for every 20%
[[ $((_CHARGE%20)) -ge 10 ]] && _INDICATOR+='❙' # for 10%-20% (after mod 20)
for ((i=${#_INDICATOR}; i<5; i++)); do _INDICATOR+=' '; done # fill
_BATTERY_STATUS="${_COLOR}${_TIME}⦗${_INDICATOR}⦘%f " # create prompt indicator
}

### architectures
function _unix_battery_status {
_BATTERY_STATUS=''
local _SYS='/sys/class/power_supply/BAT1/'
local _STATUS=`cat $_SYS/status` _TIME
[[ ! $_STATUS =~ (Disc|C)harging ]] && return
_TIME=$((`cat $_SYS/energy_now`*60/`cat $_SYS/power_now`))
_battery_status `cat $_SYS/capacity` $_STATUS $_TIME "`printf "%d:%.2d" $((_TIME/60)) $((_TIME%60))`"
}
function _osx_battery_status {
_BATTERY_STATUS=''
local -a _STATUS
_STATUS=(`pmset -g batt | tail -n +2`) # get info from pmset
[[ "${_STATUS[3]}" =~ .*charging.* ]] || return # only continue when (dis-)charging
_battery_status ${_STATUS[2]/\%;} ${_STATUS[3]} ${_STATUS[4]/\(no}
}

### update periodically
PERIOD=60
[ -d /sys/class/power_supply/BAT1 ] && periodic_functions+=(_unix_battery_status) # (=> unix/linux)
hash pmset 2> /dev/null && periodic_functions+=(_osx_battery_status) # (=> apple/OSX)

### git status
if autoload -Uz vcs_info; then
	#zstyle ':vcs_info:*+*:*' debug true
	zstyle ":vcs_info:*" enable git
	zstyle ":vcs_info:(git*):*" check-for-changes true

	local _info="%c%u%m %F{cyan}%b:%r"
	zstyle ":vcs_info:*" stagedstr "%F{green}±"
	zstyle ":vcs_info:*" unstagedstr "%F{yellow}±"
	zstyle ":vcs_info:git*" formats "$_info"
	zstyle ":vcs_info:git*" actionformats "$_info%F{red}[%a]"
	zstyle ':vcs_info:git*+set-message:*' hooks git-misc

	function +vi-git-misc() {
		local _TMP _MISC
		_TMP=$(git status -s -b)
		[[ $_TMP =~ \\?\\? ]] && _MISC+="%F{red}±"
		[[ $_TMP =~ ahead ]] && _MISC+="%F{green}@${${_TMP/*ahead }/[,\]]*}"
		[[ $_TMP =~ behind ]] && _MISC+="%F{red}@${${_TMP/*behind }/\]*}"
		[[ -s "${hook_com[base]}/.git/refs/stash" ]] && hook_com[misc]+="%F{magenta}%}±"
		hook_com[misc]+="$_MISC"
	}

	function precmd() {
		vcs_info
	}
fi

### prompts
PROMPT=''
[ -n "$SSH_TTY" ] && PROMPT+='%F{red}%m ' # host if not local
PROMPT+='%F{green}%.' # pwd
PROMPT+='%(?..%F{red}%B[%?]%b)' # return code
PROMPT+='%F{yellow}%#%(2L.%B+%b.)' # shell status
PROMPT+='%(1j.%F{yellow}[%j].)' # background jobs
PROMPT+=' %f' # reset colors

RPROMPT='${vcs_info_msg_0_} ' # git status
RPROMPT+='$_BATTERY_STATUS%F{cyan}%T%f' # battery status and time
LISTPROMPT=''
SPROMPT="%F{yellow}%R %F{white}%b-> %F{green}%r %F{white}%b? [aeNy]%f "

#############
# functions #
#############

### coffee/cafe break
function cafe {
while true
do
	dd if=/dev/urandom bs=1024 count=128 2>/dev/null
	sleep 0.3
done | (hexdump -e '"%08_ax  " 8/1 "%02x " "  " 8/1 "%02x " "  " 8/1 "%02x " "  " 8/1 "%02x " "  " 8/1 "%02x " "  " 8/1 "%02x " "  |" 48/1 "%_p" "|\n"' | grep --color=always -E "ca f(f e)?e")
}

### files [DIR] [DEPTH]
function files {
find ${1:-.} -maxdepth ${2:-2} -type d | while read _DIR
do
	echo `find $_DIR -type f | wc -l`\|$_DIR
done | sort -n | column -t -s"|"
}

### git-generate-commit
function git-generate-commit {
_STAT=`git diff --cached --numstat | awk '{print $3$4$5":+"$1"-"$2; }'`
git ci -m "[`hostname -s`] ${_STAT//\.wiki}"
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

### wiki stuff
function wiki {
[ -z $1 ] && echo 'usage: wiki $DIRECTORY' && return
[ -d $1 ] && cd $1 || return
git stash &> /dev/null
git pull
git stash pop &> /dev/null
vim index.wiki
git add --all .
git-generate-commit
git push
cd -
}

### pdf compress <FILE> <IMAGE_DPI>
function pdfcompress {
DPI=${2:-720}
ghostscript -dCompatibilityLevel=1.4 -sDEVICE=pdfwrite -dNOPAUSE -dQUIET -dBATCH \
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
scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ProxyCommand="ssh $2 nc %h %p" $1 $3
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

### hyve <on|off>
function hyve
{
	case $1 in
		on) mkdir -m 777 ~/hyve; sshfs hyve: ~/hyve;;
		off) fusermount -u ~/hyve &> /dev/null || umount ~/hyve; rmdir ~/hyve;;
		"") [ -d ~/hyve ] && hyve off || hyve on;;
	esac
}

### unisel <target> [path]
function unisel
{
	_TARGET=${1:-${HOST/.*}}
	_BASE=$(cat ~/.unison/${_TARGET}.prf | awk 'NR==1 {print $3}')
	_DIR=${PWD}/$2
	unison ${_TARGET} -ignore "Path {,.}*" -ignorenot "Path ${_DIR/${_BASE}\//}"
}

### doi2bib <doi>
function doi2bib() {
	curl -s -L -H "Accept: text/bibliography; style=bibtex" http://dx.doi.org/"$*" | sed -e "s/\(\@\S*,\)/\1\n/" -e "s/\}, /\},\n /g"
}

#########
# local #
#########

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
	[[ $HOST =~ $USER ]] && [ -z $TMUX ] && tmux a && exit # auto attach
fi

# i14
if [ -z "${HOST/i14*}" ]; then
	ls --color &> /dev/null && alias ls='ls --color'
	hash krenew 2> /dev/null && function tmux {
		local _tmux=$(which -a tmux | awk '/^\//')
		if [ -z "$*" ]; then
			krenew -biL -- /usr/bin/zsh -c "cd $HOME; $_tmux new -d && while tmux ls &>/dev/null; do sleep 60; done";
			sleep 1;
			tmux attach
		else
			$_tmux $*
		fi
	}
	function i14run {
		local _ARGS _PROCS
		[ "$1" = "-d" ] && { shift; _PROCS="1"; } || { _PROCS="0"; }
		[[ $* =~ '\$\(' ]] && _ARGS="$*" || _ARGS="\$($*)"
		echo -n pc1{84..90} s1 s{20..26} s{29..31} s34 | xargs -P $_PROCS -n1 -d ' ' -I SERVER ssh -o ConnectTimeout=3 -o PasswordAuthentication=no SERVER "echo SERVER $_ARGS"
	}
	function i14load {
		local _COL _SORT
		[ "$1" = "-d" ] && { _COL="cat -"; _SORT="cat -"; } || { _COL="column -t"; _SORT="sort -f"; }
		{
			echo "SERVER CPU LOAD L_5 L_15 PROCS MEM SWAP USERS"
			{
				_CPU='$(sysctl -n hw.ncpu 2> /dev/null || grep -c "^processor" /proc/cpuinfo)'
				_LOAD='$(cut -f1-4 -d" " /proc/loadavg)'
				_FREE='$(free -m | awk "/(buffers\/cache|Swap)/ {printf \"%.1f/%.1f\n\", \$3/1024, \$4/1024}" | tr "\n" " ")'
				_USERS='$(top -bn1 | awk "NR>7{u[\$2]+=\$9}END {for(i in u) {if (u[i]>2) printf \" %s:%d\",i,u[i]}}")'
				i14run $1 "$_CPU $_LOAD $_FREE $_USERS"
			} | eval $_SORT
		} | eval $_COL
	}
fi
