#!/bin/bash

scp -o StrictHostKeychecking=no root@10.8.0.1:/etc/kubernetes/admin.conf ~/.kube/config