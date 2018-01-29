These steps are meant to assist setup of local proxy settings for labs when proxy usage is enforced.

## General settings

ex. curl http://random.website.com

`export http_proxy=http://proxy.example.net:8080`

and

`export https_proxy=http://proxy.example.net:8080`

To persist, either add previous commands to `/etc/profile` or use `sudo -E ...` to pass environment variables along.


## Package installation

ex. `sudo apt-get install packageX`

```
vi /etc/apt/apt.conf
Acquire::http::proxy "http://proxy.example.net:8080";
Acquire::https::proxy "http://proxy.example.net:8080";
```

## Docker

The following Docker configuration should be completed after installing Docker (in lab).

Create directory for the proxy config file:

`sudo mkdir /etc/systemd/system/docker.service.d`

Edit proxy config file:

```
sudo vi /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://web-proxy.example.net:8080" "HTTPS_PROXY=http://web-proxy.example.net:8080"
```

flush changes:

`sudo systemctl daemon-reload`

restart docker:

`sudo systemctl restart docker`

See: http://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy


## Kubernetes

The following Kubernetes configuration should be completed after install Kubernetes (in lab).

Setting for K8s service vips when deployed w/kubeadm (K8s Foundation classes):

`export no_proxy=10.96.0.0/12,<your VM IP>`

Retrieve your IP by reviewing `ip a s` (depending on host OS, the interface may be ens33, eth0, or something else)


## Weave

For some students it appears the Weave installation in lab 2 of k8s foundation overlap with an existing setup.
Ex. "Network 10.32.0.0/12 overlaps with existing route 10.34.104.0/22 on host"

`kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.32.0.0/22"`
