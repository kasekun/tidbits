#!/bin/bash

set -e

function list_avds {
  emulator -list-avds
}

function cold_boot_avd {
  echo 'Choose Android AVD to cold-boot:'
  select avd in $(emulator -list-avds); do
    if [ -n "$avd" ]; then
      echo "Cold-booting AVD '$avd'"
      emulator @$avd -no-snapshot-load -no-audio
      break
    else
      echo "Invalid option selected: $REPLY"
    fi
  done
}

function usage {
    cat <<EOF
avd_manager: a simple script to manage Android Virtual Devices (AVDs)

Usage: avd_manager <command>

Available commands:

  -l, --list         - List available AVDs
  -c, --cold-boot    - Cold boot an AVD
  -h, --help         - Show this help and exit

EOF
    exit 0
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
fi

# Check if 'emulator' command is available
if ! command -v emulator &> /dev/null; then
    echo "Error: Android emulator command is not found. Please ensure you have the Android SDK tools installed and the 'emulator' command is in your PATH."
    exit 1
fi

case "$1" in
  -l|--list)
    list_avds
    ;;
  -c|--cold-boot)
    cold_boot_avd
    ;;
  *)
    echo "Invalid option: $1"
    usage
    exit 1
    ;;
esac
