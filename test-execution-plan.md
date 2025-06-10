# 🧪 **LOGISTICS PLATFORM - COMPREHENSIVE TEST EXECUTION**

## 📋 **Test Execution Strategy**

Bu test planı, tüm microservisleri sistematik olarak test etmek için tasarlanmıştır. Her aşama başarılı olmalı ki bir sonrakine geçebilelim.

---

## 🏗️ **PHASE 1: INFRASTRUCTURE SETUP & HEALTH CHECKS**

### 1.1 Database Preparation
```bash
# PostgreSQL veritabanlarını oluştur
createdb authdb
createdb userdb  
createdb transportdb

# Test kullanıcısı oluştur (eğer yoksa)
createuser logistics_user
```

### 1.2 Service Startup Sequence
```bash
# 1. Config Server (Port 8888) - İlk başlatılmalı
cd config-server && mvn spring-boot:run

# 2. Discovery Server (Port 8761) - Config'den sonra
cd discovery-server && mvn spring-boot:run

# 3. Gateway Service (Port 8080) - Discovery'den sonra
cd gateway-service && mvn spring-boot:run

# 4. Auth Service (Port 8081) - Gateway'den sonra
cd auth-service && mvn spring-boot:run

# 5. User Service (Port 8082) - Auth'dan sonra
cd user-service && mvn spring-boot:run

# 6. Transport Service (Port 8083) - Son olarak
cd transport-service && mvn spring-boot:run
```

### 1.3 Health Check Tests
```bash
# Test 1: Config Server Health
curl -X GET http://localhost:8888/actuator/health
# Expected: {"status":"UP"}

# Test 2: Discovery Server Health
curl -X GET http://localhost:8761/actuator/health
# Expected: {"status":"UP"}

# Test 3: Gateway Health
curl -X GET http://localhost:8080/actuator/health
# Expected: {"status":"UP"}

# Test 4: Auth Service Health
curl -X GET http://localhost:8081/actuator/health
# Expected: {"status":"UP"}

# Test 5: User Service Health
curl -X GET http://localhost:8082/actuator/health
# Expected: {"status":"UP"}

# Test 6: Transport Service Health
curl -X GET http://localhost:8083/actuator/health
# Expected: {"status":"UP"}
```

### 1.4 Service Discovery Verification
```bash
# Test 7: Check registered services
curl -X GET http://localhost:8761/eureka/apps
# Expected: XML response with all 4 services registered

# Test 8: Gateway routes check
curl -X GET http://localhost:8080/gateway/routes
# Expected: JSON array with configured routes
```

---

## 🔐 **PHASE 2: AUTHENTICATION & AUTHORIZATION FLOW**

### 2.1 User Registration Tests
```bash
# Test 9: Register new test user
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

### 2.2 User Login Tests
```bash
# Test 10: Login with test user
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

# Save token for subsequent tests
export USER_TOKEN="eyJhbGciOiJIUzUxMiJ9..."
```

### 2.3 Admin Login Test
```bash
# Test 11: Login as admin (pre-seeded)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'

# Save admin token
export ADMIN_TOKEN="eyJhbGciOiJIUzUxMiJ9..."
```

### 2.4 Token Validation Tests
```bash
# Test 12: Validate user token
curl -X GET http://localhost:8080/api/auth/validate \
  -H "Authorization: Bearer $USER_TOKEN"

# Test 13: Get current user info
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer $USER_TOKEN"
```

---

## 👥 **PHASE 3: USER SERVICE OPERATIONS**

### 3.1 User Profile Management
```bash
# Test 14: Create user profile
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

# Test 15: Get current user profile
curl -X GET http://localhost:8080/api/users/profile \
  -H "Authorization: Bearer $USER_TOKEN"

# Test 16: Update user profile
curl -X PUT http://localhost:8080/api/users/testuser \
  -H "Authorization: Bearer $USER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Updated Test",
    "company": "Updated Company"
  }'
