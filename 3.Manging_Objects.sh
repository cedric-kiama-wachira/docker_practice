# Before you check the objects we need to ensure that the docker daemon is running
systemctl status docker.service  
systemctl status docker.socket

# Common objects
docker images ls
docker containers ls
docker network ls
docker volume ls

# Basic Container Management

docker container run -it build
docker container attach ubuntu
docker container kill ubuntu

docker container create httpd

docker container ls -l
docker container ls -a
docker container ls -q
docker container ls -aq

docker container create httpd && docker container start <container_id>

# or

docker container run httpd

# To Interact with ubuntu

docker container run -it ubuntu

# Give the container a UNIQUE name, add the -d option to detach it

docker container run -itd --name webapp ubuntu

# Inspecting a container

docker container inspect webapp 

docker container stats
docker container top webapp
docker container logs webapp
docker container logs -f webapp

docker system events --since 30m

# Give the container a hostname

docker container run -it --name webapp --hostname webapp ubuntu

# Container Restart Policies

docker container run -itd --restart no --name webapp --hostname webapp ubuntu
docker container run  -itd --restart on-failure --name webapp --hostname webapp ubuntu
docker container run  -itd --restart always --name webapp --hostname webapp ubuntu
docker container run  -itd --restart unless-stopped --name webapp --hostname webapp ubuntu

# Setting the Docker daemon policy so that even after the docker service stops the container is still running

vi /etc/docker/daemon.json

{
    "debug": true,
    "hosts": ["tcp://172.31.17.68:2376"],
    "live-restore": true
}

# Copying files from local machine to a running docker containter

docker container cp /tmp/web.conf webapp:/etc/web.conf




