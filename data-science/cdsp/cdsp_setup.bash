#!/bin/bash
#
# CDSP Lab Machine Setup
# Tested on AWS t3.medium / 50GB disk / Ubuntu 24.04


echo '>>>> -----------------------------------------------'
echo '>>>> Configuring and starting CDSP Jupyter Server'
echo '>>>> ... this will take 4-5 minutes'
echo '>>>> -----------------------------------------------'


echo '>>>> Installing needed system packages and fonts'
echo '>>>> -----------------------------------------------'
sudo apt update && sudo apt install -y python3-pip unzip
echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends ttf-mscorefonts-installer


echo '>>>> -----------------------------------------------'
echo '>>>> Installing CDSP Python requirements'
echo '>>>> -----------------------------------------------'
sudo mkdir -p /home/student
sudo chown ubuntu:ubuntu /home/student
cd /home/student
wget -q https://raw.githubusercontent.com/RX-M/classfiles/master/data-science/cdsp/requirements.txt -O requirements.txt
pip3 install -r requirements.txt --break-system-packages --no-warn-script-location
source ~/.profile     # updates the PATH


echo '>>>> -----------------------------------------------'
echo '>>>> Installing spacy_data'
echo '>>>> -----------------------------------------------'
# original file: https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl
wget -q https://github.com/RX-M/classfiles/raw/master/data-science/cdsp/en_core_web_sm-3.7.1-py3-none-any.whl -O en_core_web_sm-3.7.1-py3-none-any.whl
if [ -d spacy_data ]; then
  rm -rf spacy_data
fi
unzip en_core_web_sm-3.7.1-py3-none-any.whl -d spacy_data


echo '>>>> -----------------------------------------------'
echo '>>>> Installing nltk_data'
echo '>>>> -----------------------------------------------'
if [ -d /home/ubuntu/nltk_data ]; then
  rm -rf /home/ubuntu/nltk_data
fi
python3 -c 'import nltk; nltk.download("punkt_tab", download_dir = "/home/ubuntu/nltk_data")'


echo '>>>> -----------------------------------------------'
echo '>>>> Installing class files'
echo '>>>> -----------------------------------------------'
wget -q https://github.com/RX-M/classfiles/raw/master/data-science/cdsp/CDSP.zip -O CDSP.zip
if [ -d CDSP ]; then
  rm -rf CDSP
fi
unzip CDSP.zip
sed -i 's/affinity/metric/g' /home/student/CDSP/Clustering/Solutions/*.ipynb                   # Move from sklearn 1.2 to 1.5
sed -i 's/app.run(/app.run(host=\\"0.0.0.0\\"/g' /home/student/CDSP/Web*/Demonstrating*.ipynb  # All interfaces for remote access


echo '>>>> -----------------------------------------------'
echo '>>>> Installing Jupyter cert/key/password'
echo '>>>> -----------------------------------------------'
# n.b. `jupyter server password` generates a new pwd in jupyter_server_config.json
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=US/ST=Florida/L=Miami/O=RX-M/OU=Training/CN=rx-m.com"
mkdir -p ~/.jupyter
wget -q https://raw.githubusercontent.com/RX-M/classfiles/master/data-science/cdsp/jupyter_server_config.json -O ~/.jupyter/jupyter_server_config.json


echo '>>>> -----------------------------------------------'
echo '>>>> Starting Jupyter Server'
echo '>>>> -----------------------------------------------'
echo Jupyter URL: https://`curl -s http://checkip.amazonaws.com`:8080/
echo Password is: rx-m2024
echo
jupyter notebook --no-browser --port=8080 --ip=0.0.0.0 --certfile=cert.pem --keyfile=key.pem