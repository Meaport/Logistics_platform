#!/bin/bash

set -e

echo "🚨 EMERGENCY DEPLOYMENT - Last Chance Fix"
echo "This script will force-resolve all issues and deploy"

echo ""
echo "🛑 Stopping all containers..."
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true

echo ""
echo "🧹 Aggressive cleanup..."
docker system prune -af
docker volume prune -f

echo ""
echo "📥 Force pulling latest code..."
git fetch origin devin/1749816948-efficiency-improvements
git reset --hard origin/devin/1749816948-efficiency-improvements

echo ""
echo "🔧 Environment setup..."
if [ ! -f .env.digitalocean.local ]; then
    cp .env.digitalocean .env.digitalocean.local
    echo "DATABASE_HOST=logistics-db-do-user-23281658-0.j.db.ondigitalocean.com" >> .env.digitalocean.local
    echo "DATABASE_PORT=25060" >> .env.digitalocean.local
    echo "DATABASE_NAME=defaultdb" >> .env.digitalocean.local
    echo "DATABASE_USERNAME=doadmin" >> .env.digitalocean.local
    echo "DATABASE_PASSWORD=AVNS_8vM-hn2nGLEeJOhEhBH" >> .env.digitalocean.local
    echo "JWT_SECRET=mySecretKey123456789012345678901234567890" >> .env.digitalocean.local
fi

echo ""
echo "🔨 Making all scripts executable..."
chmod +x *.sh

echo ""
echo "🚀 Testing config-server first..."
if ./fix-config-server.sh; then
    echo "✅ Config-server test passed!"
    echo ""
    echo "🚀 Running full deployment..."
    ./deploy-memory-optimized.sh
else
    echo "❌ Config-server test failed"
    echo "🔧 Trying sequential build approach..."
    ./build-sequential.sh
fi

echo ""
echo "🔍 Final health check..."
sleep 30

SERVICES=("8888:config-server" "8761:discovery-server" "8080:gateway-service" "8081:auth-service" "8082:user-service" "8083:transport-service")

for service in "${SERVICES[@]}"; do
    port="${service%:*}"
    name="${service#*:}"
    
    if curl -f -s "http://localhost:$port/actuator/health" > /dev/null; then
        echo "✅ $name is healthy"
    else
        echo "❌ $name health check failed"
    fi
done

echo ""
echo "📊 Container status:"
docker ps

echo ""
echo "🎉 Emergency deployment completed!"
echo "Test external access: curl http://209.38.244.176:8080/actuator/health"
