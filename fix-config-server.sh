#!/bin/bash

set -e

echo "🔧 Fixing config-server issues..."

echo "Stopping existing containers..."
docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local down || true

echo "Cleaning up Docker system..."
docker system prune -f

echo "Building config-server..."
docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local build --no-cache config-server

echo "Testing config-server standalone..."
docker run -d --name test-config-server -p 8888:8888 \
  -e SPRING_PROFILES_ACTIVE=production \
  logistics_platform-config-server

echo "Waiting for config-server to start..."
sleep 30

echo "Testing config-server health..."
if curl -f http://localhost:8888/actuator/health; then
    echo "✅ Config-server is healthy!"
else
    echo "❌ Config-server health check failed"
    docker logs test-config-server
    exit 1
fi

docker stop test-config-server
docker rm test-config-server

echo "✅ Config-server fix completed successfully!"
