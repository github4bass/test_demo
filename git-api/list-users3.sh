#!/bin/bash

###########################################
# Script: List users with read access to a GitHub repo
# Usage: ./list_read_access.sh <repo_owner> <repo_name>
###########################################

API_URL="https://api.github.com"

# ==== Check command arguments ====
if [ $# -ne 2 ]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

REPO_OWNER=$1
REPO_NAME=$2

# ==== Ask for GitHub login info ====
read -p "Enter your GitHub username: " USERNAME
read -s -p "Enter your GitHub personal access token: " TOKEN
echo

# ==== Function: Make a GET request to GitHub API ====
github_api_get() {
    local endpoint="$1"
    curl -s -u "${USERNAME}:${TOKEN}" "${API_URL}/${endpoint}"
}

# ==== Function: List users with read access ====
list_users_with_read_access() {
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    # Get collaborators & filter users with "pull" (read) access
    local collaborators
    collaborators=$(github_api_get "$endpoint" | jq -r '
        if type=="array" then
            .[] | select(.permissions.pull == true) | .login
        else
            empty
        end
    ')

    # Show results
    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

# ==== Run ====
list_users_with_read_access

