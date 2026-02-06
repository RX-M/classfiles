#!/bin/bash
#
# Script to install a single K8s node K8s. This pairs with:
# https://raw.githubusercontent.com/RX-M/classfiles/master/k8s.sh used to setup a control plane node.
#
# Usage:  $ curl https://raw.githubusercontent.com/RX-M/classfiles/master/k8s-node-ony.sh | sh
#
# N.B. The script turns off swap for the K8s control plane install but does not disable swap permanently.
#      Please comment out any swap volumes in the /etc/fstab before rebooting the VM.
#
#      This script will fail to run if the apt db is locked (wait 10 mins and retry or reboot and retry).
#
#      Kubernetes single node clusters require a 4GB ram VM to run properly.
#
# Copyright (c) 2021-2025 RX-M LLC
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

# Increase inotify limits
sudo sysctl fs.inotify.max_user_watches=5242880
sudo sysctl fs.inotify.max_user_instances=5120
echo "fs.inotify.max_user_watches=5242880" | sudo tee -a /etc/sysctl.conf
echo "fs.inotify.max_user_instances=5120" | sudo tee -a /etc/sysctl.conf
sudo systemctl restart systemd-sysctl
sysctl fs.inotify.max_user_watches fs.inotify.max_user_instances fs.inotify.max_queued_events

# Defaults
DOCKER_VERSION="${DOCKER_VERSION:-"29.1.3"}"
K8S_VERSION="${K8S_VERSION:-"v1.35.0"}"
K8S_REPO="https://pkgs.k8s.io/core:/stable:/${K8S_VERSION%.*}/deb"

# Install Docker
curl -fsSL https://get.docker.com -o /tmp/install-docker.sh && sh /tmp/install-docker.sh --version $DOCKER_VERSION

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
sudo sed -i -e 's/pause:3.8/pause:3.10.1/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Initialize the system as a Kubernetes node
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "${K8S_REPO}/Release.key" | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] ${K8S_REPO}/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo swapoff -a

printf "Run this command on CP node - kubeadm token create --print-join-command - and run its output on your worker node(s)"
