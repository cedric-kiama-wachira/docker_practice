# Checklist
1.) Create AWS Account, Create the EC2 instances and SSH Keys and update the hostname, local dns, time and packages
2.) Install Golang
3.) Have Container Runtime Installed in all Nodes - Docker Engine
4.) Install Container Network Interface -  cri-dockerd(Container Runtime Interface)
5.) Control plane Ports
6.) Worker node(s) Ports
7.) Installing kubeadm, kubelet and kubectl
8.) Install and Configure a layer 7 Load Balancer - Nginx Server
9.) Initiate the Kubernetes Cluster

chmod 0600 dockerkube-key.pem

# Defining the Architecture

DockerKubeNode1  3.29.168.243 DKN1
DockerKubeNode2  3.29.177.171 DKN2
DockerKubeNode3  3.29.190.232 DKN3
DockerKubeNode4  3.29.70.34   DKN4


DockerKubeControlPanel/Master1 3.28.93.144 DKCP1

DockerKubeLoadBalancer 5.1.112.18.14 DKLB


# Assign Elastic IPs and SSH into servers

Workers
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-168-243.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-177-171.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-190-232.me-central-1.compute.amazonaws.com
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-29-70-34.me-central-1.compute.amazonaws.com

Master/s
ssh -o "IdentitiesOnly yes" -i "dockerkube-key.pem" ubuntu@ec2-3-28-93-144.me-central-1.compute.amazonaws.com

Layer 7 Load Balancer NGINX
ssh -o "IdentitiesOnly yes"-i "dockerkube-key.pem" ubuntu@ec2-51-112-18-14.me-central-1.compute.amazonaws.com

# On each server 
vi /etc/hosts && vi /etc/hostname


3.29.168.243 DKN1
3.29.177.171 DKN2
3.29.190.232 DKN3
3.29.70.34   DKN4

3.28.93.144 DKCP1

51.112.18.14 DKLB

apt update && apt upgrade -y  && timedatectl set-timezone 'Asia/Dubai' && reboot

# Install Docker Engine(CLI, API and, Daemon)
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Post Installation Process

sudo usermod -aG docker $USER
newgrp docker
sudo systemctl enable docker && sudo reboot

# Run the first docker container
docker run hello-world


# Install Kubernetes
Kube = API Server, etcd, Kubelet, Container Runtime, Controller and Scheduler


# Install make, GOlang, cri-dockerd - This adapter provides a shim for Docker Engine that lets you control Docker via the Kubernetes Container Runtime Interface.
apt install make

wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.4.linux-amd64.tar.gz
vi $HOME/.profile
export PATH=$PATH:/usr/local/go/bin

git clone https://github.com/Mirantis/cri-dockerd.git
cd cri-dockerd
make cri-dockerd

install -o root -g root -m 0755 cri-dockerd /usr/local/bin/cri-dockerd
install packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable --now cri-docker.socket
systemctl enable cri-docker.service

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

# Ports for Docker
Protocol	Direction	        Port Range	Purpose		        Used By
TCP         ONBOUND/OUTBOUND    2377        Cluster Management
TCP         ONBOUND/OUTBOUND    7946        container network discovery Management(Communication among nodes)
TCP         ONBOUND/OUTBOUND    4789        Overlay network traffic
TCP         ONBOUND/OUTBOUND    2375        HTTP unencrypted socket for remote management of containers
TCP         ONBOUND/OUTBOUND    2376        HTTPS encrypted socket  for remote management of containers


sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Install CNI
git clone https://github.com/containernetworking/plugins.git

cd plugins/
./build_linux.sh
mkdir -p /etc/cni/net.d
cat >/etc/cni/net.d/10-mynet.conf <<EOF
{
	"cniVersion": "0.2.0",
	"name": "mynet",
	"type": "bridge",
	"bridge": "cni0",
	"isGateway": true,
	"ipMasq": true,
	"ipam": {
		"type": "host-local",
		"subnet": "10.22.0.0/16",
		"routes": [
			{ "dst": "0.0.0.0/0" }
		]
	}
}
EOF

cat >/etc/cni/net.d/99-loopback.conf <<EOF
{
	"cniVersion": "0.2.0",
	"name": "lo",
	"type": "loopback"
}
EOF

