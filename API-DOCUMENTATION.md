# 📚 **LOGISTICS PLATFORM - API DOCUMENTATION**

## 🌐 **Base URL**
```
http://localhost:8080
```

---

## 🔐 **Authentication Endpoints**

### POST /api/auth/register
Register a new user account.

**Request:**
```json
{
  "username": "string",
  "email": "string",
  "password": "string",
  "firstName": "string",
  "lastName": "string",
  "phoneNumber": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "username": "string",
    "email": "string",
    "message": "User registered successfully"
  }
}
```

### POST /api/auth/login
Authenticate user and get JWT token.

**Request:**
```json
{
  "username": "string",
  "password": "string"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzUxMiJ9...",
    "tokenType": "Bearer",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "expiresIn": 86400,
    "user": {
      "id": 1,
      "username": "string",
      "email": "string",
      "roles": ["USER"]
    }
  }
}
```

### GET /api/auth/me
Get current user information.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "string",
    "email": "string",
    "roles": ["USER"]
  }
}
```

---

## 👥 **User Management Endpoints**

### GET /api/users/profile
Get current user profile.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "string",
    "email": "string",
    "firstName": "string",
    "lastName": "string",
    "company": "string",
    "position": "string",
    "status": "ACTIVE"
  }
}
```

### PUT /api/users/{username}
Update user profile.

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "firstName": "string",
  "lastName": "string",
  "company": "string",
  "position": "string"
}
```

---

## 🚛 **Vehicle Management Endpoints**

### GET /api/transport/vehicles
Get all vehicles (Admin/Manager only).

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `page`: Page number (default: 0)
- `size`: Page size (default: 20)

**Response:**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "licensePlate": "34 ABC 123",
        "vehicleType": "Kamyon",
        "brand": "Mercedes",
        "model": "Actros",
        "year": 2022,
        "capacityKg": 15000.00,
        "capacityM3": 45.00,
        "status": "AVAILABLE",
        "currentLocation": "İstanbul Depo"
      }
    ],
    "totalElements": 1,
    "totalPages": 1
  }
}
```

### POST /api/transport/vehicles
Create new vehicle (Admin/Manager only).

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "licensePlate": "34 ABC 123",
  "vehicleType": "Kamyon",
  "brand": "Mercedes",
  "model": "Actros",
  "year": 2022,
  "capacityKg": 15000.00,
  "capacityM3": 45.00,
  "currentLocation": "İstanbul Depo",
  "fuelType": "Dizel"
}
```

### GET /api/transport/vehicles/available
Get available vehicles.

**Headers:**
```
Authorization: Bearer {token}
```

---

## 📦 **Shipment Management Endpoints**

### GET /api/transport/shipments/tracking/{trackingNumber}
**Public endpoint** - Track shipment by tracking number.

**No authentication required**

**Response:**
```json
{
  "success": true,
  "data": {
    "trackingNumber": "TRK17056789123456",
    "status": "IN_TRANSIT",
    "originAddress": "İstanbul Merkez",
    "destinationAddress": "Ankara Çankaya",
    "estimatedDelivery": "2024-01-25T15:00:00",
    "currentLocation": "Bolu Geçidi"
  }
}
```

### POST /api/transport/shipments
Create new shipment.

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "senderId": 1,
  "receiverId": 2,
  "originAddress": "İstanbul Merkez",
  "destinationAddress": "Ankara Çankaya",
  "weightKg": 150.50,
  "volumeM3": 2.30,
  "declaredValue": 2500.00,
  "priority": "HIGH",
  "estimatedDelivery": "2024-01-25T15:00:00",
  "notes": "Kırılabilir eşya"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "trackingNumber": "TRK17056789123456",
    "status": "PENDING",
    "shippingCost": 125.50,
    "createdAt": "2024-01-20T10:00:00"
  }
}
```

### PATCH /api/transport/shipments/{id}/status
Update shipment status.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `status`: New status (PENDING, PICKED_UP, IN_TRANSIT, DELIVERED, etc.)

### PATCH /api/transport/shipments/{id}/assign-vehicle
Assign vehicle to shipment.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `vehicleId`: Vehicle ID to assign

---

## 📍 **Route Logging Endpoints**

