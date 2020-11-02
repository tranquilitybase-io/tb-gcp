#!/bin/bash

set -eu

# dummy test script - tests will be kicked off from here

echo "==> Starting tests ..."

systemctl disable apt-daily-upgrade.service 

echo "==> Ending tests ..."

exit 0
