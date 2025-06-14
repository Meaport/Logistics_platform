#!/bin/bash

set -e

echo "🧪 Testing config-server standalone..."

if [ -f .env.digitalocean.local ]; then
    source .env.digitalocean.local
    echo "✅ Loaded environment variables"
else
    echo "❌ .env.digitalocean.local not found!"
    exit 1
fi

echo "🛑 Stopping any existing test containers..."
docker stop test-config-server 2>/dev/null || true
docker rm test-config-server 2>/dev/null || true

echo "🔨 Building config-server..."
docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local build --no-cache config-server

echo "🚀 Starting config-server test container..."
docker run -d --name test-config-server -p 8888:8888 \
  -e SPRING_PROFILES_ACTIVE=production \
  -e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,refresh \
  -e LOGGING_LEVEL_ROOT=INFO \
  logistics_platform-config-server

echo "⏳ Waiting for config-server to start (45 seconds)..."
sleep 45

echo "🔍 Testing config-server health..."
for i in {1..5}; do
    if curl -f http://localhost:8888/actuator/health; then
        echo ""
        echo "✅ Config-server is healthy!"
        
        echo "📋 Config-server logs:"
        docker logs test-config-server --tail 20
        
        echo "🧹 Cleaning up test container..."
        docker stop test-config-server
        docker rm test-config-server
        
        echo "✅ Config-server test completed successfully!"
        exit 0
    else
        echo "❌ Health check attempt $i failed, retrying in 10 seconds..."
        sleep 10
    fi
done

echo "❌ Config-server health check failed after 5 attempts"
echo "📋 Config-server logs:"
docker logs test-config-server

echo "🧹 Cleaning up test container..."
docker stop test-config-server
docker rm test-config-server

exit 1
