#!/bin/bash

if [ -z "$SHELL_SCRIPTS_BASE_EXPORTED" ]; then
  echo "WARNING: Shell Script base not loaded, some commands will not be available"
fi

# dl provides a generic command line downloader based on available
# tools (wget / curl)
function dl {
  CMD=

  # Attempt to use cURL
  if cmd_exists curl; then
    CMD="curl -sL"
    if [ -n "$2" ]; then
      CMD="$CMD -o $2 $1"
    else
      CMD="$CMD -O $1"
    fi

    $CMD
    return $?
  fi

  # Attempt to use WGET
  if cmd_exists wget; then
    CMD="wget -q $1"
    if [ -n "$2"  ]; then
      CMD="$CMD -O $2"
    fi

    $CMD
    return $?
  fi

  echo "No suitable command for downloading found"
  return 1
}

# pknock provides a port-knock tool based on ncat
function pknock {
  HOST="$1"

  # Check if nmap-ncat is available, otherwise fall back to nc
  # The latter is slower since sub-second timeouts are not supported
  NCAT="ncat -w 50ms"
  if ! cmd_exists "ncat"; then
    echo "Missing ncat command, falling back to nc"
    NCAT="nc -w 1"
  fi

  # Perform port knocking sequence
  echo "Knocking requested port sequence ($HOST - ${*:2})"
  for i in ${*:2}; do
    $NCAT $HOST $i 2>&1 1>/dev/null | grep -v TIMEOUT
  done
}

# pw generates a random password on the console
function pw {

  # Set entropy pool and define defaults
  ENTROPY=/dev/random
  POOL='_A-Za-z-0-9#%$@!'
  LENGTH=20

  # Perform sanity checks
  if [ "$1" != "" ]; then
    LENGTH=$1
  fi
  if [ $LENGTH -lt 4 ]; then
    echo "ERROR: Cannot fulfil required character entropy at $LENGTH characters"
    return 1
  fi
  if ([[ $LENGTH -lt 10 ]] && [[ "$2" != "force" ]]); then
    echo "WARN: Cannot fulfil required password strength at $LENGTH characters, use 'pw $LENGTH force' to override"
    return 1
  fi

  # Attempt to generate random passwords until the requirements are fulfilled
  while true; do
    PW=$(< $ENTROPY tr -dc $POOL | head -c${1:-${LENGTH}}; echo;)
    if ([[ $PW =~ [0-9] ]] && [[ $PW =~ [A-Z] ]] && [[ $PW =~ [a-z] ]] && [[ $PW =~ [_\#%\$@\!] ]]); then
      echo $PW
      return 0
    fi
  done

  return 1
}

# install_shell_scripts installs / updates itself from the current git main branch
function install_shell_scripts {

  # Check if the THISDIR path is defined
  if [ -z "$THISDIR" ]; then
    echo "THISDIR not set"
    return 1
  fi
  TMPDIR=/tmp/.shell_scripts
  mkdir -p $TMPDIR || return 1

  # Download to temporary location
  dl $SHELL_SCRIPTS_DL_URL - | tar xzf - -C $TMPDIR || return 1

  # Put in current location
  cp /tmp/.shell_scripts/shell-scripts-main/.*.sh $THISDIR/ || return 1

  # Clean up
  rm -rf $TMPDIR

  return 0
}

# install_go installs / updates Google Go
function install_go {
  if [ -z "$GOROOT" ]; then
    echo "GOROOT must be set"
    return 1
  fi

  GO_VERSION="$1"
  if [ -z "$GO_VERSION" ]; then

    # Determine latest available (stable) version of go
    URL="https://golang.org/dl/"
    GO_VERSION=$(dl $URL - | sed -rn 's/.*(go[0-9](\.[0-9]+)+)\.src\..*/\1/p' | sort -V -u | tail -1)
  fi

  if [ -z "$GO_VERSION" ]; then
    echo "Cannot determine latest go version and / or no explicit version requested"
    return 1
  fi

  # Download to temporary location
  TMPDIR=/tmp/.install_go
  mkdir -p $TMPDIR || return 1
  dl https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz - | tar xzf - -C $TMPDIR || return 1

  # Check if sudo is required
  ORIGINAL_UID=$UID
  if [ $UID -ne 0 ]; then
    sudo sh -c "rm -rf $GOROOT && mkdir -p $GOROOT && mv $TMPDIR/go/* $GOROOT/ && chown -R $ORIGINAL_UID $GOROOT"
  else
    rm -rf $GOROOT && mkdir -p $GOROOT && mv $TMPDIR/go/* $GOROOT/
  fi

  # Clean up
  rm -rf $TMPDIR

  echo Installed $(go version) in $GOROOT
  return 0
}

function gen_random_string {

  # Set entropy pool and define defaults
  ENTROPY=/dev/urandom
  POOL='A-Za-z0-9'
  LENGTH=20

  # Perform sanity checks
  if [ "$1" != "" ]; then
    LENGTH=$1
  fi

  echo $(< $ENTROPY tr -dc $POOL | head -c${1:-${LENGTH}}; echo;)

  return 0
}

function runGoFunc {
  TMPFILE="/tmp/$(gen_random_string 20).go"

  cat "$@" > $TMPFILE
  GO111MODULE=off go run $TMPFILE

  rm $TMPFILE
}

if command -v task 2>&1 > /dev/null; then
  function today {
    CURCTX=$(task _get rc.context)
    if [[ "$CURCTX" == "" ]]; then
      echo "Cannot determine current context"
      return 1
    fi

    task context none > /dev/null
    task due:today

    task context $CURCTX > /dev/null

    return 0
  }
fi

# Set marker denoting successful inclusion of this script
SHELL_SCRIPTS_FUNCTIONS_EXPORTED=1
