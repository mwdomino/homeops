variable "vsphere_user" {}
variable "vsphere_password" {}
variable "vsphere_server" {}
provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "rdu1"
}

data "vsphere_datastore" "datastore" {
  name          = "1tb-ssd"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "VLAN300-Lab"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "centos7-base"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "k3s_vms" {
  for_each = var.k3s_hosts
  name             = each.value.hostname
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = each.value.cpu
  memory   = each.value.ram
  guest_id = data.vsphere_virtual_machine.template.guest_id

  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = each.value.disk_size
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

    extra_config = {
      "guestinfo.metadata"          = base64gzip(file("${path.module}/cloudinit/${each.value.metafile}"))
      "guestinfo.metadata.encoding" = "gzip+base64"
      "guestinfo.userdata"          = base64gzip(file("${path.module}/cloudinit/${each.value.userfile}"))
      "guestinfo.userdata.encoding" = "gzip+base64"
    }
}

variable "k3s_hosts" {
  type = map(object({
    hostname        = string
    cpu             = number
    ram             = number
    ip              = string
    metafile        = string
    userfile        = string
    disk_size       = number
  }))

  default = {
    "k3s1" = {
      hostname  = "k3s1"
      cpu       = 2
      ram       = 2048
      disk_size = 25
      ip        = "172.16.200.10"
      metafile  = "k3s1-meta.yaml"
      userfile  = "userdata.yaml"
    },
    "k3s2" = {
      hostname  = "k3s2"
      cpu       = 2
      ram       = 4096
      disk_size = 50
      ip        = "172.16.200.11"
      metafile  = "k3s2-meta.yaml"
      userfile  = "userdata.yaml"
    },
    "k3s3" = {
      hostname  = "k3s3"
      cpu       = 2
      ram       = 4096
      disk_size = 50
      ip        = "172.16.200.12"
      metafile  = "k3s3-meta.yaml"
      userfile  = "userdata.yaml"
    },
  }
}
