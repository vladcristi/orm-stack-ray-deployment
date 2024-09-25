# Copyright (c) 2024 Oracle Corporation and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_core_vcn" "vcn" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid

    cidr_block = var.vcn_cidr_block
    display_name = "vcn"
}

resource "oci_core_internet_gateway" "igw" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Internet Gateway"
}

resource "oci_core_nat_gateway" "ngw" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Nat Gateway"
}

resource "oci_core_route_table" "pub_rt" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Public Route Table"
    route_rules {
        network_entity_id = oci_core_internet_gateway.igw[0].id
        destination =  "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_route_table" "priv_rt" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Private Route Table"
    route_rules {
        network_entity_id = oci_core_nat_gateway.ngw[0].id
        destination = "0.0.0.0/0"
        destination_type = "CIDR_BLOCK"
    }
}

resource "oci_core_subnet" "pub_sub" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    cidr_block = var.pubsub_cidr_block
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Public Subnet"
    prohibit_public_ip_on_vnic = false
    route_table_id = oci_core_route_table.pub_rt[0].id
    security_list_ids = [oci_core_security_list.pub_sl[0].id]
}

resource "oci_core_subnet" "priv_sub" {
    count          = var.create_network_components ? 1:0
    cidr_block = var.privsub_cidr_block
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Private Subnet"
    prohibit_public_ip_on_vnic = true
    route_table_id = oci_core_route_table.priv_rt[0].id
    security_list_ids = [oci_core_security_list.priv_sl[0].id]
}

resource "oci_core_security_list" "pub_sl" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id

    display_name = "Public Security List"

    egress_security_rules {
        destination = "0.0.0.0/0"
        protocol = "all"
    }

    ingress_security_rules {
        source = "0.0.0.0/0"
        protocol = "all"
    }
}

resource "oci_core_security_list" "priv_sl" {
    count          = var.create_network_components ? 1:0
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_vcn.vcn[0].id
    display_name = "Private Security List"

    egress_security_rules {
        destination = "0.0.0.0/0"
        protocol = "all"
    }

    ingress_security_rules {
        source = "10.0.0.0/16"
        protocol = "all"
    }
}