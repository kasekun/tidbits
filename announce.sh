#!/bin/bash

sagen() {
    message=$1
    voice=$2
    rate=$3

    case "$(uname -s)" in
       Darwin)
         say -v "$voice" -r "$rate" "$message"
         ;;
       Linux)
         espeak "$message"
         ;;
       *)
         echo "Unsupported OS"
         return 1
    esac
}

announce() {
    "$@"
    cmd_status=$?
    if [ $cmd_status -eq 0 ]; then
        sagen "done" "bad news" 70
    else
        sagen "failed" "bad news" 70
    fi
    return $cmd_status
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 command [args...]"
    exit 1
fi

announce "$@"
