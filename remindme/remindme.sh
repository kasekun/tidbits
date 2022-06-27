#!/bin/bash

# 1. place this file somewhere, e.g., ~/scripts/remindme.sh
# 2. create a symbolic link to this file in /usr/local/bin
# sudo ln -s ~/scripts/remindme.sh /usr/local/bin/remindme
# 3. make the symlink executable
# chmod +x /usr/local/bin/remindme
# 4. launch your first reminder from anywhere in terminal
# remindme "hydration check" 7 3
# (a hydration check every 7 minutes for 3 hours)

# Bonus: if you want these commands to run in
# the background (and free up your terminal)
# add this function to your ~/.bashrc or ~/.zshrc

# remindme() {
#     if ! [[ ($# -eq 3) ]]; then
#         # run in foreground if not a valid reminder (e.g., remindme -k)
#         /usr/local/bin/remindme "$@"
#     else
#         # run in background
#         nohup /usr/local/bin/remindme "$@" 2>/dev/null &
#     fi
# }

sagen() {
    if [ -x "$(command -v say)" ]; then
        # macOS
        echo $@ | say
    else
        # other
        echo $@ | espeak -s 120 2>/dev/null
    fi
}

remindme() {
    ((frequency = $2 * 60))
    ((duration = $3 * 3600))
    if [[ $frequency -ge $duration ]]; then
        echo "Duration needs to be greater than frequency!"
        echo "you gave a frequency of $2 min ($frequency sec), and a duration of $3 hours ($duration sec)"
        exit 0
    fi
    ((occurrences = $duration / $frequency))
    sagen "$1"
    for ((i = 1; i <= $occurrences; i++)); do
        sleep $frequency
        sagen "$1"
    done
    sagen "finished $1"
}

usage() {
    cat <<EOF
Periodically remind you to do something via text-to-speech

Usage: remindme <command> {"your reminder"} {frequency} {duration}
  "your reminder"       the verbal reminder you want
  frequency             the frequency of the reminder (in minutes)
  duration              the duration you want the reminders to run for (in hours)


Available commands:

  -h, --help          - Show this help and exit

  -l, --list          - List all running reminders and exit
                        (reminders are located via ps and grep)

  -k, --kill          - List all running reminders, and prompt user
                        for confirmation to terminate all reminders
                        (reminders are located via ps and grep)

EOF
    exit 0
}

purge-all() {
    procs=$(ps -ef | grep $0 | grep -vE "(grep|$0 -k|$0 --kill)")
    if ! [ -z "$procs" ]; then # check if ps results are null
        list-all
        read -p "Kill these processes? [y/N] " -n 1 -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo
            ps -ef | grep $0 | grep -vE "(grep|$0 -k|$0 --kill)" | tr -s ' ' | awk -F' ' '{print $2}' | xargs kill
        else
            if [[ $REPLY =~ ^[Nn]$ ]]; then echo; fi
            echo "kill command aborted"
            exit 0
        fi
    else
        echo "No reminders to kill"
    fi
}

list-all() {
    echo "running reminders"
    ps -ef | grep $0 | grep -vE "(grep|$0 -l|$0 --list|$0 -k|$0 --kill)" | tr -s ' ' | awk -F' ' '{$1=$2=$3=$4=$5=$6=$7=$8=""; print $0}'
}

main() {
    if [[ ($@ == "--kill") || ($@ == "-k") ]]; then
        purge-all
    elif [[ ($@ == "--list") || ($@ == "-l") ]]; then
        list-all
    elif [[ ($@ == "--help") || ($@ == "-h") || ! ($# -eq 3) ]]; then
        usage
    else
        remindme "$@"
    fi
}

main "$@"
