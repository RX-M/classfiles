These steps are meant to assist setup of local proxy settings for labs when proxy usage is enforced.

## General settings

ex. curl random.website.com

`export http_proxy=http://proxy.example.net:8080`

and: `export https_proxy=http://proxy.example.net:8080`

If `http_proxy(s)` is set with `export` (as above) as "user", must be done again after `sudo su -` (or append export to `/etc/profile`)


## Package installation

ex. `sudo apt-get install packageX`

In `/etc/apt/apt.conf`:

`Acquire::http::proxy "http://proxy.example.net:8080";`

`Acquire::https::proxy "http://proxy.example.net:8080";`


## Docker

Create directory for the proxy config file:

`sudo mkdir /etc/systemd/system/docker.service.d`

Edit proxy config file:

```
sudo vi /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://web-proxy.example.net:8080" "HTTPS_PROXY=http://web-proxy.example.net:8080"
```

Flush changes:

`sudo systemctl daemon-reload`

Restart docker:

`sudo systemctl restart docker`

See: http://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy


## Kubernetes

Setting for K8s service vips when deployed w/kubeadm (K8s Foundation classes):

`export no_proxy=10.96.0.0/12,<your VM IP>`


## Weave

For some students it appears the Weave installation in lab 2 of k8s foundation overlap with an existing setup.
Ex. "Network 10.32.0.0/12 overlaps with existing route 10.34.104.0/22 on host"

`kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&env.IPALLOC_RANGE=10.32.0.0/22"`
