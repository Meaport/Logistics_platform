# 🚀 **LOGISTICS PLATFORM - QUICK START GUIDE**

## ⚡ **Get Started in 5 Minutes**

### Prerequisites
- Node.js 14+ installed
- Java 17+ installed (for local development)
- Maven 3.6+ installed (for local development)

---

## 🎯 **Option 1: Quick Demo (Recommended)**

### Step 1: Start Services
```bash
# Clone and navigate to project
cd logistics-platform

# Start all services automatically
npm run start-services
```

### Step 2: Test the System
```bash
# Run comprehensive tests
npm test

# Expected: All tests pass ✅
```

### Step 3: Try Key Features
```bash
# Test public tracking (no auth needed)
curl http://localhost:8080/api/transport/shipments/tracking/TRK17056789123456

# Test user registration
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"demo","email":"demo@company.com","password":"demo123"}'

# Test admin login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

---

## 🐳 **Option 2: Docker Deployment**

### Step 1: Deploy with Docker
```bash
# Start production environment
npm run docker-up

# Check status
docker-compose ps
```

### Step 2: Verify Deployment
```bash
# Health check all services
npm run health-check

# Run tests against Docker environment
npm test
```

---

## 🌐 **Option 3: Cloud Deployment**

### Step 1: Configure Supabase
1. Create Supabase project at https://supabase.com
2. Run the SQL migrations provided in `/supabase/migrations/`
3. Update connection strings in service configurations

### Step 2: Deploy to Cloud
```bash
# Deploy to Kubernetes
kubectl apply -f k8s/

# Or deploy to your preferred cloud platform
# (AWS, GCP, Azure, etc.)
```

---

## 🧪 **Testing the Platform**

### Core Features Test
```bash
# 1. Health Check
curl http://localhost:8080/actuator/health

# 2. Service Discovery
curl http://localhost:8761/eureka/apps

# 3. Public Tracking
curl http://localhost:8080/api/transport/shipments/tracking/TRK17056789123456

# 4. User Authentication
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

### Advanced Features Test
```bash
# Get admin token first
TOKEN=$(curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}' | \
  jq -r '.data.token')

# Test vehicle management
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/transport/vehicles

# Test document export
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/transport/documents/export/pdf/1 \
  --output test-document.pdf

# Test reporting
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/transport/reports/today"
```

---

## 📊 **Key URLs**

### Main Services
- **API Gateway**: http://localhost:8080
- **Discovery Server**: http://localhost:8761
- **Config Server**: http://localhost:8888

### Health Checks
- **Gateway Health**: http://localhost:8080/actuator/health
- **Auth Health**: http://localhost:8081/actuator/health
- **User Health**: http://localhost:8082/actuator/health
- **Transport Health**: http://localhost:8083/actuator/health

### API Endpoints
- **Authentication**: http://localhost:8080/api/auth/*
- **User Management**: http://localhost:8080/api/users/*
- **Transport Operations**: http://localhost:8080/api/transport/*

---

## 🔑 **Default Credentials**

### Admin User
- **Username**: `admin`
- **Password**: `admin123`
- **Roles**: ADMIN (full access)

### Test User
- **Username**: `testuser`
- **Password**: `test123`
- **Roles**: USER (limited access)

---

## 📱 **Sample API Calls**

### Authentication
```bash
# Register new user
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "newuser",
    "email": "newuser@company.com",
    "password": "password123",
    "firstName": "New",
    "lastName": "User"
  }'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

### Transport Operations
```bash
# Create vehicle (Admin required)
curl -X POST http://localhost:8080/api/transport/vehicles \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "licensePlate": "34 TEST 123",
    "vehicleType": "Van",
    "brand": "Ford",
    "model": "Transit",
    "year": 2023,
    "capacityKg": 2000,
    "currentLocation": "Istanbul"
  }'

# Create shipment
curl -X POST http://localhost:8080/api/transport/shipments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "senderId": 1,
    "receiverId": 2,
    "originAddress": "Istanbul Center",
    "destinationAddress": "Ankara Center",
    "weightKg": 50.5,
    "declaredValue": 1000,
    "priority": "HIGH"
  }'
```

---

## 🔧 **Troubleshooting**

### Services Won't Start
```bash
# Check if ports are available
netstat -tulpn | grep :8080

# Check Java version
java -version

# Check Maven version
mvn -version
```

### Database Connection Issues
```bash
# Test database connectivity
curl http://localhost:8081/actuator/health

# Check database logs
docker-compose logs postgres
```

### Authentication Issues
```bash
# Verify JWT token
echo $TOKEN | cut -d'.' -f2 | base64 -d

# Check auth service logs
curl http://localhost:8081/actuator/health
```

---

## 📞 **Getting Help**

### Common Issues
1. **Port conflicts**: Change ports in application.yml files
2. **Java version**: Ensure Java 17+ is installed
3. **Database issues**: Check PostgreSQL connection
4. **Memory issues**: Increase JVM heap size

### Debug Commands
```bash
# Check all service health
for port in 8080 8081 8082 8083; do
  echo "Port $port: $(curl -s http://localhost:$port/actuator/health | jq -r .status)"
done

# Check service registration
curl -s http://localhost:8761/eureka/apps | grep -o '<name>[^<]*</name>'

# Monitor resource usage
docker stats --no-stream
```

---

## 🎉 **Success!**

If you can access these URLs successfully, your platform is ready:

- ✅ **Gateway**: http://localhost:8080/actuator/health
- ✅ **Discovery**: http://localhost:8761
- ✅ **Public Tracking**: http://localhost:8080/api/transport/shipments/tracking/TRK17056789123456

**You now have a fully functional logistics platform!**

### What's Next?
1. **Explore the APIs**: Try different endpoints
2. **Customize Configuration**: Modify for your needs
3. **Deploy to Production**: Use provided deployment guides
4. **Scale the System**: Add more service instances

**Happy logistics management! 🚛📦**