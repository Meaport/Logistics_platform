#!/bin/bash

echo "🚂 RAILWAY DEPLOYMENT SETUP SCRIPT"
echo "=================================="

# Note: Railway CLI cannot be installed globally in WebContainer
# Users will need to install it locally or use npx
echo "⚠️  Note: Railway CLI needs to be installed locally due to WebContainer limitations"
echo "📦 You can use Railway CLI by running: npx @railway/cli <command>"
echo "    Or install locally: npm install @railway/cli"

# Check if we're in the right directory (should have pom.xml)
if [ ! -f "pom.xml" ]; then
    echo "❌ Error: This script must be run from the project root directory"
    echo "   Make sure you're in the directory containing pom.xml"
    exit 1
fi

# Create railway.toml files for each service
echo "📝 Creating Railway configuration files..."

# Check if service directories exist
services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")
missing_services=()

for service in "${services[@]}"; do
    if [ ! -d "$service" ]; then
        missing_services+=("$service")
    fi
done

if [ ${#missing_services[@]} -ne 0 ]; then
    echo "❌ Error: The following service directories are missing:"
    for service in "${missing_services[@]}"; do
        echo "   - $service"
    done
    echo "   Please ensure all microservice directories exist"
    exit 1
fi

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
    local app_yml_path="$service_dir/src/main/resources/application.yml"
    
    # Check if application.yml exists
    if [ ! -f "$app_yml_path" ]; then
        echo "⚠️  Warning: $app_yml_path not found, skipping..."
        return
    fi
    
    # Check if railway profile already exists
    if grep -q "on-profile: railway" "$app_yml_path"; then
        echo "ℹ️  Railway profile already exists in $service_dir, skipping..."
        return
    fi
    
    cat >> "$app_yml_path" << EOF

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
    
    echo "✅ Added Railway profile to $service_dir"
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

# Check if Railway CLI is available
if ! command -v railway &> /dev/null && ! command -v npx &> /dev/null; then
    echo "❌ Error: Neither Railway CLI nor npx is available"
    echo "   Please install Railway CLI: npm install @railway/cli"
    exit 1
fi

# Use npx if railway command is not available
RAILWAY_CMD="railway"
if ! command -v railway &> /dev/null; then
    RAILWAY_CMD="npx @railway/cli"
    echo "ℹ️  Using npx to run Railway CLI"
fi

# Build all services
echo "🏗️ Building all services..."
mvn clean package -DskipTests

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please fix build errors before deploying."
    exit 1
fi

# Deploy services in order
services=("config-server" "discovery-server" "gateway-service" "auth-service" "user-service" "transport-service")

for service in "${services[@]}"; do
    echo "🚂 Deploying $service..."
    if [ -d "$service" ]; then
        cd "$service"
        $RAILWAY_CMD up --detach
        if [ $? -eq 0 ]; then
            echo "✅ $service deployed!"
        else
            echo "❌ Failed to deploy $service"
        fi
        cd ..
        sleep 30  # Wait for service to start
    else
        echo "⚠️  Directory $service not found, skipping..."
    fi
done

echo "🎉 Deployment process completed!"
echo ""
echo "🌐 Your services should be available at Railway-generated URLs"
echo "   Check your Railway dashboard for the actual URLs"
EOF

chmod +x deploy-to-railway.sh

echo ""
echo "🎉 Railway setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Install Railway CLI locally: npm install @railway/cli"
echo "2. Login to Railway: npx @railway/cli login"
echo "3. Set up your database environment variables in Railway dashboard"
echo "4. Run: ./deploy-to-railway.sh"
echo "5. Test your deployed services"
echo ""
echo "🔗 Important environment variables to set in Railway:"
echo "   DATABASE_URL: [Your Supabase connection string]"
echo "   DATABASE_PASSWORD: [Your database password]"
echo "   JWT_SECRET: [Strong secret key]"
echo "   EUREKA_DEFAULT_ZONE: [Discovery server URL after deployment]"
echo ""
echo "🚂 Ready for Railway deployment!"