################################################################### zsh
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt BG_NICE            # do NOT nice bg commands
setopt CORRECT              # command CORRECTION
setopt EXTENDED_HISTORY     # puts timestamps in the history
setopt APPEND_HISTORY
setopt ALL_EXPORT
bindkey -v
zstyle :compinstall filename '~/.zshrc'
autoload -Uz compinit
compinit

################################################################### prompt
# This zsh function is called whenever changing directories and
# shows the current git branch in the prompt
findup() {
    arg="$1"
    if test -z "$arg"; then return 1; fi   
    while ! test -e "$arg"; do
        cd ..
        if test "$PWD" = "/"; then
            exit 1
        fi
    done
    echo $PWD/$arg
}

function precmd() {
    PROMPT=$'%{\e[0;32m%}%n@%m [%d]'
    RPS1=$'%{\e[0;33m%}%B(%D{%m-%d %H:%M})%b%{\e[0m%}'
    
    local _git _branch

    _git=`findup .git 2>/dev/null`
    if test -n "$_git"; then
        _branch=`sed -e 's,.*/,,' $_git/HEAD 2>/dev/null`
        RPS1=$'%{\e[0;36m%}'($_branch)$'%{\e[0m%}'$RPS1
    fi

    export PROMPT=$PROMPT"%(!.#.$) "
    export RPS1=$RPS1

	print -Pn "\e]0;%~\a"
}

################################################################### env
EDITOR=vim
PATH=~/bin:~/devtools/arcanist/bin:/opt/local/bin:/Applications/Postgres.app/Contents/MacOS/bin:/usr/local/texlive/2012/bin/universal-darwin:$PATH
if [ -z "$HOSTNAME" ]; then
    HOSTNAME=`hostname`
fi

# return if not interactive
[ -z "$PS1" ] && return

################################################################### osx
if [ `uname` = "Darwin" ]; then
    alias ls='ls -G'
    export LSCOLORS=dxfxcxdxbxegedabagacad
    bindkey "\e[3~" delete-char
elif [ "$TERM" != "dumb" ]; then
    if [ -e "~/.dir_colors" ]; then
        eval `dircolors ~/.dir_colors`
    fi
    alias ls='ls --color'
fi

################################################################### commands
alias chrun='ps aux | grep'
alias mysql='/usr/local/mysql/bin/mysql'
alias mysqld='/usr/local/mysql/bin/mysqld &'
alias ack='nocorrect ack'
alias lal='ls -al'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -a'
alias df='df -h'
alias du='du -h'
alias dus='du -h -s'
alias rm="rm -i"
alias grep='grep --color'
alias cd="pushd >/dev/null"
alias bd="popd >/dev/null"
if [ -f ~/.aliases ]; then
    source ~/.aliases
fi
bindkey '^[v' edit_command_line
bindkey '^[!' edit_command_output

function fuck() {
  if killall -9 "$2"; then
    echo ; echo " (╯°□°）╯︵$(echo "$2"|~/.flip)"; echo
  fi
}

################################################################### utilities
function freq() {
    sort $* | uniq -c | sort -rn;
}

# from zsh-users
edit_command_line () {
	# edit current line in $EDITOR
	local tmpfile=${TMPPREFIX:-/tmp/zsh}ecl$$
 
	print -R - "$PREBUFFER$BUFFER" >$tmpfile
	exec </dev/tty
	jed $tmpfile
	zle kill-buffer
	BUFFER=${"$(<$tmpfile)"/$PREBUFFER/}
	CURSOR=$#BUFFER
 
	command rm -f $tmpfile
	zle redisplay
}
zle -N edit_command_line
 
# ever used this :?
edit_command_output () {
	local output
	output=$(eval $BUFFER) || return
	BUFFER=$output
	CURSOR=0
}
zle -N edit_command_output

################################################################### completion

autoload -U compinit
compinit
bindkey "^?" backward-delete-char
bindkey '^[OH' beginning-of-line
bindkey '^[OF' end-of-line
bindkey '^[[5~' up-line-or-history
bindkey '^[[6~' down-line-or-history
bindkey "^r" history-incremental-search-backward
bindkey ' ' magic-space    # also do history expansion on space
bindkey '^I' complete-word # complete on tab, leave expansion to _expand
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/6 )) numeric )'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# Completion Styles

# list of completers to use
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/6 )) numeric )'

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

## add colors to processes for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
zstyle ':completion:*:processes-names' command 'ps axho command'

# complete hosts from known hosts of ssh, users from list
knownhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} )
zstyle ':completion:*' hosts $knownhosts
zstyle ':completion:*' users hedgehog timsu tsu palantir

zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'

# ignore completion functions (until the _ignored completer)
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm apache bin daemon games gdm halt ident junkbust lp mail mailnull \
        named news nfsnobody nobody nscd ntp operator pcap postgres radvd \
        rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs avahi-autoipd\
        avahi backup messagebus beagleindex debian-tor dhcp dnsmasq fetchmail\
        firebird gnats haldaemon hplip irc klog list man cupsys postfix\
        proxy syslog www-data mldonkey sys snort

# SSH Completion
zstyle ':completion:*:yafc:*' tag-order \
   users hosts
zstyle ':completion:*:scp:*' tag-order \
   files users hosts
zstyle ':completion:*:scp:*' group-order \
   files all-files users hosts
zstyle ':completion:*:ssh:*' tag-order \
   users hosts
zstyle ':completion:*:ssh:*' group-order \
   hosts
zstyle '*' single-ignored show

#vim tags
function _get_tags {
  [ -f ./tags ] || return
  local cur
  read -l cur
  echo $(echo $(awk -v ORS=" "  "/^${cur}/ { print \$1 }" tags))
}
compctl -x 'C[-1,-t]' -K _get_tags -- vim
#end vim tags

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh # This loads NVM
