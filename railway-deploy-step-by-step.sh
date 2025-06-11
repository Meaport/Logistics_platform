#!/bin/bash

echo "🚂 RAILWAY DEPLOYMENT - STEP BY STEP"
echo "===================================="

echo "📋 We'll deploy services in this order:"
echo "1. Config Server (8888)"
echo "2. Discovery Server (8761)" 
echo "3. Gateway Service (8080)"
echo "4. Auth Service (8081)"
echo "5. User Service (8082)"
echo "6. Transport Service (8083)"
echo ""

# Generate JWT secret
JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' 2>/dev/null || echo "mySecretKey123456789012345678901234567890")
echo "🔑 Generated JWT Secret: $JWT_SECRET"
echo ""

echo "🚀 STEP 1: Login to Railway"
echo "=========================="
echo "Run this command and follow the prompts:"
echo "npx @railway/cli login"
echo ""
echo "Press Enter when you've completed login..."
read -p ""

echo "🏗️ STEP 2: Create and Deploy Config Server"
echo "=========================================="
echo "Creating config-server project..."

cd config-server
echo "📦 Creating Railway project for config-server..."
npx @railway/cli new --name logistics-config-server

if [ $? -eq 0 ]; then
    echo "✅ Config server project created!"
    
    echo "🔧 Setting environment variables..."
    npx @railway/cli variables set PORT=8888
    npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
    npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
    
    echo "🚀 Deploying config-server..."
    npx @railway/cli up --detach
    
    if [ $? -eq 0 ]; then
        echo "✅ Config server deployed!"
        echo "⏳ Waiting 60 seconds for config server to start..."
        sleep 60
        
        # Get the URL
        CONFIG_URL=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-config-server-production.railway.app")
        echo "🌐 Config Server URL: $CONFIG_URL"
    else
        echo "❌ Config server deployment failed"
        exit 1
    fi
else
    echo "❌ Failed to create config server project"
    exit 1
fi

cd ..

echo ""
echo "🔍 STEP 3: Create and Deploy Discovery Server"
echo "============================================"

cd discovery-server
echo "📦 Creating Railway project for discovery-server..."
npx @railway/cli new --name logistics-discovery-server

if [ $? -eq 0 ]; then
    echo "✅ Discovery server project created!"
    
    echo "🔧 Setting environment variables..."
    npx @railway/cli variables set PORT=8761
    npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
    npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
    npx @railway/cli variables set CONFIG_SERVER_URL="$CONFIG_URL"
    
    echo "🚀 Deploying discovery-server..."
    npx @railway/cli up --detach
    
    if [ $? -eq 0 ]; then
        echo "✅ Discovery server deployed!"
        echo "⏳ Waiting 90 seconds for discovery server to start..."
        sleep 90
        
        # Get the URL
        DISCOVERY_URL=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-discovery-server-production.railway.app")
        echo "🌐 Discovery Server URL: $DISCOVERY_URL"
    else
        echo "❌ Discovery server deployment failed"
        exit 1
    fi
else
    echo "❌ Failed to create discovery server project"
    exit 1
fi

cd ..

echo ""
echo "🌐 STEP 4: Create and Deploy Gateway Service"
echo "==========================================="

cd gateway-service
echo "📦 Creating Railway project for gateway-service..."
npx @railway/cli new --name logistics-gateway-service

if [ $? -eq 0 ]; then
    echo "✅ Gateway service project created!"
    
    echo "🔧 Setting environment variables..."
    npx @railway/cli variables set PORT=8080
    npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
    npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
    npx @railway/cli variables set CONFIG_SERVER_URL="$CONFIG_URL"
    npx @railway/cli variables set EUREKA_DEFAULT_ZONE="$DISCOVERY_URL/eureka/"
    
    echo "🚀 Deploying gateway-service..."
    npx @railway/cli up --detach
    
    if [ $? -eq 0 ]; then
        echo "✅ Gateway service deployed!"
        echo "⏳ Waiting 120 seconds for gateway service to start..."
        sleep 120
        
        # Get the URL
        GATEWAY_URL=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-gateway-service-production.railway.app")
        echo "🌐 Gateway Service URL: $GATEWAY_URL"
    else
        echo "❌ Gateway service deployment failed"
        exit 1
    fi
else
    echo "❌ Failed to create gateway service project"
    exit 1
fi

cd ..

echo ""
echo "🔐 STEP 5: Create and Deploy Auth Service"
echo "========================================"

cd auth-service
echo "📦 Creating Railway project for auth-service..."
npx @railway/cli new --name logistics-auth-service

