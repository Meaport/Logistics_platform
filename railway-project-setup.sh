#!/bin/bash

echo "🚂 RAILWAY PROJECT SETUP - STEP 2"
echo "================================="

# Check if Railway CLI is available
if ! command -v railway > /dev/null 2>&1 && ! command -v npx > /dev/null 2>&1; then
    echo "❌ Error: Neither Railway CLI nor npx is available"
    echo "   Please install Railway CLI: npm install @railway/cli"
    exit 1
fi

# Use npx if railway command is not available
RAILWAY_CMD="railway"
if ! command -v railway > /dev/null 2>&1; then
    RAILWAY_CMD="npx @railway/cli"
    echo "ℹ️  Using npx to run Railway CLI"
fi

echo "🔍 Checking Railway login status..."
$RAILWAY_CMD whoami

if [ $? -ne 0 ]; then
    echo "❌ You are not logged in to Railway"
    echo "   Please run: $RAILWAY_CMD login"
    exit 1
fi

echo "✅ Railway login confirmed!"
echo ""

# Create projects for each service
echo "🏗️ Creating Railway projects for each microservice..."
echo ""

services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

for service in "${services[@]}"; do
    echo "📦 Creating project for $service..."
    
    if [ -d "$service" ]; then
        cd "$service"
        
        # Create new Railway project
        $RAILWAY_CMD new --name "logistics-$service"
        
        if [ $? -eq 0 ]; then
            echo "✅ Project created for $service"
            
            # Link the project
            $RAILWAY_CMD link
            
            echo "🔗 Project linked for $service"
        else
            echo "❌ Failed to create project for $service"
        fi
        
        cd ..
        echo ""
    else
        echo "⚠️  Directory $service not found, skipping..."
    fi
done

echo "🎉 All Railway projects created!"
echo ""
echo "📋 Next steps:"
echo "1. Set environment variables for each service"
echo "2. Deploy services in the correct order"
echo "3. Test the deployment"
echo ""
echo "🔧 Run the environment setup script next:"
echo "   ./railway-env-setup.sh"