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

### Prerequisites

- Java 17 or higher
- Maven 3.6+
- PostgreSQL 12+
- Node.js 14+ (for test scripts)

### Option 1: Using Node.js Scripts (Recommended)

1. **Start all services:**
   ```bash
   npm run start-services
   ```

2. **Run tests:**
   ```bash
   npm test
   ```

3. **Quick health check:**
   ```bash
   curl http://localhost:8080/actuator/health
   ```

### Option 2: Using Docker Compose

1. **Start with Docker:**
   ```bash
   npm run docker-up
   ```

2. **View logs:**
   ```bash
   npm run docker-logs
   ```

3. **Stop services:**
   ```bash
   npm run docker-down
   ```

### Option 3: Manual Startup

1. **Start services in order:**
   ```bash
   # 1. Config Server
   cd config-server && mvn spring-boot:run &
   
   # 2. Discovery Server (wait for config server)
   cd discovery-server && mvn spring-boot:run &
   
   # 3. Gateway Service (wait for discovery)
   cd gateway-service && mvn spring-boot:run &
   
   # 4. Auth Service (wait for gateway)
   cd auth-service && mvn spring-boot:run &
   
   # 5. User Service (wait for auth)
   cd user-service && mvn spring-boot:run &
   
   # 6. Transport Service (wait for auth)
   cd transport-service && mvn spring-boot:run &
   ```

## 🧪 Testing

### Automated Testing

The platform includes a comprehensive test suite that covers:

- Health checks for all services
- Authentication and authorization flows
- Core business functionality
- Error handling and edge cases
- Basic performance testing

Run the automated tests:
```bash
npm test
```

### Manual Testing

Key endpoints to test manually:

```bash
# Health checks
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health

# User registration
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"test123","firstName":"Test","lastName":"User"}'

# User login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"test123"}'

# Public shipment tracking (no auth required)
curl http://localhost:8080/api/transport/shipments/tracking/TRK123456789
```

## 🔧 Configuration

### Database Setup

Create the required PostgreSQL databases:

```sql
CREATE DATABASE logistics_db;
CREATE USER logistics_user WITH PASSWORD 'logistics_pass';
GRANT ALL PRIVILEGES ON DATABASE logistics_db TO logistics_user;
```

### Environment Variables

Key configuration can be overridden with environment variables:

- `SPRING_PROFILES_ACTIVE` - Active Spring profile (default: local)
- `DATABASE_URL` - PostgreSQL connection URL
- `JWT_SECRET` - JWT signing secret
- `JWT_EXPIRATION` - JWT token expiration time

## 📊 Monitoring

### Service Discovery

View registered services:
- Eureka Dashboard: http://localhost:8761

### Gateway Routes

View configured routes:
```bash
curl http://localhost:8080/actuator/gateway/routes
```

### Health Endpoints

All services expose health endpoints:
- Gateway: http://localhost:8080/actuator/health
- Auth: http://localhost:8081/actuator/health
- User: http://localhost:8082/actuator/health
- Transport: http://localhost:8083/actuator/health

## 🛡️ Security

The platform implements:

- JWT-based authentication
- Role-based access control (RBAC)
- API Gateway security filters
- CORS configuration
- Rate limiting

### Default Users

The system creates default users on startup:

- **Admin User:**
  - Username: `admin`
  - Password: `admin123`
  - Roles: `ADMIN`, `USER`

- **Regular User:**
  - Username: `user`
  - Password: `user123`
  - Roles: `USER`

## 🚛 Core Features

### Authentication Service
- User registration and login
- JWT token management
- Password reset functionality
- Role and permission management

### User Service
- User profile management
- User activity tracking
- Search and filtering capabilities

### Transport Service
- Vehicle management
- Shipment creation and tracking
- Route logging with GPS coordinates
- Document export (PDF/Excel)
- Advanced filtering and reporting

## 🔍 Troubleshooting

### Common Issues

1. **Service won't start:**
   - Check if the required port is available
   - Verify database connection
   - Check application logs

2. **Connection refused errors:**
   - Ensure services are started in the correct order
   - Wait for each service to be fully ready before starting the next

3. **Authentication failures:**
   - Verify JWT token is valid and not expired
   - Check user roles and permissions

### Debug Commands

```bash
# Check service logs
tail -f auth-service/logs/application.log

# Test connectivity
curl -v http://localhost:8080/actuator/health

# Check registered services
curl http://localhost:8761/eureka/apps
```

## 📝 API Documentation

### Authentication Endpoints

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user info
- `POST /api/auth/refresh` - Refresh JWT token

### Transport Endpoints

- `GET /api/transport/shipments/tracking/{trackingNumber}` - Public tracking
- `POST /api/transport/shipments` - Create shipment (Auth required)
- `GET /api/transport/vehicles` - List vehicles (Auth required)
- `POST /api/transport/vehicles` - Create vehicle (Admin only)

### User Endpoints

- `GET /api/users/profile` - Get user profile
- `PUT /api/users/{username}` - Update user profile
- `GET /api/users/search` - Search users (Admin only)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.