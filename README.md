# Harbor Appliance for Tanzu

This OVA contains Harbor and Tanzu packages for an air-gapped environment. The entire project is based on the amazing work by [William Lam](https://github.com/lamw/harbor-appliance).

The appliance is based on [Photon 4](https://github.com/vmware/photon/tree/master). You can customize the components in the final image. Have a look at the tanzu-bom.json file.

## Requirements

* MacOS or Linux Desktop
* vCenter Server or Standalone ESXi host 6.x or greater
* [VMware OVFTool](https://developer.vmware.com/web/tool/4.4.0/ovf)
* [Packer](https://www.packer.io/intro/getting-started/install.html)
* [govc](https://github.com/vmware/govmomi/tree/master/govc)
* [jq](https://github.com/stedolan/jq)

> `packer` builds the OVA on a remote ESXi host via the [`vmware-iso`](https://www.packer.io/docs/builders/vmware-iso.html) builder. This builder requires the SSH service running on the ESXi host, as well as `GuestIPHack` enabled via the command below.

```bash
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```

Step 1 - Clone the git repository

```bash
git clone https://github.com/devulrix/tanzu-harbor-appliance
```

Step 2 - Edit the `photon-builder.json` file to configure the vSphere endpoint for building the Harbor appliance

```json
{
  "builder_host": "192.168.30.10",
  "builder_host_username": "root",
  "builder_host_password": "VMware1!",
  "builder_host_datastore": "vsanDatastore",
  "builder_host_portgroup": "VM Network"
}
```

The `photon.json` file contains the variables for the vCenter configuration. You need to update these as well if you're using a vCenter and want to clean up the orphaned VM once the image was created.

```json
  "variables": {
    "photon_ovf_template": "photon.xml.template",
    "ovftool_deploy_vcenter": "vcenter.lab.uhtec.com",
    "ovftool_deploy_vcenter_username": "alana@lab.uhtec.com",
    "ovftool_deploy_vcenter_password": "VMware@UHTec22"
  }
```

**Note:** If you need to change the initial root password on the Harbor appliance, take a look at `photon-version.json` and `http/photon-kickstart.json`. When the OVA is produced, there is no default password, so this does not really matter other than for debugging purposes.

Setp 3 - Update the `tanzu-harbor-bom.json` file. It contains everything that is put into the ova. For details see the [Configuration Section](#configuration)

Step 4 - Start the build by running the build script which simply calls Packer and the respective build files

```bash
./build.sh
````

If the build was successful, you will find the Harbor OVA located in `output-harbor-iso/Tanzu_Harbor_Appliance-VERSION.ova`

## Configuration

The entire contents of the appliance can be configured via the `tanzu-harbor-bom.json` file.

```json
"harbor": {
        "version": "2.4.1",
        "trivy": true,
        "notary": true,
        "chartmuseum": false,
        "projects": [
            {
                "name": "tkg",
                "public": true
            },
            {
                "name": "tac",
                "public": true
            }
        ]
    },
```

You can specify the harbor version as well as the projects that you need during setup. If you enable trivy support it will download the latest CVE database during the creation of the OVA and use it.

If you need more containers just add them to the container array with the `tag` and `destination` make sure you created the project in the harbor section above.

```json
"containers": [
        {
            "image": "projects.registry.vmware.com/tkg/kapp-controller",
            "tag": "v0.25.0_vmware.1",
            "destination": "tkg"
        }
    ]
```

For the Tanzu Application Catalog (TAC) you can specifiy which helm charts to sync as well.

```json
 "tac": {
        "version": "latest",
        "target": "tac",
        "charts": [
            {
                "name": "wordpress"
            }
```

To integrate the Tanzu Kubernetes releases you need to specify the name of the relase. The install scrip will automatically pick up the OVA.

```json
"tkr": [
        {
            "name": "v1.21.6---vmware.1-tkg.1.b3d708a"
        },
```

If you want to integrate the carvel packages as well you need to add them to the bundels section. Make sure the `destination` project exists in the harbor configuration above.

```json
"bundles": [
        {
            "source": "projects.registry.vmware.com/tkg/packages/standard/repo:v1.4.0",
            "destination": "tkg/tanzu-packages"
        },
```

## Use Appliance

Once the application is up and running you can use it. All repositories have been created and all images and helm charts have been put into the projects. If you log into the appliance you can use all the carvel tools as well as the tanzu cli.

### TKR content library

If you haven’t changed the `tanzu-harbor-bom.json` file, you’ll have the latest 3 TKR release for TKGs in your OVA. To create the content library, use the `tanzu-cl.sh` command:

```bash

tanzu-cl.sh [ -v VCENTER URL ] [-u USER ] [-p PASSWORD ] [-l CONTENT_LIBRARY_NAME ] [-c CREATE CONTENT_LIBRARY ] [-d CONTENT_LIBRARY DATASTORE]

```

This will automatically create the content library and import the TKR OVA files. 

### Certifcate handling

The appliance generates a self-signed certificate during setup with the hostname you provided during ova deployment. The certificate is stored in the appliance under **/etc/docker/certs.d/[HARBOR-FQDN]/ca.crt** and can be copyied via scp to your local machine. Alternatively, you can download the certificate directly from your browser if you go the Harbor Web UI.

### Deploy Tanzu Cluster

You need to create a Tanzu Kubernetes Cluster that trusts our Harbor appliance. We’re using self-signed certificates, so we must embed this certificate in the cluster configuration. Below, find a Tanzu Cluster deployment example for vSphere with Tanzu. Please adjust to your needs. You need to encode the certificate in base64 before you put it into the cluster configuration.

```yaml {linenos=table,hl_lines=[25,26,27,28],linenostart=1}
 kind: TanzuKubernetesCluster
 metadata:
   name: simple-cluster
   namespace: tkc-test
 spec:
   topology:
     controlPlane:
       replicas: 1
       vmClass: best-effort-xsmall
       storageClass: tanzu-storage
       tkr:
         reference:
           name: v1.21.2---vmware.1-tkg.1.ee25d55
     nodePools:
     - name: workerpool-1
       replicas: 3
       vmClass: best-effort-medium
       storageClass: tanzu-storage
       tkr:
         reference:
           name: v1.21.2---vmware.1-tkg.1.ee25d55
   settings:
     storage:
       defaultClass: tanzu-storage
    trust:
        additionalTrustedCAs:
          - name: HarborAppliance
            data: LS0tLS1C...LS0tCg==
```
