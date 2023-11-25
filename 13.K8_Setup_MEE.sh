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

# Local DNS resolve /etc/hosts
172.31.7.138 M1MEEK8 ec2-51-112-18-14.me-central-1.compute.amazonaws.com 
172.31.9.50 W1MEEK8 ec2-3-29-70-34.me-central-1.compute.amazonaws.com
172.31.12.84 W2MEEK8 ec2-3-28-93-144.me-central-1.compute.amazonaws.com

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

# Copy it into the Master Node
scp -o "IdentitiesOnly yes" -i "dockerkube-key.pem" launchpad-linux-x64  ubuntu@ec2-51-112-18-14.me-central-1.compute.amazonaws.com:/home/ubuntu

# Download with Mirantis the Download assets
wget https://github.com/Mirantis/launchpad/releases/download/1.5.2/launchpad-linux-x64wget 
mv  mv launchpad-linux-x64 launchpad
chmod +x launchpad
./launchpad init > launchpad.yaml

# Create a Launchpad configuration file for your Mirantis Kubernetes Engine cluster
./launchpad-linux-x64 init > launchpad.yaml

# Edit below content vi launchpad.yaml
