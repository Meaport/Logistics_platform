# 🚀 **LOGISTICS PLATFORM - DEPLOYMENT GUIDE**

## 📋 **Quick Start Options**

### Option 1: Local Development (Recommended for Development)
```bash
# Prerequisites: Java 17+, Maven 3.6+, PostgreSQL
npm run start-services
npm test
```

### Option 2: Docker Deployment (Recommended for Production)
```bash
# Prerequisites: Docker, Docker Compose
npm run docker-up
npm test
```

### Option 3: Cloud Deployment (Kubernetes)
```bash
# Deploy to Kubernetes cluster
kubectl apply -f k8s/
```

---

## 🏗️ **Architecture Overview**

The platform consists of 6 microservices:

1. **Config Server** (8888) - Centralized configuration
2. **Discovery Server** (8761) - Service registry (Eureka)
3. **Gateway Service** (8080) - API Gateway and routing
4. **Auth Service** (8081) - Authentication and authorization
5. **User Service** (8082) - User profile management
6. **Transport Service** (8083) - Core logistics operations

---

## 🔧 **Environment Setup**

### Local Development Requirements
- **Java**: OpenJDK 17 or higher
- **Maven**: 3.6 or higher
- **PostgreSQL**: 12 or higher
- **Node.js**: 14+ (for test scripts)

### Database Setup
```sql
-- Create databases
CREATE DATABASE authdb;
CREATE DATABASE userdb;
CREATE DATABASE transportdb;

-- Create user
CREATE USER logistics_user WITH PASSWORD 'logistics_pass';
GRANT ALL PRIVILEGES ON DATABASE authdb TO logistics_user;
GRANT ALL PRIVILEGES ON DATABASE userdb TO logistics_user;
GRANT ALL PRIVILEGES ON DATABASE transportdb TO logistics_user;
```

---

## 🐳 **Docker Deployment**

### Quick Start
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### Production Configuration
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: logistics_db
      POSTGRES_USER: logistics_user
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      replicas: 1
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

---

## ☁️ **Cloud Deployment**

### Kubernetes Deployment
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: logistics-platform

---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: logistics-config
  namespace: logistics-platform
data:
  database.url: "jdbc:postgresql://postgres:5432/logistics_db"
  eureka.url: "http://discovery-server:8761/eureka/"
```

### Helm Chart Deployment
```bash
# Install with Helm
helm install logistics-platform ./helm-chart \
  --namespace logistics-platform \
  --create-namespace \
  --set database.password=${DB_PASSWORD}
```

---

## 🔐 **Security Configuration**

### JWT Configuration
```yaml
jwt:
  secret: ${JWT_SECRET}  # Use strong secret in production
  expiration: 86400000   # 24 hours
  refresh-expiration: 604800000  # 7 days
```

### HTTPS Setup
```yaml
server:
  ssl:
    enabled: true
    key-store: classpath:keystore.p12
    key-store-password: ${KEYSTORE_PASSWORD}
    key-store-type: PKCS12
```

---

## 📊 **Monitoring and Observability**

### Health Checks
- Gateway: http://localhost:8080/actuator/health
- Auth: http://localhost:8081/actuator/health
- User: http://localhost:8082/actuator/health
- Transport: http://localhost:8083/actuator/health

### Metrics Endpoints
- Prometheus: /actuator/prometheus
- Metrics: /actuator/metrics
- Info: /actuator/info

### Logging Configuration
```yaml
logging:
  level:
    com.logistics: INFO
    org.springframework.security: WARN
  pattern:
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n"
  file:
    name: logs/application.log
```

---

## 🧪 **Testing**

### Automated Testing
```bash
# Run all tests
npm test

# Performance testing
npm run performance-test

# Stress testing
npm run stress-test
```

### Manual Testing
```bash
# Health check
curl http://localhost:8080/actuator/health

# User registration
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"test123"}'

# Public tracking
curl http://localhost:8080/api/transport/shipments/tracking/TRK123456789
```

---

## 🔄 **CI/CD Pipeline**

### GitHub Actions Example
```yaml
name: Deploy Logistics Platform
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
      - run: mvn test
      
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - run: docker-compose up -d
      - run: npm test
```

---

## 📈 **Scaling Guidelines**

### Horizontal Scaling
```yaml
# docker-compose.scale.yml
services:
  auth-service:
    deploy:
      replicas: 3
  user-service:
    deploy:
      replicas: 2
  transport-service:
    deploy:
      replicas: 3
```

### Load Balancing
```nginx
# nginx.conf
upstream auth_service {
    server auth-service-1:8081;
    server auth-service-2:8081;
    server auth-service-3:8081;
}

upstream transport_service {
    server transport-service-1:8083;
    server transport-service-2:8083;
    server transport-service-3:8083;
}
```

---

## 🚨 **Troubleshooting**

### Common Issues

1. **Service Won't Start**
   ```bash
   # Check logs
   docker-compose logs service-name
   
   # Check port conflicts
   netstat -tulpn | grep :8080
   ```

2. **Database Connection Issues**
   ```bash
   # Test database connection
   psql -h localhost -U logistics_user -d authdb
   
   # Check database logs
   docker-compose logs postgres
   ```

3. **Service Discovery Issues**
   ```bash
   # Check Eureka dashboard
   curl http://localhost:8761/eureka/apps
   
   # Restart discovery server
   docker-compose restart discovery-server
   ```

### Debug Commands
```bash
# Check all service health
for port in 8080 8081 8082 8083; do
  echo "Port $port: $(curl -s http://localhost:$port/actuator/health | jq -r .status)"
done

# Check service registration
curl -s http://localhost:8761/eureka/apps | grep -o '<name>[^<]*</name>'

# Monitor resource usage
docker stats --no-stream
```

---

## 📞 **Support and Maintenance**

### Backup Strategy
```bash
# Database backup
docker exec postgres pg_dump -U logistics_user logistics_db > backup.sql

# Configuration backup
kubectl get configmaps -o yaml > configmaps-backup.yaml
```

### Update Strategy
```bash
# Rolling update
docker-compose pull
docker-compose up -d --no-deps service-name

# Zero-downtime deployment
kubectl set image deployment/auth-service auth-service=logistics/auth-service:v2.0.0
```

---

## 🎯 **Performance Optimization**

### JVM Tuning
```yaml
environment:
  JAVA_OPTS: >
    -Xms512m -Xmx1g
    -XX:+UseG1GC
    -XX:MaxGCPauseMillis=200
    -XX:+UseStringDeduplication
```

### Database Optimization
```sql
-- Create indexes for better performance
CREATE INDEX idx_shipments_tracking ON shipments(tracking_number);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_users_username ON users(username);
```

---

**🚀 The Logistics Platform is ready for production deployment!**

For additional support, please refer to the comprehensive documentation and test reports included in this project.