#!/bin/bash -eux
##
## Download the tanzu packages 
##

echo ' > Downloading kapp-controller...'
mkdir images
docker pull projects.registry.vmware.com/tkg/kapp-controller:v0.25.0_vmware.1
docker save projects.registry.vmware.com/tkg/kapp-controller:v0.25.0_vmware.1 | gzip > images/kapp-controller-0.25.0.tar.gz
docker rmi projects.registry.vmware.com/tkg/kapp-controller:v0.25.0_vmware.1
docker pull projects.registry.vmware.com/tkg/kapp-controller:v0.30.0_vmware.1
docker save projects.registry.vmware.com/tkg/kapp-controller:v0.30.0_vmware.1 | gzip > images/kapp-controller-0.30.0.tar.gz
docker rmi projects.registry.vmware.com/tkg/kapp-controller:v0.30.0_vmware.1

echo ' > Downloading package repo 1.4.0'
imgpkg copy -b projects.registry.vmware.com/tkg/packages/standard/repo:v1.4.0 --to-tar images/packages-1.4.0.tar

echo ' > Downloading package repo 1.5.0'
imgpkg copy -b projects.registry.vmware.com/tkg/packages/standard/repo:v1.5.0 --to-tar images/packages-1.5.0.tar
