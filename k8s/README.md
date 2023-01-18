# Learn K8S

## Use Gitpod
Gipod variable:
- K8S_TYPE=<name> (master|worker1|worker2|worker3)

At host machine:
```
# keep alive & forward port vpn to all container
npm run gbmange

# join vpn at self-host machine
npm run gbvpn

# copy kube config on master to self-host machine
npm run gbcluster
```

Solution
```
______________________________
___________________________   |
| VPN Server, K8S Master  |   |
|       Qemu x86          |   |
|_________________________|   |
        |  GitPod Container   |
________|_____________________|
        |
        | 1194/tcp (vpn)
        |
        |___________(SSH tunel)____________________
                |                   ______________|________________
                |                  | ___________________________   |
                |                  | | VPN Server, K8S Worker  |   |
                |                  | |       Qemu x86          |   |
                |                  | |_________________________|   |
                |                  |         |  GitPod Container   |
                |                  |_________|_____________________|
                |
                |
                |
                |
________________|______
|                      |
|    Host Machine      |
|  (Manage Tunnel)     |
|______________________|
```