# Exit immediately if any command fails
set -e

# Add all changes to the staging area
echo "Staging all changes..."
git add . || { echo "Failed to add changes"; exit 1; }

# Amend the last commit without editing the message
echo "Amending the last commit..."
git commit --amend --no-edit || { echo "Failed to amend the commit"; exit 1; }

# Check if the branch is up-to-date with the remote before force-pushing
current_branch=$(git branch --show-current)
echo "Checking if the branch is up-to-date with the remote..."
git fetch origin "$current_branch"
local_commit=$(git rev-parse "$current_branch")
remote_commit=$(git rev-parse "origin/$current_branch")

if [ "$local_commit" != "$remote_commit" ]; then
  echo "Warning: Your local branch is behind the remote. Force-pushing may cause data loss."
fi

# Force-push the amended commit
echo "Force-pushing the amended commit to the remote..."
git push -f || { echo "Failed to force-push the commit"; exit 1; }

echo "Force-push completed successfully!"