```

### 3.2 User Search & Management
```bash
# Test 17: Search users (Admin only)
curl -X GET "http://localhost:8080/api/users/search?q=test" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 18: Get users by status
curl -X GET "http://localhost:8080/api/users/status/ACTIVE" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## 🚛 **PHASE 4: TRANSPORT SERVICE - CORE OPERATIONS**

### 4.1 Vehicle Management
```bash
# Test 19: Create vehicle (Admin/Manager only)
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

# Test 20: Get all vehicles
curl -X GET http://localhost:8080/api/transport/vehicles \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 21: Get available vehicles
curl -X GET http://localhost:8080/api/transport/vehicles/available \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 4.2 Shipment Management
```bash
# Test 22: Create shipment
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

# Save tracking number from response
export TRACKING_NUMBER="TRK17056789123456"

# Test 23: Get shipment by ID
curl -X GET http://localhost:8080/api/transport/shipments/1 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 4.3 Public Tracking (No Auth Required)
```bash
# Test 24: Track shipment without authentication
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

### 4.4 Vehicle Assignment & Status Updates
```bash
# Test 25: Assign vehicle to shipment
curl -X PATCH "http://localhost:8080/api/transport/shipments/1/assign-vehicle?vehicleId=1" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 26: Update shipment status
curl -X PATCH "http://localhost:8080/api/transport/shipments/1/status?status=PICKED_UP" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

curl -X PATCH "http://localhost:8080/api/transport/shipments/1/status?status=IN_TRANSIT" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## 🔍 **PHASE 5: ADVANCED FEATURES TESTING**

### 5.1 Advanced Filtering
```bash
# Test 27: Filter shipments by multiple criteria
curl -X POST http://localhost:8080/api/transport/transport/filter \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "origin": "İstanbul",
    "destination": "Ankara",
    "startDate": "2024-01-01T00:00:00",
    "endDate": "2024-01-31T23:59:59",
    "status": "IN_TRANSIT"
  }'

# Test 28: Search shipments
curl -X GET "http://localhost:8080/api/transport/shipments/search?q=İstanbul" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 5.2 Reporting & Analytics
```bash
# Test 29: Generate monthly report
curl -X GET "http://localhost:8080/api/transport/transport/reports/monthly?year=2024&month=1" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 30: Generate today's report
curl -X GET http://localhost:8080/api/transport/transport/reports/today \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 31: Generate comprehensive report
curl -X GET "http://localhost:8080/api/transport/transport/reports/comprehensive?startDate=2024-01-01T00:00:00&endDate=2024-01-31T23:59:59" \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 5.3 Route Logging & GPS Tracking
```bash
# Test 32: Add pickup log
curl -X POST "http://localhost:8080/api/transport/route-logs/pickup?shipmentId=1&location=İstanbul Depo&latitude=41.0082&longitude=28.9784" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 33: Add checkpoint log
curl -X POST "http://localhost:8080/api/transport/route-logs/checkpoint?shipmentId=1&location=Bolu Geçidi&description=Ara durak&latitude=40.7394&longitude=31.6068" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 34: Add delivery log
curl -X POST "http://localhost:8080/api/transport/route-logs/delivery?shipmentId=1&location=Ankara Merkez&latitude=39.9334&longitude=32.8597" \
  -H "Authorization: Bearer $ADMIN_TOKEN"

# Test 35: Get shipment route logs
curl -X GET http://localhost:8080/api/transport/route-logs/shipment/1 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## 📄 **PHASE 6: DOCUMENT EXPORT TESTING**

### 6.1 PDF Export
```bash
# Test 36: Export shipment document as PDF
curl -X GET http://localhost:8080/api/transport/documents/export/pdf/1 \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  --output "transport-document-1.pdf"

# Verify file was created
ls -la transport-document-1.pdf
```

### 6.2 Excel Export
```bash
# Test 37: Export shipment document as Excel
curl -X GET http://localhost:8080/api/transport/documents/export/excel/1 \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  --output "transport-document-1.xlsx"

