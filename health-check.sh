#!/bin/bash

echo "🔍 LOGISTICS PLATFORM - HEALTH CHECK"
echo "===================================="

services=(
    "Config Server:8888:/actuator/health"
    "Discovery Server:8761:/actuator/health"
    "Gateway Service:8080:/actuator/health"
    "Auth Service:8081:/api/auth/health"
    "User Service:8082:/api/users/health"
    "Transport Service:8083:/api/transport/health"
)

all_healthy=true

for service in "${services[@]}"; do
    IFS=':' read -r name port path <<< "$service"
    
    echo -n "Checking $name... "
    
    if curl -s --connect-timeout 5 --max-time 10 "http://localhost:$port$path" > /dev/null; then
        echo "✅ Healthy"
    else
        echo "❌ Unhealthy"
        all_healthy=false
    fi
done

echo ""
echo "🐳 Docker Container Status:"
docker-compose -f docker-compose.production.yml ps

echo ""
if [ "$all_healthy" = true ]; then
    echo "🎉 All services are healthy!"
    echo ""
    echo "🌐 Test URLs:"
    echo "   Main Site: http://www.meaport.online"
    echo "   API Gateway: http://209.38.244.176:8080/actuator/health"
    echo "   Discovery: http://209.38.244.176:8761"
    echo ""
    echo "🧪 API Test Commands:"
    echo "   curl http://209.38.244.176:8080/api/auth/health"
    echo "   curl http://209.38.244.176:8080/api/transport/shipments/tracking/TEST123"
else
    echo "⚠️  Some services are not healthy!"
    echo ""
    echo "🔍 Debug commands:"
    echo "   docker-compose -f docker-compose.production.yml logs"
    echo "   docker-compose -f docker-compose.production.yml logs auth-service"
    echo "   docker-compose -f docker-compose.production.yml restart"
fi

echo ""
echo "📊 System Resources:"
echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo ""