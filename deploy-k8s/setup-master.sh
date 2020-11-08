"""
These steps are summarized from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
to deploy 1 master & n worker nodes
"""


# Set hostname for the worker node
hostnamectl set-hostname <master_hostname>

# Load `br_netfilter` kernel module
sudo modprobe br_netfilter

# For the node's iptables to correctly see bridged traffic
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

# Uncomment below if using RHEL
#subscription-manager unregister
#subscription-manager clean
#subscription-manager register --activationkey <key> --org <org_id>
#subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms

# Install firewalld and enable the service
yum install firewalld wget vim -y
systemctl status firewalld
systemctl start firewalld
systemctl enable firewalld
systemctl status firewalld

# Add necessary ports required for master nodes
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --reload

# Configure k8s repo to install required kube packages
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install kubelet kubeadm kubectl. Using docker container runtime
yum install -y kubelet kubeadm kubectl docker --disableexcludes=kubernetes

systemctl enable --now kubelet
systemctl enable --now docker

systemctl daemon-reload
systemctl restart kubelet
systemctl restart docker 

# Initialize control-plane, if using 1 master node
kubeadm init --apiserver-advertise-address $(hostname -i) &> join.txt

# Initialize control-plane, if using 3 master node specify the IP of the loadbalancer
kubeadm init --apiserver-advertise-address <loadbalancer_ip> &> join.txt

# Export path to the certificates for kubernetes-admin user
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get nodes

# If using non-root user, use below
#mkdir -p $HOME/.kube
#cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#chown $(id -u):$(id -g) $HOME/.kube/config

# Setup pod network 
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"

# Setup k8s dashboard 
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml
kubectl proxy


