#!/bin/bash

# dashboard
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
# https://xuanthulab.net/cai-dat-va-su-dung-kubernetes-dashboard.html
kubectl apply -f k8s/dashboard-v2.6.1.yaml

# self certs
sudo mkdir certs
sudo chmod 777 -R certs
openssl req -nodes -newkey rsa:2048 -keyout certs/dashboard.key -out certs/dashboard.csr -subj "/C=/ST=/L=/O=/OU=/CN=kubernetes-dashboard"
openssl x509 -req -sha256 -days 365 -in certs/dashboard.csr -signkey certs/dashboard.key -out certs/dashboard.crt
sudo chmod -R 777 certs

# 
kubectl create secret generic kubernetes-dashboard-certs --from-file=certs -n kubernetes-dashboard

#
kubectl apply -f k8s/admin-user.yaml
# kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
kubectl -n kubernetes-dashboard create token admin-user