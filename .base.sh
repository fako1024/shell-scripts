#!/bin/bash

# Set global variables
SHELL_SCRIPTS_REPO="https://github.com/fako1024/shell-scripts"
SHELL_SCRIPTS_DL_URL="$SHELL_SCRIPTS_REPO/archive/main.tar.gz"

# Set proper bash history parameters
export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT="%h %d %H:%M:%S "
export PROMPT_COMMAND='history -a'

# Set editor / viewer preferences (yes, I know it's nano)
export VISUAL=nano
export EDITOR="$VISUAL"
export PAGER=less

# Set shell flags / options
shopt -s cdspell        # Auto-corrects cd misspellings
shopt -s cmdhist        # Save multi-line commands in history as single line
shopt -s extglob        # Enable extended pattern-matching features
shopt -s expand_aliases # Expand aliases upon completion
shopt -s checkwinsize   # Check window size after each command

# Set generic formatting parameters
CLR_WHITE='\033[1;37m'
CLR_BLACK='\033[0;30m'
CLR_RED='\033[0;31m'
CLR_GREEN='\033[0;32m'
CLR_YELLOW='\033[0;33m'
CLR_BLUE='\033[0;34m'
CLR_MAGENTA='\033[0;35m'
CLR_CYAN='\033[0;36m'
CLR_CLEAR='\033[0m'

# cmd_exists is a shorthand for 'command', returning if a command exists
function cmd_exists {
  if ! command -v $1 &> /dev/null; then
    return 1
  fi

  return 0
}

# Provide some generic variables
ID_UID=$(id -u)
ID_GID=$(id -g)

SYSTEM_TYPE="UNKNOWN"
cmd_exists apt-get && SYSTEM_TYPE="DEB"
cmd_exists dnf     && SYSTEM_TYPE="RPM"
cmd_exists apk     && SYSTEM_TYPE="APK"

# Set marker denoting successful inclusion of this script
SHELL_SCRIPTS_BASE_EXPORTED=1
