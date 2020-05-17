#!/bin/bash

TICKETBOOTH_DATA=/data/ticketbooth
COMPENDIUM_API_DATA=/data/compendium-api
COMPENDIUM_DATA=/data/compendium

TICKETBOOTH_PRIVATE_KEY=$TICKETBOOTH_DATA/keys/private.key
TICKETBOOTH_PUBLIC_KEY=$TICKETBOOTH_DATA/keys/public.key
COMPENDIUM_API_PUBLIC_KEY=$COMPENDIUM_API_DATA/keys/public.key

TICKETBOOTH_DB=$TICKETBOOTH_DATA/database.sqlite3
COMPENDIUM_API_DB=$COMPENDIUM_API_DATA/database.sqlite3

TOKEN=`cat token.txt`

docker-compose down
docker rmi $(docker images -a -q)

#rm -r $TICKETBOOTH_DATA $COMPENDIUM_API_DATA $COMPENDIUM_DATA
mkdir -p $TICKETBOOTH_DATA/keys
mkdir -p $COMPENDIUM_API_DATA/keys
mkdir -p $COMPENDIUM_DATA

# Create keys for ticketbooth
[ -f "$TICKETBOOTH_PRIVATE_KEY" ] && echo "Private key already exists: $TICKETBOOTH_PRIVATE_KEY" || openssl genrsa -out $TICKETBOOTH_PRIVATE_KEY 2048
[ -f "$TICKETBOOTH_PUBLIC_KEY" ] && echo "Public key already exists: $TICKETBOOTH_PUBLIC_KEY" || openssl rsa -in $TICKETBOOTH_PRIVATE_KEY -outform PEM -pubout -out $TICKETBOOTH_PUBLIC_KEY

# Copy public keys to compendium-api
cp $TICKETBOOTH_PUBLIC_KEY $COMPENDIUM_API_PUBLIC_KEY

echo -n "GitLab Docker Registry username": 
read -s username
echo "Getting token from token.txt."
docker login registry.gitlab.com -u $username -p $TOKEN
docker-compose up -d

sleep 10

# Ticketbooth database
if [ -f "$TICKETBOOTH_DB" ]; then
  echo "Database for Ticketbooth already exists: $TICKETBOOTH_DB"
else 
  echo "Creating Ticketbooth database: $TICKETBOOTH_DB"
  echo "Setting up Ticketbooth database..."
  docker exec -t --workdir /app ticketbooth npx sequelize-cli db:migrate
  docker exec -t --workdir /app ticketbooth npx sequelize-cli db:seed:all
fi

# Compendium API database
if [ -f "$COMPENDIUM_API_DB" ]; then
  echo "Database for Compendium API already exists: $COMPENDIUM_API_DB"
else 
  echo "Creating Compendium API database: $COMPENDIUM_API_DB"
  echo "Setting up Compendium API database..."
  docker exec -t --workdir /app compendium-api npx sequelize-cli db:migrate
  docker exec -t --workdir /app compendium-api npx sequelize-cli db:seed:all
fi
