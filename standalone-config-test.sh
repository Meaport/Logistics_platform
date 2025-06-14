#!/bin/bash

set -e

echo "🧪 STANDALONE CONFIG-SERVER TEST"
echo "================================="

echo ""
echo "🛑 Stopping all containers..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

echo ""
echo "🧹 Cleaning up networks..."
docker network prune -f

echo ""
echo "🚀 Building config-server image..."
docker build -t logistics-config-server -f config-server/Dockerfile .

echo ""
echo "🌐 Creating network..."
docker network create logistics-network || true

echo ""
echo "🚀 Running config-server standalone..."
docker run -d \
  --name logistics-config-server \
  --network logistics-network \
  -p 8888:8888 \
  -e SPRING_PROFILES_ACTIVE=production \
  -e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,refresh \
  -e LOGGING_LEVEL_ROOT=DEBUG \
  logistics-config-server

echo ""
echo "⏳ Waiting for config-server to start (90 seconds)..."
sleep 90

echo ""
echo "📋 Config-server logs:"
docker logs logistics-config-server

echo ""
echo "🔍 Container status:"
docker ps | grep config-server

echo ""
echo "🧪 Testing health endpoint (multiple attempts)..."
for i in {1..5}; do
    echo "Attempt $i:"
    if curl -f -s http://localhost:8888/actuator/health; then
        echo "✅ Health endpoint responded successfully"
        break
    else
        echo "❌ Health endpoint failed, waiting 10 seconds..."
        sleep 10
    fi
done

echo ""
echo "🔍 Network connectivity test:"
docker exec logistics-config-server netstat -tlnp | grep 8888 || echo "Port 8888 not listening"

echo ""
echo "🔍 Process check:"
docker exec logistics-config-server ps aux | grep java

echo ""
echo "🎯 Standalone config-server test complete!"
