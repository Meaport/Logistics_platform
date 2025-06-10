# 🚀 Logistics Platform - Comprehensive Testing Plan

## 📋 Test Strategy Overview

Bu test planı, tüm microservisleri sistematik olarak test etmek için tasarlanmıştır. Testler aşamalı olarak yapılacak ve her servisin bağımsız çalışabilirliği doğrulanacaktır.

## 🏗️ Infrastructure Setup (Phase 1)

### 1.1 Database Setup
```bash
# PostgreSQL veritabanlarını oluştur
createdb authdb
createdb userdb  
createdb transportdb

# Kullanıcı oluştur
createuser logistics_user
```

### 1.2 Service Startup Order
```bash
# 1. Config Server (Port 8888)
cd config-server && mvn spring-boot:run

# 2. Discovery Server (Port 8761) 
cd discovery-server && mvn spring-boot:run

# 3. Gateway Service (Port 8080)
cd gateway-service && mvn spring-boot:run

# 4. Auth Service (Port 8081)
cd auth-service && mvn spring-boot:run

# 5. User Service (Port 8082)
cd user-service && mvn spring-boot:run

# 6. Transport Service (Port 8083)
cd transport-service && mvn spring-boot:run
```

## 🔐 Authentication Flow Testing (Phase 2)

### 2.1 User Registration Test
```bash
# Test 1: Register new user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@logistics.com",
    "password": "test123",
    "firstName": "Test",
    "lastName": "User"
  }'

# Expected Response:
{
  "success": true,
  "data": {
    "username": "testuser",
    "email": "test@logistics.com",
    "message": "User registered successfully"
  }
}
```

### 2.2 User Login Test
```bash
# Test 2: Login with registered user
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "test123"
  }'

# Expected Response:
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzUxMiJ9...",
    "tokenType": "Bearer",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "expiresIn": 86400,
    "user": {
      "id": 2,
      "username": "testuser",
      "email": "test@logistics.com",
      "roles": ["USER"]
    }
  }
}
```

### 2.3 Admin Login Test
```bash
# Test 3: Login as admin (pre-seeded)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'

# Save the admin token for subsequent tests
export ADMIN_TOKEN="eyJhbGciOiJIUzUxMiJ9..."
```

## 👤 User Service Testing (Phase 3)

### 3.1 Create User Profile
```bash
# Test 4: Create user profile (Admin only)
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "authUserId": 2,
    "username": "testuser",
    "email": "test@logistics.com",
    "firstName": "Test",
    "lastName": "User",
    "company": "Test Company",
    "position": "Developer"
  }'
```

### 3.2 Get Current User Profile
```bash
# Test 5: Get current user profile
curl -X GET http://localhost:8080/api/users/profile \
  -H "Authorization: Bearer $USER_TOKEN"
```

### 3.3 Search Users
```bash
# Test 6: Search users (Admin/Manager only)
curl -X GET "http://localhost:8080/api/users/search?q=test" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

## 🚛 Transport Service Testing (Phase 4)

### 4.1 Create Vehicle
```bash
# Test 7: Create new vehicle (Admin/Manager only)
curl -X POST http://localhost:8080/api/transport/vehicles \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "licensePlate": "34 ABC 123",
    "vehicleType": "Kamyon",
    "brand": "Mercedes",
    "model": "Actros",
    "year": 2022,
    "capacityKg": 15000,
    "capacityM3": 45,
    "currentLocation": "İstanbul Depo",
    "fuelType": "Dizel"
  }'
```

### 4.2 Create Shipment
```bash
# Test 8: Create new shipment
curl -X POST http://localhost:8080/api/transport/shipments \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "senderId": 1,
    "receiverId": 2,
    "originAddress": "İstanbul Merkez",
    "destinationAddress": "Ankara Çankaya",
    "weightKg": 15.5,
    "volumeM3": 0.8,
    "declaredValue": 1500.00,
    "priority": "HIGH",
    "pickupDate": "2024-01-20T09:00:00",
    "estimatedDelivery": "2024-01-22T17:00:00",
    "notes": "Kırılabilir eşya"
  }'

# Save tracking number for next tests
export TRACKING_NUMBER="TRK17056789123456"
```

### 4.3 Track Shipment (Public)
```bash
# Test 9: Track shipment without authentication
curl -X GET "http://localhost:8080/api/transport/shipments/tracking/$TRACKING_NUMBER"

# Expected Response:
{
  "success": true,
  "data": {
    "trackingNumber": "TRK17056789123456",
    "status": "PENDING",
    "originAddress": "İstanbul Merkez",
    "destinationAddress": "Ankara Çankaya",
    "estimatedDelivery": "2024-01-22T17:00:00"
  }
}
```

### 4.4 Assign Vehicle to Shipment
```bash
# Test 10: Assign vehicle to shipment
curl -X PATCH "http://localhost:8080/api/transport/shipments/1/assign-vehicle?vehicleId=1" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

## 🔄 Integration Testing (Phase 5)

