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

**Note:** If you need to change the initial root password on the Harbor appliance, take a look at `photon-version.json` and `http/photon-kickstart.json`. When the OVA is produced, there is no default password, so this does not really matter other than for debugging purposes.

Step 3 - Start the build by running the build script which simply calls Packer and the respective build files

```bash
./build.sh
````

If the build was successful, you will find the Harbor OVA located in `output-harbor-iso/Tanzu_Harbor_Appliance-VERSION.ova`
