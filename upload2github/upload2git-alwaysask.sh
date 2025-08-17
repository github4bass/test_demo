#!/bin/bash

read -p "Enter GitHub repo URL (HTTPS or SSH): " REPO_URL
read -p "Enter commit message: " COMMIT_MSG

git init
git branch -M main
git remote remove origin 2>/dev/null
git remote add origin "$REPO_URL"

git add .
git commit -m "$COMMIT_MSG"
git push -u origin main