# Verify file was created
ls -la transport-document-1.xlsx
```

### 6.3 Document Preview
```bash
# Test 38: Get document preview
curl -X GET http://localhost:8080/api/transport/documents/preview/1 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## 🛡️ **PHASE 7: SECURITY & AUTHORIZATION TESTING**

### 7.1 Unauthorized Access Tests
```bash
# Test 39: Access protected endpoint without token (Should fail)
curl -X GET http://localhost:8080/api/users
# Expected: 401 Unauthorized

# Test 40: Access admin endpoint with user token (Should fail)
curl -X DELETE http://localhost:8080/api/transport/vehicles/1 \
  -H "Authorization: Bearer $USER_TOKEN"
# Expected: 403 Forbidden

# Test 41: Invalid token test
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer invalid_token"
# Expected: 401 Unauthorized
```

### 7.2 Role-Based Access Control
```bash
# Test 42: User can access own profile
curl -X GET http://localhost:8080/api/users/profile \
  -H "Authorization: Bearer $USER_TOKEN"
# Expected: 200 OK

# Test 43: User cannot access admin functions
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer $USER_TOKEN"
# Expected: 403 Forbidden

# Test 44: Admin can access all functions
curl -X GET http://localhost:8080/api/users \
  -H "Authorization: Bearer $ADMIN_TOKEN"
# Expected: 200 OK
```

---

## ⚡ **PHASE 8: PERFORMANCE & LOAD TESTING**

### 8.1 Concurrent Request Testing
```bash
# Test 45: Multiple concurrent tracking requests
for i in {1..10}; do
  curl -X GET "http://localhost:8080/api/transport/shipments/tracking/$TRACKING_NUMBER" &
done
wait

# Test 46: Concurrent login requests
for i in {1..5}; do
  curl -X POST http://localhost:8080/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username": "testuser", "password": "test123"}' &
done
wait
```

### 8.2 Database Connection Testing
```bash
# Test 47: Check all service health under load
for i in {1..20}; do
  curl -X GET http://localhost:8080/actuator/health &
  curl -X GET http://localhost:8081/actuator/health &
  curl -X GET http://localhost:8082/actuator/health &
  curl -X GET http://localhost:8083/actuator/health &
done
wait
```

---

## 🐛 **PHASE 9: ERROR HANDLING & EDGE CASES**

### 9.1 Invalid Data Tests
```bash
# Test 48: Invalid login credentials
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "invalid",
    "password": "wrong"
  }'
# Expected: 400 Bad Request

# Test 49: Invalid tracking number
curl -X GET http://localhost:8080/api/transport/shipments/tracking/INVALID123
# Expected: 404 Not Found

# Test 50: Missing required fields
curl -X POST http://localhost:8080/api/transport/shipments \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "originAddress": "İstanbul"
  }'
# Expected: 400 Bad Request with validation errors
```

### 9.2 Resource Not Found Tests
```bash
# Test 51: Non-existent shipment
curl -X GET http://localhost:8080/api/transport/shipments/99999 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
# Expected: 404 Not Found

# Test 52: Non-existent vehicle
curl -X GET http://localhost:8080/api/transport/vehicles/99999 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
# Expected: 404 Not Found
```

---

## 📊 **PHASE 10: MONITORING & METRICS**

### 10.1 Service Discovery Monitoring
```bash
# Test 53: Check all registered services
curl -X GET http://localhost:8761/eureka/apps

# Test 54: Check gateway routes
curl -X GET http://localhost:8080/gateway/routes
```

### 10.2 Metrics Collection
```bash
# Test 55: Collect metrics from all services
curl -X GET http://localhost:8080/actuator/metrics
curl -X GET http://localhost:8081/actuator/metrics
curl -X GET http://localhost:8082/actuator/metrics
curl -X GET http://localhost:8083/actuator/metrics
```

