#!/bin/bash

echo "🔧 HIZLI DÜZELTME - Environment Variables"
echo "========================================"

cd /opt/logistics-platform

# .env.production dosyasını oluştur
cat > .env.production << 'EOF'
# Production Environment Configuration
SPRING_PROFILES_ACTIVE=production

# Database Configuration
DATABASE_URL=postgresql://logistics_user:logistics_prod_pass_2025@postgres:5432/logistics_db
DATABASE_USERNAME=logistics_user
DATABASE_PASSWORD=logistics_prod_pass_2025
JWT_SECRET=myVerySecureJWTSecretKeyForLogisticsPlatform2025WithMinimum32Characters

# Service Discovery
EUREKA_DEFAULT_ZONE=http://discovery-server:8761/eureka/

# Security Settings
CORS_ALLOWED_ORIGINS=*
RATE_LIMIT_REQUESTS_PER_MINUTE=100

# Monitoring
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_LOGISTICS=INFO

# Performance Settings
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=5
SPRING_JPA_HIBERNATE_DDL_AUTO=update
EOF

# Docker Compose dosyasını düzelt
cat > docker-compose.production.yml << 'EOF'
services:
  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: logistics-postgres
    environment:
      POSTGRES_DB: logistics_db
      POSTGRES_USER: logistics_user
      POSTGRES_PASSWORD: logistics_prod_pass_2025
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=C --lc-ctype=C"
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db.sql:/docker-entrypoint-initdb.d/init-db.sql
    networks:
      - logistics-network
    restart: unless-stopped

  # Config Server
  config-server:
    build: 
      context: ./config-server
      dockerfile: Dockerfile
    container_name: logistics-config-server
    ports:
      - "8888:8888"
    environment:
      - SPRING_PROFILES_ACTIVE=production
    networks:
      - logistics-network
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
    container_name: logistics-discovery-server
    ports:
      - "8761:8761"
    depends_on:
      config-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
    networks:
      - logistics-network
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
    container_name: logistics-gateway-service
    ports:
      - "8080:8080"
    depends_on:
      discovery-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://discovery-server:8761/eureka/
    networks:
      - logistics-network
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
    container_name: logistics-auth-service
    ports:
      - "8081:8081"
    depends_on:
      postgres:
        condition: service_started
      gateway-service:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=postgresql://logistics_user:logistics_prod_pass_2025@postgres:5432/logistics_db
      - SPRING_DATASOURCE_USERNAME=logistics_user
      - SPRING_DATASOURCE_PASSWORD=logistics_prod_pass_2025
      - JWT_SECRET=myVerySecureJWTSecretKeyForLogisticsPlatform2025WithMinimum32Characters
    networks:
      - logistics-network
    restart: unless-stopped

  # User Service
  user-service:
    build: 
      context: ./user-service
      dockerfile: Dockerfile
    container_name: logistics-user-service
    ports:
      - "8082:8082"
    depends_on:
      postgres:
        condition: service_started
      auth-service:
        condition: service_started
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=postgresql://logistics_user:logistics_prod_pass_2025@postgres:5432/logistics_db
      - SPRING_DATASOURCE_USERNAME=logistics_user
      - SPRING_DATASOURCE_PASSWORD=logistics_prod_pass_2025
      - JWT_SECRET=myVerySecureJWTSecretKeyForLogisticsPlatform2025WithMinimum32Characters
    networks:
      - logistics-network
    restart: unless-stopped

  # Transport Service
  transport-service:
    build: 
      context: ./transport-service
      dockerfile: Dockerfile
    container_name: logistics-transport-service
    ports:
      - "8083:8083"
    depends_on:
      postgres:
        condition: service_started
      auth-service:
        condition: service_started
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=postgresql://logistics_user:logistics_prod_pass_2025@postgres:5432/logistics_db
      - SPRING_DATASOURCE_USERNAME=logistics_user
      - SPRING_DATASOURCE_PASSWORD=logistics_prod_pass_2025
      - JWT_SECRET=myVerySecureJWTSecretKeyForLogisticsPlatform2025WithMinimum32Characters
    networks:
      - logistics-network
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local

networks:
  logistics-network:
    driver: bridge
EOF

# Database init script
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

# Deploy script'i güncelle
cat > deploy.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting production deployment..."

# Load environment variables
set -a
source .env.production
set +a

# Stop any running containers
echo "🛑 Stopping existing containers..."
docker-compose -f docker-compose.production.yml down

# Remove old images to force rebuild
echo "🧹 Cleaning up old images..."
docker system prune -f

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose -f docker-compose.production.yml up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 90

# Run health checks
echo "🔍 Running health checks..."
./health-check.sh

echo "✅ Production deployment completed!"
echo ""
echo "🌐 Access URLs:"
echo "   Main Application: http://209.38.244.176:8080"
echo "   Discovery Server: http://209.38.244.176:8761"
echo "   Config Server: http://209.38.244.176:8888"
echo ""
echo "📊 Monitoring:"
echo "   Health: http://209.38.244.176:8080/actuator/health"
echo "   Gateway Routes: http://209.38.244.176:8080/actuator/gateway/routes"
echo ""
EOF

chmod +x deploy.sh

echo "✅ Dosyalar güncellendi!"
echo ""
echo "🚀 Şimdi deploy'u başlatın:"
echo "   ./deploy.sh"
echo ""
EOF

chmod +x quick-fix.sh