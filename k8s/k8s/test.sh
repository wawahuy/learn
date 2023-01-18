#!/bin/bash


# remove plugin hang
name_pod1=dashboard-metrics-scraper-7bc864c59-fxb84
name_pod2=kubernetes-dashboard-6ff574dd47-dbqwz
name_namespace=kubernetes-dashboard
kubectl delete pod $name_pod1 --grace-period=0 --force --namespace $name_namespace
kubectl delete pod $name_pod2 --grace-period=0 --force --namespace $name_namespace
kubectl delete namespaces $name_namespace

# > kubectl logs -n kube-system calico-node-275td -c install-cni
# > kubectl logs -n kube-system calico-node-275td -c install-cni --previous=true
# unable to retrieve container logs for docker://26fdb9e02c50be72b74dee0f003cd1e516184a206faddd1cb1b3587fb602f395

# de gan nhan node
kubectl label node <tennode> <tennhan>=<value>

# get node by label
kubectl get node -l  '<tennhan>=<value>'

# remove label
kubectl label node <tennode>-

