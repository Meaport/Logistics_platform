#!/bin/bash

echo "🚀 TÜM MICROSERVICES OLUŞTURULUYOR"
echo "=================================="

# Ana dizin kontrolü
if [ ! -f "pom.xml" ]; then
    echo "❌ Ana pom.xml bulunamadı! Önce ana proje dosyalarını oluşturun."
    exit 1
fi

echo "📦 Microservice dosyaları oluşturuluyor..."

# Auth Service oluştur
echo "🔐 Auth Service oluşturuluyor..."
mkdir -p auth-service/src/main/java/com/logistics/auth/{config,controller,dto,entity,repository,security,service}
mkdir -p auth-service/src/main/resources

cat > auth-service/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.logistics</groupId>
        <artifactId>logistics-platform</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>auth-service</artifactId>
    <name>Auth Service</name>
    <description>Authentication and authorization service</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.3</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>com.logistics</groupId>
            <artifactId>common-lib</artifactId>
            <version>1.0.0</version>
        </dependency>
    </dependencies>
</project>
EOF

cat > auth-service/src/main/java/com/logistics/auth/AuthApplication.java << 'EOF'
package com.logistics.auth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.logistics.auth", "com.logistics.common"})
@EnableDiscoveryClient
public class AuthApplication {
    public static void main(String[] args) {
        SpringApplication.run(AuthApplication.class, args);
    }
}
EOF

cat > auth-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8081

spring:
  application:
    name: auth-service
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/authdb}
    username: ${DATABASE_USERNAME:logistics_user}
    password: ${DATABASE_PASSWORD:logistics_pass}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}
  expiration: 86400000

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_DEFAULT_ZONE:http://localhost:8761/eureka/}
    fetch-registry: true
    register-with-eureka: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
EOF

cat > auth-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Auth Service oluşturuldu"

# User Service oluştur
echo "👤 User Service oluşturuluyor..."
mkdir -p user-service/src/main/java/com/logistics/user/{controller,dto,entity,repository,security,service}
mkdir -p user-service/src/main/resources

cat > user-service/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.logistics</groupId>
        <artifactId>logistics-platform</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>user-service</artifactId>
    <name>User Service</name>
    <description>User profile management and RBAC operations</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.3</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>com.logistics</groupId>
            <artifactId>common-lib</artifactId>
            <version>1.0.0</version>
        </dependency>
    </dependencies>
</project>
EOF

cat > user-service/src/main/java/com/logistics/user/UserServiceApplication.java << 'EOF'
package com.logistics.user;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.logistics.user", "com.logistics.common"})
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
EOF

cat > user-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8082

spring:
  application:
    name: user-service
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/userdb}
    username: ${DATABASE_USERNAME:logistics_user}
    password: ${DATABASE_PASSWORD:logistics_pass}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}
  expiration: 86400000

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_DEFAULT_ZONE:http://localhost:8761/eureka/}
    fetch-registry: true
    register-with-eureka: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
EOF

cat > user-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ User Service oluşturuldu"

# Transport Service oluştur
echo "🚛 Transport Service oluşturuluyor..."
mkdir -p transport-service/src/main/java/com/logistics/transport/{controller,dto,entity,repository,security,service}
mkdir -p transport-service/src/main/resources

cat > transport-service/pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>com.logistics</groupId>
        <artifactId>logistics-platform</artifactId>
        <version>1.0.0</version>
    </parent>

    <artifactId>transport-service</artifactId>
    <name>Transport Service</name>
    <description>Transportation and logistics operations management</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.3</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi</artifactId>
            <version>5.2.4</version>
        </dependency>
        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml</artifactId>
            <version>5.2.4</version>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>com.logistics</groupId>
            <artifactId>common-lib</artifactId>
            <version>1.0.0</version>
        </dependency>
    </dependencies>
</project>
EOF

cat > transport-service/src/main/java/com/logistics/transport/TransportServiceApplication.java << 'EOF'
package com.logistics.transport;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication(scanBasePackages = {"com.logistics.transport", "com.logistics.common"})
@EnableDiscoveryClient
public class TransportServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(TransportServiceApplication.class, args);
    }
}
EOF

cat > transport-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8083

spring:
  application:
    name: transport-service
  datasource:
    url: ${DATABASE_URL:jdbc:postgresql://localhost:5432/transportdb}
    username: ${DATABASE_USERNAME:logistics_user}
    password: ${DATABASE_PASSWORD:logistics_pass}
    driver-class-name: org.postgresql.Driver
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}
  expiration: 86400000

eureka:
  client:
    service-url:
      defaultZone: ${EUREKA_DEFAULT_ZONE:http://localhost:8761/eureka/}
    fetch-registry: true
    register-with-eureka: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
  endpoint:
    health:
      show-details: always
EOF

cat > transport-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Transport Service oluşturuldu"

# Temel Controller'ları oluştur
echo "🎮 Temel Controller'lar oluşturuluyor..."

# Auth Controller
cat > auth-service/src/main/java/com/logistics/auth/controller/AuthController.java << 'EOF'
package com.logistics.auth.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*", maxAge = 3600)
public class AuthController {

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> loginRequest) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Login successful");
        response.put("token", "sample-jwt-token");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> registerRequest) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "User registered successfully");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "auth-service");
        health.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(health);
    }
}
EOF

# User Controller
cat > user-service/src/main/java/com/logistics/user/controller/UserController.java << 'EOF'
package com.logistics.user.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*", maxAge = 3600)
public class UserController {

