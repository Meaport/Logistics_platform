#!/bin/bash

set -e

echo "🔧 FIXING CONFIG-SERVER HEALTH CHECK TIMING"
echo "============================================"

echo ""
echo "📋 Current health check configuration:"
grep -A 5 -B 1 "healthcheck:" docker-compose.digitalocean.yml | head -20

echo ""
echo "🔧 Creating optimized health check configuration..."

cat > docker-compose.health-fix.yml << 'EOF'
version: '3.8'

services:
  config-server:
    build: 
      context: .
      dockerfile: ./config-server/Dockerfile
    container_name: logistics-config-server
    ports:
      - "8888:8888"
    environment:
      - SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE:-production}
      - MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=${MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE:-health,info,refresh}
      - LOGGING_LEVEL_ROOT=${LOGGING_LEVEL_ROOT:-INFO}
    networks:
      - logistics-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "sh", "-c", "wget --quiet --tries=1 --spider http://localhost:8888/actuator/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s  # Increased from 45s to 120s

  discovery-server:
    build: 
      context: .
      dockerfile: ./discovery-server/Dockerfile
    container_name: logistics-discovery-server
    ports:
      - "8761:8761"
    depends_on:
      config-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - EUREKA_INSTANCE_HOSTNAME=${EUREKA_INSTANCE_HOSTNAME:-localhost}
      - MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=${MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE:-health,info,refresh}
      - LOGGING_LEVEL_ROOT=${LOGGING_LEVEL_ROOT:-INFO}
    networks:
      - logistics-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "sh", "-c", "wget --quiet --tries=1 --spider http://localhost:8761/actuator/health || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 150s  # Increased from 60s to 150s

networks:
  logistics-network:
    driver: bridge
    name: logistics-network
EOF

echo "✅ Created docker-compose.health-fix.yml with relaxed timing"

echo ""
echo "🚀 Testing config-server with relaxed health check timing..."

echo "🛑 Stopping existing containers..."
docker compose -f docker-compose.digitalocean.yml down 2>/dev/null || true

echo "🚀 Starting config-server with relaxed health check..."
docker compose -f docker-compose.health-fix.yml --env-file .env.digitalocean.local up -d config-server

echo ""
echo "⏳ Waiting for config-server to start (2 minutes)..."
sleep 120

echo ""
echo "🔍 Checking config-server health status..."
docker ps | grep config-server

echo ""
echo "📋 Config-server logs:"
docker logs logistics-config-server --tail=20

echo ""
echo "🧪 Testing health endpoint:"
curl -f -s http://localhost:8888/actuator/health && echo "✅ Config-server health check PASSED" || echo "❌ Config-server health check FAILED"

echo ""
echo "🎯 Health check timing fix test complete!"
