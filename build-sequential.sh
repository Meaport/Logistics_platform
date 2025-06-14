#!/bin/bash

set -e

echo "🚀 Starting sequential Docker build for Logistics Platform..."
echo "This approach builds services one by one to avoid memory issues."

if [ -f .env.digitalocean.local ]; then
    source .env.digitalocean.local
    echo "✅ Loaded environment variables from .env.digitalocean.local"
else
    echo "❌ .env.digitalocean.local not found!"
    exit 1
fi

echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local down || true

echo "🧹 Cleaning up Docker system..."
docker system prune -f

SERVICES=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

echo ""
echo "📦 Building services in order: ${SERVICES[*]}"
echo ""

export DOCKER_BUILDKIT=0

for service in "${SERVICES[@]}"; do
    echo "🔨 Building $service..."
    start_time=$(date +%s)
    
    if docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local build --no-cache --memory=1g "$service"; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo "✅ $service built successfully in ${duration}s"
        
        docker system prune -f --volumes=false
        docker image prune -f
        echo "🧹 Cleaned up intermediate containers and images"
        
        sleep 10
    else
        echo "❌ Failed to build $service"
        echo "📋 Showing Docker logs for debugging..."
        docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local logs "$service" || true
        exit 1
    fi
    
    echo ""
done

echo "🎉 All services built successfully!"
echo ""
echo "🚀 Starting services in order..."

for service in "${SERVICES[@]}"; do
    echo "▶️ Starting $service..."
    docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local up -d "$service"
    
    if [ "$service" = "config-server" ]; then
        echo "⏳ Waiting for config-server to be ready..."
        sleep 45
    elif [ "$service" = "discovery-server" ]; then
        echo "⏳ Waiting for discovery-server to be ready..."
        sleep 60
    else
        echo "⏳ Waiting for $service to be ready..."
        sleep 30
    fi
done

echo ""
echo "⏳ Final wait for all services to stabilize (2 minutes)..."
sleep 120

echo ""
echo "🔍 Running health checks..."
if [ -f "./health-check-digitalocean.sh" ]; then
    ./health-check-digitalocean.sh
else
    echo "Health check script not found, running manual checks..."
    curl -f http://localhost:8888/actuator/health || echo "Config-server health check failed"
    curl -f http://localhost:8761/actuator/health || echo "Discovery-server health check failed"
    curl -f http://localhost:8080/actuator/health || echo "Gateway-service health check failed"
fi

echo ""
echo "✅ Sequential build and deployment completed!"
echo ""
echo "📊 Container status:"
docker-compose -f docker-compose.digitalocean.yml --env-file .env.digitalocean.local ps
