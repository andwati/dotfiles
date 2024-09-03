#!/bin/bash

GITHUB_USERNAME="andwati"

DESTINATION_FOLDER=~/GitHub


clone_repositories() {
    local parent_dir=$1
    local url=$2

    # Extract the repository name from the URL
    local repo_name=$(basename "${url%.git}")

    # Clone the repository into the specified folder
    git clone "$url" "$parent_dir/$repo_name"

    # Move into the cloned repository folder
    cd "$parent_dir/$repo_name" || exit

    # If there are submodules, initialize and update them
    if [ -f ".gitmodules" ]; then
        git submodule init
        git submodule update
    fi

    # Recursively clone submodules if any
    if [ -f ".gitmodules" ]; then
        git submodule foreach --recursive "$0" "$parent_dir/$repo_name"
    fi

    # Move back to the parent folder
    cd "$parent_dir" || exit
}

repositories=$(curl -s "https://api.github.com/users/$GITHUB_USERNAME/repos?per_page=100" | grep -o 'git@[^"]*')

mkdir -p $DESTINATION_FOLDER


cd "$DESTINATION_FOLDER" || exit

for repository in $repositories; do
    clone_repositories "$DESTINATION_FOLDER" "$repository"
done
