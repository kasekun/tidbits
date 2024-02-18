#!/bin/bash

set -e

TMUXER_DIR="$HOME/scripts/jtm-launchers"

function list_tmuxers {
  echo 'Available tmuxer scripts:'
  _list
}

function _list() {
  find "$TMUXER_DIR" -name '*.sh' -exec basename {} \;
}


function run_tmuxer {
  echo 'Choose a tmuxer script to run:'
  select tmuxer_script in $(_list); do
    if [ -n "$tmuxer_script" ]; then
      source "$TMUXER_DIR/$tmuxer_script"
      session_exists=$(tmux ls | grep -o "^$session_name:" || true)
      if [ -n "$session_exists" ]; then
        echo "Session '$session_name' already exists."
        select action in "attach" "kill and recreate" "abort"; do
          case $REPLY in
            1) tmux attach-session -t "$session_name"; break ;;
            2) tmux kill-session -t "$session_name" && setup_session; tmux attach-session -t "$session_name"; break ;;
            3) echo "Operation cancelled."; exit 0 ;;
            *) echo "Invalid option. Please choose again." ;;
          esac
        done
      else
        setup_session
        tmux attach-session -t "$session_name"
      fi
      break
    else
      echo "Invalid option selected: $REPLY"
    fi
  done
}

function usage {
    cat <<EOF
jtm: a simple script to manage tmux sessions

Usage: jtm [option]

Available options:

  -l, --list         - List available tmuxer scripts
  -r, --run          - Select and run a tmuxer script (default option)
  -h, --help         - Show this help and exit

EOF
}

if [[ $# -eq 0 ]]; then
    set -- "-r"
fi

case "$1" in
  -l|--list)
    list_tmuxers
    ;;
  -r|--run)
    run_tmuxer
    ;;
  -h|--help)
    usage
    ;;
  *)
    echo "Invalid option: $1"
    usage
    exit 1
    ;;
esac
