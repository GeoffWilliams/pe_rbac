#!/bin/bash

openssl genrsa -out private_keys/localhost.key 1024
openssl req -new -key private_keys/localhost.key -out localhost.csr

openssl x509 -req -in localhost.csr -CA certs/ca.pem -CAkey private_keys/ca.key -set_serial 1 -out certs/localhost.pem
rm localhost.csr

