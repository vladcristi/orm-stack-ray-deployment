# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

provider "oci" {}

data "oci_core_images" "gpu_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.GPU.A10.1"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "launch_mode"
    values = ["NATIVE"]
  }
  filter {
    name = "display_name"
    values = ["\\w*GPU\\w*"]
    regex = true
  }
}

data "oci_core_images" "cpu_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E4.Flex"
  state                    = "AVAILABLE"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"

  filter {
    name   = "launch_mode"
    values = ["NATIVE"]
  }
}

data "cloudinit_config" "config_bastion" {
  gzip          = false
  base64_encode = true
  part {
    filename     = "cloudinit.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata/cloudinit_bastion.sh")
  }
}

data "cloudinit_config" "config_nodes" {
  gzip          = false
  base64_encode = true
  part {
    filename     = "cloudinit.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/userdata/cloudinit_ray_nodes.sh")
  }
}

resource "oci_core_instance" "bastion" {
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Oracle Java Management Service"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "OS Management Hub Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute RDMA GPU Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Auto-Configuration"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Authentication"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Cloud Guard Workload Protection"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		is_live_migration_preferred = "false"
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = var.ad
	compartment_id = var.compartment_ocid
	create_vnic_details {
		assign_ipv6ip = "false"
		assign_private_dns_record = "true"
		assign_public_ip = "true"
		subnet_id = var.create_network_components ? oci_core_subnet.pub_sub[0].id : var.public_subnet_id
	}
	display_name = var.bastion_display_name
	metadata = {
		ssh_authorized_keys = local.bundled_ssh_public_keys
		user_data_base64    = data.cloudinit_config.config_bastion.rendered
	}
	shape = "VM.Standard.E4.Flex"
    shape_config {
        memory_in_gbs = 16
        ocpus = 1
    }
	source_details {
		boot_volume_size_in_gbs = "250"
		boot_volume_vpus_per_gb = "10"
		source_id = data.oci_core_images.cpu_images.images[0].id
		source_type = "image"
	}
	
}

resource "oci_core_instance" "ray_nodes" {
    depends_on = [ oci_core_subnet.priv_sub ]
    count = var.no_ray_nodes
	agent_config {
		is_management_disabled = "false"
		is_monitoring_disabled = "false"
		plugins_config {
			desired_state = "DISABLED"
			name = "Vulnerability Scanning"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Oracle Java Management Service"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "OS Management Service Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "OS Management Hub Agent"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Management Agent"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Custom Logs Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute RDMA GPU Monitoring"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Run Command"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Compute Instance Monitoring"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Auto-Configuration"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Compute HPC RDMA Authentication"
		}
		plugins_config {
			desired_state = "ENABLED"
			name = "Cloud Guard Workload Protection"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Block Volume Management"
		}
		plugins_config {
			desired_state = "DISABLED"
			name = "Bastion"
		}
	}
	availability_config {
		is_live_migration_preferred = "false"
		recovery_action = "RESTORE_INSTANCE"
	}
	availability_domain = var.ad
	compartment_id = var.compartment_ocid
	create_vnic_details {
		assign_ipv6ip = "false"
		assign_private_dns_record = "true"
		assign_public_ip = count.index == 0 ? "true" : "false"
		subnet_id = count.index == 0 ? (var.create_network_components ? oci_core_subnet.pub_sub[0].id : var.public_subnet_id) : (var.create_network_components ? oci_core_subnet.priv_sub[0].id : var.private_subnet_id)
	}
	display_name = "${var.nodes_name_prefix}${count.index}"
	metadata = {
		ssh_authorized_keys = local.bundled_ssh_public_keys
		user_data           = data.cloudinit_config.config_nodes.rendered
	}
	shape = "VM.GPU.A10.1"
	source_details {
		boot_volume_size_in_gbs = "250"
		boot_volume_vpus_per_gb = "10"
		source_id = data.oci_core_images.gpu_images.images[0].id
		source_type = "image"
	}
	
}

resource "time_sleep" "wait_for_instance_to_be_available" {
  depends_on = [oci_core_instance.bastion, oci_core_instance.ray_nodes]

  create_duration = "20s"
}


resource "local_file" "id_rsa_file" {
    depends_on = [ time_sleep.wait_for_instance_to_be_available ]
    content  = tls_private_key.stack_key.private_key_openssh
    filename = "${path.module}/id_rsa"
    file_permission = "0600"
}

