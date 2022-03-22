#!/bin/bash

set -euo pipefail

REPO=$(jq -r < ${APPLIANCE_BOM_FILE} '.tac.target')
mkdir /root/tmp
ytt -f /root/config/config-load-bundles.yml -v hostname=$HOSTNAME \
-v repo=${REPO} \
-v username=admin \
-v password=${HARBOR_PASSWORD} > /root/tmp/load-bundles.yml
TMPDIR=/root/tmp charts-syncer sync --config /root/tmp/load-bundles.yml 
#clean up 
rm -rf /root/tmp
rm -rf /root/images/chart-bundles-dir