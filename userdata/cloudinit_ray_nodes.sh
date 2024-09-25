## Copyright © 2024, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


#!/bin/bash
echo "running cloudinit_ray_nodes.sh script"

#Make sure you have all the size of partition available
sudo /usr/libexec/oci-growfs -y

#Docker install
sudo yum update -y --nobest
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum update -y —-nobest
sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

docker pull rayproject/ray:latest-gpu


sudo firewall-cmd --zone=trusted --permanent --add-source=10.0.0.0/16
sudo firewall-cmd --permanent --add-port=8265/tcp
sudo firewall-cmd --permanent --add-port=6379/tcp
sudo firewall-cmd --permanent --add-port=8000/tcp
sudo firewall-cmd --reload