# K8s Setup Instructions for RX-M Lab VM

You can run this as a script if you like:
`$ wget -O- https://raw.githubusercontent.com/RX-M/classfiles/master/k8s.sh | sh`

Quick and dirty installation of Docker and Kubernetes on an RX-M lab VM.

```
$ wget -qO- https://get.docker.com/ | sh

...

$ VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4 | cut -b 2-)

$ wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz

$ tar xvf cri-dockerd-${VER}-linux-amd64.tar.gz

...

$ sudo mv cri-dockerd /usr/bin/

$ sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/50c048cb54e52cd9058f044671e309e9fbda82e4/packaging/systemd/cri-docker.service

$ sudo wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/50c048cb54e52cd9058f044671e309e9fbda82e4/packaging/systemd/cri-docker.socket

$ sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/

$ sudo mkdir -p /etc/systemd/system/cri-docker.service.d/

$ cat <<EOF | sudo tee /etc/systemd/system/cri-docker.service.d/cni.conf
[Service]
ExecStart=
ExecStart=/usr/bin/cri-dockerd/cri-dockerd --container-runtime-endpoint fd:// --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d
EOF

...

$ sudo systemctl daemon-reload

$ sudo systemctl enable cri-docker.service

$ sudo systemctl enable --now cri-docker.socket

$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

OK

$ echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

deb http://apt.kubernetes.io/ kubernetes-xenial main

$ sudo apt-get update

...

$ sudo apt-get install -y kubeadm 

...

$ sudo kubeadm init --cri-socket=unix:///run/cri-dockerd.sock

...

$ mkdir -p $HOME/.kube

$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

$ kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml

...

$ kubectl taint node --all node-role.kubernetes.io/master- node-role.kubernetes.io/control-plane-

node/<hostname> untainted

$
```
