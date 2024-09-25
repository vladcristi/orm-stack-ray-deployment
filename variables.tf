## Copyright (c) 2024, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
    required_providers {
        oci = {
            source  = "oracle/oci"
            version = ">= 5.10.0"
        }
    }
    required_version = "= 1.2.9"
}

variable "compartment_ocid" {}
 
variable vcn_id {
    type = string
    default = ""
}

variable  public_subnet_id {
    type = string
    default = ""
}

variable  private_subnet_id {
    type = string
    default = ""
}

variable bastion_display_name {
    type = string
    default = "bastion"
}

variable nodes_name_prefix {
    type = string
    default = "A10-"
}

variable no_ray_nodes {
    type = number
    default = 3
}

variable ssh_public_key {
    type = string
    default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEWqxhVnQD/VtbOBTO3ofNhQk3z9v1rxa+Fnra2wv6Hy gvlad@gvlad-mac"
}

variable ad {
    type = string
    default = ""
}


#Network

variable create_network_components {
    type = bool
    default = false
}

variable vcn_cidr_block {
    type = string
    default = "10.0.0.0/16"
}

variable pubsub_cidr_block {
    type = string
    default = "10.0.0.0/24"
}

variable privsub_cidr_block {
    type = string
    default = "10.0.1.0/24"
}