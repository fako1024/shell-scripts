#!/bin/bash

# Check for dependencies
if [ -z "$SHELL_SCRIPTS_BASE_EXPORTED" ]; then
  echo "WARNING: Shell Script base not loaded, some commands will not be available"
fi
if [ -z "$SHELL_SCRIPTS_FUNCTIONS_EXPORTED" ]; then
  echo "WARNING: Shell Script functions are not loaded, some commands will not be available"
fi

# Generic command aliases
alias grep="grep -a --color=auto --exclude-dir=.git"
alias g="grep --color=auto"
alias n="nano"
alias v="vim"

# Shorthands for 'ls'
alias ls='LC_COLLATE=C ls --color=auto --group-directories-first'
alias l='ls -CFa'
alias ll='ls -alF'
alias lsd='ls -Gal | grep ^d'

# Shorthands for 'cd'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

# Shorthands for 'ps'
alias ps='ps -aux'
alias p='ps'
alias pstree='pstree -g 3 -s'

# Shorthands for 'git' (if available)
if cmd_exists git; then
  alias gb='git branch'
  alias gc='git checkout'
  alias gcb='git checkout -b'
  alias gd='git diff'
  alias gds='git diff --cached'
  alias gf='git fetch --prune'
  alias gfa='git fetch --all --tags --prune'
  alias gs='git status'
  alias gti="git"
fi

# Set marker denoting successful inclusion of this script
SHELL_SCRIPTS_ALIASES_EXPORTED=1
