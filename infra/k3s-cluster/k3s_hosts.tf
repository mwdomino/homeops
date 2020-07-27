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
