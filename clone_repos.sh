#!/bin/bash

# Define the desired path
BASE_PATH="$1"

# Check if a path was provided
if [ -z "$BASE_PATH" ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

# Create the directory structure with error handling
mkdir -p "$BASE_PATH/laravel" || { echo "Failed to create directory: $BASE_PATH/laravel"; exit 1; }
mkdir -p "$BASE_PATH/nextjs" || { echo "Failed to create directory: $BASE_PATH/nextjs"; exit 1; }
mkdir -p "$BASE_PATH/dotnet-api" || { echo "Failed to create directory: $BASE_PATH/dotnet-api"; exit 1; }
mkdir -p "$BASE_PATH/dev/laravel" || { echo "Failed to create directory: $BASE_PATH/dev/laravel"; exit 1; }
mkdir -p "$BASE_PATH/dev/nextjs" || { echo "Failed to create directory: $BASE_PATH/dev/nextjs"; exit 1; }
mkdir -p "$BASE_PATH/dev/dotnet-api" || { echo "Failed to create directory: $BASE_PATH/dev/dotnet-api"; exit 1; }

# Function to clone repositories and handle errors
clone_repo() {
  local repo_url=$1
  local target_path=$2
  local branch_name=$3
  if git clone --branch "$branch_name" "$repo_url" "$target_path"; then
    echo "Cloned $repo_url to $target_path (branch: $branch_name)"
  else
    echo "Failed to clone $repo_url to $target_path"
    exit 1
  fi
}

# Install Git if not already installed
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install git -y
fi

# Clone the repositories from the main branch
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/Laravel.git" "$BASE_PATH/laravel" "main"
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/WebsiteNextJS.git" "$BASE_PATH/nextjs" "main"
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/DotnetApi.git" "$BASE_PATH/dotnet-api" "main"

# Clone the repositories into the dev folder from the dev branch
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/Laravel.git" "$BASE_PATH/dev/laravel" "dev"
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/WebsiteNextJS.git" "$BASE_PATH/dev/nextjs" "dev"
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/DotnetApi.git" "$BASE_PATH/dev/dotnet-api" "dev"

echo "Repositories cloned successfully."

# Find the update script
UPDATE_SCRIPT=$(find . -name "update_repos.sh" | fzf --select-1 --exit-0)

# Add the cron job to run the update script every 3 minutes if it doesn't already exist
if ! crontab -l | grep -q "$UPDATE_SCRIPT"; then
  (crontab -l 2>/dev/null; echo "*/3 * * * * $UPDATE_SCRIPT $BASE_PATH >> /var/log/update_repo.log 2>&1") | crontab -
  echo "Cron job added to fetch updates every 3 minutes."
else
  echo "Cron job already exists."
fi
