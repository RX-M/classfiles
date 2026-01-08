#!/bin/bash
#
# Script to install a single node K8s cluster on an RX-M Lab VM
#
# Usage:  $ curl https://raw.githubusercontent.com/RX-M/classfiles/master/k8s-no-cni.sh | sh
#
# N.B. The script turns off swap for the K8s control plane install but does not disable swap permanently.
#      Please comment out any swap volumes in the /etc/fstab before rebooting the VM.
#
#      This script will fail to run if the apt db is locked (wait 10 mins and retry or reboot and retry).
#
#      Kubernetes single node clusters require a 4GB ram VM to run properly.
#
# Copyright (c) 2026 RX-M LLC
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
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
echo "sysctl fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
echo "sysctl fs.inotify.max_user_instances=512" | sudo tee -a /etc/sysctl.conf

# Defaults
DOCKER_VERSION="${DOCKER_VERSION:-"29.1.3"}"
K8S_VERSION="${K8S_VERSION:-"v1.35.0"}"
K8S_REPO="https://pkgs.k8s.io/core:/stable:/${K8S_VERSION%.*}/deb"

# Install Docker
if command -v docker >/dev/null 2>&1; then
    echo "Docker is already installed, skipping Docker installation"
else
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
fi

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

# e.g. to set K8s version `export K8S_VERSION=v1.35.0 && bash -x k8s.sh`
# Install the Kubernetes control plane
sudo kubeadm init --cri-socket=unix:///var/run/containerd/containerd.sock --kubernetes-version="${K8S_VERSION}"
mkdir -p "${HOME}/.kube"
sudo cp -i /etc/kubernetes/admin.conf "${HOME}/.kube/config"
sudo chown "$(id -u):$(id -g)" "${HOME}/.kube/config"

# Untaint the control plane node so that normal pods can run
kubectl patch node "$(hostname)" -p '{"spec":{"taints":[]}}'

# Install the latest crictl (cni-tools package is not always the latest)
crictl_ver=$(curl -s https://api.github.com/repos/kubernetes-sigs/cri-tools/releases/latest | grep tag_name | cut -d '"' -f 4 | cut -b 2-)
wget "https://github.com/kubernetes-sigs/cri-tools/releases/download/v${crictl_ver}/crictl-v${crictl_ver}-linux-amd64.tar.gz"
sudo tar zxvf "crictl-v${crictl_ver}-linux-amd64.tar.gz" -C /usr/local/bin
rm -f "crictl-v${crictl_ver}-linux-amd64.tar.gz"
echo "runtime-endpoint: unix:///run/containerd/containerd.sock" | sudo tee /etc/crictl.yaml

# Scale CoreDNS down to 1 pod
kubectl scale deployment.apps/coredns --replicas=1 -n kube-system

# Add kubectl command completion
echo "source <(kubectl completion bash)" >> ~/.bashrc
