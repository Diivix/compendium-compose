#!/bin/bash

TICKETBOOTH_DATA=/data/ticketbooth

docker-compose down
docker rmi $(docker images -a -q)

rm -r $TICKETBOOTH_DATA
mkdir -p $TICKETBOOTH_DATA/keys
openssl genrsa -out $TICKETBOOTH_DATA/keys/private.key 2048
openssl rsa -in $TICKETBOOTH_DATA/keys/private.key -outform PEM -pubout -out $TICKETBOOTH_DATA/keys/public.key
# openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=AU/ST=ACT/L=Canberra/O=OrangeLightning/CN=ticketbooth" -keyout $TICKETBOOTH_DATA/keys/server.key -out $TICKETBOOTH_DATA/keys/server.crt

echo -n "Registry username": 
read -s username
echo -n "Registry password": 
read -s password

docker login registry.gitlab.com -u $username -p $password
docker-compose up -d

sleep 10

docker exec -t --workdir /app ticketbooth node_modules/.bin/sequelize db:migrate
docker exec -t --workdir /app ticketbooth node_modules/.bin/sequelize db:seed:all