---

## ✅ **SUCCESS CRITERIA CHECKLIST**

### Phase 1 - Infrastructure ✅
- [ ] All services start without errors
- [ ] Services register with Eureka successfully
- [ ] Gateway routes traffic correctly
- [ ] Health checks pass for all services

### Phase 2 - Authentication ✅
- [ ] User registration works correctly
- [ ] User login returns valid JWT tokens
- [ ] Token validation works across services
- [ ] Admin login provides elevated access

### Phase 3 - User Management ✅
- [ ] User profiles can be created and updated
- [ ] Authorization works correctly
- [ ] Search functionality operates properly
- [ ] Role-based access is enforced

### Phase 4 - Transport Core ✅
- [ ] Vehicles can be created and managed
- [ ] Shipments can be created and tracked
- [ ] Public tracking works without authentication
- [ ] Status updates function correctly

### Phase 5 - Advanced Features ✅
- [ ] Advanced filtering works with multiple criteria
- [ ] Reports generate accurate analytics
- [ ] Route logging captures GPS coordinates
- [ ] Search functionality is responsive

### Phase 6 - Document Export ✅
- [ ] PDF export generates valid documents
- [ ] Excel export creates proper spreadsheets
- [ ] Document preview provides information
- [ ] File downloads work correctly

### Phase 7 - Security ✅
- [ ] Unauthorized access is properly blocked
- [ ] Role-based permissions are enforced
- [ ] Invalid tokens are rejected
- [ ] Security restrictions work as expected

### Phase 8 - Performance ✅
- [ ] System handles concurrent requests
- [ ] Response times are acceptable (<2s)
- [ ] No memory leaks or connection issues
- [ ] Database connections remain stable

### Phase 9 - Error Handling ✅
- [ ] Invalid data returns proper error messages
- [ ] Resource not found scenarios handled
- [ ] Validation errors are descriptive
- [ ] System gracefully handles failures

### Phase 10 - Monitoring ✅
- [ ] All services are discoverable
- [ ] Metrics are collected properly
- [ ] Health checks provide accurate status
- [ ] System monitoring is functional

---

## 🔧 **TROUBLESHOOTING GUIDE**

### Common Issues & Solutions:

1. **Service Won't Start**
   - Check database connection
   - Verify port availability
   - Check application.yml configuration

2. **401 Unauthorized Errors**
   - Verify JWT token is valid and not expired
   - Check Authorization header format
   - Ensure user has proper roles

3. **503 Service Unavailable**
   - Check if target service is registered with Eureka
   - Verify service discovery is working
   - Check network connectivity

4. **Database Connection Errors**
   - Verify PostgreSQL is running
   - Check database credentials
   - Ensure databases exist

### Debug Commands:
```bash
# Check service logs
tail -f auth-service/logs/application.log
tail -f user-service/logs/application.log
tail -f transport-service/logs/application.log

# Check network connectivity
curl -v http://localhost:8761/eureka/apps
curl -v http://localhost:8080/actuator/health

# Verify JWT token
echo "eyJhbGciOiJIUzUxMiJ9..." | base64 -d
```

---

## 📝 **TEST EXECUTION LOG**

**Date**: [Current Date]  
**Tester**: [Your Name]  
**Environment**: Local Development  

### Test Results Summary:
- **Total Tests**: 55
- **Passed**: [ ]
- **Failed**: [ ]
- **Skipped**: [ ]

### Failed Tests (if any):
[List any failed tests with details]

### Performance Metrics:
- **Average Response Time**: [ ]ms
- **Peak Memory Usage**: [ ]MB
- **Database Connections**: [ ]

### Recommendations:
[Any improvements or issues found]

---

**🎉 READY TO START TESTING! 🎉**

Bu kapsamlı test planı ile sistemimizin her bileşenini detaylı olarak test edeceğiz. Her aşamayı sırayla takip edelim!