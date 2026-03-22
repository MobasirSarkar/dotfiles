#!/bin/bash

set -e

COMPOSE_FILE="$HOME/docker-c/docker-compose.yml"
PASSWORD="moba9811"

echo "Stopping existing containers..."

echo "$PASSWORD" | sudo -S docker compose -f "$COMPOSE_FILE" down -v

echo "Starting containers..."

echo "$PASSWORD" | sudo -S docker compose -f "$COMPOSE_FILE" up -d

echo "Waiting for Redis nodes to start..."
sleep 8

echo "Creating Redis cluster..."

echo "yes" | docker exec -i redis-7000 redis-cli --cluster create \
    redis-7000:7000 \
    redis-7001:7001 \
    redis-7002:7002 \
    redis-7003:7003 \
    redis-7004:7004 \
    redis-7005:7005 \
    --cluster-replicas 1

echo "Redis cluster setup completed!"
