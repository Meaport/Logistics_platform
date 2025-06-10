#!/bin/bash

echo "🚂 RAILWAY DEPLOYMENT SETUP SCRIPT"
echo "=================================="

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli
fi

# Login to Railway
echo "🔐 Logging into Railway..."
railway login

# Create railway.toml files for each service
echo "📝 Creating Railway configuration files..."

# Config Server
cat > config-server/railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8888"
SPRING_PROFILES_ACTIVE = "railway"
EOF

# Discovery Server
cat > discovery-server/railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8761"
SPRING_PROFILES_ACTIVE = "railway"
EOF

# Gateway Service
cat > gateway-service/railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8080"
SPRING_PROFILES_ACTIVE = "railway"
EOF

# Auth Service
cat > auth-service/railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8081"
SPRING_PROFILES_ACTIVE = "railway"
EOF

# User Service
cat > user-service/railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8082"
SPRING_PROFILES_ACTIVE = "railway"
EOF

# Transport Service
cat > transport-service/railway.toml << 'EOF'
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8083"
SPRING_PROFILES_ACTIVE = "railway"
EOF

echo "✅ Railway configuration files created!"

# Add Railway profiles to application.yml files
echo "📝 Adding Railway profiles to application.yml files..."

# Function to add Railway profile to application.yml
add_railway_profile() {
    local service_dir=$1
    local port=$2
    
    cat >> "$service_dir/src/main/resources/application.yml" << EOF

---
spring:
  config:
    activate:
      on-profile: railway
  datasource:
    url: \${DATABASE_URL}
    username: postgres
    password: \${DATABASE_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

server:
  port: \${PORT:$port}

eureka:
  client:
    service-url:
      defaultZone: \${EUREKA_DEFAULT_ZONE:http://localhost:8761/eureka/}
  instance:
    hostname: \${RAILWAY_PUBLIC_DOMAIN:localhost}
    prefer-ip-address: false

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics

jwt:
  secret: \${JWT_SECRET:mySecretKey123456789012345678901234567890}
  expiration: 86400000
EOF
}

# Add Railway profiles to each service
add_railway_profile "config-server" "8888"
add_railway_profile "discovery-server" "8761"
add_railway_profile "gateway-service" "8080"
add_railway_profile "auth-service" "8081"
add_railway_profile "user-service" "8082"
add_railway_profile "transport-service" "8083"

echo "✅ Railway profiles added to all services!"

# Create deployment script
cat > deploy-to-railway.sh << 'EOF'
#!/bin/bash

echo "🚀 DEPLOYING TO RAILWAY..."
echo "========================="

# Build all services
echo "🏗️ Building all services..."
mvn clean package -DskipTests

# Deploy services in order
services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

for service in "${services[@]}"; do
    echo "🚂 Deploying $service..."
    cd "$service"
    railway up --detach
    cd ..
    echo "✅ $service deployed!"
    sleep 30  # Wait for service to start
done

echo "🎉 All services deployed to Railway!"
echo ""
echo "🌐 Your services will be available at:"
echo "   Config Server: https://config-server-production.railway.app"
echo "   Discovery Server: https://discovery-server-production.railway.app"
echo "   Gateway Service: https://gateway-service-production.railway.app"
echo "   Auth Service: https://auth-service-production.railway.app"
echo "   User Service: https://user-service-production.railway.app"
echo "   Transport Service: https://transport-service-production.railway.app"
EOF

chmod +x deploy-to-railway.sh

echo ""
echo "🎉 Railway setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Set up your Supabase environment variables in Railway dashboard"
echo "2. Run: ./deploy-to-railway.sh"
echo "3. Test your deployed services"
echo ""
echo "🔗 Important URLs to configure in Railway:"
echo "   DATABASE_URL: [Your Supabase connection string]"
echo "   JWT_SECRET: [Strong secret key]"
echo "   EUREKA_DEFAULT_ZONE: https://discovery-server-production.railway.app/eureka/"
echo ""
echo "🚂 Ready for Railway deployment!"