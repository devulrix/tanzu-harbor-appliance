#!/usr/bin/env bash

set -euo pipefail

APPLIANCE_BOM_FILE=tanzu-harbor-bom.json

build_local=

while getopts l flag
do
    case "${flag}" in
        l) build_local=TRUE;;
    esac
done 

if [! has jq 2>/dev/null]; then
  echo "jq is missing"
  exit 1
fi

echo "Cleaning up old Harbor OVA Appliance ..."
rm -f output-harbor-iso/*.ova

APPLIANCE_VERSION=$(jq -r < ${APPLIANCE_BOM_FILE} '.appliance.version')

if [ -z "$build_local" ]
then
  echo "Applying packer build to photon.json ..."
  packer build -var "APPLIANCE_VERSION=${APPLIANCE_VERSION}"  -var-file=photon-builder.json -var-file=photon-version.json photon.json
else
  echo "Applying packer build to photon.json ..."
  packer build -var "APPLIANCE_VERSION=${APPLIANCE_VERSION}"  -var-file=photon-version.json photon-local.json
fi