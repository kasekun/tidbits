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

function update_from_parent_branch {
  parent_branch=${1:-master}  # Default to 'master' if no parent branch is specified
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$current_branch" == "$parent_branch" ]]; then
    echo "On $parent_branch branch already, fetching and merging"
    git fetch && git merge
  else
    git checkout "$parent_branch"
    git fetch && git merge
    git checkout "${current_branch}"
    
    set +e
    git merge --no-commit --no-ff "$parent_branch"
    STATUS=$?
    set -e
    git merge --abort 2>/dev/null

    if [[ $STATUS -eq 0 ]]; then
      git merge "$parent_branch"
    else
      echo "Warning: A merge with $parent_branch would result in conflicts. Please resolve them before merging."
    fi
  fi
}

function purge_gone_branches {
  git fetch origin
  branches=$(git branch -vv | grep ': gone]' | grep -Ev '(\*|master|develop|staging|green)' | awk '{ print $1 }')
  confirm "$branches"
  echo $branches | xargs -n 1 git branch -D
}

function purge_merged_branches {
  git fetch origin
  branches=$(git branch --merged | grep -Ev "(\*|master|develop|staging|green)")
  confirm "$branches"
  echo $branches | xargs -n 1 git branch -d
}

function list_changed_files {
  parent_branch=${1:-master}  # Default to 'master' if no parent branch is specified
  git diff "origin/${parent_branch}" --name-only | xargs -n 1 echo -e $(git rev-parse --show-toplevel)/ | sed 's/ //'
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
  -u, --update-from-parent  - Update the current branch with remote parent branch (defaults to "master")
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
    shift  # Remove the '-f' or '--files-changed' argument
    parent_branch=""
    while getopts ":p:" opt; do
      case $opt in
        p) parent_branch="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
      esac
    done
    list_changed_files "$parent_branch"
    ;;
  -t|--track-all)
    track_all_branches
    ;;
  -u|--update-from-parent)
    shift  # Remove the '-u' or '--update-from-parent' argument
    parent_branch=""
    while getopts ":p:" opt; do
      case $opt in
        p) parent_branch="$OPTARG" ;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
      esac
    done
    update_from_parent_branch "$parent_branch"
    ;;
  *)
    echo "Invalid option: $1"
    usage
    exit 1
    ;;
esac
