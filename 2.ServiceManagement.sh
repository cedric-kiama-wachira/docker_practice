#  Common commands to check the status
systemctl start docker
systemctl stop docker
systemctl status docker

# If there is a problem with docker
systemctl stop docker # For simulation Purposes

dockerd 
dockerd --debug

# Connecting remotley

# On the server host Unencrypted traffic on port 2375 and encrypted on port 2376
dockerd --debug --host=tcp://<IP Of Docker Host that we need to access>:2375
# Enabliing TLS certiifcates
dockerd --debug --host=tcp://<IP Of Docker Host that we need to access>:2376 --tls=true --tlscert=/var/docker/server.pem --tlskey=/var/docker/serverkey.pem

# We can make this permanent on the server by creating a yaml file with all entries
vi /etc/docker/daemon.json
{
    "debug": true,
    "hosts": ["tcp://<IP Of Docker Host that we need to access>:2376"]
    "tls": true,
    "tlscert": "/var/docker/server.pem",
    "tlskey": "/var/docker/serverkey.pem"
}


# On remote client
export DOCKER_HOST="tcp://<IP Of Docker Host that we need to access>:2375
docker ps



