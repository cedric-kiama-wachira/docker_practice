vi docker-compose.yml

Services:
    web:
        image: "cedrickiama/simple-webbapp"
    database:
        image: "Mongodb"
    messaging:
        image: "redis:alpine"
    orchestartion:
        image: "ansible"

docker compose up

mkdir /root/app
cd /root/app
git clone https://github.com/dockersamples/example-voting-app.git

docker container run -d --name redis redis:alpine
docker container run -itd -e POSTGRES_USER="postgres" -e POSTGRES_PASSWORD="postgres" -v db-data:/var/lib/postgresql/data --name db postgres:15-alpine
docker container exec -it db /bin/bash



