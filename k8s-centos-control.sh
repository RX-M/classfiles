#!/bin/sh

# Script to install a single node K8s cluster on a Rocky 8 AWS Instance
#
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

# Show all commands and exit on error
set -xe


# Install and start containerd
sudo yum install -y container-selinux
sudo yum install -y https://download.docker.com/linux/centos/8/x86_64/stable/Packages/containerd.io-1.6.18-3.1.el8.x86_64.rpm
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl enable containerd && sudo systemctl start containerd


# Put SELinux in permissive mode
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


# Set up the Kernel Modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter


# Set up the sysctl modules
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system


# Set up packages
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.29/rpm/repodata/repomd.xml.key
EOF


# Install kubeadm
sudo yum install -y kubelet kubeadm kubectl  nfs-utils iscsi-initiator-utils


# Ensure Kubelet starts up on restart
sudo systemctl enable kubelet


# Initialize the cluster
sudo kubeadm init


# Set up local Kubectl and untaint the control plane node
mkdir -p "$HOME"/.kube
sudo cp -i /etc/kubernetes/admin.conf "$HOME"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
kubectl patch node $(hostname) -p '{"spec":{"taints":[]}}'

kubectl apply -f https://raw.githubusercontent.com/weaveworks/weave/2.8/prog/weave-kube/weave-daemonset-k8s-1.11.yaml
