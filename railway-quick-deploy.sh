#!/bin/bash

echo "🚂 RAILWAY QUICK DEPLOYMENT"
echo "==========================="

# Check if user is logged in
echo "🔍 Checking Railway login status..."
npx @railway/cli whoami

if [ $? -ne 0 ]; then
    echo "❌ You are not logged in to Railway"
    echo "   Please run: npx @railway/cli login"
    exit 1
fi

echo "✅ Railway login confirmed!"
echo ""

# Generate JWT secret
JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' 2>/dev/null || echo "mySecretKey123456789012345678901234567890")
echo "🔑 Generated JWT Secret: $JWT_SECRET"
echo ""

echo "🚀 Starting deployment process..."
echo ""

# Deploy each service
services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")
ports=(8888 8761 8080 8081 8082 8083)

for i in "${!services[@]}"; do
    service="${services[$i]}"
    port="${ports[$i]}"
    
    echo "📦 Deploying $service..."
    
    if [ -d "$service" ]; then
        cd "$service"
        
        # Create Railway project
        npx @railway/cli new --name "logistics-$service"
        
        if [ $? -eq 0 ]; then
            echo "✅ Project created for $service"
            
            # Set basic environment variables
            npx @railway/cli variables set PORT="$port"
            npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
            npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
            
            # Deploy
            npx @railway/cli up --detach
            
            if [ $? -eq 0 ]; then
                echo "✅ $service deployed successfully!"
                
                # Get domain
                DOMAIN=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-$service-production.railway.app")
                echo "🌐 $service URL: $DOMAIN"
                
                # Wait for service to start
                echo "⏳ Waiting for $service to start..."
                sleep 30
            else
                echo "❌ Failed to deploy $service"
            fi
        else
            echo "❌ Failed to create project for $service"
        fi
        
        cd ..
        echo ""
    else
        echo "⚠️  Directory $service not found, skipping..."
    fi
done

echo "🎉 Quick deployment completed!"
echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo "1. Set DATABASE_URL for auth-service, user-service, and transport-service"
echo "2. Set EUREKA_DEFAULT_ZONE for all services except config-server"
echo "3. Set CONFIG_SERVER_URL for all services except config-server"
echo ""
echo "🌐 Railway Dashboard: https://railway.app/dashboard"
echo "🔑 JWT Secret: $JWT_SECRET"