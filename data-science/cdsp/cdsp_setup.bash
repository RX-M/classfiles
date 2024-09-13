#!/bin/bash
#
# CDSP Lab Machine Setup
# Tested on AWS t3.medium / 50GB disk / Ubuntu 24.04


echo '>>>> Configuring and starting CDSP Jupyter Server'
echo '>>>> ... this will take a minute or two'
echo '>>>> -----------------------------------------------'


echo '>>>> Installing needed system packages'
echo '>>>> -----------------------------------------------'
sudo apt update && sudo apt install -y python3-pip unzip


echo '>>>> Installing CDSP Python requirements'
echo '>>>> -----------------------------------------------'
mkdir -p ~/cdsp && cd $_
wget -q https://raw.githubusercontent.com/RX-M/classfiles/master/data-science/cdsp/requirements.txt -O requirements.txt
pip3 install -r requirements.txt --break-system-packages
source ~/.profile     # updates the PATH


echo '>>>> Installing spacy_data'
echo '>>>> -----------------------------------------------'
# original file: https://github.com/explosion/spacy-models/releases/download/en_core_web_sm-3.7.1/en_core_web_sm-3.7.1-py3-none-any.whl
wget -q https://github.com/RX-M/classfiles/raw/master/data-science/cdsp/en_core_web_sm-3.7.1-py3-none-any.whl -O en_core_web_sm-3.7.1-py3-none-any.whl
if [ -d spacy_data ]; then
  rm -rf spacy_data
fi
unzip en_core_web_sm-3.7.1-py3-none-any.whl -d spacy_data


echo '>>>> Installing nltk_data'
echo '>>>> -----------------------------------------------'
if [ -d nltk_data ]; then
  rm -rf nltk_data
fi
python3 -c 'import nltk; nltk.download("punkt", download_dir = "nltk_data")'


echo '>>>> Installing Jupyter cert/key/password'
echo '>>>> -----------------------------------------------'
# n.b. `jupyter server password` generates a new pwd in jupyter_server_config.json
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/C=US/ST=Florida/L=Miami/O=RX-M/OU=Training/CN=rx-m.com"
mkdir -p ~/.jupyter
wget -q https://raw.githubusercontent.com/RX-M/classfiles/master/data-science/cdsp/jupyter_server_config.json -O ~/.jupyter/jupyter_server_config.json

echo Jupyter URL: https://`curl -s http://checkip.amazonaws.com`:8080/
echo Password is: rx-m2024
echo
jupyter notebook --no-browser --port=8080 --ip=0.0.0.0 --certfile=cert.pem --keyfile=key.pem