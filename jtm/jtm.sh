#!/bin/bash

set -e

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
TMUXER_DIR="$SCRIPT_DIR/launchers"
CONFIG_FILE="$HOME/.jtmrc"

if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
fi

#  overriding the launchers directory via config
TMUXER_DIR="${JTM_LAUNCHERS_DIR:-$TMUXER_DIR}"

function list_tmuxers {
  echo 'Available tmuxer scripts:'
  _list
}

function _list() {
  find "$TMUXER_DIR" -type f -name '*.sh' -exec basename {} \; | sort
}

function _list_with_descriptions() {
  for script in $(find "$TMUXER_DIR" -name '*.sh' | sort); do
    name=$(basename "$script")
    # extract description if it exists
    description=$(grep -m 1 "^# description:" "$script" | cut -d ':' -f 2- | xargs)
    if [ -n "$description" ]; then
      printf "%-20s - %s\n" "$name" "$description"
    else
      printf "%s\n" "$name"
    fi
  done
}

function run_tmuxer {
  # if a specific launcher was provided, use it directly
  if [ -n "$1" ]; then
    if [ -f "$TMUXER_DIR/$1.sh" ]; then
      source "$TMUXER_DIR/$1.sh"
      _handle_session
    else
      echo "Launcher '$1.sh' not found."
      exit 1
    fi
    return
  fi

  # otherwise show the selection menu
  echo 'Choose a tmuxer script to run:'
  select tmuxer_script in $(_list); do
    if [ -n "$tmuxer_script" ]; then
      source "$TMUXER_DIR/$tmuxer_script"
      _handle_session
      break
    else
      echo "Invalid option selected: $REPLY"
    fi
  done
}

function _handle_session() {
  session_exists=$(tmux ls 2>/dev/null | grep -o "^$session_name:" || true)
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
}

function create_new_launcher() {
  read -p "Enter launcher name (without .sh): " launcher_name
  if [ -z "$launcher_name" ]; then
    echo "Launcher name cannot be empty."
    exit 1
  fi
  
  read -p "Enter session name: " session_name
  read -p "Enter working directory (default: $HOME): " dir
  dir="${dir:-$HOME}"
  
  read -p "Enter description (optional): " description
  
  cat > "$TMUXER_DIR/$launcher_name.sh" << EOF
#!/bin/bash

# description: $description
session_name="$session_name"
dir="$dir"

function setup_session() {
    tmux new-session -d -s "\$session_name" -n 'dev'
    sleep 0.1
    tmux send-keys -t "\$session_name:dev.0" "cd \${dir}" C-m
    tmux split-window -v -t "\$session_name:dev"
    sleep 0.1
    tmux send-keys -t "\$session_name:dev.1" "cd \${dir}" C-m
    
    # Uncomment to add a command to the top pane
    # tmux send-keys -t "\$session_name:dev.0" "your command here" C-m
}
EOF

  chmod +x "$TMUXER_DIR/$launcher_name.sh"
  echo "Created launcher: $TMUXER_DIR/$launcher_name.sh"
}

function usage {
    cat <<EOF
jtm: a simple script to manage tmux sessions

Usage: jtm [option] [launcher-name]

Available options:

  -l, --list         - List available tmuxer scripts
  -r, --run          - Select and run a tmuxer script (default option)
  -n, --new          - Create a new launcher script
  -h, --help         - Show this help and exit

Examples:
  jtm                - Run the default selection menu
  jtm project-name   - Run the specified launcher directly
  jtm --new          - Create a new launcher script

EOF
}

# handle direct launcher execution
if [[ $# -eq 1 && "$1" != -* ]]; then
  run_tmuxer "$1"
  exit 0
fi

if [[ $# -eq 0 ]]; then
  set -- "-r"
fi

case "$1" in
  -l|--list)
    _list_with_descriptions
    ;;
  -r|--run)
    shift
    run_tmuxer "$@"
    ;;
  -n|--new)
    create_new_launcher
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