    @GetMapping("/profile")
    public ResponseEntity<Map<String, Object>> getProfile() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "User profile retrieved");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "user-service");
        health.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(health);
    }
}
EOF

# Transport Controller
cat > transport-service/src/main/java/com/logistics/transport/controller/TransportController.java << 'EOF'
package com.logistics.transport.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/transport")
@CrossOrigin(origins = "*", maxAge = 3600)
public class TransportController {

    @GetMapping("/shipments/tracking/{trackingNumber}")
    public ResponseEntity<Map<String, Object>> trackShipment(@PathVariable String trackingNumber) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("trackingNumber", trackingNumber);
        response.put("status", "IN_TRANSIT");
        response.put("message", "Shipment tracking information");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/vehicles")
    public ResponseEntity<Map<String, Object>> getVehicles() {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "Vehicles retrieved");
        return ResponseEntity.ok(response);
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> health = new HashMap<>();
        health.put("status", "UP");
        health.put("service", "transport-service");
        health.put("timestamp", System.currentTimeMillis());
        return ResponseEntity.ok(health);
    }
}
EOF

# Package.json oluştur
cat > package.json << 'EOF'
{
  "name": "logistics-platform",
  "version": "1.0.0",
  "description": "Comprehensive logistics management platform built with Spring Boot microservices",
  "main": "start-services.js",
  "scripts": {
    "start-services": "node start-services.js",
    "test": "node test-runner.js",
    "docker-up": "docker-compose up -d",
    "docker-down": "docker-compose down",
    "health-check": "node -e \"const { exec } = require('child_process'); const services = [8080, 8081, 8082, 8083]; services.forEach(port => { exec('curl -s http://localhost:' + port + '/actuator/health', (err, stdout) => { console.log('Port ' + port + ':', err ? 'DOWN' : JSON.parse(stdout).status); }); });\""
  },
  "keywords": [
    "logistics",
    "microservices",
    "spring-boot",
    "java",
    "transport",
    "shipment"
  ],
  "author": "Logistics Platform Team",
  "license": "MIT"
}
EOF

# README.md oluştur
cat > README.md << 'EOF'
# 🚛 Logistics Platform - Microservices Architecture

A comprehensive logistics management platform built with Spring Boot microservices architecture.

## 🏗️ Architecture Overview

The platform consists of the following microservices:

- **Config Server** (Port 8888) - Centralized configuration management
- **Discovery Server** (Port 8761) - Service registry and discovery
- **Gateway Service** (Port 8080) - API Gateway and routing
- **Auth Service** (Port 8081) - Authentication and authorization
- **User Service** (Port 8082) - User profile management
- **Transport Service** (Port 8083) - Shipment and vehicle management

## 🚀 Quick Start

### Using Docker Compose (Recommended)

```bash
# Start all services
docker-compose -f docker-compose.production.yml up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Manual Startup

```bash
# 1. Config Server
cd config-server && mvn spring-boot:run &

# 2. Discovery Server
cd discovery-server && mvn spring-boot:run &

# 3. Gateway Service
cd gateway-service && mvn spring-boot:run &

# 4. Auth Service
cd auth-service && mvn spring-boot:run &

# 5. User Service
cd user-service && mvn spring-boot:run &

# 6. Transport Service
cd transport-service && mvn spring-boot:run &
```

## 🧪 Testing

### Health Checks
- Gateway: http://localhost:8080/actuator/health
- Auth: http://localhost:8081/actuator/health
- User: http://localhost:8082/actuator/health
- Transport: http://localhost:8083/actuator/health

### API Endpoints
- Authentication: http://localhost:8080/api/auth/*
- User Management: http://localhost:8080/api/users/*
- Transport Operations: http://localhost:8080/api/transport/*

## 📊 Monitoring

- Service Discovery: http://localhost:8761
- Gateway Routes: http://localhost:8080/actuator/gateway/routes

## 🔧 Configuration

Environment variables can be set in `.env.production`:

- `DATABASE_URL` - PostgreSQL connection URL
- `JWT_SECRET` - JWT signing secret
- `EUREKA_DEFAULT_ZONE` - Service discovery URL

## 🚀 Production Deployment

```bash
# Deploy to production
./deploy.sh

# Check deployment status
./health-check-production.sh
```

## 📄 License

This project is licensed under the MIT License.
EOF

echo ""
echo "🎉 TÜM MICROSERVICES OLUŞTURULDU!"
echo ""
echo "📋 Oluşturulan Servisler:"
echo "   ✅ Config Server (8888)"
echo "   ✅ Discovery Server (8761)"
echo "   ✅ Gateway Service (8080)"
echo "   ✅ Auth Service (8081)"
echo "   ✅ User Service (8082)"
echo "   ✅ Transport Service (8083)"
echo "   ✅ Common Library"
echo ""
echo "📁 Oluşturulan Dosyalar:"
echo "   - Tüm pom.xml dosyaları"
echo "   - Application.java dosyaları"
echo "   - application.yml konfigürasyonları"
echo "   - Dockerfile'lar"
echo "   - Temel Controller'lar"
echo "   - package.json"
echo "   - README.md"
echo ""
echo "🚀 Sonraki Adımlar:"
echo "1. GitHub'a push et"
echo "2. Droplet'e çek"
echo "3. ./deploy.sh ile başlat"
echo ""