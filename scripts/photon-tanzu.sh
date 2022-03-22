#!/bin/bash -eux
##
## Download tanzu cli
##

echo ' > Syncing TAC demo catalog'
APPS=""
for row in $(jq -c '.tac.charts | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }
    if [[ -z "$APPS" ]]
    then  
        APPS=$(_jq '.name')
    else
        APPS=${APPS},$(_jq '.name')
    fi
done

mkdir /root/tmp
ytt -f /root/config/config-save-bundles.yml -v my_apps=${APPS} > /root/tmp/save-bundles.yml
TMPDIR=/root/tmp charts-syncer sync --config /root/tmp/save-bundles.yml --latest-version-only
rm -rf /root/tmp

echo ' > Downloading tanzu community edition...'
TANZU_VERSION=$(jq -r < ${APPLIANCE_BOM_FILE} '.["tanzu-cli"].version')
curl -L https://github.com/vmware-tanzu/community-edition/releases/download/v${TANZU_VERSION}/tce-linux-amd64-v${TANZU_VERSION}.tar.gz -o tce-${TANZU_VERSION}.tar.gz
mkdir tce
tar xvzf tce-*.tar.gz --strip-components=1 -C tce
rm tce-*.tar.gz