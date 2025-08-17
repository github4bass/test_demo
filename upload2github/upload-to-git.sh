#!/bin/bash

# Ask for repo URL
read -p "Enter your GitHub repo URL (HTTPS or SSH): " REPO_URL

# Ask for commit message
read -p "Enter commit message: " COMMIT_MSG

# Initialize git if not already
if [ ! -d ".git" ]; then
    git init
    git branch -M main
    git remote add origin "$REPO_URL"
fi

# Stage all files
git add .

# Commit changes
git commit -m "$COMMIT_MSG"

# Push to GitHub
git push -u origin main