### 5.1 End-to-End Workflow Test
```bash
# Test 11: Complete shipment workflow
# 1. Create shipment
# 2. Assign vehicle
# 3. Update status to PICKED_UP
# 4. Update status to IN_TRANSIT
# 5. Update status to DELIVERED

curl -X PATCH "http://localhost:8080/api/transport/shipments/1/status?status=PICKED_UP" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

curl -X PATCH "http://localhost:8080/api/transport/shipments/1/status?status=IN_TRANSIT" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

curl -X PATCH "http://localhost:8080/api/transport/shipments/1/status?status=DELIVERED" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 5.2 Security Testing
```bash
# Test 12: Access protected endpoint without token (Should fail)
curl -X GET http://localhost:8080/api/users

# Expected Response: 401 Unauthorized

# Test 13: Access admin endpoint with user token (Should fail)
curl -X DELETE http://localhost:8080/api/transport/vehicles/1 \
  -H "Authorization: Bearer $USER_TOKEN"

# Expected Response: 403 Forbidden
```

## 📊 Performance & Load Testing (Phase 6)

### 6.1 Gateway Load Test
```bash
# Test 14: Multiple concurrent requests
for i in {1..10}; do
  curl -X GET "http://localhost:8080/api/transport/shipments/tracking/$TRACKING_NUMBER" &
done
wait
```

### 6.2 Database Connection Test
```bash
# Test 15: Check database connections
curl -X GET http://localhost:8080/actuator/health
curl -X GET http://localhost:8081/actuator/health  
curl -X GET http://localhost:8082/actuator/health
curl -X GET http://localhost:8083/actuator/health
```

## 🐛 Error Handling Testing (Phase 7)

### 7.1 Invalid Data Tests
```bash
# Test 16: Invalid login credentials
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "invalid",
    "password": "wrong"
  }'

# Test 17: Invalid tracking number
curl -X GET http://localhost:8080/api/transport/shipments/tracking/INVALID123
```

### 7.2 Validation Tests
```bash
# Test 18: Missing required fields
curl -X POST http://localhost:8080/api/transport/shipments \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originAddress": "İstanbul"
  }'
```

## 📈 Monitoring & Metrics (Phase 8)

### 8.1 Service Discovery Check
```bash
# Test 19: Check registered services
curl -X GET http://localhost:8761/eureka/apps
```

### 8.2 Gateway Routes Check
```bash
# Test 20: Check gateway routes
curl -X GET http://localhost:8080/gateway/routes
```

### 8.3 Metrics Collection
```bash
# Test 21: Collect metrics from all services
curl -X GET http://localhost:8080/actuator/metrics
curl -X GET http://localhost:8081/actuator/metrics
curl -X GET http://localhost:8082/actuator/metrics
curl -X GET http://localhost:8083/actuator/metrics
```

## 🎯 Success Criteria

### ✅ Phase 1 Success Criteria:
- [ ] All services start without errors
- [ ] Services register with Eureka
- [ ] Gateway routes traffic correctly

### ✅ Phase 2 Success Criteria:
- [ ] User registration works
- [ ] User login returns valid JWT
- [ ] Token validation works across services

### ✅ Phase 3 Success Criteria:
- [ ] User profiles can be created/updated
- [ ] Authorization works correctly
- [ ] Search functionality works

### ✅ Phase 4 Success Criteria:
- [ ] Vehicles can be created/managed
- [ ] Shipments can be created/tracked
- [ ] Public tracking works without auth
- [ ] Business logic (cost calculation) works

### ✅ Phase 5 Success Criteria:
- [ ] End-to-end workflows complete successfully
- [ ] Security restrictions are enforced
- [ ] Cross-service communication works

### ✅ Phase 6 Success Criteria:
- [ ] System handles concurrent requests
- [ ] Response times are acceptable (<2s)
- [ ] No memory leaks or connection issues

### ✅ Phase 7 Success Criteria:
- [ ] Error responses are properly formatted
- [ ] Validation works correctly
- [ ] System gracefully handles failures

### ✅ Phase 8 Success Criteria:
- [ ] All services are discoverable
- [ ] Metrics are collected properly
- [ ] Health checks pass

## 🔧 Troubleshooting Guide

### Common Issues:
1. **Service won't start**: Check database connection and port availability
2. **401 Unauthorized**: Verify JWT token is valid and not expired
3. **503 Service Unavailable**: Check if target service is registered with Eureka
4. **Database errors**: Verify PostgreSQL is running and databases exist

### Debug Commands:
```bash
# Check service logs
docker logs logistics-postgres
tail -f auth-service/logs/application.log

# Check network connectivity
curl -v http://localhost:8761/eureka/apps
curl -v http://localhost:8080/actuator/health

# Verify JWT token
echo "eyJhbGciOiJIUzUxMiJ9..." | base64 -d
```

## 📝 Test Report Template

```markdown
# Test Execution Report

**Date**: [Date]
**Tester**: [Name]
**Environment**: Local Development

## Test Results Summary
- Total Tests: 21
- Passed: [X]
- Failed: [Y]
- Skipped: [Z]

## Failed Tests
[List any failed tests with details]

## Performance Metrics
- Average Response Time: [X]ms
- Peak Memory Usage: [X]MB
- Database Connections: [X]

## Recommendations
[Any improvements or issues found]
```

---

Bu test planı, sistemin tüm bileşenlerini kapsamlı olarak test eder ve production'a hazır olduğunu doğrular.