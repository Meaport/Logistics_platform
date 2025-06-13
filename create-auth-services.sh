#!/bin/bash

echo "🔐 AUTH, USER VE TRANSPORT SERVİSLERİ OLUŞTURULUYOR"
echo "================================================="

cd /opt/logistics-platform

# Auth Service oluştur
echo "📦 Auth Service oluşturuluyor..."
mkdir -p auth-service/src/main/java/com/logistics/auth/{controller,service,entity,repository,dto,security,config}
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
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
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
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}
  expiration: 86400000

eureka:
  client:
    service-url:
      defaultZone: http://discovery-server:8761/eureka/
    fetch-registry: true
    register-with-eureka: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
EOF

cat > auth-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Auth Service oluşturuldu"

# User Service oluştur
echo "📦 User Service oluşturuluyor..."
mkdir -p user-service/src/main/java/com/logistics/user/{controller,service,entity,repository,dto,security}
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
    <description>User profile management service</description>

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
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
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
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}

eureka:
  client:
    service-url:
      defaultZone: http://discovery-server:8761/eureka/
    fetch-registry: true
    register-with-eureka: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
EOF

cat > user-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ User Service oluşturuldu"

# Transport Service oluştur
echo "📦 Transport Service oluşturuluyor..."
mkdir -p transport-service/src/main/java/com/logistics/transport/{controller,service,entity,repository,dto,security}
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
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.postgresql</groupId>
            <artifactId>postgresql</artifactId>
            <scope>runtime</scope>
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
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect

jwt:
  secret: ${JWT_SECRET:mySecretKey123456789012345678901234567890}

eureka:
  client:
    service-url:
      defaultZone: http://discovery-server:8761/eureka/
    fetch-registry: true
    register-with-eureka: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
EOF

cat > transport-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Transport Service oluşturuldu"

# Nginx konfigürasyonu
echo "🌐 Nginx konfigürasyonu oluşturuluyor..."
cat > nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream gateway_backend {
        server gateway-service:8080;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    server {
        listen 80;
        server_name www.meaport.online meaport.online;

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

        # Health check endpoint
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

echo ""
echo "🎉 Tüm microservices oluşturuldu!"
echo ""
echo "📋 Oluşturulan servisler:"
echo "   ✅ Config Server (8888)"
echo "   ✅ Discovery Server (8761)"
echo "   ✅ Gateway Service (8080)"
echo "   ✅ Auth Service (8081)"
echo "   ✅ User Service (8082)"
echo "   ✅ Transport Service (8083)"
echo ""
echo "📋 Sonraki adım:"
echo "   ./deploy.sh ile servisleri başlatabilirsiniz"
echo ""