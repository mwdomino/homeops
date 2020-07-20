## homeops - Infrastructure as Code for the home
This repo contains everything needed to bootstrap a vSphere cluster for homelab usage. Over time each of these steps will be automated with a configuration management tool. For now, follow the below steps to deploy.

#### Install ESXi on each host
Normal install with a USB drive

#### Install VCSA
Download and install the VCSA (vSphere Server Appliance) on a Windows 10 computer/VM and deploy it on node `srv04`. Once installed, perform initial datastore/cluster setup and add remaining servers to the cluster.

#### Build Packer image (centos7-base)
This step builds the `packer` image that will be used as a base for the Kubernetes cluster. Before building this image, download the CentOS7.2003 installer ISO to the cluster datastore at `[1tb-ssd] centos7.2003-minimal.iso`. Specific instructions to build are included at `packer/centos7-base/README.md`

#### Deploy VMs with Terraform
This step deploys the VMs to the vSphere cluster using `terraform`. More detailed instructions are located within the `terraform/k3s-cluster/README.md`file.

#### Bootstrap cluster with Ansible
The Ansible playbook is a modification of https://github.com/rancher/k3s-ansible. Simply enter the `ansible` folder and run `ansible-playbook site.yml -i inventory/k3s-cluster/hosts.ini`

Once Ansible has provisioned your cluster, copy the `~/.kube/config` file to your local box for the `kubectl` commands to follow. This can be done with SCP as `scp root@172.16.200.10:~/.kube/config ~/.kube/config`

#### Configure MetalLB
MetalLB peers BGP with an EdgeRouter Lite to advertise `LoadBalancer` type IPs from Kubernetes services. You'll need to configure both the router and the cluster to accept this peering. The EdgeRouter will use BGP ASN 64513 and the MetalLB speakers will use ASN 64514

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
##### K8s Config
Install MetalLB
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```

And then apply our BGP configuration:

``` sh
kubectl apply -f k3s/metallb-config.yml`
```


#### Install Longhorn
Longhorn is a distributed storage backend for Kubernetes that provides tools to make persistent storage easy while avoiding the locking pitfalls of NFS. 

Install Longhorn
``` sh
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml
```


Patch Longhorn to use a LoadBalancer
``` sh
kubectl -n longhorn-system patch svc longhorn-frontend --patch "$(cat k3s/longhorn-service-patch.yaml)"
```


Patch the Longhorn StorageClass to use 2 replicas, as we only have 3 hosts.
``` sh
kc replace -f k3s/longhorn-sc-patch.yaml --force
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
