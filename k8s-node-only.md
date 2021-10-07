#!/bin/bash

echo "Basic worker node setup"
echo "This script works in conjunction with https://github.com/RX-M/classfiles/blob/master/k8s.sh"

sudo apt-get update
sudo apt-get install -y kubeadm
wget -qO- https://get.docker.com/ | sh

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm
sudo swapoff -a

echo "Run on control plane to retrieve join command: kubeadm token create --print-join-command"
