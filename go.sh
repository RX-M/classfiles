wget https://golang.org/dl/go1.16.linux-amd64.tar.gz							
tar zxf go1.16.linux-amd64.tar.gz							
sudo mv ~/go/ /usr/local/							
echo "export PATH=/usr/local/go/bin:$PATH" >> .bashrc							
echo "[[ -r ~/.bashrc ]] && . ~/.bashrc" >> ~/.bash_profile							
source ~/.bash_profile							