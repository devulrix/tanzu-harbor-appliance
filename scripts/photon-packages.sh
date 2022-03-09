#!/usr/bin/env bash
##
## Download all container images
##

set -euo pipefail

echo ' > Downloading container images...'

for row in $(jq -c '.containers | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }
    echo $(_jq '.image')":"$(_jq '.tag')
    imgpkg copy -i $(_jq '.image'):$(_jq '.tag') --to-tar images/$(_jq '.image' | awk -F '/' '{print $NF}'):$(_jq '.tag').tar
done

echo ' > Downloading bundles...'

for row in $(jq -c '.bundles | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }
    echo $(_jq '.source')
    imgpkg copy -b $(_jq '.source') --to-tar images/$(_jq '.source' | awk -F '/' '{print $NF}').tar
done