if [ $? -eq 0 ]; then
    echo "✅ Auth service project created!"
    
    echo "🔧 Setting environment variables..."
    npx @railway/cli variables set PORT=8081
    npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
    npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
    npx @railway/cli variables set CONFIG_SERVER_URL="$CONFIG_URL"
    npx @railway/cli variables set EUREKA_DEFAULT_ZONE="$DISCOVERY_URL/eureka/"
    
    echo "⚠️  IMPORTANT: You need to set DATABASE_URL manually in Railway dashboard"
    echo "   Format: postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=auth_service"
    echo ""
    echo "Press Enter when you've set the DATABASE_URL..."
    read -p ""
    
    echo "🚀 Deploying auth-service..."
    npx @railway/cli up --detach
    
    if [ $? -eq 0 ]; then
        echo "✅ Auth service deployed!"
        echo "⏳ Waiting 90 seconds for auth service to start..."
        sleep 90
        
        # Get the URL
        AUTH_URL=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-auth-service-production.railway.app")
        echo "🌐 Auth Service URL: $AUTH_URL"
    else
        echo "❌ Auth service deployment failed"
        exit 1
    fi
else
    echo "❌ Failed to create auth service project"
    exit 1
fi

cd ..

echo ""
echo "👤 STEP 6: Create and Deploy User Service"
echo "========================================"

cd user-service
echo "📦 Creating Railway project for user-service..."
npx @railway/cli new --name logistics-user-service

if [ $? -eq 0 ]; then
    echo "✅ User service project created!"
    
    echo "🔧 Setting environment variables..."
    npx @railway/cli variables set PORT=8082
    npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
    npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
    npx @railway/cli variables set CONFIG_SERVER_URL="$CONFIG_URL"
    npx @railway/cli variables set EUREKA_DEFAULT_ZONE="$DISCOVERY_URL/eureka/"
    
    echo "⚠️  IMPORTANT: You need to set DATABASE_URL manually in Railway dashboard"
    echo "   Format: postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=user_service"
    echo ""
    echo "Press Enter when you've set the DATABASE_URL..."
    read -p ""
    
    echo "🚀 Deploying user-service..."
    npx @railway/cli up --detach
    
    if [ $? -eq 0 ]; then
        echo "✅ User service deployed!"
        echo "⏳ Waiting 60 seconds for user service to start..."
        sleep 60
        
        # Get the URL
        USER_URL=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-user-service-production.railway.app")
        echo "🌐 User Service URL: $USER_URL"
    else
        echo "❌ User service deployment failed"
        exit 1
    fi
else
    echo "❌ Failed to create user service project"
    exit 1
fi

cd ..

echo ""
echo "🚛 STEP 7: Create and Deploy Transport Service"
echo "============================================="

cd transport-service
echo "📦 Creating Railway project for transport-service..."
npx @railway/cli new --name logistics-transport-service

if [ $? -eq 0 ]; then
    echo "✅ Transport service project created!"
    
    echo "🔧 Setting environment variables..."
    npx @railway/cli variables set PORT=8083
    npx @railway/cli variables set SPRING_PROFILES_ACTIVE=railway
    npx @railway/cli variables set JWT_SECRET="$JWT_SECRET"
    npx @railway/cli variables set CONFIG_SERVER_URL="$CONFIG_URL"
    npx @railway/cli variables set EUREKA_DEFAULT_ZONE="$DISCOVERY_URL/eureka/"
    
    echo "⚠️  IMPORTANT: You need to set DATABASE_URL manually in Railway dashboard"
    echo "   Format: postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=transport_service"
    echo ""
    echo "Press Enter when you've set the DATABASE_URL..."
    read -p ""
    
    echo "🚀 Deploying transport-service..."
    npx @railway/cli up --detach
    
    if [ $? -eq 0 ]; then
        echo "✅ Transport service deployed!"
        echo "⏳ Waiting 60 seconds for transport service to start..."
        sleep 60
        
        # Get the URL
        TRANSPORT_URL=$(npx @railway/cli domain 2>/dev/null || echo "https://logistics-transport-service-production.railway.app")
        echo "🌐 Transport Service URL: $TRANSPORT_URL"
    else
        echo "❌ Transport service deployment failed"
        exit 1
    fi
else
    echo "❌ Failed to create transport service project"
    exit 1
fi

cd ..

echo ""
echo "🎉 DEPLOYMENT COMPLETED!"
echo "======================="
echo ""
echo "🌐 Service URLs:"
echo "   Config Server: $CONFIG_URL"
echo "   Discovery Server: $DISCOVERY_URL"
echo "   Gateway Service: $GATEWAY_URL"
echo "   Auth Service: $AUTH_URL"
echo "   User Service: $USER_URL"
echo "   Transport Service: $TRANSPORT_URL"
echo ""
echo "🔑 JWT Secret: $JWT_SECRET"
echo ""
echo "🧪 Test Commands:"
echo "   curl $GATEWAY_URL/actuator/health"
echo "   curl $GATEWAY_URL/api/transport/shipments/tracking/TRK123"
echo ""
echo "🎊 Your Logistics Platform is now live on Railway!"