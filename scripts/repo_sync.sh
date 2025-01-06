#!/bin/bash

GITHUB_USERNAME="andwati"
DESTINATION_FOLDER=~/cloned

clone_repositories() {
    local parent_dir=$1
    local repo_name=$2
    
    gh repo clone "$GITHUB_USERNAME/$repo_name" "$parent_dir/$repo_name"

    cd "$parent_dir/$repo_name" || exit

    if [ -f ".gitmodules" ]; then
        git submodule init
        git submodule update
    fi
}

main() {
    mkdir -p "$DESTINATION_FOLDER"

    repos=$(gh repo list "$GITHUB_USERNAME" --visibility all --limit 100 --json name -q '.[].name')

    for repo in $repos; do
        echo "Cloning repository: $repo"
        clone_repositories "$DESTINATION_FOLDER" "$repo"
    done
}

main
