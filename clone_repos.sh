#!/bin/bash

# Define the desired path
BASE_PATH="$1"

# Check if a path was provided
if [ -z "$BASE_PATH" ]; then
  echo "Usage: $0 <path>"
  exit 1
fi

# Create the directory structure with error handling if not already exists
mkdir -p "$BASE_PATH/laravel" || { echo "Failed to create directory: $BASE_PATH/laravel"; exit 1; }
mkdir -p "$BASE_PATH/nextjs" || { echo "Failed to create directory: $BASE_PATH/nextjs"; exit 1; }
mkdir -p "$BASE_PATH/dotnet-api" || { echo "Failed to create directory: $BASE_PATH/dotnet-api"; exit 1; }

# Function to clone repositories and handle errors
clone_repo() {
  local repo_url=$1
  local target_path=$2
  local branch_name=$3

  # Check if the repository already exists in the target directory
  if [ -d "$target_path/.git" ]; then
    echo "Repository already exists at $target_path. Skipping clone."
  else
    if git clone --branch "$branch_name" "$repo_url" "$target_path"; then
      echo "Cloned $repo_url to $target_path (branch: $branch_name)"
    else
      echo "Failed to clone $repo_url to $target_path"
      exit 1
    fi
  fi
}

# Install Git if not already installed
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Installing..."
  sudo apt-get update
  sudo apt-get install git -y
fi

# Clone the repositories from the main branch (or skip if they exist)
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/Laravel.git" "$BASE_PATH/laravel" "main"
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/WebsiteNextJS.git" "$BASE_PATH/nextjs" "main"
clone_repo "https://github.com/Latitude-OpenDATA-SIO-Saintbe/DotnetApi.git" "$BASE_PATH/dotnet-api" "main"

echo "Repositories cloned successfully."

# Find the update script
UPDATE_SCRIPT=$(find "$BASE_PATH" -name "update_repos.sh" | fzf --select-1 --exit-0)

# Ensure the update script exists before running it
if [ -n "$UPDATE_SCRIPT" ] && [ -f "$UPDATE_SCRIPT" ]; then
  echo "Running update script: $UPDATE_SCRIPT"
  bash "$UPDATE_SCRIPT"
else
  echo "No valid update_repos.sh script found."
  exit 1
fi

# Add the cron job to run the update script every 3 minutes if it doesn't already exist
if ! crontab -l | grep -q "$UPDATE_SCRIPT"; then
  (crontab -l 2>/dev/null; echo "*/3 * * * * $UPDATE_SCRIPT $BASE_PATH >> /var/log/update_repo.log 2>&1") | crontab -
  echo "Cron job added to fetch updates every 3 minutes."
else
  echo "Cron job already exists."
fi

echo "Script completed successfully."
