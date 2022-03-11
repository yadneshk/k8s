# Deploy Kubernetes cluster on RHOSP 16.2

## Master and worker node running Ubuntu Focal 
```
(overcloud) [stack@undercloud-0 ~]$ openstack server list 
+--------------------------------------+--------+--------+-----------------------------------+--------+--------+
| ID                                   | Name   | Status | Networks                          | Image  | Flavor |
+--------------------------------------+--------+--------+-----------------------------------+--------+--------+
| a42e71d7-bc8e-44aa-818b-81e63ef9d951 | master | ACTIVE | private=192.168.0.85, 10.0.0.148  | master | med    |
| da3c4a80-b115-428c-a11f-87e36662724d | worker | ACTIVE | private=192.168.0.171, 10.0.0.124 | master | med    |
+--------------------------------------+--------+--------+-----------------------------------+--------+--------+
```

## [Ports](https://kubernetes.io/docs/reference/ports-and-protocols/)  used by Kubernetes components
```
(overcloud) [stack@undercloud-0 ~]$ openstack security group rule list master
+--------------------------------------+-------------+-----------+-----------+-------------+-----------------------+
| ID                                   | IP Protocol | Ethertype | IP Range  | Port Range  | Remote Security Group |
+--------------------------------------+-------------+-----------+-----------+-------------+-----------------------+
| 0812a8e5-e196-4801-bbdd-590dbcdf5cb4 | udp         | IPv4      | 0.0.0.0/0 | 53:53       | None                  |
| 0eb6355b-28fb-4bf3-ab23-c345676f7145 | tcp         | IPv4      | 0.0.0.0/0 | 9153:9153   | None                  |
| 17fe167b-867f-4426-8ec7-29059363d063 | tcp         | IPv4      | 0.0.0.0/0 | 22:22       | None                  |
| 38acb579-b140-4223-a3bd-bb9f469b8d57 | tcp         | IPv4      | 0.0.0.0/0 | 10259:10259 | None                  |
| 38f7b629-1dcb-4160-b70f-f13245fbdf7e | None        | IPv4      | 0.0.0.0/0 |             | None                  |
| 5623e047-213b-4794-97c9-0555bcf1b960 | tcp         | IPv4      | 0.0.0.0/0 | 2379:2380   | None                  |
| 7bc68376-860b-433e-b92b-b27e1201c8de | tcp         | IPv4      | 0.0.0.0/0 | 10257:10257 | None                  |
| 92d0ab32-4859-47a2-9878-0d20ce0b5986 | tcp         | IPv4      | 0.0.0.0/0 | 6443:6443   | None                  |
| 94457006-b847-4e25-a0a1-8e68f5b4b7c9 | None        | IPv6      | ::/0      |             | None                  |
| d1ecb875-6432-416b-9055-71a0e8dc8b52 | tcp         | IPv4      | 0.0.0.0/0 | 443:443     | None                  |
| d525280c-3bce-44e5-bb3d-860eba4f8f18 | tcp         | IPv4      | 0.0.0.0/0 | 10250:10250 | None                  |
| d9edeb3d-0090-4ea6-8256-d898ae0dd0ea | tcp         | IPv4      | 0.0.0.0/0 | 53:53       | None                  |
| eea43615-f802-470c-bf10-ed9c5ab6a3e6 | icmp        | IPv4      | 0.0.0.0/0 |             | None                  |
+--------------------------------------+-------------+-----------+-----------+-------------+-----------------------+

(overcloud) [stack@undercloud-0 ~]$ openstack security group rule list worker
+--------------------------------------+-------------+-----------+-----------+-------------+-----------------------+
| ID                                   | IP Protocol | Ethertype | IP Range  | Port Range  | Remote Security Group |
+--------------------------------------+-------------+-----------+-----------+-------------+-----------------------+
| 0179bb23-d60c-42bd-83cc-99f1d549b4bb | tcp         | IPv4      | 0.0.0.0/0 | 53:53       | None                  |
| 18349704-0fd0-4415-9d68-dff6929446cf | tcp         | IPv4      | 0.0.0.0/0 | 9153:9153   | None                  |
| 2a07490e-0b6f-46d7-88d9-36097e010730 | None        | IPv6      | ::/0      |             | None                  |
| 32cd2813-7430-4232-a93e-cd8a7e481c4a | None        | IPv4      | 0.0.0.0/0 |             | None                  |
| 84180dd5-7317-4f3a-a989-d3ebbc701811 | icmp        | IPv4      | 0.0.0.0/0 |             | None                  |
| b2f66709-34c5-467d-a775-1012bfbb7b94 | tcp         | IPv4      | 0.0.0.0/0 | 30000:32767 | None                  |
| ba868f43-b83b-4a42-b7c2-bd7a37321850 | udp         | IPv4      | 0.0.0.0/0 | 53:53       | None                  |
| c42acab8-6b82-4b3a-abb6-62bf2cd3c307 | tcp         | IPv4      | 0.0.0.0/0 | 10250:10250 | None                  |
| e6741dd1-a56c-43cb-a408-e162e2b47b17 | tcp         | IPv4      | 0.0.0.0/0 | 22:22       | None                  |
+--------------------------------------+-------------+-----------+-----------+-------------+-----------------------+
```

## Configure Master node

### Letting iptables see bridged traffic 
```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

### Setup `containerd` repository from [docs.docker.com](https://docs.docker.com/engine/install/ubuntu/)
```
sudo apt-get update
sudo apt-get install containerd.io
```

### Install `crictl` from [release page](https://github.com/kubernetes-sigs/cri-tools/blob/master/docs/crictl.md)

### Installing `kubeadm`, `kubelet` and `kubectl`
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```
### [Initialize cluster](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
```
kubeadm init --config=kubeadm.yaml
```

### Setup CNI
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

### Add worker node
```
kubeadm join <control-plane-host>:<control-plane-port> --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

## Deploy [cloud-controller-manager](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md)

### Create secret with `cloud.conf`
```
cat cloud.conf
[global]
auth-url="http://10.0.0.101:5000"
username="admin"
password="jsxATlaLO4JcfCnkAE9lfIjkA"
region="regionOne"
tenant-id=""
tenant-name="admin"
domain-name="Default"
domain-id=""
application-credential-id=""
application-credential-secret=""

[BlockStorage]
bs-version=v3
ignore-volume-az=false

[LoadBalancer]
Floating-network-id=2666b115-a9b9-45ff-bcaf-0fc2afeba00c
floating-subnet-id=a7421985-1828-4293-8348-a571cef15533
subnet-id=b27ceade-288d-4205-92b3-910bd268af81
network-id=b5cacff2-d5f2-4a11-864b-a4586f16ae5e
```
```
kubectl create secret -n kube-system generic cloud-config --from-file=cloud.conf
```

### Create RBAC resources and openstack-cloud-controller-manager deamonset
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-roles.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/cloud-controller-manager-role-bindings.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/cloud-provider-openstack/master/manifests/controller-manager/openstack-cloud-controller-manager-ds.yaml
```

## Deploy [cinder-csi-plugin](https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/cinder-csi-plugin/using-cinder-csi-plugin.md)
