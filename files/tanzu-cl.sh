#/bin/bash

set -euo pipefail


 usage() {
     echo "Usage: $0 [ -v VCENTER URL ] [-u USER ] [-p PASSWORD ] [-l CONTENT_LIBRARY_NAME ] [-c CREATE CONTENT_LIBRARY ] [-d CONTENT_LIBRARY DATASTORE]"
 }

 exit_abnormal() {
     usage
     exit 1
 }

while getopts v:u:p:l:d:c flag
do
    case "$flag" in
        v) VCENTER_URL="$OPTARG";;
        u) VCENTER_USER="$OPTARG";;
        p) VCENTER_PASSWORD="$OPTARG";;
        l) CONTENT_LIBRARY_NAME="$OPTARG";;
        d) DATASTORE="$OPTARG";;
        c) CREATE_CL=TRUE;;
        *) exit_abnormal;;
    esac
done 

export GOVC_INSECURE=1
GOVC_USERNAME=${VCENTER_USER}
GOVC_PASSWORD=${VCENTER_PASSWORD}

export GOVC_URL="${GOVC_USERNAME}:${GOVC_PASSWORD}@${VCENTER_URL}"

#create content library 
if [[ ! -z CREATE_CL ]] 
then 
   CONTENT_LIBRARY_NAME=$(govc library.create -d "Tanzu Kubernetes Grid Releases" -ds ${DATASTORE} ${CONTENT_LIBRARY_NAME})
fi 

#import tkr 
for row in $(jq -c '.tkr | map(.) | .[]' ${APPLIANCE_BOM_FILE}); do
    _jq() {
        echo ${row} | jq -r "${1}"
    }

    govc library.import -t=ova ${CONTENT_LIBRARY_NAME} /root/images/$(_jq '.name').ova
done