#provider "libvirt" {
#  uri = "qemu:///system"
#}

provider "libvirt" {
#  alias = "srv04"
  uri   = "qemu+ssh://root@192.168.1.8/system"
}

resource "libvirt_volume" "centos7-qcow2" {
  name = "centos7.qcow2"
  pool = "default"
#  source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  source = "/tmp/packer-centos7.orig"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "test_host" {
  name   = "test_host"
  memory = "2048"
  vcpu   = 2

  network_interface {
    vepa = "bridge0"
  }

  disk {
    volume_id = libvirt_volume.centos7-qcow2.id
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
  }
}
