#!/bin/bash

# ===================================
# Git Automation Tool
# ===================================

# Colors for nice output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

# Check if inside a git repo
if [ ! -d ".git" ]; then
  echo -e "${YELLOW}Not a git repository. Run inside a project folder.${NC}"
  exit 1
fi

# Function: Auto add + commit + push
auto_commit_push() {
  echo -e "${GREEN}Staging all changes...${NC}"
  git add .

  # Ask for commit message or generate default
  read -p "Enter commit message (leave empty for auto): " msg
  if [ -z "$msg" ]; then
    msg="Auto commit on $(date +'%Y-%m-%d %H:%M:%S')"
  fi

  git commit -m "$msg"
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  echo -e "${GREEN}Pushing to branch $current_branch...${NC}"
  git push origin "$current_branch"
}

# Function: Branch management
branch_menu() {
  echo -e "${GREEN}Available branches:${NC}"
  git branch -a
  read -p "Enter branch to switch/create: " branch

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git checkout "$branch"
  else
    git checkout -b "$branch"
  fi
}

# Function: Tagging
tag_release() {
  read -p "Enter tag name (leave empty for auto): " tag
  if [ -z "$tag" ]; then
    tag="release-$(date +'%Y%m%d%H%M%S')"
  fi

  git tag "$tag"
  git push origin "$tag"
  echo -e "${GREEN}Created and pushed tag: $tag${NC}"
}

# Function: PR creation (requires GitHub CLI)
create_pr() {
  if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}GitHub CLI (gh) not installed. Skipping...${NC}"
    return
  fi

  read -p "Enter PR title: " title
  read -p "Enter PR body (optional): " body
  gh pr create --title "$title" --body "$body" --base main
}

# Menu
echo "==== Git Automation Tool ===="
echo "1. Auto Commit & Push"
echo "2. Switch/Create Branch"
echo "3. Create & Push Tag"
echo "4. Create Pull Request"
echo "5. Exit"

read -p "Choose an option: " choice

case $choice in
  1) auto_commit_push ;;
  2) branch_menu ;;
  3) tag_release ;;
  4) create_pr ;;
  5) exit 0 ;;
  *) echo "Invalid option" ;;
esac
