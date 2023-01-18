#!/bin/bash

openssl req -nodes -newkey rsa:2048 -keyout tls.key  -out ca.csr -subj "/CN=itconnect.pw"
openssl x509 -req -sha256 -days 365 -in ca.csr -signkey tls.key -out tls.crt