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

# Install cri-dockerd
VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4)
wget https://github.com/Mirantis/cri-dockerd/releases/download/${VER}/cri-dockerd-${VER}-linux-amd64.tar.gz
tar xvf cri-dockerd-${VER}-linux-amd64.tar.gz
sudo mv cri-dockerd /usr/local/bin/
sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/50c048cb54e52cd9058f044671e309e9fbda82e4/packaging/systemd/cri-docker.service
sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/50c048cb54e52cd9058f044671e309e9fbda82e4/packaging/systemd/cri-docker.socket
sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
sudo mkdir -p /etc/systemd/system/cri-docker.service.d/
cat <<EOF | sudo tee /etc/systemd/system/cri-docker.service.d/cni.conf
[Service]
ExecStart=
ExecStart=/usr/local/bin/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d
EOF
sudo systemctl daemon-reload
sudo systemctl enable cri-docker.service
sudo systemctl enable --now cri-docker.socket


# kubeadm, kubelet, and company
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

if [ -z ${K8S_VERSION+x} ]; then K8S_VERSION="--kubernetes-version=stable-1" ; else K8S_VERSION="--kubernetes-version=$K8S_VERSION"; fi

sudo apt-get install -y kubeadm
sudo swapoff -a

printf "To retrieve join command, run on control plane:\nkubeadm token create --print-join-command\n"
printf "Make sure to append to the end: \n--cri-socket=unix:///var/run/cri-dockerd.sock\n"
