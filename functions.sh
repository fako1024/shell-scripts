#!/bin/bash

# cmd_exists is a shorthand for 'command', returning if a command exists
function cmd_exists {
  if ! command -v $1 &> /dev/null; then
    return 1
  fi

  return 0
}