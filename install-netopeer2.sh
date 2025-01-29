#!/bin/bash
#
# Script to install a Netopeer2 server on Ubuntu 22.04 LTS
#
# Usage:  $ curl https://raw.githubusercontent.com/RX-M/classfiles/master/install-netopeer2.sh | sh
#
# If the script fail for some reason to compile the Netopeer2 server, you can try to run the following commands manually:
# $ rm -rf ~/server
#
# This will wipe the entire compilation directory and you can start over by running it again. o
#

#
# Copyright (c) 2021-2025 RX-M LLC
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

set -e # Exit on error

# Update and install dependencies
echo "Install all Netopeer2 dependencies... using apt"
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y -o Dpkg::Options::="--force-confnew" git cmake build-essential bison flex \
	libpcre2-dev libpcre3-dev libev-dev libavl-dev \
	libprotobuf-c-dev protobuf-c-compiler swig python3-dev python3-pip lua5.4 pkg-config libpcre++-dev openssl libssl-dev \
	libcrypto++-dev zlib1g-dev libssh-dev libcurl4 libcurlpp-dev

# Create build directory
mkdir -p ~/server && cd ~/server

# Clone and install libyang
echo "Installing libyang from source..."
git clone https://github.com/CESNET/libyang.git
cd libyang && mkdir build && cd build
cmake .. && make -j$(nproc) && sudo make install
cd ~/server

# Clone and install sysrepo
echo "Installing sysrepo from source..."
git clone https://github.com/sysrepo/sysrepo.git
cd sysrepo && mkdir build && cd build
cmake .. && make -j$(nproc) && sudo make install
cd ~/server

# Clone and install libnetconf2
echo "Installing libnetconf2 from source..."
git clone https://github.com/CESNET/libnetconf2.git
cd libnetconf2 && mkdir build && cd build
cmake .. && make -j$(nproc) && sudo make install
cd ~/server

# Install additional dependencies
echo "Installing additional dependencies..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y -o Dpkg::Options::="--force-confnew" cmake build-essential libcmocka-dev libsystemd-dev uncrustify valgrind libsysrepo-dev

# Add library path to environment variables for Netopeer2 otherwise it will fail.
echo "Fixing Library paths for Netopeer2..."
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Clone and install Netopeer2
echo "Installing Netopeer2 from source..."
git clone https://github.com/CESNET/netopeer2.git
cd netopeer2 && mkdir build && cd build
cmake .. && make -j$(nproc) && sudo make install
cd ~/server

# Generate SSH keys for authentication
echo "Generating SSH keys for authentication to Netopeer2..."
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
pub_key=$(cat ~/.ssh/id_rsa.pub | awk '{print $2}')

# Create XML configuration for Netopeer2. We will use the $USER variable to set the username.
echo "Configuring Netopeer2 for SSH key authentication..."

cat <<EOF >user_ssh.xml
<netconf-server xmlns="urn:ietf:params:xml:ns:yang:ietf-netconf-server">
  <listen>
    <endpoints>
      <endpoint>
        <name>default-ssh</name>
        <ssh>
          <ssh-server-parameters>
            <client-authentication>
              <users>
                <user>
                  <name>${USER}</name>
                  <public-keys>
                    <inline-definition>
                      <public-key>
                        <name>${USER}</name>
                        <public-key-format xmlns:ct="urn:ietf:params:xml:ns:yang:ietf-crypto-types">ct:ssh-public-key-format</public-key-format>
                        <public-key>${pub_key}</public-key>
                      </public-key>
                    </inline-definition>
                  </public-keys>
                </user>
              </users>
            </client-authentication>
          </ssh-server-parameters>
        </ssh>
      </endpoint>
    </endpoints>
  </listen>
</netconf-server>
EOF

# Apply configuration to Netopeer2
echo "Applying NETCONF update configuration...\n"
sysrepocfg --edit=user_ssh.xml --format=xml --datastore=running --module=ietf-netconf-server

# Give user full permissions to be able to make changes
echo "Give user full access to netopeer2 server to be able to make changes..."
cat <<EOF >nacm-config.xml
<nacm xmlns="urn:ietf:params:xml:ns:yang:ietf-netconf-acm">
  <enable-nacm>true</enable-nacm>
  <read-default>permit</read-default>
  <write-default>permit</write-default>
  <exec-default>permit</exec-default>
  <groups>
    <group>
      <name>superuser</name>
      <user-name>${USER}</user-name>
    </group>
  </groups>
  <rule-list>
    <name>full-access</name>
    <group>superuser</group>
    <rule>
      <name>allow-everything</name>
      <module-name>*</module-name>
      <access-operations>*</access-operations>
      <action>permit</action>
    </rule>
  </rule-list>
</nacm>
EOF

# Apply config
echo "Applying full access configuration\n"
sudo sysrepocfg --import=nacm-config.xml --datastore=running --format=xml --module=ietf-netconf-acm

# Successful

echo "###########################################################################"
echo "#                                                                         #"
echo "# Installation successful. You can now start the Netopeer2 server         #"
echo "#                                                                         #"
echo "###########################################################################"

# Uncomment that if you want to Start Netopeer2 server
#echo "Starting Netopeer2 server..."
#sudo netopeer2-server -d -v3 -U
