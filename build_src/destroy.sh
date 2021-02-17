#!/bin/sh
set -e
echo "I want to destroy the deployment"

while (( "$#" )); do
  case "$1" in
    -b|--branch_name)
      BRANCH_NAME=$2
      shift 2
      ;;
    -t|--tag)
      TAG=$2
      shift 2
      ;;
    -p|--pr_number )
      PR_NUMBER=$2
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    --*=|-*) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # unsupported positional arguments
      echo "Error: Unsupported positional argument $1" >&2
      shift
      ;;
  esac
done

echo "branch: $BRANCH_NAME";
echo "repo_tag: $TAG";
echo "pr_number: $PR_NUMBER";