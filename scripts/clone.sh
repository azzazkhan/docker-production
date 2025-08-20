#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
set -eu

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hostname>"
    exit 1
fi

REMOTE_HOST="$1"

scp scripts/provision.sh root@"$REMOTE_HOST":provision.sh
ssh -t root@"$REMOTE_HOST" "bash provision.sh"

zip -r9 docker.zip scripts volumes .env.example docker-compose*.yml
scp docker.zip deployer@"$REMOTE_HOST":docker.zip

rm -rf docker.zip

ssh -t deployer@"$REMOTE_HOST" "unzip docker.zip -d docker && rm -f docker.zip && cd docker && bash scripts/setup.sh && docker compose pull && docker compose -f docker-compose.http.yml up -d traefik"
