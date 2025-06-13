#!/bin/bash

cd /opt/logistics-platform

echo "🚀 HIZLI MICROSERVICE OLUŞTURMA"
echo "==============================="

# Common Library
if [ ! -d "common-lib" ]; then
    echo "📦 Common Library oluşturuluyor..."
    mkdir -p common-lib/src/main/java/com/logistics/common/{dto,exception}
    
    cat > common-lib/pom.xml << 'EOF'
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

    <artifactId>common-lib</artifactId>
    <name>Common Library</name>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-annotations</artifactId>
        </dependency>
    </dependencies>
</project>
EOF

    cat > common-lib/src/main/java/com/logistics/common/dto/BaseResponse.java << 'EOF'
package com.logistics.common.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import java.time.LocalDateTime;

@JsonInclude(JsonInclude.Include.NON_NULL)
public class BaseResponse<T> {
    private boolean success;
    private String message;
    private T data;
    private String error;
    private LocalDateTime timestamp;

    public BaseResponse() {
        this.timestamp = LocalDateTime.now();
    }

    public static <T> BaseResponse<T> success(T data) {
        BaseResponse<T> response = new BaseResponse<>();
        response.success = true;
        response.data = data;
        return response;
    }

    public static <T> BaseResponse<T> success(T data, String message) {
        BaseResponse<T> response = new BaseResponse<>();
        response.success = true;
        response.data = data;
        response.message = message;
        return response;
    }

    public static <T> BaseResponse<T> error(String error) {
        BaseResponse<T> response = new BaseResponse<>();
        response.success = false;
        response.error = error;
        return response;
    }

    // Getters and Setters
    public boolean isSuccess() { return success; }
    public void setSuccess(boolean success) { this.success = success; }
    
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    
    public T getData() { return data; }
    public void setData(T data) { this.data = data; }
    
    public String getError() { return error; }
    public void setError(String error) { this.error = error; }
    
    public LocalDateTime getTimestamp() { return timestamp; }
    public void setTimestamp(LocalDateTime timestamp) { this.timestamp = timestamp; }
}
EOF

    cat > common-lib/src/main/java/com/logistics/common/exception/BusinessException.java << 'EOF'
package com.logistics.common.exception;

public class BusinessException extends RuntimeException {
    public BusinessException(String message) {
        super(message);
    }
}
EOF

    cat > common-lib/src/main/java/com/logistics/common/exception/ResourceNotFoundException.java << 'EOF'
package com.logistics.common.exception;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
EOF

    echo "✅ Common Library oluşturuldu"
fi

# Config Server
if [ ! -d "config-server" ]; then
    echo "📦 Config Server oluşturuluyor..."
    mkdir -p config-server/src/main/java/com/logistics/config
    mkdir -p config-server/src/main/resources
    
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
fi

# Discovery Server
if [ ! -d "discovery-server" ]; then
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
fi

# Gateway Service
if [ ! -d "gateway-service" ]; then
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
fi

# Auth Service
if [ ! -d "auth-service" ]; then
    echo "📦 Auth Service oluşturuluyor..."
    mkdir -p auth-service/src/main/java/com/logistics/auth/controller
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
fi

# User Service
if [ ! -d "user-service" ]; then
    echo "📦 User Service oluşturuluyor..."
    mkdir -p user-service/src/main/java/com/logistics/user/controller
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
fi

# Transport Service
if [ ! -d "transport-service" ]; then
    echo "📦 Transport Service oluşturuluyor..."
    mkdir -p transport-service/src/main/java/com/logistics/transport/controller
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
fi

echo ""
echo "🎉 TÜM MICROSERVICE'LER OLUŞTURULDU!"
echo ""
echo "📋 Oluşturulan servisler:"
echo "   ✅ Common Library"
echo "   ✅ Config Server (8888)"
echo "   ✅ Discovery Server (8761)"
echo "   ✅ Gateway Service (8080)"
echo "   ✅ Auth Service (8081)"
echo "   ✅ User Service (8082)"
echo "   ✅ Transport Service (8083)"
echo ""