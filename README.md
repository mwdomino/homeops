## homeops - Infrastructure as Code for the home
This repo contains everything needed to bootstrap a vSphere cluster for homelab usage. Over time each of these steps will be automated with a configuration management tool. For now, follow the below steps to deploy.

#### Install ESXi on each host
Normal install with a USB drive

#### Install VCSA
Download and install the VCSA (vSphere Server Appliance) on a Windows 10 computer/VM and deploy it on node `srv04`. Once installed, perform initial datastore/cluster setup and add remaining servers to the cluster.

#### Build Packer image (centos7-base)
This step builds the `packer` image that will be used as a base for the Kubernetes cluster. Before building this image, download the CentOS7.2003 installer ISO to the cluster datastore at `[1tb-ssd] centos7.2003-minimal.iso`. Specific instructions to build are included at `packer/centos7-base/README.md`

#### Deploy VMs and provision cluster with Ansible
This command will use `terraform` to deploy the VMs and then configure the k3s cluster with `ansible`. More details in the `ansible/`folder of this repo.

Just go to the `infra/` folder and run:
```
ansible-playbook -i ansible/inventory/k3s-cluster/hosts.ini ansible/site.yml
```

##### Edgerouter Config
```
configure
set protocols bgp 64513 parameters router-id 172.16.200.1
set protocols bgp 64513 neighbor 172.16.200.10 remote-as 64514
set protocols bgp 64513 neighbor 172.16.200.10 ebgp-multihop 255
set protocols bgp 64513 neighbor 172.16.200.10 soft-reconfiguration inbound
set protocols bgp 64513 neighbor 172.16.200.11 remote-as 64514
set protocols bgp 64513 neighbor 172.16.200.11 ebgp-multihop 255
set protocols bgp 64513 neighbor 172.16.200.11 soft-reconfiguration inbound
set protocols bgp 64513 neighbor 172.16.200.12 remote-as 64514
set protocols bgp 64513 neighbor 172.16.200.12 ebgp-multihop 255
set protocols bgp 64513 neighbor 172.16.200.12 soft-reconfiguration inbound
```

### Done!
Once the above steps are complete you are ready to begin deploying apps to this cluster using `kubectl`. The apps will be added to this repo in the future, but expect to see:

* Radarr - TV Episode Search/Manager
* Sonarr - movie Search/Manager
* SabNZB - usenet file download
* Plex - media server for external clients
* Jellyfin - media server for internal clients
* Bitwarden - password manager
* Heimdall - dashboard for services
* Grafana - graphs for all the things
* code-server - VSCode server to manage cluster files on the go
* ELK stack - for logging
