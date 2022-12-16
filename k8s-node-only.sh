#!/bin/bash

echo "Basic worker node setup"
echo "This script works in conjunction with https://github.com/RX-M/classfiles/blob/master/k8s.sh"

sudo apt-get update
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

# Configure Docker's bundled containerd to enable cni
sudo cp /etc/containerd/config.toml /etc/containerd/config.bak
sudo sed -i -e 's/disabled_plugins/#disabled_plugins/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Install crictl
CRICTL_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest|grep tag_name | cut -d '"' -f 4 | cut -b 2-)
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v$CRICTL_VERSION/crictl-v$CRICTL_VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-v$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-v$CRICTL_VERSION-linux-amd64.tar.gz
echo "runtime-endpoint: unix:///run/containerd/containerd.sock" | sudo tee /etc/crictl.yaml

# kubeadm, kubelet, and company
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

if [ -z ${K8S_VERSION+x} ]; then K8S_VERSION="--kubernetes-version=stable-1" ; else K8S_VERSION="--kubernetes-version=$K8S_VERSION"; fi

sudo apt-get install -y kubeadm
sudo swapoff -a

printf "To retrieve join command, run on control plane:\nkubeadm token create --print-join-command\n"
printf "Make sure to append to the end: \n--cri-socket=unix:///var/run/containerd/containerd.sock\n"
