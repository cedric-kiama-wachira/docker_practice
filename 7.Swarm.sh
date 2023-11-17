#Prerequisites
Ports on both Docker nodes - master and worker 
2377
7946
4789

docker system info | grep -i swarm
docker swarm init
docker swarm join --token SWMTKN-1-2hn5x4frp7dqqwb1y55x7yzl2i8ro3ip78vu9x3f2kugbrd80t-bxus7cee4as7xd24bnkdvk59f 3.29.177.171:2377
docker swarm join-token worker
docker node ls
docker node inspect dockerredhat --pretty

docker node promote dockerredhat
docker node demote dockerubuntu
docker node update --availability drain dockerubuntu
docker node update --availability active dockerubuntu

docker node update --availability drain dockerubuntu

docker swarm leave

docker node rm dockerubuntu
