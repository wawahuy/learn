#!/bin/bash

K8S_TYPE=$1

set -xeuo pipefail

.gitpod/wait-apt.sh

sudo apt update -y
sudo apt install qemu qemu-system-x86 linux-image-generic -y

script_dirname="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
outdir="${script_dirname}/_output"


if [[ "$K8S_TYPE" == "master" ]]; then
    sudo qemu-system-x86_64 -kernel "/boot/vmlinuz" \
        -boot c -m 8000M -hda "${outdir}/rootfs/focal-server-cloudimg-amd64.img" \
        -net user \
        -smp 8 \
        -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
        -nic user,hostfwd=tcp::2222-:22,hostfwd=tcp::1194-:1194 \
        -serial mon:stdio -display none
elif [[ "$K8S_TYPE" =~ ^worker(1|2|3)$ ]]; then
    sudo qemu-system-x86_64 -kernel "/boot/vmlinuz" \
        -boot c -m 8000M -hda "${outdir}/rootfs/focal-server-cloudimg-amd64.img" \
        -net user \
        -smp 8 \
        -append "root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr" \
        -nic user,hostfwd=tcp::2222-:22 \
        -serial mon:stdio -display none
else
    echo "$K8S_TYPE not support"
fi

