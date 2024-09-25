## Copyright © 2024, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


#!/bin/bash
echo "running cloudinit_bastion.sh script"

#Docker install
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf remove -y runc
sudo dnf install -y docker-ce --nobest
sudo systemctl enable docker.service
sudo dnf install -y nvidia-container-toolkit
sudo systemctl start docker.service
sudo usermod -aG docker $USER
# sudo yum update -y --nobest
# sudo yum install -y yum-utils
# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
# sudo yum update -y —-nobest
# sudo yum install docker-ce docker-ce-cli containerd.io -y
# sudo systemctl start docker
# sudo systemctl enable docker


#Ray install


sudo dnf -y install oraclelinux-developer-release-el8
sudo dnf module -y install python39
sudo alternatives --set python3 /usr/bin/python3.9
# sudo python3 -m pip install python3.9
# sudo update-alternatives --set python3 /usr/bin/python3.9
# sudo python3 -m pip install --upgrade pip
sudo python3 -m pip install -U urllib3 requests setuptools_scm multidict typing_extensions attrs yarl async_timeout idna_ssl aiosignal charset_normalizer
sudo python3 -m pip install "ray[default]"
sudo python3 -m pip install fastapi
sudo python3 -m pip install "ray[serve]"
sudo python3 -m pip install jupyter
sudo yum -y install telnet nmap

nohup jupyter notebook --ip=0.0.0.0 --port=8888 > /home/opc/jupyter.log 2>&1 &

sudo firewall-cmd --permanent --add-port=7860/tcp
sudo firewall-cmd --permanent --add-port=8888/tcp
sudo firewall-cmd --reload

# sudo yum remove python3-six -y
# sudo yum install python3-six -y 
# sudo yum install firewalld -y
# sudo systemctl start firewalld 
# sudo yum install python3-slip-dbus -y
# sudo python3 -m pip install jsonschema
# sudo python3 -m pip install -U idna
# sudo python3 -m pip install -U certifi

wget https://raw.githubusercontent.com/ray-project/ray/master/python/ray/autoscaler/local/example-full.yaml
