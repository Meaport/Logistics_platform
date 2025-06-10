#!/bin/bash

echo "🚀 LOGISTICS PLATFORM - PRODUCTION DEPLOYMENT"
echo "=============================================="

# Ensure we're in the project root directory
cd "$(dirname "$0")"

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create production environment file
echo "📝 Creating production environment configuration..."

cat > .env.production << EOF
# Production Environment Configuration
SPRING_PROFILES_ACTIVE=production
DATABASE_URL=jdbc:postgresql://postgres:5432/logistics_db
DATABASE_USERNAME=logistics_user
DATABASE_PASSWORD=logistics_prod_pass_$(date +%s)
JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n')
JWT_EXPIRATION=86400000
EUREKA_DEFAULT_ZONE=http://discovery-server:8761/eureka/

# Security Settings
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
RATE_LIMIT_REQUESTS_PER_MINUTE=100

# Monitoring
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics,prometheus
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_LOGISTICS=INFO

# Performance Settings
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=5
SPRING_JPA_HIBERNATE_DDL_AUTO=validate
EOF

echo "✅ Production environment file created"

# Create production docker-compose file
echo "📝 Creating production Docker Compose configuration..."

cat > docker-compose.production.yml << 'EOF'
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: logistics-postgres-prod
    environment:
      POSTGRES_DB: logistics_db
      POSTGRES_USER: logistics_user
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_prod_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - logistics-prod-network
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  # Config Server
  config-server:
    build: 
      context: ./config-server
      dockerfile: Dockerfile
    container_name: logistics-config-server-prod
    ports:
      - "8888:8888"
    environment:
      - SPRING_PROFILES_ACTIVE=production
    networks:
      - logistics-prod-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8888/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s

  # Discovery Server
  discovery-server:
    build: 
      context: ./discovery-server
      dockerfile: Dockerfile
    container_name: logistics-discovery-server-prod
    ports:
      - "8761:8761"
    depends_on:
      config-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_CLOUD_CONFIG_URI=http://config-server:8888
    networks:
      - logistics-prod-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8761/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 90s

  # Gateway Service
  gateway-service:
    build: 
      context: ./gateway-service
      dockerfile: Dockerfile
    container_name: logistics-gateway-service-prod
    ports:
      - "8080:8080"
    depends_on:
      discovery-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_CLOUD_CONFIG_URI=http://config-server:8888
      - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://discovery-server:8761/eureka/
    networks:
      - logistics-prod-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 120s

  # Auth Service
  auth-service:
    build: 
      context: ./auth-service
      dockerfile: Dockerfile
    container_name: logistics-auth-service-prod
    ports:
      - "8081:8081"
    depends_on:
      postgres:
        condition: service_started
      gateway-service:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_CLOUD_CONFIG_URI=http://config-server:8888
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/logistics_db
      - SPRING_DATASOURCE_USERNAME=logistics_user
      - SPRING_DATASOURCE_PASSWORD=${DATABASE_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
    networks:
      - logistics-prod-network
    restart: unless-stopped
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M

  # User Service
  user-service:
    build: 
      context: ./user-service
      dockerfile: Dockerfile
    container_name: logistics-user-service-prod
    ports:
      - "8082:8082"
    depends_on:
      postgres:
        condition: service_started
      auth-service:
        condition: service_started
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_CLOUD_CONFIG_URI=http://config-server:8888
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/logistics_db
      - SPRING_DATASOURCE_USERNAME=logistics_user
      - SPRING_DATASOURCE_PASSWORD=${DATABASE_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
    networks:
      - logistics-prod-network
    restart: unless-stopped
    deploy:
      replicas: 2

  # Transport Service
  transport-service:
    build: 
      context: ./transport-service
      dockerfile: Dockerfile
    container_name: logistics-transport-service-prod
    ports:
      - "8083:8083"
    depends_on:
      postgres:
        condition: service_started
      auth-service:
        condition: service_started
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_CLOUD_CONFIG_URI=http://config-server:8888
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/logistics_db
      - SPRING_DATASOURCE_USERNAME=logistics_user
      - SPRING_DATASOURCE_PASSWORD=${DATABASE_PASSWORD}
      - JWT_SECRET=${JWT_SECRET}
    networks:
      - logistics-prod-network
    restart: unless-stopped
    deploy:
      replicas: 3

  # Nginx Load Balancer
  nginx:
    image: nginx:alpine
    container_name: logistics-nginx-prod
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - gateway-service
    networks:
      - logistics-prod-network
    restart: unless-stopped

volumes:
  postgres_prod_data:
    driver: local

networks:
  logistics-prod-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF

echo "✅ Production Docker Compose file created"

# Create database initialization script
echo "📝 Creating database initialization script..."

cat > init-db.sql << 'EOF'
-- Create separate databases for each service
CREATE DATABASE authdb;
CREATE DATABASE userdb;
CREATE DATABASE transportdb;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE authdb TO logistics_user;
GRANT ALL PRIVILEGES ON DATABASE userdb TO logistics_user;
GRANT ALL PRIVILEGES ON DATABASE transportdb TO logistics_user;

-- Create extensions
\c authdb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c userdb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c transportdb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOF

echo "✅ Database initialization script created"

# Create Nginx configuration
echo "📝 Creating Nginx load balancer configuration..."

cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream gateway_backend {
        server gateway-service:8080;
    }

    upstream auth_backend {
        server auth-service:8081;
    }

    upstream user_backend {
        server user-service:8082;
    }

    upstream transport_backend {
        server transport-service:8083;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req_zone $binary_remote_addr zone=auth:10m rate=5r/s;

    server {
        listen 80;
        server_name localhost;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";

        # Main API Gateway
        location / {
            limit_req zone=api burst=20 nodelay;
            proxy_pass http://gateway_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Auth service direct access
        location /auth/ {
            limit_req zone=auth burst=10 nodelay;
            proxy_pass http://auth_backend/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo "✅ Nginx configuration created"

# Create production deployment script
echo "📝 Creating production deployment commands..."

cat > deploy.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting production deployment..."

# Load environment variables
set -a
source .env.production
set +a

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose -f docker-compose.production.yml up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 60

# Run health checks
echo "🔍 Running health checks..."
./health-check-production.sh

echo "✅ Production deployment completed!"
echo ""
echo "🌐 Access URLs:"
echo "   Main Application: http://localhost"
echo "   API Gateway: http://localhost:8080"
echo "   Discovery Server: http://localhost:8761"
echo "   Config Server: http://localhost:8888"
echo ""
echo "📊 Monitoring:"
echo "   Health: http://localhost/actuator/health"
echo "   Metrics: http://localhost/actuator/metrics"
echo ""
EOF

chmod +x deploy.sh

# Create health check script
cat > health-check-production.sh << 'EOF'
#!/bin/bash

echo "🔍 Production Health Check"
echo "========================="

services=(
    "Config Server:8888:/actuator/health"
    "Discovery Server:8761:/actuator/health"
    "Gateway Service:8080:/actuator/health"
    "Auth Service:8081:/actuator/health"
    "User Service:8082:/actuator/health"
    "Transport Service:8083:/actuator/health"
    "Load Balancer:80:/health"
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
if [ "$all_healthy" = true ]; then
    echo "🎉 All services are healthy!"
    echo "🚀 Production deployment successful!"
else
    echo "⚠️ Some services are not healthy. Please check logs:"
    echo "   docker-compose -f docker-compose.production.yml logs"
fi
EOF

chmod +x health-check-production.sh

echo ""
echo "🎉 Production deployment setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Review the configuration files created"
echo "2. Customize .env.production for your environment"
echo "3. Run: ./deploy.sh"
echo "4. Test: ./health-check-production.sh"
echo ""
echo "📁 Files created:"
echo "   - .env.production (Environment configuration)"
echo "   - docker-compose.production.yml (Production compose file)"
echo "   - nginx.conf (Load balancer configuration)"
echo "   - init-db.sql (Database initialization)"
echo "   - deploy.sh (Deployment script)"
echo "   - health-check-production.sh (Health check script)"
echo ""
echo "🚀 Ready for production deployment!"