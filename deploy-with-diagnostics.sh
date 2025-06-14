#!/bin/bash

set -e

echo "🚀 DEPLOYMENT WITH COMPREHENSIVE DIAGNOSTICS"
echo "============================================="

echo ""
echo "🔧 Environment setup..."
if [ ! -f .env.digitalocean.local ]; then
    echo "❌ .env.digitalocean.local not found!"
    exit 1
fi

echo ""
echo "🧹 Cleanup existing containers..."
docker compose -f docker-compose.digitalocean.yml down 2>/dev/null || true
docker system prune -f

echo ""
echo "🚀 Starting deployment with diagnostics..."

echo "🔧 Starting config-server..."
docker compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d config-server

echo ""
echo "⏳ Waiting for config-server (2 minutes)..."
sleep 120

echo ""
echo "🔍 Running config-server diagnostics..."
./debug-config-server.sh

if curl -f -s http://localhost:8888/actuator/health > /dev/null; then
    echo "✅ Config-server is healthy, continuing deployment..."
    
    echo "🔧 Starting discovery-server..."
    docker compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d discovery-server
    
    echo "⏳ Waiting for discovery-server (2 minutes)..."
    sleep 120
    
    echo "🔧 Starting remaining services..."
    docker compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d
    
    echo "⏳ Waiting for all services (3 minutes)..."
    sleep 180
    
    echo "🔍 Final health checks..."
    ./health-check-digitalocean.sh
    
else
    echo "❌ Config-server health check failed!"
    echo "🧪 Trying standalone config-server test..."
    ./standalone-config-test.sh
    
    echo "🔧 Trying health check timing fix..."
    ./fix-health-check-timing.sh
fi

echo ""
echo "📊 Final container status:"
docker ps

echo ""
echo "🎯 Deployment with diagnostics complete!"
