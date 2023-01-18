#!/bin/bash

# scp root@172.16.10.100:/etc/kubernetes/admin.conf ~/.kube/config-mycluster

# export KUBECONFIG=~/.kube/config:~/.kube/config-mycluster
# kubectl config view --flatten > ~/.kube/config_temp
# mv ~/.kube/config_temp ~/.kube/config

# export KUBECONFIG=~/.kube/config
# rm -rf ~/.kube/config-mycluster

scp -o StrictHostKeychecking=no root@172.16.10.100:/etc/kubernetes/admin.conf ~/.kube/config


# kubectl config use-context kubernetes-admin@kubernetes