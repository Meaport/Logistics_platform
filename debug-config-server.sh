#!/bin/bash

set -e

echo "🔍 DEBUG CONFIG-SERVER HEALTH CHECK FAILURE"
echo "=============================================="

echo ""
echo "📊 Current container status:"
docker ps -a | grep config-server || echo "No config-server container found"

echo ""
echo "📋 Config-server logs (last 50 lines):"
docker logs logistics-config-server --tail=50 2>&1 || echo "Failed to get logs"

echo ""
echo "🔍 Testing health endpoint manually:"
echo "Attempting to connect to config-server health endpoint..."

if docker ps | grep -q logistics-config-server; then
    echo "✅ Config-server container is running"
    
    echo ""
    echo "🧪 Testing health endpoint from inside container:"
    docker exec logistics-config-server wget --quiet --tries=1 --spider http://localhost:8888/actuator/health 2>&1 && echo "✅ Health endpoint accessible from inside container" || echo "❌ Health endpoint NOT accessible from inside container"
    
    echo ""
    echo "🧪 Testing health endpoint from host:"
    curl -f -s http://localhost:8888/actuator/health > /dev/null 2>&1 && echo "✅ Health endpoint accessible from host" || echo "❌ Health endpoint NOT accessible from host"
    
    echo ""
    echo "📋 Actual health endpoint response:"
    curl -s http://localhost:8888/actuator/health 2>&1 || echo "Failed to get health response"
    
    echo ""
    echo "🧪 Testing if Spring Boot application is fully started:"
    docker exec logistics-config-server ps aux | grep java || echo "Java process not found"
    
else
    echo "❌ Config-server container is NOT running"
fi

echo ""
echo "🔧 Docker health check configuration:"
docker inspect logistics-config-server | grep -A 10 -B 2 "Healthcheck" || echo "No healthcheck configuration found"

echo ""
echo "📊 Container resource usage:"
docker stats logistics-config-server --no-stream 2>&1 || echo "Failed to get container stats"

echo ""
echo "🔍 Network connectivity test:"
docker exec logistics-config-server netstat -tlnp 2>&1 | grep 8888 || echo "Port 8888 not listening"

echo ""
echo "📋 Environment variables in container:"
docker exec logistics-config-server env | grep -E "(SPRING|MANAGEMENT|LOGGING)" || echo "No relevant environment variables found"

echo ""
echo "🎯 DIAGNOSIS COMPLETE"
echo "Check the output above to identify the root cause of health check failure"
