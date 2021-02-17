#!/bin/bash
set -e
echo "I want to run the deployment"

while [ "$1" != "" ]; do
  PARAM=`echo $1 | awk -F= '{print $1}'`
  VALUE=`echo $1 | awk -F= '{print $2}'`
  case "$PARAM" in
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
    -d|--dev_billing )
      DEV_BILLING=$2
      shift 2
      ;;
    -f|--target_folder )
      TARGET_FOLDER=$2
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
echo "dev_billing: $DEV_BILLING";
echo "target_folder: $TARGET_FOLDER";

sh build_src/auto-deploy.sh --folder-id $TARGET_FOLDER --billing-account $DEV_BILLING --fixed-name "Integration"  --no-labels