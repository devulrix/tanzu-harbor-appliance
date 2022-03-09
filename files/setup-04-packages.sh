#!/bin/bash

set -euo pipefail

# create harbor projects
for row in $(jq -c '.harbor.projects | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }
    curl -k -X POST -u "admin:${HARBOR_PASSWORD}" "https://${HOSTNAME}/api/v2.0/projects" -H  "accept: application/json" -H  "X-Resource-Name-In-Location: false" -H  "Content-Type: application/json" -d "{  \"project_name\": \"$(_jq '.name')\", \"metadata\": {    \"enable_content_trust\": \"false\",    \"auto_scan\": \"false\",       \"public\": \"$(_jq '.public')\",    \"reuse_sys_cve_allowlist\": \"true\"}}"
done

# copy tar images into harbor projects
for row in $(jq -c '.containers | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }
    imgpkg copy --tar /root/images/$(_jq '.image' | awk -F '/' '{print $NF}'):$(_jq '.tag').tar --to-repo ${HOSTNAME}/$(_jq '.destination')/$(_jq '.image' | awk -F '/' '{print $NF}') --registry-username admin --registry-password ${HARBOR_PASSWORD} --registry-verify-certs=false
done

# import bundles into harbor
for row in $(jq -c '.bundles | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }
    echo $(_jq '.source')
    imgpkg copy --tar /root/images/$(_jq '.image' | awk -F '/' '{print $NF}'):$(_jq '.tag').tar --to-repo ${HOSTNAME}/$(_jq '.destination')/$(_jq '.image' | awk -F '/' '{print $NF}') --registry-username admin --registry-password ${HARBOR_PASSWORD} --registry-verify-certs=false
done