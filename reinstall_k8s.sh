set -e

# If you are looking to install k8s the first time use
# https://github.com/RX-M/classfiles/blob/master/k8s.sh

# REINSTALL specific version (this is not upgrade so be careful)
# Assumes correct versions of software (Docker, Kubelet, Kubeadm, Kubectl) are already installed.

sudo kubeadm reset -f
sudo systemctl stop docker.service
# leave /opt/cni due to portmap - installed via kubernetes-cni
sudo rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes ~/.kube/*
sudo iptables -F && sudo iptables -X
sudo iptables -t nat -F && sudo iptables -t nat -X
sudo iptables -t raw -F && sudo iptables -t raw -X
sudo iptables -t mangle -F && sudo iptables -t mangle -X
sudo systemctl start docker.service

# if downgrading kubeadm itself remove following comment
# sudo apt remove kubeadm conntrack cri-tools kubectl kubelet kubernetes-cni socat

# now start over (install kubeadm version if it was removed, then init; otherwise just init)

if [ -z ${K8S_VERSION+x} ]; then K8S_VERSION="--kubernetes-version=v1.20.2" ; else K8S_VERSION="--kubernetes-version=$K8S_VERSION"; fi
sudo kubeadm init $K8S_VERSION
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl taint node --all node-role.kubernetes.io/master-
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
