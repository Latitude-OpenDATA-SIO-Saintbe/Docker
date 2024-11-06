#!/bin/bash

# Define the desired path
BASE_PATH="$1"

# Function to fetch updates from a repository
fetch_repo() {
  local target_path=$1
  if [ -d "$target_path/.git" ]; then
    (cd "$target_path" && {
      git fetch origin
      if git status | grep -q "Your branch is behind"; then
        echo "Fetching updates for $target_path..."
        git pull
      else
        echo "$target_path is up to date."
      fi
    })
  else
    echo "$target_path is not a valid Git repository."
  fi
}

# Loop through each repository and fetch updates
for repo in "$BASE_PATH"/laravel "$BASE_PATH"/nextjs "$BASE_PATH"/dotnet-api; do
  fetch_repo "$repo"
done
