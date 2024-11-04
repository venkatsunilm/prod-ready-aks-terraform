# Exit the script on any error
set -e

# Get the current branch name
current_branch=$(git branch --show-current)
base_branch='main'

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
  echo "Uncommitted changes detected. Stashing changes before switching branches..."
  git stash push -m "auto-stash before switching to $base_branch"
  stash_applied=true
else
  stash_applied=false
fi

# Fetch the latest updates and prune stale remote-tracking branches
echo "Fetching latest changes and pruning stale remote branches..."
git fetch --prune || { echo "Failed to fetch updates"; exit 1; }

# Check if we are already on the $base_branch branch
if [ "$current_branch" == $base_branch ]; then
  echo "Already on $base_branch branch. Pulling the latest changes..."
  git pull origin $base_branch || { echo "Failed to pull changes on $base_branch"; exit 1; }
else
  echo "Switching to $base_branch branch..."
  git checkout $base_branch || { echo "Failed to switch to $base_branch"; exit 1; }

  # Pull the latest changes from $base_branch
  echo "Pulling latest changes from $base_branch..."
  git pull origin $base_branch || { echo "Failed to pull changes from origin"; exit 1; }
fi

# Switch back to the previous branch, if it wasn't '$base_branch'
if [ "$current_branch" != $base_branch ]; then
  echo "Switching back to $current_branch..."
  git checkout "$current_branch" || { echo "Failed to switch back to $current_branch"; exit 1; }
fi

# Rebase the current branch onto $base_branch
echo "Rebasing $current_branch onto $base_branch..."
git rebase $base_branch || { echo "Rebase failed"; exit 1; }

# Apply the stash if changes were stashed earlier
if [ "$stash_applied" = true ]; then
  echo "Re-applying stashed changes..."
  git stash pop || { echo "Failed to reapply stashed changes"; exit 1; }
fi

echo "Rebase completed successfully!"
