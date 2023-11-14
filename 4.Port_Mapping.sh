# Limiting access to our container on a specific port to a specific IP - On AWS EC2 we cannot use a public IP
docker container run -itd -p 172.31.17.68:80:5000 --restart no --hostname webapp --name webapp --rm httpd