### GET /api/transport/route-logs/shipment/{shipmentId}
Get route logs for a shipment.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "shipmentId": 1,
      "location": "İstanbul Depo",
      "latitude": 41.0082,
      "longitude": 28.9784,
      "logType": "PICKUP",
      "description": "Shipment picked up",
      "timestamp": "2024-01-20T09:00:00"
    }
  ]
}
```

### POST /api/transport/route-logs/pickup
Log pickup event.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `shipmentId`: Shipment ID
- `location`: Location name
- `latitude`: GPS latitude (optional)
- `longitude`: GPS longitude (optional)

### POST /api/transport/route-logs/delivery
Log delivery event.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `shipmentId`: Shipment ID
- `location`: Location name
- `latitude`: GPS latitude (optional)
- `longitude`: GPS longitude (optional)

---

## 📊 **Reporting Endpoints**

### GET /api/transport/reports/today
Get today's transport report.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "reportDate": "2024-01-20T10:00:00",
    "reportType": "DAILY_SUMMARY",
    "totalShipments": 15,
    "deliveredShipments": 8,
    "inTransitShipments": 5,
    "pendingShipments": 2,
    "totalRevenue": 12500.00,
    "onTimeDeliveryRate": 95.5
  }
}
```

### GET /api/transport/reports/monthly
Get monthly report.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `year`: Year (e.g., 2024)
- `month`: Month (1-12)

---

## 📄 **Document Export Endpoints**

### GET /api/transport/documents/export/pdf/{shipmentId}
Export shipment document as PDF.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** PDF file download

### GET /api/transport/documents/export/excel/{shipmentId}
Export shipment document as Excel.

**Headers:**
```
Authorization: Bearer {token}
```

**Response:** Excel file download

---

## 🔍 **Search and Filter Endpoints**

### POST /api/transport/filter
Advanced shipment filtering.

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "origin": "İstanbul",
  "destination": "Ankara",
  "startDate": "2024-01-01T00:00:00",
  "endDate": "2024-01-31T23:59:59",
  "status": "IN_TRANSIT",
  "priority": "HIGH"
}
```

### GET /api/transport/shipments/search
Search shipments.

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `q`: Search term
- `page`: Page number
- `size`: Page size

---

## 🏥 **Health Check Endpoints**

### GET /actuator/health
Service health check.

**Response:**
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP"
    },
    "diskSpace": {
      "status": "UP"
    }
  }
}
```

### GET /actuator/metrics
Service metrics.

### GET /actuator/info
Service information.

---

## 🔒 **Authentication & Authorization**

### JWT Token Format
```
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJhZG1pbiIsInJvbGVzIjpbIlJPTEVfQURNSU4iXSwiaWF0IjoxNjQwOTk1MjAwLCJleHAiOjE2NDA5OTg4MDB9.signature
```

### Role-Based Access Control

**ADMIN Role:**
- Full access to all endpoints
- Can manage users, vehicles, and shipments
- Can access all reports and analytics

**MANAGER Role:**
- Can manage vehicles and shipments
- Can access reports
- Limited user management

**USER Role:**
- Can view own shipments
- Can track shipments
- Limited access to reports

### Public Endpoints (No Auth Required)
- `GET /api/transport/shipments/tracking/{trackingNumber}`
- `GET /actuator/health`
- `POST /api/auth/register`
- `POST /api/auth/login`

---

## 📝 **Error Responses**

### Standard Error Format
```json
{
  "success": false,
  "error": "Error Type",
  "message": "Detailed error message",
  "timestamp": "2024-01-20T10:00:00"
}
```

### Common HTTP Status Codes
- `200 OK`: Success
- `201 Created`: Resource created
- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

---

## 🧪 **Testing Examples**

### Complete Workflow Test
```bash
# 1. Register user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testapi","email":"testapi@company.com","password":"test123"}'

# 2. Login and get token
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | \
  jq -r '.data.token')

# 3. Create vehicle
curl -X POST http://localhost:8080/api/transport/vehicles \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"licensePlate":"34 API 123","vehicleType":"Van","brand":"Ford","model":"Transit"}'

# 4. Create shipment
curl -X POST http://localhost:8080/api/transport/shipments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"senderId":1,"receiverId":2,"originAddress":"Test Origin","destinationAddress":"Test Destination"}'

# 5. Track shipment (public)
curl http://localhost:8080/api/transport/shipments/tracking/TRK17056789123456
```

---

**📚 This API documentation covers all available endpoints in the Logistics Platform. For more examples and advanced usage, refer to the test files and implementation guides.**