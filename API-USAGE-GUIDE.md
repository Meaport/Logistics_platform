# 🚀 Logistics Platform API Usage Guide

## 🌐 Server Information
- **Production Server**: http://52.183.72.253:8080 ✅ ONLINE
- **Eureka Dashboard**: http://52.183.72.253:8761 ✅ ACCESSIBLE
- **External Connectivity**: ✅ FULLY OPERATIONAL

## 🔐 Quick Authentication Test

### Admin Login
```bash
curl -X POST http://52.183.72.253:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Get JWT Token (Automated)
```bash
TOKEN=$(curl -s -X POST http://52.183.72.253:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | \
  jq -r '.data.token')
echo "Token: $TOKEN"
```

## 🚛 Transport Operations

### Create Vehicle
```bash
curl -X POST http://52.183.72.253:8080/api/transport/vehicles \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "licensePlate": "34 ABC 123",
    "vehicleType": "Truck",
    "brand": "Mercedes",
    "model": "Actros",
    "year": 2023,
    "capacityKg": 5000
  }'
```

### Create Shipment
```bash
curl -X POST http://52.183.72.253:8080/api/transport/shipments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "senderId": 1,
    "receiverId": 2,
    "originAddress": "Istanbul Merkez",
    "destinationAddress": "Ankara Merkez",
    "weightKg": 100.5,
    "declaredValue": 2000,
    "priority": "HIGH"
  }'
```

### Track Shipment (Public - No Auth Required)
```bash
curl http://52.183.72.253:8080/api/transport/shipments/tracking/TRK17056789123456
```

## 👥 User Management

### Get User Profile
```bash
curl -X GET http://52.183.72.253:8080/api/users/profile \
  -H "Authorization: Bearer $TOKEN"
```

### Update User Profile
```bash
curl -X PUT http://52.183.72.253:8080/api/users/admin \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Updated",
    "lastName": "Name",
    "email": "updated@company.com"
  }'
```

## 🧪 Health Check Commands

### Test All Service Health
```bash
curl http://52.183.72.253:8080/actuator/health  # Gateway
curl http://52.183.72.253:8081/actuator/health  # Auth
curl http://52.183.72.253:8082/actuator/health  # User
curl http://52.183.72.253:8083/actuator/health  # Transport
curl http://52.183.72.253:8888/actuator/health  # Config
curl http://52.183.72.253:8761/actuator/health  # Discovery
```

## 🔧 Default Credentials
- **Admin Username**: `admin`
- **Admin Password**: `admin123`

## 🌍 External Access Status
✅ **CONFIRMED WORKING**: Digital Ocean firewall correctly applied to "logistics-platform-server" droplet. All API endpoints are accessible externally using server IP address (52.183.72.253).

**PowerShell Test Commands (Confirmed Working)**:
```powershell
# Test main services
Invoke-RestMethod -Uri "http://52.183.72.253:8080/actuator/health"
Invoke-RestMethod -Uri "http://52.183.72.253:8081/actuator/health"
Invoke-RestMethod -Uri "http://52.183.72.253:8082/actuator/health"
Invoke-RestMethod -Uri "http://52.183.72.253:8083/actuator/health"

# Access Eureka dashboard
Invoke-WebRequest -Uri "http://52.183.72.253:8761"
```

For complete API documentation, see `API-DOCUMENTATION.md`.
