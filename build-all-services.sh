#!/bin/bash

echo "🏗️ BUILDING ALL MICROSERVICES - Logistics Platform"
echo "=================================================="

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

echo "🏗️ Building parent POM..."
if ! mvn clean install -N; then
    echo "❌ Failed to build parent POM"
    exit 1
fi
echo "✅ Parent POM built successfully"

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

echo ""
echo "📦 Generated JAR files:"
for service in "${services[@]}"; do
    jar_file=$(find "$service/target" -name "*.jar" -not -name "*-sources.jar" 2>/dev/null | head -1)
    if [ -n "$jar_file" ]; then
        echo "  ✅ $service: $jar_file"
    else
        echo "  ❌ $service: JAR file not found"
    fi
done

echo ""
echo "🎉 Build completed successfully!"
echo ""
echo "🚀 Ready for Docker deployment!"
echo ""
