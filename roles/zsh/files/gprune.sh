#!/bin/bash

# Default values
MAIN_BRANCH="main"   # Main branch to compare against
PRUNE_TARGET="both"  # Target to prune: local, remote, or both
REMOTE_NAME="origin" # Default remote name
DRY_RUN=true         # Dry run is the default

# Function to display help
function display_help() {
    echo "Usage: $0 [-b MAIN_BRANCH] [-t PRUNE_TARGET] [-r REMOTE_NAME] [--execute] [-h]"
    echo
    echo "This script prunes feature/* and bugfix/* branches that have been merged into the specified branch."
    echo
    echo "Options:"
    echo "  -b, --branch       MAIN_BRANCH       The main branch to compare against (default: main)."
    echo "  -t, --target       PRUNE_TARGET      Specify which branches to prune: 'local', 'remote', or 'both' (default: both)."
    echo "  -r, --remote       REMOTE_NAME       The remote to use for remote branch deletion (default: origin)."
    echo "  -e, --execute                        Run the script in execute mode, which actually deletes branches."
    echo "                                       Prompts for confirmation with the current folder name."
    echo "  -h, --help                           Show this help message and exit."
    echo
    echo "Examples:"
    echo "  $0                         # Dry run (default): Prune local and remote branches merged into 'main' on 'origin'."
    echo "  $0 -b master -t local      # Dry run: Prune only local branches merged into 'master'."
    echo "  $0 -b main -t remote -r upstream -e # Execute: Prune only remote branches on 'upstream' merged into 'main', requires confirmation."
    echo
}

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
    -b | --branch)
        MAIN_BRANCH="$2"
        shift 2
        ;;
    -t | --target)
        PRUNE_TARGET="$2"
        shift 2
        ;;
    -r | --remote)
        REMOTE_NAME="$2"
        shift 2
        ;;
    -e | --execute)
        DRY_RUN=false
        shift
        ;;
    -h | --help)
        display_help
        exit 0
        ;;
    *)
        echo "Unknown option: $1"
        display_help
        exit 1
        ;;
    esac
done

# Confirm if in execute mode
if ! $DRY_RUN; then
    # Get the current folder name for confirmation
    FOLDER_NAME=$(basename "$PWD")
    echo "You are about to delete branches. To confirm, type the current folder name: $FOLDER_NAME"
    read -r CONFIRMATION
    if [[ "$CONFIRMATION" != "$FOLDER_NAME" ]]; then
        echo "Confirmation failed. Exiting without deleting any branches."
        exit 1
    fi
fi

# Fetch the latest updates from the specified remote
git fetch --all --prune

# Switch to the specified main branch
git checkout "$MAIN_BRANCH"
git pull "$REMOTE_NAME" "$MAIN_BRANCH"

# Get branches merged into the main branch with prefixes feature/* and bugfix/*
for branch in $(git branch --merged "$MAIN_BRANCH" | grep -E '^\s*(feature/|bugfix/)'); do
    # Remove leading/trailing whitespace
    branch=$(echo "$branch" | xargs)

    # DRY RUN: Display actions without executing
    if $DRY_RUN; then
        if [[ "$PRUNE_TARGET" == "local" || "$PRUNE_TARGET" == "both" ]]; then
            echo "[Dry Run] Local branch to delete: $branch"
        fi
        if [[ "$PRUNE_TARGET" == "remote" || "$PRUNE_TARGET" == "both" ]]; then
            if git ls-remote --exit-code --heads "$REMOTE_NAME" "$branch" &>/dev/null; then
                echo "[Dry Run] Remote branch '$REMOTE_NAME/$branch' to delete"
            fi
        fi
        continue
    fi

    # Execute deletion based on prune target
    if [[ "$PRUNE_TARGET" == "local" || "$PRUNE_TARGET" == "both" ]]; then
        if git show-ref --verify --quiet refs/heads/$branch; then
            echo "Deleting local branch: $branch"
            git branch -d "$branch"
        fi
    fi

    if [[ "$PRUNE_TARGET" == "remote" || "$PRUNE_TARGET" == "both" ]]; then
        if git ls-remote --exit-code --heads "$REMOTE_NAME" "$branch" &>/dev/null; then
            echo "Deleting remote branch '$REMOTE_NAME/$branch'"
            git push "$REMOTE_NAME" --delete "$branch"
        fi
    fi
done

echo "Pruning completed!"
