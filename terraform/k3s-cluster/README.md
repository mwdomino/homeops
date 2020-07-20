## Terraform - k3s-cluster
This builds 3 VMs to supply a Kubernetes cluster.

|VM|ROLE|CPU|RAM|DISK|
|--|--|--|--|--|
|k8s1|master|2|2048|25gb|
|k8s2|worker|2|4096|50gb|
|k8s3|worker|2|4096|50gb|

#### Requirements
This requires a recent version of `terraform` installed on a supported OS (using a Macbook Pro for this build) and a vSphere Server with licensing that permits API access. This can be obtained through VMUG for $200/yr or through the normal VMWare channels. The ISO paths are hardcoded into the template, and variables are located in `variables.json`.

#### Variables
First make a copy of the example variables file: `cp terraform.tfvars.example terraform.tfvars`

Then edit `terraform.tfvars` to include your vSphere authentication details

#### Deploying 
`terraform apply`
