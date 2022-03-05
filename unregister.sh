#!/usr/bin/env bash

while getopts v:u:p:t: flag
do
    case "${flag}" in
        v) vcenter=${OPTARG};;
        u) user=${OPTARG};;
        p) password=${OPTARG};;
        t) vms=${OPTARG};;
    esac
done

export GOVC_INSECURE=1
GOVC_USERNAME=$user
GOVC_PASSWORD=$password

export GOVC_URL="${GOVC_USERNAME}:${GOVC_PASSWORD}@${vcenter}"

govc vm.unregister ${vms}