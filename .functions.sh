#!/bin/bash

if [ -z "$SHELL_SCRIPTS_BASE_EXPORTED" ]; then
  echo "WARNING: Shell Script base not loaded, some commands will not be available"
fi

# cmd_exists is a shorthand for 'command', returning if a command exists
function cmd_exists {
  if ! command -v $1 &> /dev/null; then
    return 1
  fi

  return 0
}

# function dl provides a generic command line downloader based on available
# tools (wget / curl)
function dl {
  CMD=
  if cmd_exists wget; then
    CMD="wget -q $1"
    if [ -n "$2"  ]; then
      CMD="$CMD -O $2"
      $CMD
      return $?
    fi
  fi

  echo "No suitable command for downloading found"
  return 1
}

# install_shell_scripts installs / updates itself from the current git main branch
function install_shell_scripts {

  if [ -z "$THISDIR" ]; then
    echo "THISDIR not set"
    return 1
  fi
  TMPDIR=/tmp/.shell_scripts
  mkdir -p $TMPDIR

  # Download to temporary location
  dl $SHELL_SCRIPTS_DL_URL - | tar xzf - -C $TMPDIR || return 1

  # Put in current location
  cp /tmp/.shell_scripts/shell-scripts-main/.*.sh $THISDIR/ || return 1

  # Clean up
  rm -rf $TMPDIR

  return 0
}

# Set marker denoting successful inclusion of this script
SHELL_SCRIPTS_FUNCTIONS_EXPORTED=1
