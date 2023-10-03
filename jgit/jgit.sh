#!/bin/bash

set -e

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
      echo "Aborting"
      exit 1
    fi
  fi
}

function update_from_master {
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [[ "$current_branch" == "master" ]]; then
    echo "On master branch already, fetching and merging"
    git fetch && git merge
  else
    git checkout master
    git fetch && git merge
    git checkout "${current_branch}"
    
    # dry merge to check for conflicts
    set +e
    git merge --no-commit --no-ff master
    STATUS=$?
    set -e
    git merge --abort 2>/dev/null

    # if the merge is clean, proceed; otherwise, warn user
    if [[ $STATUS -eq 0 ]]; then
      git merge master
    else
      echo "Warning: A merge with master would result in conflicts. Please resolve them before merging."
    fi
  fi
}

function purge_gone_branches {
  git fetch origin
  branches=$(git branch -vv | grep ': gone]' | grep -Ev '(\*|master|develop|staging)' | awk '{ print $1 }')
  confirm "$branches"
  echo $branches | xargs -n 1 git branch -D
}

function purge_merged_branches {
  git fetch origin
  branches=$(git branch --merged | grep -Ev "(\*|master|develop|staging)")
  confirm "$branches"
  echo $branches | xargs -n 1 git branch -d
}

function list_changed_files {
  git diff origin/master --name-only | xargs -n 1 echo -e $(git rev-parse --show-toplevel)/ | sed 's/ //'
}

function track_all_branches {
  git fetch origin
  for b in `git branch -r | grep -v -- '->'`; do git branch --track ${b##origin/} $b; done && git fetch --all
}

function usage {
    cat <<EOF
jgit: a simple script to help manage git branches

Usage: jgit <command>

Available commands:

  -p, --purge-gone          - Remove local branches tracking remote branches that are gone
  -m, --purge-merged        - Remove local branches that have been merged
  -f, --files-changed       - List files changed from origin/master
  -t, --track-all           - Track all remote branches locally
  -u, --update-from-master  - Update the current branch with remote master
  -h, --help                - Show this help and exit

EOF
    exit 0
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
    exit 0
fi

if ! is_git_repo; then
  echo "Not a git repository. Exiting..."
  exit 1
fi

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
  -u|--update-from-master)
    update_from_master
    ;;
  *)
    echo "Invalid option: $1"
    usage
    exit 1
    ;;
esac