resource "null_resource" "scp_to_bastion" {
	depends_on = [ local_file.id_rsa_file ]
	provisioner "file" {
		source      = "${path.module}/userdata/cloudinit_bastion.sh"
		destination = "/home/opc/cloudinit_bastion.sh"
 	}

    provisioner "file" {
		source      = "${path.module}/userdata/cloudinit_ray_nodes.sh"
		destination = "/home/opc/cloudinit_ray_nodes.sh"
 	}

    provisioner "file" {
		source      = "${path.module}/userdata/serve_config.yaml"
		destination = "/home/opc/serve_config.yaml"
 	}

     provisioner "file" {
		source      = "${path.module}/userdata/test.ipynb"
		destination = "/home/opc/test.ipynb"
 	}

    provisioner "file" {
		source      = "${path.module}/id_rsa"
		destination = "/home/opc/.ssh/id_rsa"
 	}

    provisioner "remote-exec" {
        inline = ["chmod 600 /home/opc/.ssh/id_rsa"]     
    }

    connection {
		type    	= "ssh"
		user     	= "opc"
		private_key = tls_private_key.stack_key.private_key_openssh
		host    	= oci_core_instance.bastion.public_ip
        
	}
}

resource "null_resource" "config_ray_cluster_example" {
    depends_on = [null_resource.scp_to_bastion]

    connection {
		type    	= "ssh"
		user     	= "opc"
		private_key = tls_private_key.stack_key.private_key_openssh
		host    	= oci_core_instance.bastion.public_ip
        
	}

    provisioner "remote-exec" {
        inline = [ 
            "sh /home/opc/cloudinit_bastion.sh",
            "sed -i 's/YOUR_HEAD_NODE_HOSTNAME/${oci_core_instance.ray_nodes[0].private_ip}/g' /home/opc/example-full.yaml",
            "sed -i 's/YOUR_USERNAME/opc/g' /home/opc/example-full.yaml",
            "sed -i 's|# ssh_private_key: ~/.ssh/id_rsa|ssh_private_key: ~/.ssh/id_rsa|g' /home/opc/example-full.yaml",
            "sed -i 's/WORKER_NODE_1_HOSTNAME, WORKER_NODE_2_HOSTNAME, ... /${oci_core_instance.ray_nodes[1].private_ip}, ${oci_core_instance.ray_nodes[2].private_ip}/g' /home/opc/example-full.yaml",
            "sed -i 's/TYPICALLY_THE_NUMBER_OF_WORKER_IPS/${var.no_ray_nodes - 1}/g' /home/opc/example-full.yaml",
            "sed -i 's/ray start --head --port=6379/ray start --head --dashboard-host ${oci_core_instance.ray_nodes[0].private_ip} --port=6379/g' /home/opc/example-full.yaml",
            "sed -i 's|\\$RAY_HEAD_IP|${oci_core_instance.ray_nodes[0].private_ip}|g' /home/opc/example-full.yaml",
            "sed -i 's/HEAD_IP/${oci_core_instance.ray_nodes[0].private_ip}/g' /home/opc/test.ipynb"
        ]     
    }
}

resource "null_resource" "scp_to_raynodes" {
    depends_on = [null_resource.config_ray_cluster_example]
    count      = var.no_ray_nodes

    connection {
		type    	= "ssh"
		user     	= "opc"
		private_key = tls_private_key.stack_key.private_key_openssh
		host    	= oci_core_instance.bastion.public_ip
        
	}

    provisioner "remote-exec" {
        inline = [ 
            "scp -i /home/opc/.ssh/id_rsa -o StrictHostKeyChecking=no /home/opc/cloudinit_ray_nodes.sh opc@${oci_core_instance.ray_nodes[count.index].private_ip}:~/ ", 
            "ssh -i /home/opc/.ssh/id_rsa -o StrictHostKeyChecking=no opc@${oci_core_instance.ray_nodes[count.index].private_ip} \"sh /home/opc/cloudinit_ray_nodes.sh\""
        ]     
    }
    
}

resource "null_resource" "ray_up" {
    depends_on = [null_resource.scp_to_raynodes]

    connection {
		type    	= "ssh"
		user     	= "opc"
		private_key = tls_private_key.stack_key.private_key_openssh
		host    	= oci_core_instance.bastion.public_ip
        
	}

    provisioner "remote-exec" {
        inline = [ 
           "ray up /home/opc/example-full.yaml -y"
        ]     
    }
}

resource "time_sleep" "wait_for_ray_worker_nodes_to_become_alive_in_cluster" {
  depends_on = [null_resource.ray_up]

  create_duration = "20s"
}

resource "null_resource" "ray_serve_run" {
    depends_on = [ time_sleep.wait_for_ray_worker_nodes_to_become_alive_in_cluster ]

    connection {
		type    	= "ssh"
		user     	= "opc"
		private_key = tls_private_key.stack_key.private_key_openssh
		host    	= oci_core_instance.bastion.public_ip
        
	}

    provisioner "remote-exec" {
        inline = [ 
            "serve deploy serve_config.yaml -a http://${oci_core_instance.ray_nodes[0].private_ip}:8265"
        ]
    }
}
