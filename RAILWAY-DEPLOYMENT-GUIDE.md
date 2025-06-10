# 🚂 **RAILWAY DEPLOYMENT GUIDE - LOGISTICS PLATFORM**

## 📋 **Railway Deployment Overview**

Railway, modern microservices için ideal bir cloud platform. Logistics Platform'umuzu Railway'e deploy etmek için her servisi ayrı ayrı deploy edeceğiz.

---

## 🚀 **STEP 1: Railway Account Setup**

### 1.1 Railway Hesabı Oluşturma
1. https://railway.app adresine gidin
2. GitHub hesabınızla giriş yapın
3. "New Project" butonuna tıklayın

### 1.2 GitHub Repository Bağlama
```bash
# Projeyi GitHub'a push edin (eğer henüz yapmadıysanız)
git init
git add .
git commit -m "Initial commit - Logistics Platform"
git branch -M main
git remote add origin https://github.com/[USERNAME]/logistics-platform.git
git push -u origin main
```

---

## 🗄️ **STEP 2: Database Configuration (Supabase Integration)**

### 2.1 Environment Variables Hazırlama
Railway'de her servis için environment variables tanımlayacağız:

```bash
# Supabase Connection Details
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres
SUPABASE_URL=https://[PROJECT-ID].supabase.co
SUPABASE_ANON_KEY=[YOUR-ANON-KEY]

# JWT Configuration
JWT_SECRET=[STRONG-SECRET-KEY]
JWT_EXPIRATION=86400000

# Service Discovery (Railway internal URLs)
EUREKA_DEFAULT_ZONE=https://discovery-service.railway.app/eureka/
CONFIG_SERVER_URL=https://config-service.railway.app
```

---

## 🏗️ **STEP 3: Service Deployment Order**

Railway'de servisleri doğru sırayla deploy etmeliyiz:

### 3.1 Config Server (İlk Deploy)
```yaml
# railway.toml for config-server
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/config-server-1.0.0.jar"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8888"
SPRING_PROFILES_ACTIVE = "railway"
```

### 3.2 Discovery Server (İkinci Deploy)
```yaml
# railway.toml for discovery-server
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/discovery-server-1.0.0.jar"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8761"
SPRING_PROFILES_ACTIVE = "railway"
CONFIG_SERVER_URL = "https://config-service.railway.app"
```

### 3.3 Gateway Service (Üçüncü Deploy)
```yaml
# railway.toml for gateway-service
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/gateway-service-1.0.0.jar"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8080"
SPRING_PROFILES_ACTIVE = "railway"
CONFIG_SERVER_URL = "https://config-service.railway.app"
EUREKA_DEFAULT_ZONE = "https://discovery-service.railway.app/eureka/"
JWT_SECRET = "[YOUR-JWT-SECRET]"
```

### 3.4 Auth Service (Dördüncü Deploy)
```yaml
# railway.toml for auth-service
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/auth-service-1.0.0.jar"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8081"
SPRING_PROFILES_ACTIVE = "railway"
DATABASE_URL = "postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=auth_service"
JWT_SECRET = "[YOUR-JWT-SECRET]"
EUREKA_DEFAULT_ZONE = "https://discovery-service.railway.app/eureka/"
```

### 3.5 User Service (Beşinci Deploy)
```yaml
# railway.toml for user-service
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/user-service-1.0.0.jar"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8082"
SPRING_PROFILES_ACTIVE = "railway"
DATABASE_URL = "postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=user_service"
JWT_SECRET = "[YOUR-JWT-SECRET]"
EUREKA_DEFAULT_ZONE = "https://discovery-service.railway.app/eureka/"
```

### 3.6 Transport Service (Son Deploy)
```yaml
# railway.toml for transport-service
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/transport-service-1.0.0.jar"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8083"
SPRING_PROFILES_ACTIVE = "railway"
DATABASE_URL = "postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=transport_service"
JWT_SECRET = "[YOUR-JWT-SECRET]"
EUREKA_DEFAULT_ZONE = "https://discovery-service.railway.app/eureka/"
```

