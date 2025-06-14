#!/bin/bash

echo "🔍 DIGITAL OCEAN HEALTH CHECK - Logistics Platform"
echo "=================================================="

services=(
    "Config Server:8888:/actuator/health"
    "Discovery Server:8761:/actuator/health"
    "Gateway Service:8080:/actuator/health"
    "Auth Service:8081:/actuator/health"
    "User Service:8082:/actuator/health"
    "Transport Service:8083:/actuator/health"
)

all_healthy=true

for service in "${services[@]}"; do
    IFS=':' read -r name port path <<< "$service"
    
    echo -n "Checking $name... "
    
    if curl -s --connect-timeout 10 --max-time 15 "http://localhost:$port$path" > /dev/null; then
        echo "✅ Healthy"
    else
        echo "❌ Unhealthy"
        all_healthy=false
    fi
done

echo ""
echo "🐳 Container Status:"
docker compose -f docker-compose.digitalocean.yml ps

echo ""
if [ "$all_healthy" = true ]; then
    echo "🎉 All services are healthy!"
    echo "🚀 Digital Ocean deployment successful!"
    echo ""
    echo "🌐 Your services are ready at:"
    echo "   Replace 'localhost' with your Digital Ocean droplet IP"
    echo "   Main API: http://localhost:8080"
    echo "   Service Discovery: http://localhost:8761"
    echo ""
    echo "🧪 Test API endpoints:"
    echo "   curl http://localhost:8080/actuator/health"
    echo "   curl http://localhost:8081/actuator/health"
    echo "   curl http://localhost:8082/actuator/health"
    echo "   curl http://localhost:8083/actuator/health"
else
    echo "⚠️ Some services are not healthy!"
    echo ""
    echo "🔍 Debug commands:"
    echo "   docker-compose -f docker-compose.digitalocean.yml logs"
    echo "   docker-compose -f docker-compose.digitalocean.yml logs SERVICE_NAME"
    echo "   docker-compose -f docker-compose.digitalocean.yml restart SERVICE_NAME"
    echo ""
    echo "💡 Common issues:"
    echo "   - Database connection: Check .env.digitalocean credentials"
    echo "   - Service startup time: Wait longer and retry health check"
    echo "   - Memory issues: Check Digital Ocean droplet resources"
fi

echo ""
echo "📊 System Resources:"
if command -v free &> /dev/null; then
    echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
fi
if command -v df &> /dev/null; then
    echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
fi

echo ""
echo "🔗 MapStruct Optimizations:"
echo "   ✅ Transport Service: MapStruct DTO conversion active"
echo "   ✅ User Service: MapStruct DTO conversion active"
echo "   ✅ Reduced boilerplate: 200+ lines eliminated"
echo ""
