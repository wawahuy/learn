#!/bin/bash

# Install Docker
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Issue qemu docker
# Create /etc/docker directory.
# mkdir /etc/docker
# cat > /etc/docker/daemon.json <<EOF
# {
#   "exec-opts": ["native.cgroupdriver=systemd"],
#   "log-driver": "json-file",
#   "log-opts": {
#     "max-size": "100m"
#   },
#   "storage-driver": "overlay2",
#   "storage-opts": [
#     "overlay2.override_kernel_check=true"
#   ]
# }
# EOF
# systemctl daemon-reload

# Restart Docker
systemctl enable docker
systemctl restart docker

# Issue master init
# https://github.com/containerd/containerd/issues/4581
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
rm -rf /etc/containerd/config.toml
systemctl restart containerd

# QEMU default: disable 
# # Disable SELinux
# setenforce 0
# sed -i --follow-symlinks 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/sysconfig/selinux

# QEMU default: disable 
# # Disable Firewall
# systemctl disable firewalld >/dev/null 2>&1
# systemctl stop firewalld


# Issue init node
# https://stackoverflow.com/questions/44125020/cant-install-kubernetes-on-vagrant
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Disable swap
sed -i '/swap/d' /etc/fstab
swapoff -a

# Add yum repo file for Kubernetes
apt-get update
apt-get install -y ca-certificates curl
mkdir -p /etc/apt/keyrings
wget https://packages.cloud.google.com/apt/doc/apt-key.gpg -O /etc/apt/keyrings/kubernetes-archive-keyring.gpg
# curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt install -y -q kubeadm kubelet kubectl

systemctl enable kubelet
systemctl start kubelet

# Configure NetworkManager before attempting to use Calico networking.
cat >>/etc/NetworkManager/conf.d/calico.conf<<EOF
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:tunl*
EOF