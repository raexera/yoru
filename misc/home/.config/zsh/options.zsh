##
## ZSH Options
##

umask 022
zmodload zsh/zle
zmodload zsh/zpty
zmodload zsh/complist

autoload _vi_search_fix

autoload -Uz compinit
compinit

autoload -Uz colors
colors

zle -N _vi_search_fix
zle -N _sudo_command_line

# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# History
HISTFILE="$XDG_CACHE_HOME/zsh/.zhistory"
HISTSIZE=10000
SAVEHIST=10000

# Completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ":completion:*" sort false
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
zstyle ":completion:*" special-dirs true
zstyle ":completion:*" ignored-patterns
zstyle ":completion:*" completer _complete

# Autocomplete
zstyle ':autocomplete:*' default-context ''
zstyle ':autocomplete:*' min-delay 0.05
zstyle ':autocomplete:*' min-input 1
zstyle ':autocomplete:*' ignored-input ''
zstyle ':autocomplete:*' list-lines 16
zstyle ':autocomplete:history-search:*' list-lines 16
zstyle ':autocomplete:history-incremental-search-*:*' list-lines 16
zstyle ':autocomplete:*' recent-dirs cdr
zstyle ':autocomplete:*' insert-unambiguous no
zstyle ':autocomplete:*' widget-style complete-word
zstyle ':autocomplete:*' fzf-completion no
zstyle ':autocomplete:*' add-space executables aliases functions builtins reserved-words commands

# Autosuggestion
export ZSH_AUTOSUGGEST_USE_ASYNC="true"
export ZSH_AUTOSUGGEST_STRATEGY=("match_prev_cmd" "completion")
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#484e5b,underline"

while read -r opt
do 
  setopt $opt
done <<-EOF
AUTOCD
AUTO_MENU
AUTO_PARAM_SLASH
COMPLETE_IN_WORD
NO_MENU_COMPLETE
HASH_LIST_ALL
ALWAYS_TO_END
NOTIFY
NOHUP
MAILWARN
INTERACTIVE_COMMENTS
NOBEEP
APPEND_HISTORY
SHARE_HISTORY
INC_APPEND_HISTORY
EXTENDED_HISTORY
HIST_IGNORE_ALL_DUPS
HIST_IGNORE_SPACE
HIST_NO_FUNCTIONS
HIST_EXPIRE_DUPS_FIRST
HIST_SAVE_NO_DUPS
HIST_REDUCE_BLANKS
EOF

while read -r opt
do 
  unsetopt $opt
done <<-EOF
FLOWCONTROL
NOMATCH
CORRECT
EQUALS
EOF

# vim:ft=zsh:nowrap
