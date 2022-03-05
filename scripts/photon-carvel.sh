#!/bin/bash -eux
##
## Download and put carvel tools into path
##

echo ' > Downloading ytt...'
YTT_VERSION=0.40.0
curl -L https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 -o /usr/local/bin/ytt
chmod +x /usr/local/bin/ytt

echo '> Downloading kapp...'
KAPP_VERSION=0.46.0
curl -L "https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64" -o /usr/local/bin/kapp
chmod +x /usr/local/bin/kapp

echo '> Downloading imgpkg...'
IMGPKG_VERSION=0.25.0
curl -L "https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64" -o /usr/local/bin/imgpkg
chmod +x /usr/local/bin/imgpkg

echo '> Downloading kbld...'
KBLD_VERSION=0.32.0
curl -L "https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64" -o /usr/local/bin/kbld
chmod +x /usr/local/bin/kbld

echo '> Downloading kubectl...'
KUBECTL_VERSION=1.23.4
curl -L "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl