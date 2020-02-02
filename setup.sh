#!/bin/bash

TICKETBOOTH_DATA=/data/ticketbooth
COMPENDIUM_API_DATA=/data/compendium-api
COMPENDIUM_DATA=/data/compendium

docker-compose down
docker rmi $(docker images -a -q)

rm -r $TICKETBOOTH_DATA $COMPENDIUM_API_DATA $COMPENDIUM_DATA
mkdir -p $TICKETBOOTH_DATA/keys
mkdir -p $COMPENDIUM_API_DATA/keys
mkdir -p $COMPENDIUM_DATA

# Create keys for ticketbooth
openssl genrsa -out $TICKETBOOTH_DATA/keys/private.key 2048
openssl rsa -in $TICKETBOOTH_DATA/keys/private.key -outform PEM -pubout -out $TICKETBOOTH_DATA/keys/public.key
# openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -subj "/C=AU/ST=ACT/L=Canberra/O=OrangeLightning/CN=ticketbooth" -keyout $TICKETBOOTH_DATA/keys/server.key -out $TICKETBOOTH_DATA/keys/server.crt

# Copy public keys to compendium-api
cp $TICKETBOOTH_DATA/keys/public.key $COMPENDIUM_API_DATA/keys/public.key

echo -n "GitLab Docker Registry username": 
read -s username
echo -n "GitLab Docker Registry password": 
read -s password

docker login registry.gitlab.com -u $username -p $password
docker-compose up -d

sleep 10

# Ticketbooth database
echo "Setting up ticketbooth database..."
docker exec -t --workdir /app ticketbooth npx sequelize-cli db:migrate
docker exec -t --workdir /app ticketbooth npx sequelize-cli db:seed:all

# Compendium API database
echo "Setting up compendium-api database..."
docker exec -t --workdir /app compendium-api npx sequelize-cli db:migrate
docker exec -t --workdir /app compendium-api npx sequelize-cli db:seed:all
