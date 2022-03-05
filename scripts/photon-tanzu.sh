#!/bin/bash -eux
##
## Download tanzu cli
##

echo ' > Downloading tanzu...'
TANZU_VERSION=0.10.0
curl -L https://github.com/vmware-tanzu/community-edition/releases/download/v${TANZU_VERSION}/tce-linux-amd64-v${TANZU_VERSION}.tar.gz -o tce-${TANZU_VERSION}.tar.gz
mkdir tce
tar xvzf tce-*.tar.gz --strip-components=1 -C tce
rm tce-*.tar.gz