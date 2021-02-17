#!/bin/sh
echo "I want to destroy the deployment"

while getopts branch_name:tag:pr: flag
do
    case "${flag}" in
        branch_name) branch=${OPTARG};;
        tag) repo_tag=${OPTARG};;
        pr) pr_number=${OPTARG};;
    esac
done

echo "branch: $branch";
echo "repo_tag: $repo_tag";
echo "pr_number: $pr_number";