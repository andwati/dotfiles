#!/bin/bash

GITHUB_USERNAME="andwati"
DESTINATION_FOLDER=~/cloned

GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

clone_repositories() {
    local parent_dir=$1
    local repo_name=$2

    echo -e "${BLUE}Cloning repository: $repo_name${RESET}"
    if gh repo clone "$GITHUB_USERNAME/$repo_name" "$parent_dir/$repo_name"; then
        echo -e "${GREEN}Successfully cloned: $repo_name${RESET}"
    else
        echo -e "${RED}Failed to clone: $repo_name${RESET}"
        return
    fi

  
    cd "$parent_dir/$repo_name" || exit

   
    if [ -f ".gitmodules" ]; then
        echo -e "${BLUE}Initializing and updating submodules for: $repo_name${RESET}"
        git submodule init
        git submodule update
    fi
}

main() {
  
    mkdir -p "$DESTINATION_FOLDER"


    echo -e "${BLUE}Fetching repositories for user: $GITHUB_USERNAME${RESET}"
    repos=$(gh repo list "$GITHUB_USERNAME" --visibility all --limit 100 --json name -q '.[].name')


    total_repos=$(echo "$repos" | wc -w)
    count=0

    for repo in $repos; do
        count=$((count + 1))
        echo -e "${BLUE}Progress: [$count/$total_repos]${RESET}"
        clone_repositories "$DESTINATION_FOLDER" "$repo"
    done

    echo -e "${GREEN}Cloning complete! ${RESET}"
}

main
