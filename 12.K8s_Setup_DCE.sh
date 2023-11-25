# Phase 1 using Docker Community Edition Containers for Kubernetes Cluster
1. Master Node 1
2. Worket Node 1
3. Worket Node 2

#Identify the elastic Public IPs(Optional)
3.29.168.243
3.29.177.171
3.29.190.232

# Ports for Kubernetes Control Plane
 Protocol	Direction	Port Range	Purpose			            Used By
 TCP		    Inbound	    6443		Kubernetes API server		All
 TCP		    Inbound	    2379-2380	etcd server client API		kube-apiserver, etcd
 TCP		    Inbound	    10250		Kubelet API			        Self, Control plane
 TCP		    Inbound	    10259		kube-scheduler			    Self
 TCP		    Inbound	    10257		kube-controller-manager	    Self

# Ports for Kubernetes Worker Nodes
Protocol	Direction	Port Range	Purpose		        Used By
TCP		    Inbound	    10250		Kubelet API		    Self, Control plane
TCP		    Inbound	    30000-32767	NodePort Services	All

# Ports for Docker On All Nodes
Protocol	Direction	        Port Range	Purpose		        Used By
TCP         ONBOUND/OUTBOUND    2377        Cluster Management
TCP         ONBOUND/OUTBOUND    7946        container network discovery Management(Communication among nodes)
TCP         ONBOUND/OUTBOUND    4789        Overlay network traffic
TCP         ONBOUND/OUTBOUND    2375        HTTP unencrypted socket for remote management of containers
TCP         ONBOUND/OUTBOUND    2376        HTTPS encrypted socket  for remote management of containers


# Log into each system and update the DNS local resolv plus update the node names
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-168-243.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-177-171.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-190-232.me-central-1.compute.amazonaws.com

# Local DNS resolve /etc/hosts
172.31.5.35 M1DCEK8 ec2-3-29-168-243.me-central-1.compute.amazonaws.com
172.31.30.85 W1DCEK8 ec2-3-29-177-171.me-central-1.compute.amazonaws.com
172.31.27.144 W2DCEK8 ec2-3-29-190-232.me-central-1.compute.amazonaws.com

#Hostnames under /etc/hostname
M1DCEK8
W1DCEK8
W2DCEK8

# Set the correct Time and date
timedatectl set-timezone 'Asia/Dubai'

# Update and Upgrade the OS
apt update && apt upgrade -y

# Disable Swap
swapoff -a
cat /etc/fstab 

# Load the Kernel modules
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
sysctl --system

# Set up Docker's apt repository. The current Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

# Install the Docker packages.
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Post install for non root users
sudo usermod -aG docker $USER
newgrp docker
docker version
docker run hello-world

# Configure Containerd to use SystemD
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd


# Installing Kubernetes - update apt package needed to install K8s apt repos

sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download the public signing key for the Kubernetes package repositories.
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add the appropriate Kubernetes apt repository.
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update the apt package index, install kubelet, kubeadm and kubectl, and pin their version:
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm init --pod-network-cidr=10.10.0.0/16 --control-plane-endpoint=172.31.5.35

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copyig certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join 172.31.5.35:6443 --token 6vc9pa.xloh8jzpu1c41kkl \
        --discovery-token-ca-cert-hash sha256:c31aa5f1df88d9092e7cdb3c1abd51711374d856ece27e2899af29efc75e4079 \
        --control-plane 

Then you can join any number of worker nodes by running the following on each as root:


kubeadm join 172.31.5.35:6443 --token 6vc9pa.xloh8jzpu1c41kkl \
        --discovery-token-ca-cert-hash sha256:c31aa5f1df88d9092e7cdb3c1abd51711374d856ece27e2899af29efc75e4079 


# The the K8s cluster information
kubectl cluster-info

# Install Calico with Kubernetes API datastore, 50 nodes or less
curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.4/manifests/calico.yaml -O

# Edit the Calico File and uncpmment the values below and update CIDR pool
vi calico.yaml
- name: CALICO_IPV4POOL_CIDR
  value: "10.10.0.0/16"CALICO_IPV4POOL_CIDR 

# Install the network plugin
kubectl apply -f calico.yaml

# Get the status of the cluster 
kubectl get pods -n kube-system

