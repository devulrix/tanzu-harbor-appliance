#!/bin/bash

curl -k -X POST -u "admin:${HARBOR_PASSWORD}" "https://${HOSTNAME}/api/v2.0/projects" -H  "accept: application/json" -H  "X-Resource-Name-In-Location: false" -H  "Content-Type: application/json" -d "{  \"project_name\": \"tkg\", \"metadata\": {    \"enable_content_trust\": \"false\",    \"auto_scan\": \"false\",       \"public\": \"true\",    \"reuse_sys_cve_allowlist\": \"true\"},  \"public\": true}"

docker login ${HOSTNAME} -u admin -p ${HARBOR_PASSWORD}
docker load -i /root/images/kapp-controller-0.25.0.tar.gz
docker tag projects.registry.vmware.com/tkg/kapp-controller:v0.25.0_vmware.1 ${HOSTNAME}/tkg/kapp-controller:v0.25.0_vmware.1
docker push ${HOSTNAME}/tkg/kapp-controller:v0.25.0_vmware.1

docker load -i /root/images/kapp-controller-0.30.0.tar.gz
docker tag projects.registry.vmware.com/tkg/kapp-controller:v0.30.0_vmware.1 ${HOSTNAME}/tkg/kapp-controller:v0.30.0_vmware.1
docker push ${HOSTNAME}/tkg/kapp-controller:v0.30.0_vmware.1

imgpkg copy --tar /root/images/packages-1.4.0.tar --to-repo ${HOSTNAME}/tkg/tanzu-packages --registry-ca-cert-path=/etc/docker/certs.d/${HOSTNAME}/${HOSTNAME}.cert --registry-username=admin --registry-password=${HARBOR_PASSWORD}
imgpkg copy --tar /root/images/packages-1.5.0.tar --to-repo ${HOSTNAME}/tkg/tanzu-packages --registry-ca-cert-path=/etc/docker/certs.d/${HOSTNAME}/${HOSTNAME}.cert --registry-username=admin --registry-password=${HARBOR_PASSWORD}