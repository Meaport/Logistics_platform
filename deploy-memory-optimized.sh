#!/bin/bash

set -e

echo "🚀 Memory-Optimized Deployment for Digital Ocean"
echo "This script handles memory-constrained servers by building sequentially"

if [ -f .env.digitalocean.local ]; then
    source .env.digitalocean.local
    echo "✅ Loaded environment variables"
else
    echo "❌ .env.digitalocean.local not found!"
    echo "Please copy .env.digitalocean to .env.digitalocean.local and configure it"
    exit 1
fi

echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local down || true

echo "🧹 Cleaning up Docker system to free memory..."
docker system prune -f
docker volume prune -f

echo "🔧 Setting memory optimization flags..."
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

SERVICES=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

echo ""
echo "📦 Building services sequentially: ${SERVICES[*]}"
echo ""

for service in "${SERVICES[@]}"; do
    echo "🔨 Building $service with memory limits..."
    start_time=$(date +%s)
    
    if docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local build --no-cache --memory=1g "$service"; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo "✅ $service built successfully in ${duration}s"
        
        echo "🧹 Cleaning up to free memory..."
        docker system prune -f --volumes=false
        docker image prune -f
        
        echo "⏳ Brief pause to let system recover..."
        sleep 15
    else
        echo "❌ Failed to build $service"
        echo "📋 Docker system info:"
        docker system df
        exit 1
    fi
    
    echo ""
done

echo "🎉 All services built successfully!"
echo ""
echo "🚀 Starting services with staggered startup..."

docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d config-server
echo "⏳ Waiting for config-server (60s)..."
sleep 60

docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d discovery-server
echo "⏳ Waiting for discovery-server (90s)..."
sleep 90

docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d gateway-service
echo "⏳ Waiting for gateway-service (60s)..."
sleep 60

docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d auth-service user-service transport-service
echo "⏳ Waiting for remaining services (120s)..."
sleep 120

echo ""
echo "🔍 Running comprehensive health checks..."

HEALTH_ENDPOINTS=(
    "http://localhost:8888/actuator/health:config-server"
    "http://localhost:8761/actuator/health:discovery-server"
    "http://localhost:8080/actuator/health:gateway-service"
    "http://localhost:8081/actuator/health:auth-service"
    "http://localhost:8082/actuator/health:user-service"
    "http://localhost:8083/actuator/health:transport-service"
)

ALL_HEALTHY=true

for endpoint in "${HEALTH_ENDPOINTS[@]}"; do
    url="${endpoint%:*}"
    service="${endpoint#*:}"
    
    echo "🔍 Checking $service..."
    if curl -f -s "$url" > /dev/null; then
        echo "✅ $service is healthy"
    else
        echo "❌ $service health check failed"
        ALL_HEALTHY=false
    fi
done

echo ""
if [ "$ALL_HEALTHY" = true ]; then
    echo "🎉 All services are healthy!"
    echo ""
    echo "📊 Container status:"
    docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local ps
    echo ""
    echo "🌐 External access test (replace with your server IP):"
    echo "curl http://YOUR_SERVER_IP:8080/actuator/health"
    echo ""
    echo "✅ Memory-optimized deployment completed successfully!"
else
    echo "❌ Some services are not healthy. Check logs:"
    echo "docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local logs"
    exit 1
fi
