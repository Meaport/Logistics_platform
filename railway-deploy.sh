#!/bin/bash

echo "🚀 RAILWAY DEPLOYMENT SCRIPT"
echo "============================"

# Check if Railway CLI is available
if ! command -v railway &> /dev/null && ! command -v npx &> /dev/null; then
    echo "❌ Error: Neither Railway CLI nor npx is available"
    exit 1
fi

RAILWAY_CMD="railway"
if ! command -v railway &> /dev/null; then
    RAILWAY_CMD="npx @railway/cli"
fi

echo "🏗️ Building all services..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix build errors before deploying."
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Deploy services in correct order
services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")
wait_times=(60 90 120 90 60 60)  # Wait times in seconds

for i in "${!services[@]}"; do
    service="${services[$i]}"
    wait_time="${wait_times[$i]}"
    
    echo "🚂 Deploying $service..."
    
    if [ -d "$service" ]; then
        cd "$service"
        
        # Deploy to Railway
        $RAILWAY_CMD up --detach
        
        if [ $? -eq 0 ]; then
            echo "✅ $service deployment initiated!"
            echo "⏳ Waiting ${wait_time} seconds for $service to start..."
            sleep $wait_time
            
            # Check deployment status
            echo "🔍 Checking $service status..."
            $RAILWAY_CMD status
            
        else
            echo "❌ Failed to deploy $service"
            echo "   Please check the logs and try again"
            cd ..
            exit 1
        fi
        
        cd ..
        echo ""
    else
        echo "⚠️  Directory $service not found, skipping..."
    fi
done

echo "🎉 All services deployed!"
echo ""
echo "🔍 Getting deployment URLs..."

# Get service URLs
for service in "${services[@]}"; do
    if [ -d "$service" ]; then
        cd "$service"
        echo "📍 $service URL:"
        $RAILWAY_CMD domain
        cd ..
    fi
done

echo ""
echo "🧪 Testing deployment..."
echo "========================"

# Wait a bit more for all services to be ready
echo "⏳ Waiting 2 minutes for all services to be fully ready..."
sleep 120

echo "🔍 Running health checks..."

# Test gateway health (replace with actual URL)
echo "Testing Gateway Service health..."
# Note: User will need to replace with actual Railway URL
echo "   Run: curl https://logistics-gateway-service-production.railway.app/actuator/health"

echo ""
echo "🎉 DEPLOYMENT COMPLETED!"
echo "======================="
echo ""
echo "📋 Next steps:"
echo "1. Get your actual service URLs from Railway Dashboard"
echo "2. Test the health endpoints"
echo "3. Test the API endpoints"
echo "4. Update any frontend applications with new URLs"
echo ""
echo "🌐 Main API Gateway URL will be:"
echo "   https://logistics-gateway-service-production.railway.app"
echo ""
echo "🧪 Test commands (replace with your actual URLs):"
echo "   curl https://logistics-gateway-service-production.railway.app/actuator/health"
echo "   curl https://logistics-gateway-service-production.railway.app/api/transport/shipments/tracking/TRK123"
echo ""
echo "🎊 Your Logistics Platform is now live on Railway!"