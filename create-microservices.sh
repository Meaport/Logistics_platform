#!/bin/bash

echo "🚀 MICROSERVICES OLUŞTURULUYOR"
echo "=============================="

cd /opt/logistics-platform

# Config Server oluştur
echo "📦 Config Server oluşturuluyor..."
mkdir -p config-server/src/main/java/com/logistics/config
mkdir -p config-server/src/main/resources/config

cat > config-server/pom.xml << 'EOF'
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

    <artifactId>config-server</artifactId>
    <name>Config Server</name>
    <description>Centralized configuration server</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-config-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
</project>
EOF

cat > config-server/src/main/java/com/logistics/config/ConfigServerApplication.java << 'EOF'
package com.logistics.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.config.server.EnableConfigServer;

@SpringBootApplication
@EnableConfigServer
public class ConfigServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(ConfigServerApplication.class, args);
    }
}
EOF

cat > config-server/src/main/resources/application.yml << 'EOF'
server:
  port: 8888

spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        native:
          search-locations: classpath:/config
  profiles:
    active: native

management:
  endpoints:
    web:
      exposure:
        include: health,info,refresh
EOF

cat > config-server/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Config Server oluşturuldu"

# Discovery Server oluştur
echo "📦 Discovery Server oluşturuluyor..."
mkdir -p discovery-server/src/main/java/com/logistics/discovery
mkdir -p discovery-server/src/main/resources

cat > discovery-server/pom.xml << 'EOF'
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

    <artifactId>discovery-server</artifactId>
    <name>Discovery Server</name>
    <description>Eureka service discovery server</description>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-server</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
</project>
EOF

cat > discovery-server/src/main/java/com/logistics/discovery/DiscoveryServerApplication.java << 'EOF'
package com.logistics.discovery;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
public class DiscoveryServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(DiscoveryServerApplication.class, args);
    }
}
EOF

cat > discovery-server/src/main/resources/application.yml << 'EOF'
server:
  port: 8761

spring:
  application:
    name: discovery-server

eureka:
  instance:
    hostname: localhost
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
  server:
    enable-self-preservation: false
EOF

cat > discovery-server/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Discovery Server oluşturuldu"

# Gateway Service oluştur
echo "📦 Gateway Service oluşturuluyor..."
mkdir -p gateway-service/src/main/java/com/logistics/gateway
mkdir -p gateway-service/src/main/resources

cat > gateway-service/pom.xml << 'EOF'
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

    <artifactId>gateway-service</artifactId>
    <name>API Gateway Service</name>

    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>com.logistics</groupId>
            <artifactId>common-lib</artifactId>
            <version>1.0.0</version>
        </dependency>
    </dependencies>
</project>
EOF

cat > gateway-service/src/main/java/com/logistics/gateway/GatewayServiceApplication.java << 'EOF'
package com.logistics.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class GatewayServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayServiceApplication.class, args);
    }
}
EOF

cat > gateway-service/src/main/resources/application.yml << 'EOF'
server:
  port: 8080

spring:
  application:
    name: gateway-service
  cloud:
    gateway:
      discovery:
        locator:
          enabled: true
          lower-case-service-id: true
      routes:
        - id: auth-service
          uri: lb://auth-service
          predicates:
            - Path=/api/auth/**
        - id: user-service
          uri: lb://user-service
          predicates:
            - Path=/api/users/**
        - id: transport-service
          uri: lb://transport-service
          predicates:
            - Path=/api/transport/**

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
        include: health,info,gateway,routes
EOF

cat > gateway-service/Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

echo "✅ Gateway Service oluşturuldu"

echo ""
echo "🎉 Temel microservices oluşturuldu!"
echo ""
echo "📋 Sonraki adım:"
echo "Auth, User ve Transport servislerini oluşturmak için devam edelim..."