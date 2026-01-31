#!/bin/bash
#
# Script to create a dummy CA and sign a client certificate for testing TLS ingress in K8s.
#
# Usage:  $ curl https://raw.githubusercontent.com/RX-M/classfiles/master/bootcamp-drills/create-tls-files.sh | sh
#
# Copyright (c) 2026 RX-M LLC
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

set -e

# Create working directory
mkdir -p /home/ubuntu/ing-tls && cd /home/ubuntu/ing-tls

# Create a dummy CA
openssl rand -out ~/.rnd -writerand ~/.rnd
openssl genrsa -out app-ca-key.pem 2048
openssl req -x509 -new -nodes -key app-ca-key.pem -days 10000 -out app-ca.pem -subj "/CN=www.example.com" -addext "subjectAltName = DNS:www.example.com"

# Client certificate
openssl genrsa -out web-app.key 2048
openssl req -new -key web-app.key -out web-app.csr -subj "/CN=User"
openssl x509 -req -in web-app.csr -CA app-ca.pem -CAkey app-ca-key.pem -CAcreateserial -out web-app.pem -days 10000