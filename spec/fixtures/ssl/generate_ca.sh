#!/bin/bash
openssl req -new -x509 -keyout private_keys/ca.key -out certs/ca.pem -days 3650 -nodes
