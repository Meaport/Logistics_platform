#!/bin/bash

echo "🌊 DIGITAL OCEAN DEPLOYMENT - LOGISTICS PLATFORM"
echo "================================================"

cd "$(dirname "$0")"

echo "🔍 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven first."
    exit 1
fi

echo "✅ Prerequisites check passed"

echo "📝 Loading Digital Ocean environment configuration..."
if [ ! -f ".env.digitalocean" ]; then
    echo "❌ .env.digitalocean file not found. Please create it with your Digital Ocean database credentials."
    echo "📋 Required variables:"
    echo "   - DATABASE_HOST"
    echo "   - DATABASE_PORT"
    echo "   - DATABASE_NAME"
    echo "   - DATABASE_USERNAME"
    echo "   - DATABASE_PASSWORD"
    echo "   - JWT_SECRET"
    exit 1
fi

set -a
source .env.digitalocean
set +a

echo "✅ Environment configuration loaded"

echo "🏗️ Building Java microservices with Maven..."

services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

for service in "${services[@]}"; do
    echo "Building $service..."
    cd "$service"
    if ! mvn clean package -DskipTests; then
        echo "❌ Failed to build $service"
        exit 1
    fi
    cd ..
    echo "✅ $service built successfully"
done

echo "✅ All microservices built successfully"

echo "🐳 Building Docker images..."
if ! docker-compose -f docker-compose.digitalocean.yml build; then
    echo "❌ Failed to build Docker images"
    exit 1
fi

echo "✅ Docker images built successfully"

echo "🚀 Deploying services to Digital Ocean..."
docker-compose -f docker-compose.digitalocean.yml up -d

echo "⏳ Waiting for services to be ready..."
sleep 90

echo "🔍 Running health checks..."
./health-check-digitalocean.sh

echo ""
echo "🎉 Digital Ocean deployment completed!"
echo ""
echo "🌐 Access URLs (replace with your actual Digital Ocean droplet IP):"
echo "   Main Application: http://YOUR_DROPLET_IP"
echo "   API Gateway: http://YOUR_DROPLET_IP:8080"
echo "   Discovery Server: http://YOUR_DROPLET_IP:8761"
echo "   Config Server: http://YOUR_DROPLET_IP:8888"
echo "   Auth Service: http://YOUR_DROPLET_IP:8081"
echo "   User Service: http://YOUR_DROPLET_IP:8082"
echo "   Transport Service: http://YOUR_DROPLET_IP:8083"
echo ""
echo "📊 Monitoring:"
echo "   Health: http://YOUR_DROPLET_IP:8080/actuator/health"
echo "   Metrics: http://YOUR_DROPLET_IP:8080/actuator/metrics"
echo ""
echo "🔧 Management Commands:"
echo "   View logs: docker-compose -f docker-compose.digitalocean.yml logs -f"
echo "   Stop services: docker-compose -f docker-compose.digitalocean.yml down"
echo "   Restart service: docker-compose -f docker-compose.digitalocean.yml restart SERVICE_NAME"
echo ""
