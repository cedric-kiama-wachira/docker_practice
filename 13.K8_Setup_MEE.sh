# Phase 1 using Mirantis Docker Enterprise Edition Containers for Kubernetes Cluster
1. Master Node 1
2. Worket Node 1
3. Worket Node 2

#Identify the elastic Public IPs(Optional)
51.112.18.14
3.29.70.34
3.29.10.76

# For AWS Will modify the security group for INBOUND Connections to enable a seamless connection between the above three nodes
Port Range 0-65535 TCP <Public_IP>/32

# Log into each system and update the DNS local resolv plus update the node names
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-51-112-18-14.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-70-34.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-28-93-144.me-central-1.compute.amazonaws.com

#Hostnames under /etc/hostname
M1MEEK8
W1MEEK8
W2MEEK8

# Set the correct Time and date
timedatectl set-timezone 'Asia/Dubai'

# Update and Upgrade the OS
apt update && apt upgrade -y

sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

# Store https://repos.mirantis.com in an environment variable: vi .profile
DOCKER_EE_URL="https://repos.mirantis.com"
DOCKER_EE_VERSION=23.0.8

# Add Docker Official GPG
curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -

# Use the following command to set up the stable repository:
sudo add-apt-repository \
  "deb [arch=$(dpkg --print-architecture)] $DOCKER_EE_URL/ubuntu \
  $(lsb_release -cs) \
  stable-$DOCKER_EE_VERSION"

# Install the latest version of MCR and containerd:
sudo apt-get install docker-ee docker-ee-cli containerd.io


# Enable Seamless Login between nodes by moving into the .ssh directory and run the ssh-keygen utility to create a high-security keypair:
cd .ssh
ssh–keygen –t rsa -b 4096
Append contents of file ~/.ssh/id_rsa.pub on you local machine to ~/.ssh/authorized_keys on ALL Cluster Nodes machine.

# Disable Swap
swapoff -a
cat /etc/fstab 

# Load the Kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

# Download with Mirantis the Download assets
wget https://github.com/Mirantis/launchpad/releases/download/1.5.2/launchpad-linux-x64wget 
mv  mv launchpad-linux-x64 launchpad
chmod +x launchpad
./launchpad init > launchpad.yaml

# Create a Launchpad configuration file for your Mirantis Kubernetes Engine cluster to macth below entries in the launchpad.yaml
apiVersion: launchpad.mirantis.com/mke/v1.4
kind: mke
metadata:
  name: my-mke-cluster
spec:
  hosts:
  - ssh:
      address: ec2-51-112-18-14.me-central-1.compute.amazonaws.com
      user: ubuntu
      #port: 22
      keyPath: /home/ubuntu/.ssh/id_rsa
    role: manager
  - ssh:
      address: ec2-3-29-70-34.me-central-1.compute.amazonaws.com
      user: ubuntu
      port: 22
      keyPath: /home/ubuntu/.ssh/id_rsa
    role: worker
  - ssh:
      address: ec2-3-28-93-144.me-central-1.compute.amazonaws.com
      user: ubuntu
      port: 22
      keyPath: /home/ubuntu/.ssh/id_rsa
    role: worker
  mke:
    version: 3.7.2
    installFlags:
    - --default-node-orchestrator=kubernetes
    - --pod-cidr 10.0.0.0/16
    - --admin-username admin
    - --admin-password Timeline
  mcr:
    version: 23.0.8
  cluster:
    prune: false

# After we can launch as below
./launchpad apply

# Below is the expected output after the installtion is completed
INFO Cluster is now configured.                   
INFO MKE cluster admin UI: https://ec2-51-112-18-14.me-central-1.compute.amazonaws.com/ 
INFO You can download the admin client bundle with the command 'launchpad client-config'

# Adding my Docker Register
W3MEEK8DR

ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-187-108.me-central-1.compute.amazonaws.com

# Store https://repos.mirantis.com in an environment variable: vi .profile
DOCKER_EE_URL="https://repos.mirantis.com"
DOCKER_EE_VERSION=23.0.8

# Add Docker Official GPG
curl -fsSL "${DOCKER_EE_URL}/ubuntu/gpg" | sudo apt-key add -

# Use the following command to set up the stable repository:
sudo add-apt-repository \
  "deb [arch=$(dpkg --print-architecture)] $DOCKER_EE_URL/ubuntu \
  $(lsb_release -cs) \
  stable-$DOCKER_EE_VERSION"

# Install the pre-requisite
sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
# Install the latest version of MCR and containerd:
sudo apt-get install docker-ee docker-ee-cli containerd.io

# Enable Seamless Login between nodes by moving into the .ssh directory and run the ssh-keygen utility to create a high-security keypair:
cd .ssh
ssh–keygen –t rsa -b 4096
Append contents of file ~/.ssh/id_rsa.pub on you local machine to ~/.ssh/authorized_keys on ALL Cluster Nodes machine.

# Disable Swap
swapoff -a
cat /etc/fstab 

# Load the Kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system