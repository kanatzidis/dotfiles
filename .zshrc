################################################################### zsh
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
unsetopt BG_NICE            # don't deprioritize background jobs
setopt CORRECT              # offer corrections for mistyped commands
setopt EXTENDED_HISTORY     # store timestamps in history
setopt INC_APPEND_HISTORY   # write to history file immediately, not on exit
bindkey -v                  # vi keybindings

################################################################### prompt
function precmd() {
    PROMPT=$'%{\e[0;32m%}%n@%m [%d]'
    RPS1=$'%{\e[0;33m%}%B(%D{%m-%d %H:%M})%b%{\e[0m%}'

    local _branch
    _branch=$(git branch --show-current 2>/dev/null)
    if [ -n "$_branch" ]; then
        RPS1=$'%{\e[0;36m%}'($_branch)$'%{\e[0m%}'$RPS1
    fi

    PROMPT=$PROMPT"%(!.#.$) "

    # set terminal title to current directory
    print -Pn "\e]0;%~\a"
}

################################################################### env
export EDITOR=vim

if [ -f ~/.zsh_local ]; then
  source ~/.zsh_local
fi

# return if not interactive
[ -z "$PS1" ] && return

################################################################### platform
if [[ $(uname) == Darwin ]]; then
    alias ls='ls -G'
    export LSCOLORS=dxfxcxdxbxegedabagacad
    bindkey "\e[3~" delete-char
else
    if [ -e ~/.dir_colors ]; then
        eval $(dircolors ~/.dir_colors)
    fi
    alias ls='ls --color'
fi

################################################################### commands

########## Aliases

alias rm='rm -f'
alias aws='nocorrect aws'
alias screen='screen -S screen'

alias lal='ls -al'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -a'
alias df='df -h'
alias du='du -h'
alias dus='du -h -s'
alias grep='grep --color'

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

bindkey '^[v' edit-command-line

########## Convenience functions

# usage: fuck you <process>
function fuck() {
  echo
  killall -9 "$2"
  if [ -f ~/.flip ]; then
    echo " (╯°□°）╯︵$(echo "$2"|~/.flip)"
  else
    echo " Killed: $2"
  fi
  echo
}

################################################################### utilities

# edit current command line in $EDITOR (Alt+v)
autoload -Uz edit-command-line
zle -N edit-command-line

################################################################### completion

autoload -U compinit
compinit

# keybindings for completion and navigation
bindkey "^?" backward-delete-char    # backspace past insert point in vi mode
bindkey '^[OH' beginning-of-line     # Home key
bindkey '^[OF' end-of-line           # End key
bindkey '^[[5~' up-line-or-history   # Page Up
bindkey '^[[6~' down-line-or-history # Page Down
bindkey "^r" history-incremental-search-backward
bindkey ' ' magic-space              # expand history references on space
bindkey '^I' complete-word           # tab completes, leave expansion to _expand

# cache completions for faster results
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

# color completion matches like ls
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' menu select=1 _complete _ignored _approximate
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# completion strategies in order: expand, complete, ignored, approximate, aliases
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate _expand_alias

# allow one typo per six characters typed
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/6 )) numeric )'

# show all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# colorize PIDs for kill completion
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# cross-platform process listing for kill/process completion
if [[ $(uname) == Darwin ]]; then
    zstyle ':completion:*:*:kill:*:processes' command 'ps -A -o pid,user,command'
    zstyle ':completion:*:processes-names' command 'ps -A -o command'
else
    zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -A -o pid,user,cmd'
    zstyle ':completion:*:processes-names' command 'ps axho command'
fi

# hide compiled/backup files from completion (except for rm)
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
    '*?.old' '*?.pro'

# hide internal completion functions
zstyle ':completion:*:functions' ignored-patterns '_*'

# hide system/daemon users from completion (UID < 1000)
zstyle ':completion:*:*:*:users' ignored-patterns \
    $(awk -F: '$3 < 1000 && $1 != "root" { print $1 }' /etc/passwd 2>/dev/null)

# ssh/scp completion ordering
zstyle ':completion:*:scp:*' tag-order files users hosts
zstyle ':completion:*:scp:*' group-order files all-files users hosts
zstyle ':completion:*:ssh:*' tag-order users hosts
zstyle ':completion:*:ssh:*' group-order hosts
zstyle '*' single-ignored show
