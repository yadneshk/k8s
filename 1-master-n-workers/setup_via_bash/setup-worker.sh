"""
These steps are summarized from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
to deploy 1 master & n worker nodes
"""


# Set hostname for the worker node
hostnamectl set-hostname <worker_hostname>

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
systemctl start firewalld
systemctl enable firewalld
systemctl status firewalld

# Add necessary ports required for worker nodes
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
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
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install kubelet kubeadm kubectl. Using docker container runtime
sudo yum install -y kubelet kubeadm kubectl docker --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
sudo systemctl enable --now docker

systemctl daemon-reload
systemctl restart kubelet
systemctl restart docker
