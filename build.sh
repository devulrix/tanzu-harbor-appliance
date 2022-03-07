#!/usr/bin/env bash

set -euxo pipefail

APPLIANCE_BOM_FILE=tanzu-harbor-bom.json

if [! has jq 2>/dev/null]; then
  echo "jq is missing"
  exit 1
fi

echo "Building Harbor OVA Appliance ..."
rm -f output-vmware-iso/*.ova

APPLIANCE_VERSION=$(jq -r < ${APPLIANCE_BOM_FILE} '.appliance.version')

echo "Applying packer build to photon.json ..."
packer build -var "APPLIANCE_VERSION=${APPLIANCE_VERSION}"  -var-file=photon-builder.json -var-file=photon-version.json photon.json