---

## 📝 **STEP 4: Railway Configuration Files**

### 4.1 Her Servis İçin railway.toml Oluşturma

**Config Server:**
```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8888"
SPRING_PROFILES_ACTIVE = "railway"
```

**Discovery Server:**
```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8761"
SPRING_PROFILES_ACTIVE = "railway"
```

**Gateway Service:**
```toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "mvn spring-boot:run"
healthcheckPath = "/actuator/health"
healthcheckTimeout = 300

[env]
PORT = "8080"
SPRING_PROFILES_ACTIVE = "railway"
```

---

## 🔧 **STEP 5: Application Configuration Updates**

### 5.1 Railway Profile Ekleme
Her servisin `application.yml` dosyasına Railway profili ekleyin:

```yaml
---
spring:
  config:
    activate:
      on-profile: railway
  datasource:
    url: ${DATABASE_URL}
    username: postgres
    password: ${DATABASE_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: false

server:
  port: ${PORT:8080}

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_DEFAULT_ZONE:http://localhost:8761/eureka/}
  instance:
    hostname: ${RAILWAY_PUBLIC_DOMAIN:localhost}
    prefer-ip-address: false

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
```

---

## 🚀 **STEP 6: Deployment Process**

### 6.1 Manuel Deployment
```bash
# 1. Config Server Deploy
railway login
railway link [config-server-project-id]
railway up

# 2. Discovery Server Deploy (Config Server hazır olduktan sonra)
railway link [discovery-server-project-id]
railway up

# 3. Gateway Service Deploy
railway link [gateway-service-project-id]
railway up

# 4. Auth Service Deploy
railway link [auth-service-project-id]
railway up

# 5. User Service Deploy
railway link [user-service-project-id]
railway up

# 6. Transport Service Deploy
railway link [transport-service-project-id]
railway up
```

### 6.2 Automated Deployment (GitHub Actions)
```yaml
# .github/workflows/railway-deploy.yml
name: Deploy to Railway

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Build with Maven
        run: mvn clean package -DskipTests
      
      - name: Deploy Config Server
        uses: railway-deploy@v1
        with:
          service: config-server
          token: ${{ secrets.RAILWAY_TOKEN }}
      
      - name: Deploy Discovery Server
        uses: railway-deploy@v1
        with:
          service: discovery-server
          token: ${{ secrets.RAILWAY_TOKEN }}
      
      - name: Deploy Gateway Service
        uses: railway-deploy@v1
        with:
          service: gateway-service
          token: ${{ secrets.RAILWAY_TOKEN }}
      
      - name: Deploy Auth Service
        uses: railway-deploy@v1
        with:
          service: auth-service
          token: ${{ secrets.RAILWAY_TOKEN }}
      
      - name: Deploy User Service
        uses: railway-deploy@v1
        with:
          service: user-service
          token: ${{ secrets.RAILWAY_TOKEN }}
      
      - name: Deploy Transport Service
        uses: railway-deploy@v1
        with:
          service: transport-service
          token: ${{ secrets.RAILWAY_TOKEN }}
```

---

## 🔗 **STEP 7: Service URLs and Testing**

### 7.1 Railway Service URLs
Railway deployment sonrası şu URL'leri alacaksınız:

```bash
# Service URLs
CONFIG_SERVER: https://config-service-production.railway.app
DISCOVERY_SERVER: https://discovery-service-production.railway.app
GATEWAY_SERVICE: https://gateway-service-production.railway.app
AUTH_SERVICE: https://auth-service-production.railway.app
USER_SERVICE: https://user-service-production.railway.app
TRANSPORT_SERVICE: https://transport-service-production.railway.app
```

