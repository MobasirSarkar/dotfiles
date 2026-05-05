#!/bin/bash
set -e

COMPOSE_FILE="$HOME/docker-c/docker-compose.yml"

echo "Stopping old cluster..."
sudo docker compose -f "$COMPOSE_FILE" down -v

echo "Starting containers..."
sudo docker compose -f "$COMPOSE_FILE" up -d

echo "Waiting for Redis nodes..."
sleep 8

echo "Creating cluster..."

echo yes | sudo docker exec -i redis-7000 redis-cli --cluster create \
    redis-7000:7000 \
    redis-7001:7001 \
    redis-7002:7002 \
    redis-7003:7003 \
    redis-7004:7004 \
    redis-7005:7005 \
    --cluster-replicas 1

echo "Cluster created successfully."

echo "Cluster status:"
docker exec redis-7000 redis-cli --cluster check redis-7000:7000
