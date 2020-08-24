# K8s Setup Instructions for RX-M Lab VM

You can run this as a script if you like:
`$ wget -O- https://raw.githubusercontent.com/RX-M/classfiles/master/k8s.sh | sh`

Quick and dirty installation of Docker and Kubernetes on an RX-M lab VM.

```
$ wget -qO- https://get.docker.com/ | sh

...

$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

OK

$ echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list

deb http://apt.kubernetes.io/ kubernetes-xenial main

$ sudo apt-get update

...

$ sudo apt-get install -y kubeadm

...

$ sudo kubeadm init

...

$ mkdir -p $HOME/.kube

$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

$ kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

...

$ kubectl taint node --all node-role.kubernetes.io/master-


node/<hostname> untainted

$
```
