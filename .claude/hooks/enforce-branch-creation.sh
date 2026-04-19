#!/bin/bash

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$CURRENT_BRANCH" ]; then
  echo "Could not determine current branch. Blocking writes as a safety measure." >&2
  exit 2
fi

PROTECTED_BRANCHES=("main" "master" "develop")

for branch in "${PROTECTED_BRANCHES[@]}"; do
  if [ "$CURRENT_BRANCH" = "$branch" ]; then
    echo "Cannot make changes on '$CURRENT_BRANCH' branch. Please create a new branch first." >&2
    exit 2
  fi
done

exit 0
