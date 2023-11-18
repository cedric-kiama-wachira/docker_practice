#Prerequisites
Ports on both Docker nodes - master and worker 
2377 - Cluster Management
7946 - container network discovery Management(Communication among nodes)
4789 - overlay network traffic

docker system info | grep -i swarm
docker swarm init
docker swarm join --token SWMTKN-1-2hn5x4frp7dqqwb1yugbrd80t-bxus7cee4as7xd24bnkdvk59f 3.29.177.171:2377
docker swarm join-token worker
docker swarm join-token manager
docker swarm join --token SWMTKN-1-2hn5x4frp78vu9x3f2kugbrd80t-5mh4948bjkh4xgmunve0t5529 3.28.93.144:2377
docker node ls
docker node inspect dockerredhat --pretty

docker node promote dockerredhat
docker node demote dockerubuntu

docker node update --availability drain dockerubuntu
docker node update --availability active dockerubuntu

docker node update --availability drain dockerubuntu

docker swarm leave

docker node rm dockerubuntu
docker swarm init --force-new-cluster

# Locking the Swarm Cluster

docker swarm init --autolock=true

docker swarm update --autolock=true

Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-lySoJ5+NZQAPeW4knLkgWtn+vwDQKPZboDelTm/AOAI

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager

systemctl stop docker
systemctl start docker
docker node ls
docker swarm unlock
docker node ls

# Scaling using Swarm Cluster - Single Deployement and Replica Deployments
docker service create --replicas=3 httpd

command -> API -> Ocrhestrator -> Allocator -> Dispatcher -> Scheduler -> (Task1 -> OneService)
command -> API -> Ocrhestrator -> Allocator -> Dispatcher -> Scheduler -> (Task2 -> SecondService)

docker service create --name firstservice -p 80:80 --replicas 4 httpd:alpine
docker service ls
docker service ps firstservice
xdocker service inspect firstservice --pretty
docker service logs firstservice

docker service rm firstservice

docker service create -p 80:80 web
docker service update --replicas=3 -p 80:80 web
docker service update --replicas=1 -p 80:80 web

docker service update -p 80:80 --image web:2.0 web

docker service update -p 80:80 --update-delay 120s --image web:3.0 web
docker service update -p 80:80 --update-delay 120s --update-parallelism 3 --image web:3.0 web
docker service update -p 80:80 --update-delay 120s --update-parallelism 3 --update-failure-action pause|continue|rollback  --image web:3.0 web

docker service update --rollback web

docker service create --replicas=5 web

# Scaling using Swarm Cluster - Global Mode Replication

docker service create --mode global agent

docker node update --label-add type=cpu-optimized w1
docker node update --label-add type=memory-optimized w2
docker node update --label-add type=gpu-optimized w3

docker service create --constraint node.lables.type==cpu-optimized batch-processing
docker service create --constraint node.lables.type==memory-optimized realtime-analytics
docker service create --constraint node.lables.type==gpu-optimized memory-optimized

# Deploy a service in a non optimized label
docker service create --constraint node.lables.type!=memory-optimized web

# Practice exercise - 1 replica
docker service create --name firstservice -p 80:80 httpd:alpine
docker service ls
docker service ps firstservice
docker service inspect firstservice --pretty
docker service rm firstservice

# Practice exercise - 3 replicas
docker service create --name firstservice -p 80:80 --replicas 3 httpd:alpine

# Practice exercise - 6 Replicas - I have 4 workers and 3 Master Nodes
docker service update --replicas 6 firstservice
docker service ls
docker service ps firstservice

# Practice exercise - Scaledown the replicas to 4
docker service update --replicas 4 firstservice
docker service ls
docker service ps firstservice

# Update our Image from httpd:alpine to httpd:2.4.58
docker service inspect firstservice --pretty | grep -i image
Image": "httpd:alpine@sha256:5b3cd2c5faf4da636709e7b71ce9daca24c03166125e11a10b58e276b8b0469d

docker service update --image httpd:2.4.58 firstservice

docker service inspect firstservice --pretty | grep -i image
Image:         httpd:2.4.58@sha256:4e24356b4b0aa7a961e7dfb9e1e5025ca3874c532fa5d999f13f8fc33c09d1b7
docker service ls

# Rollback from httpd:2.4.58 to httpd:alpine
docker service update --rollback firstservice
docker service inspect firstservice --pretty

# Parallelism  during image update

docker service update --image httpd:2.4.58 --update-parallelism 2 firstservice
docker service inspect firstservice --pretty | grep -i parallelism
 Parallelism:   2
 Parallelism:   1


docker service create --name replicatedtest --replicas 9 redis
docker service rm replicatedtest

# Practice Global Service Creation
docker service create --mode global --name globaltest redis


# Placement 
docker node update --label-add env=dev w1
docker node update --label-add env=qa w2
docker node update --label-add env=staging w3
docker node update --label-add env=prod w4

docker service create --name placementtest --constraint=node.labels.env==dev --replicas 3 redis



docker config create nginx-config /tmp/nginx.conf
docker service create --replicas=4 --config src=nginx-conf,target="/etc/nginx/nginx.conf" nginx
docker service update --config-rm nginx-conf nginx
docker config rm nginx-conf
docker config create nginx-conf-new /tmp/nginx-new.conf

docker service update --config-rm nginx-conf --config-add nginc-new.conf nginx


# Practice - creation of overlay network

