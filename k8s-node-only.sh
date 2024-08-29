#!/bin/bash
#
# Script to install a single K8s node K8s. This pairs with https://raw.githubusercontent.com/RX-M/classfiles/master/k8s.sh used to setup control plane node.
#
# Usage:  $ curl https://raw.githubusercontent.com/RX-M/classfiles/master/k8s-node-ony.sh | sh
#
# Copyright (c) 2021-2024 RX-M LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e

# Defaults
DOCKER_VER="26.1.1"
K8S_VERSION="v1.30.2"
K8S_REPO="https://pkgs.k8s.io/core:/stable:/v1.30/deb"
WEAVE_VER="v2.8.1"
WEAVE_DS="weave-daemonset-k8s-1.11.yaml"
WEAVE_REPO="https://github.com/weaveworks/weave/releases/download"

# Install Docker
curl -fsSL https://get.docker.com -o /tmp/install-docker.sh && sh /tmp/install-docker.sh --version $DOCKER_VER

sudo mkdir -p /etc/docker
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

# Configure Docker's bundled containerd to enable cni & use systemd for cgroups
sudo cp /etc/containerd/config.toml /etc/containerd/config.bak
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i -e 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo sed -i -e 's/pause:3.6/pause:3.9/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Initialize a control plane node
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "${K8S_REPO}/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${K8S_REPO}/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo swapoff -a
if [ -z "${K8S_VERSION+x}" ]; then K8S_VERSION="stable-1"; fi

printf "Run this command on CP node - kubeadm token create --print-join-command - runs its output on worker node(s)"
