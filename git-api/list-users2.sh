#!/bin/bash

############################################
# Script: list_github_read_access_users.sh
# Purpose: List all users with read access to a given GitHub repository
# Usage: ./list_github_read_access_users.sh <repo_owner> <repo_name>
# Requirements: curl, jq
############################################

API_URL="https://api.github.com"

# ===== Helper function: Validate inputs =====
helper() {
    local expected_args=2
    if [ $# -ne $expected_args ]; then
        echo "Usage: $0 <repo_owner> <repo_name>"
        echo "Example: $0 octocat Hello-World"
        exit 1
    fi

    if [[ -z "$username" || -z "$token" ]]; then
        echo "Error: Please set your GitHub username and personal access token as environment variables:"
        echo "  export username=your_github_username"
        echo "  export token=your_personal_access_token"
        exit 1
    fi
}

# ===== Function to call the GitHub API =====
github_api_get() {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    # Fetch data from GitHub API
    local response
    response=$(curl -s -u "${username}:${token}" "$url")

    # Check if API returned a message (error)
    if echo "$response" | jq -e '.message?' >/dev/null; then
        local msg
        msg=$(echo "$response" | jq -r '.message')
        echo "GitHub API error: $msg"
        exit 1
    fi

    echo "$response"
}

# ===== Function to list users with read access =====
list_users_with_read_access() {
    local repo_owner="$1"
    local repo_name="$2"
    local endpoint="repos/${repo_owner}/${repo_name}/collaborators"

    # Get collaborators
    local collaborators
    collaborators=$(github_api_get "$endpoint" | jq -r '
        if type=="array" then
            .[] | select(.permissions.pull == true) | .login
        else
            empty
        end
    ')

    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${repo_owner}/${repo_name}."
    else
        echo "Users with read access to ${repo_owner}/${repo_name}:"
        echo "$collaborators"
    fi
}

# ===== Main script execution =====
helper "$@"                     # Validate arguments & credentials
REPO_OWNER=$1
REPO_NAME=$2

echo "Listing users with read access to ${REPO_OWNER}/${REPO_NAME}..."
list_users_with_read_access "$REPO_OWNER" "$REPO_NAME"

