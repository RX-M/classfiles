# Script to install a single node K8s cluster on an RX-M Lab VM
#
# N.B. The script turns off swap for the K8s control plane install but does
#      not disable swap permenantly. Please comment out any swap volumes in 
#      the /etc/fstab before rebooting the VM.
# 
#      This script will fail to run if the apt db is locked (wait 10 mins 
#      and retry or reboot and retry). 
#
#      Kubernetes single node clusters require a 4GB ram VM to run properly.
#
# Copyright (c) 2021 RX-M LLC
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
wget -qO- https://get.docker.com/ | sh
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubeadm
sudo swapoff -a
if [ -z ${K8S_VERSION+x} ]; then K8S_VERSION="--kubernetes-version=stable-1" ; else K8S_VERSION="--kubernetes-version=$K8S_VERSION"; fi
echo sudo kubeadm init $K8S_VERSION
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
kubectl taint node --all node-role.kubernetes.io/master-
