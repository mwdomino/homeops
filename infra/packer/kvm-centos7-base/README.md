## Packer Template - centos7-base

This template builds a CentOS 7 VM with some basic dependencies needed to build the rest of the lab's virtual infrastructure. This VM serves as the base to the rest of the instances we will build.

|VM| Specs |
|--|--|
| CPU | 2 cores |
| RAM | 4gb |
| Disk | 25gb |
| Image | CentOS7.2003 DVD Installer |

#### Interesting Packages Included
* `cloud-init` - allows reconfiguration of instances as they are cloned from this template using metadata/userdata files as specified from https://cloudinit.readthedocs.io/en/latest/
* `cloud-init-growpart` - resizes disks on first boot, enables cloning of VMs with custom disk sizes, as long as they are larger than the default
* `iscsi-initiator-utils` - required by https://github.com/longhorn/longhorn to provision k8s PVCs and other persistent storage
* VMWare cloud-init datastore - adds the ability to pass cloud-init data to vSphere VMs using `terraform` https://github.com/vmware/cloud-init-vmware-guestinfo

#### Requirements
This requires a recent version of `packer` installed on a supported OS (using a Macbook Pro for this build) and a vSphere Server with licensing that permits API access. This can be obtained through VMUG for $200/yr or through the normal VMWare channels. The ISO paths are hardcoded into the template, and variables are located in `variables.json`.

#### Variables
First make a copy of the example variables file: `cp variables.json.example variables.json`

Then edit `variables.json` to include your vSphere authentication details

#### Building

And edit the file to include your vSphere authentication details

`packer build -var-file=variables.json centos7-base`
