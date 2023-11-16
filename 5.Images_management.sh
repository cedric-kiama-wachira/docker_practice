docker images ls
docker search httpd
docker search apache2
docker search mongo
docker search postgres:alpine
docker pull postgres:alpine
docker pull mongo:7.0-rc-jammy
docker search apache2 --limit 2
docker search --filter stars=10 httpd 
docker search --filter is-official=true httpd 

docker image pull
docker image pull httpd:alpine
docker image tag httpd:alpine httpd:cedric-kiama-wachira
docker push httpd:cedric-kiama-wachira


docker image tag httpd:alpine cedrickiama/docker-exam-prep 
docker push cedrickiama/docker-exam-prep

docker image ls
docker system df

docker image prune -a

docker image history ubuntu
docker image inspect ubuntu

docker image inspect httpd:alpine -f '{{.Os}}'
docker image inspect httpd:alpine -f  '{{.Architecture}}'
docker image inspect httpd:alpine -f  '{{.Os}} {{.Architecture}}'

docker image inspect httpd:alpine -f '{{.ContainerConfig.ExposedPorts}}'

docker image pull httpd:alpine
docker image save alpine:latest -o cedric-kiama-wachira.tar

scp cedric-kiama-wachira.tar to_Remote_Machine:/dir/location

ssh remote_machine
docker image load -i cedric-kiama-wachira.tar

docker container run -itd  --name mongodb-mine mongo:7.0-rc-jammy
docker export mongodb-mine > cedric-kiama-wachira-mongodb.tar
docker image import cedric-kiama-wachira-mongodb.tar mongo:7.0-rc-jamm

# Creating Own Images

vi /home/ec2-user/Dockerfile

FROM ubuntu
RUN apt-get update -y 
RUN apt-get install -y --force-yes apache2
COPY ./index.html /var/www/html/index.html
EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

vi /home/ec2-user/index.html
<h1> Welcome to the first image </h1>


docker image build -t cedrickiama/httpdtest -f Dockerfile .
docker container run -itd --name apache2test-image -p 82:80 cedrickiama/httpdtest
docker push cedrickiama/httpdtest

git clone https://github.com/yogeshraheja/dockertomcat.git
rm -Rf dockertomcat/.gi*
cd dockertomcat
docker image build -t cedrickiama/tomcattest -f Dockerfile .
docker container run -itd --name tomcattest-image -p 84:8080 cedrickiama/tomcattest
docker image build -t cedrickiama/tomcattest2 -f Dockerfile .
docker container run -itd --name tomcattest2-image -p 86:8080 cedrickiama/tomcattest2



ddocker image pull centos:7
docker image ls
docker container create -itd --name test centos:7
docker container start test
docker container exec -it test /bin/bash

yum -y update
yum install -y httpd
echo "<h1> Hello again and welcome to the Httpd Server </h1>" >> /var/www/html/index.html

docker container stop test
docker container commit -a "Cedric" -c 'CMD ["httpd", "-D", "FOREGROUND"]' test webtest:v1 
docker image ls

docker container run -itd --name webtesting -p 80:80 webtest:v1 
docker container ls -a

docker image tag webtest:v1 cedrickiama/webtest3:v1

docker login
docker push cedrickiama/webtest3:v1

docker run ubuntu sleep 5
docker container ls -a
docker container start <Container_ID>
docker run ubuntu sleep 20

# Base and Parent Images
vi Dockerfile

FROM httpd:2.4
COPY ./public-html/ /usr/local/apache2/htdocs/

docker build -t my-apache2 .
docker run -dit --name my-running-app -p 8080:80 my-apache2


docker run -itd --name testone ubuntu
docker run -itd --name testtwo --memory 200m ubuntu
docker run -itd --name testthree --memory 200m  --memory-swap -1 ubuntu
docker run -itd --name testfour --memory 200m  --memory-swap -1 --memory-reservation 100m ubuntu

docker run -itd --name testcpuone --cpus 1 ubuntu
docker run -itd --name testcputwo --cpuset-cpus "1" ubuntu

docker network ls
docker network inspect <Network_ID>

docker container run -itd --name first centos:7
docker container run -itd --name second centos:7

docker network create --driver bridge --subnet 192.168.10.0/24 my-ubuntu-network

docker network ls
docker network inspect my-ubuntu-network

docker container run -itd --name custfirst --net my-ubuntu-network centos:7
docker container run -itd --name custsecond --net my-ubuntu-network centos:7

docker container exec -it custfirst ping custsecond
docker container exec -it custsecond ping custfirst

docker container exec -it custfirst cat /etc/resolv.conf

docker network connect my-ubuntu-network first
docker container exec -it custsecond ping first

docker network disconnect my-ubuntu-network first

ip -c netns
ip netns add blue
ip netns add red

ip netns

ip netns exec red ip link

ip netns exec blue arp
ip netns exec blue route

ip link add veth-red type veth peer name veeth-blue

ip link set veth-red netns red
ip link set veth-blue netns blue


ip netns exec red addr add 192.168.15.1 dev veth-red
ip netns exec blue addr add 192.168.15.2 dev veeth-blue


 ip -n red link set veth-red up
 ip -n blue link set veeth-blue up

ip link add v-net-0 type bridge

ip link set dev v-net-0 up

ip link add veth-red type veth peer name veth-red-br
ip link add veth-blue type veth peer name veth-blue-br
ip link set veth-red netns red
ip link set veth-blue netns blue

ip link set veth-red-br master v-net-0
ip link set veth-blue-br master v-net-0

ip -n red link set veth-red up
ip -n blue link set veth-blue up

ip addr add 192.168.15.5/24 dev v-net-0
ip addr add 192.168.15.1/24 dev veth-red
ip addr add 192.168.15.2/24 dev veth-blue
ip netns exec red ping blue
