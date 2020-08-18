#!/bin/bash
set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: get-policy.sh BOOLEAN"
  exit 2
fi

if [ "$1" == "true" ]; then
  echo '{ "policy": null }'
else
  echo '{ "policy": "{}"}'
fi
