#!/bin/bash

# To install go: $ curl https://raw.githubusercontent.com/RX-M/classfiles/master/go.sh | sh
wget https://go.dev/dl/go1.20.2.linux-amd64.tar.gz
tar zxf go1.20.2.linux-amd64.tar.gz
sudo mv ./go/ /usr/local/							
echo "export PATH=/usr/local/go/bin:$PATH" >> ~/.bashrc							
echo "[[ -r ~/.bashrc ]] && . ~/.bashrc" >> ~/.bash_profile							
. ~/.bash_profile							
go version
