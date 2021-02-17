#!/bin/sh
set -e
echo "I want to destroy the deployment"

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

echo "DEV_BILLING_ACCOUNT: $DEV_BILLING_ACCOUNT";
echo "branch: $BRANCH_NAME";
echo "repo_tag: $TAG";
echo "pr_number: $PR_NUMBER";

secret=$(gcloud secrets versions access 1 --secret="geoff_test_secret")
echo "secret " + secret
#./tb-projects-deleter -r fl0jhl5g -f 70705938661 -b 0171E1-E25AD9-6240E8