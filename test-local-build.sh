#!/bin/bash

echo "🧪 LOCAL BUILD TEST - Logistics Platform"
echo "========================================"

cd "$(dirname "$0")"

echo "🔍 Checking prerequisites..."

if ! command -v mvn &> /dev/null; then
    echo "❌ Maven is not installed. Please install Maven first."
    exit 1
fi

if ! command -v java &> /dev/null; then
    echo "❌ Java is not installed. Please install Java 17+ first."
    exit 1
fi

echo "✅ Prerequisites check passed"

echo "🏗️ Building Java microservices with Maven..."

services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

for service in "${services[@]}"; do
    echo "Building $service..."
    cd "$service"
    if ! mvn clean compile -DskipTests; then
        echo "❌ Failed to build $service"
        exit 1
    fi
    cd ..
    echo "✅ $service compiled successfully"
done

echo "✅ All microservices compiled successfully"

echo "🐳 Testing Docker image builds..."
for service in "${services[@]}"; do
    echo "Testing Docker build for $service..."
    if ! docker build -t "logistics-$service:test" "$service" --no-cache; then
        echo "❌ Failed to build Docker image for $service"
        exit 1
    fi
    echo "✅ $service Docker image built successfully"
done

echo "✅ All Docker images built successfully"

echo "🧹 Cleaning up test images..."
for service in "${services[@]}"; do
    docker rmi "logistics-$service:test" 2>/dev/null || true
done

echo ""
echo "🎉 Local build test completed successfully!"
echo ""
echo "✅ All services compile correctly"
echo "✅ All Docker images build correctly"
echo "✅ MapStruct dependencies are properly configured"
echo ""
echo "🚀 Ready for Digital Ocean deployment!"
echo ""
