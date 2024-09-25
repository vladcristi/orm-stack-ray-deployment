# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "bastion_ip" {
    value = oci_core_instance.bastion.public_ip
}

output "ray_nodes_ips" {
    value = [oci_core_instance.ray_nodes[*].private_ip ]
}