# Install the load balancer

sudo apt-get update 
sudo apt-get install nginx -y

vi /etc/nginx/nginx.conf

http {
    upstream k8s {
    	server 3.28.93.144;
	server 3.29.168.243;
	server 3.29.177.171;
	server 3.29.190.232;
	server 3.29.70.34;
    }
 
    server {
        listen 80;
        location / {
            proxy_pass http://k8s;
        }
    }
}

systemctl restart nginx.service

# On the First Control Pane
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm config images list
kubeadm config images pull --cri-socket unix:///var/run/cri-dockerd.sock

kubeadm init --apiserver-advertise-address=172.31.30.56 --control-plane-endpoint=172.31.30.56 --cri-socket unix:///var/run/cri-dockerd.sock
#Your Kubernetes control-plane has initialized successfully!

#To start using your cluster, you need to run the following as a regular user:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

#You should now deploy a pod network to the cluster.
#Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#  https://kubernetes.io/docs/concepts/cluster-administration/addons/

#You can now join any number of control-plane nodes by copying certificate authorities
#and service account keys on each node and then running the following as root:

kubeadm join 172.31.30.56:6443 --token sovv0o.cpvcckxrhohvbb2l --discovery-token-ca-cert-hash sha256:3bf21c0fa42ba4cce18250059a0ce04a0cfc3ab5ffc09dba2ccfde559f71b31a --control-plane 

#Then you can join any number of worker nodes by running the following on each as root:
kubeadm join 172.31.30.56:6443 --token sovv0o.cpvcckxrhohvbb2l --discovery-token-ca-cert-hash sha256:3bf21c0fa42ba4cce18250059a0ce04a0cfc3ab5ffc09dba2ccfde559f71b31a

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

vi .profile
export KUBECONFIG=/etc/kubernetes/admin.conf


# Conformance Certificate
wget https://github.com/vmware-tanzu/sonobuoy/releases/download/v0.57.1/sonobuoy_0.57.1_linux_amd64.tar.gz
mkdir /root/Software_Certification_K8s
tar -C /root/Software_Certification_K8s-xzf  sonobuoy_0.57.1_linux_amd64.tar.gz
cd /root/Software_Certification_K8s-xzf
./sonobuoy run --mode=certified-conformance




# Simple House Keeping commands to familiarize oneself

kubectl get nodes
kubectl version
kubectl get nodes -o wide

# Create an nginx pod using an image from docker hub without deploying it
kubectl run nginx --image nginx
kubectl run nginx --image=nginx

# Create an nginx pod using an image from docker hub and deploying it
kubectl create deployment nginx --image=nginx

# Check created pods status and more information related to the pod
kubectl get pods
kubectl describe pod nginx-7854ff8877-xpf9x

# Notes
https://kubernetes.io/docs/concepts/
https://kubernetes.io/docs/concepts/workloads/pods/

# Use of Yamls -some simple examples

1.) Key-Value pair:

Fruit: Apple
Vegetable: Carrot
Liquid: Water
Meat: Chicken

2.) Array/list

Fruits:
-   Orange
-   Apple
-   Banana

Vegetable:
-   Carrot
-   Cauliflower
-   Tomato

3.) Dictionary/Map

Banana:
    Calories: 105
    Fat:    0.4 g
    Carbs:  27 g
Grapes:
    Calories:   62
     Fat:    0.3 g
     Carbs:  16 g

4.) Key Value/Dictionary/Lists

Fruits:
    -   Banana:
            calories: 105
            fat: 0.4 g
            carbs: 27 g
    -   Grape:
            calories: 62
            fat: 0.3 g
            carbs: 16 g

# YAML in Kubernetes

vi pod-definition.yml

apiVersion:
kind: Job|POD|Service|ReplicaSet|Deployment
metadata: 

spec:

# Simple Manifest to getting started

apiVersion: batch/v1
kind: Job
metadata:
  name: hello
spec:
  template:
    # This is the pod template
    spec:
      containers:
      - name: hello
        image: busybox:1.28
        command: ['sh', '-c', 'echo "Hello, Kubernetes!" && sleep 3600']
      restartPolicy: OnFailure
    # The pod template ends here

kubectl create -f pod-definition.yml

