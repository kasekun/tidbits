#!/bin/bash

function is_git_repo {
  git rev-parse --is-inside-work-tree > /dev/null 2>&1
}

function confirm {
  if [ -z "$1" ]
  then
    echo "No branches will be affected. Exiting..."
    exit 0
  else
    echo "The following branches will be affected:"
    echo $1
    read -p "Are you sure you want to continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
      exit 1
    else
      echo "Aborting"
    fi
  fi
}

function purge_gone_branches {
  if is_git_repo; then
    branches=$(git branch -vv | grep ': gone]' | grep -Ev '(\*|master|develop|staging)' | awk '{ print $1 }')
    confirm "$branches"
    echo $branches | xargs -n 1 git branch -D
  else
    echo "Not a git repository. Skipping..."
  fi
}

function purge_merged_branches {
  if is_git_repo; then
    branches=$(git branch --merged | grep -Ev "(\*|master|develop|staging)")
    confirm "$branches"
    echo $branches | xargs -n 1 git branch -d
  else
    echo "Not a git repository. Skipping..."
  fi
}

function list_changed_files {
  if is_git_repo; then
    git diff origin/master --name-only | xargs -n 1 echo -e $(git rev-parse --show-toplevel)/ | sed 's/ //'
  else
    echo "Not a git repository. Skipping..."
  fi
}

function track_all_branches {
  if is_git_repo; then
    for b in `git branch -r | grep -v -- '->'`; do git branch --track ${b##origin/} $b; done && git fetch --all
  else
    echo "Not a git repository. Skipping..."
  fi
}

function usage {
    cat <<EOF
jgit: a simple script to help manage git branches

Usage: jgit <command>

Available commands:

  -p, --purge-gone     - Remove local branches tracking remote branches that are gone
  -m, --purge-merged   - Remove local branches that have been merged
  -f, --files-changed  - List files changed from origin/master
  -t, --track-all      - Track all remote branches locally
  -h, --help           - Show this help and exit

EOF
    exit 0
}

case "$1" in
  -p|--purge-gone)
    purge_gone_branches
    ;;
  -m|--purge-merged)
    purge_merged_branches
    ;;
  -f|--files-changed)
    list_changed_files
    ;;
  -t|--track-all)
    track_all_branches
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
