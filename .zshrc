# .zshrc

# host activation
_HYVE=`[ ${HOST/.*} = hyve ] && echo true || echo false`
_MBP=`[ ${HOST/.*} = mbp ] && echo true || echo false`
_I14=`[ ${HOST/i14*/i14} = i14 ] && echo true || echo false`

# zsh settings
source $HOME/.zsh/zsh-settings
source $HOME/.zsh/zsh-alias
source $HOME/.zsh/zsh-export
source $HOME/.zsh/zsh-prompt

# additional shell functions
source $HOME/.zsh/zsh-functions

# execute upon login
source $HOME/.zsh/zsh-login