### 7.2 Production Testing
```bash
# Health Check
curl https://gateway-service-production.railway.app/actuator/health

# Public Tracking Test
curl https://gateway-service-production.railway.app/api/transport/shipments/tracking/TRK17056789123456

# Admin Login Test
curl -X POST https://gateway-service-production.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

## 📊 **STEP 8: Monitoring and Scaling**

### 8.1 Railway Monitoring
```bash
# Railway CLI ile monitoring
railway logs --service=gateway-service
railway status
railway metrics
```

### 8.2 Auto-Scaling Configuration
```toml
# railway.toml scaling configuration
[deploy]
replicas = 2
restartPolicyType = "ON_FAILURE"
restartPolicyMaxRetries = 3

[resources]
memory = "1Gi"
cpu = "0.5"
```

---

## 🔒 **STEP 9: Security and Environment Variables**

### 9.1 Production Environment Variables
```bash
# Railway Dashboard'da her servis için set edin:

# Common Variables
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[STRONG-SECRET-256-BIT]
DATABASE_URL=[SUPABASE-CONNECTION-STRING]

# Service-Specific Variables
EUREKA_DEFAULT_ZONE=https://discovery-service-production.railway.app/eureka/
CONFIG_SERVER_URL=https://config-service-production.railway.app

# Security Variables
CORS_ALLOWED_ORIGINS=https://your-frontend-domain.com
RATE_LIMIT_ENABLED=true
```

### 9.2 SSL/TLS Configuration
Railway otomatik olarak SSL sertifikası sağlar. Ek konfigürasyon gerekmez.

---

## 🚨 **STEP 10: Troubleshooting**

### 10.1 Common Issues
```bash
# Service Discovery Issues
railway logs --service=discovery-server

# Database Connection Issues
railway logs --service=auth-service | grep -i database

# Memory Issues
railway metrics --service=transport-service
```

### 10.2 Debug Commands
```bash
# Check service health
curl https://[service-url]/actuator/health

# Check service registration
curl https://discovery-service-production.railway.app/eureka/apps

# Check environment variables
railway variables --service=gateway-service
```

---

## 💰 **STEP 11: Cost Optimization**

### 11.1 Railway Pricing
- **Hobby Plan**: $5/month per service
- **Pro Plan**: $20/month per service
- **Team Plan**: Custom pricing

### 11.2 Cost Optimization Tips
```toml
# Optimize resource usage
[resources]
memory = "512Mi"  # Minimum required
cpu = "0.25"      # Minimum required

# Use fewer replicas for non-critical services
[deploy]
replicas = 1
```

---

## 🎯 **STEP 12: Production Checklist**

### Pre-Deployment ✅
- [ ] Supabase database configured
- [ ] Environment variables set
- [ ] Railway projects created
- [ ] GitHub repository ready

### Deployment ✅
- [ ] Config Server deployed
- [ ] Discovery Server deployed
- [ ] Gateway Service deployed
- [ ] Auth Service deployed
- [ ] User Service deployed
- [ ] Transport Service deployed

### Post-Deployment ✅
- [ ] Health checks passing
- [ ] Service discovery working
- [ ] API endpoints accessible
- [ ] Database connections stable
- [ ] Monitoring configured

---

## 🎉 **SUCCESS!**

Railway deployment tamamlandığında:

### 🌐 **Production URLs:**
- **Main API**: https://gateway-service-production.railway.app
- **Discovery**: https://discovery-service-production.railway.app
- **Admin Panel**: https://gateway-service-production.railway.app/admin

### 🧪 **Test Commands:**
```bash
# Quick health check
curl https://gateway-service-production.railway.app/actuator/health

# Test authentication
curl -X POST https://gateway-service-production.railway.app/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Test public tracking
curl https://gateway-service-production.railway.app/api/transport/shipments/tracking/TRK17056789123456
```

**🚂 Railway deployment başarıyla tamamlandı! Production'da çalışan bir logistics platform'unuz var!**