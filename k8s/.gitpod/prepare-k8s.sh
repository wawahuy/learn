#!/bin/bash

ABSOLUTE_PATH_K8S="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $ABSOLUTE_PATH_K8S/common/support-os.sh
source $ABSOLUTE_PATH_K8S/common/sudo.sh

ABSOLUTE_PATH_K8S="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

K8S_TYPE=$1
OVPN_FILE=$ABSOLUTE_PATH_K8S/vpn-s2c/keys/$K8S_TYPE.ovpn

if [[ ! -e "$OVPN_FILE" ]]; then
    echo "Cant find $OVPN_FILE"
fi

# test init
rootfslock="$ABSOLUTE_PATH_K8S/_output/rootfs/rootfs-ready.lock"
k8sreadylock="$ABSOLUTE_PATH_K8S/_output/rootfs/k8s-ready.lock"
if test -f "${k8sreadylock}"; then
    exit 0
fi

function waitssh() {
  while ! nc -z 127.0.0.1 2222; do   
    sleep 0.1
  done
  echo 'SSH connect...'
  $ABSOLUTE_PATH_K8S/ssh.sh "whoami" &>/dev/null
  if [ $? -ne 0 ]; then
    sleep 1
    waitssh
  fi
}

function waitrootfs() {
  while ! test -f "${rootfslock}"; do
    sleep 0.1
  done
}

function setupMaser() {
    # setup openvpn server
    $ABSOLUTE_PATH_K8S/prepare-vpn-server.sh

    # setup k8s
    $SUDO $ABSOLUTE_PATH_K8S/scp.sh $ABSOLUTE_PATH_K8S/prepare-docker-kube.sh root@localhost:~/shell
    $ABSOLUTE_PATH_K8S/ssh.sh "~/shell/prepare-docker-kube.sh"
    
    # run kubeadm init
    $ABSOLUTE_PATH_K8S/ssh.sh "kubeadm init --apiserver-advertise-address=10.8.0.1 --pod-network-cidr=192.168.0.0/16"

    # run master-token
    $ABSOLUTE_PATH_K8S/scp.sh -r $ABSOLUTE_PATH_K8S/master-token root@localhost:~/shell
    $ABSOLUTE_PATH_K8S/ssh.sh "~/shell/master-token/run.sh"
}

function setupWorker() {
    # setup openvpn client service
    # setup k8s
    # run kubeadm join
    echo "worker update..."
    exit
}


echo "🔥 Installing everything, this will be done only one time per workspace."

echo "Waiting for the rootfs to become available, it can take a while, open the terminal #2 for progress"
waitrootfs
echo "✅ rootfs available"

echo "Wait for apt lock to end"
$ABSOLUTE_PATH_K8S/wait-apt.sh
sudo apt install netcat sshpass -y
echo "✅ no more apt lock"

echo "Waiting for the ssh server to become available, it can take a while, after this k8s is getting installed"
waitssh
echo "✅ ssh server available"

if [[ "$K8S_TYPE" == "master" ]]; then
    setupMaser
elif [[ "$K8S_TYPE" =~ ^worker(1|2|3)$ ]]; then
    setupWorker
else
    echo "$K8S_TYPE not support"
fi

touch "${k8sreadylock}"