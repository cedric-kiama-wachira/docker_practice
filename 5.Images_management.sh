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


