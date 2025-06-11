# 🚂 **RAILWAY MANUAL SETUP GUIDE**

## WebContainer Environment - Manual Deployment

Since global npm packages cannot be installed in WebContainer, we'll use alternative approaches.

---

## 🔧 **Option 1: Using npx (Recommended)**

### Step 1: Login to Railway
```bash
npx @railway/cli login
```

### Step 2: Create Projects for Each Service
```bash
# Config Server
npx @railway/cli new --name logistics-config-server

# Discovery Server  
npx @railway/cli new --name logistics-discovery-server

# Gateway Service
npx @railway/cli new --name logistics-gateway-service

# Auth Service
npx @railway/cli new --name logistics-auth-service

# User Service
npx @railway/cli new --name logistics-user-service

# Transport Service
npx @railway/cli new --name logistics-transport-service
```

### Step 3: Deploy Services
```bash
# For each service directory:
cd config-server
npx @railway/cli up

cd ../discovery-server
npx @railway/cli up

# Continue for all services...
```

---

## 🔧 **Option 2: Manual Dashboard Setup**

### Step 1: Go to Railway Dashboard
1. Visit: https://railway.app/dashboard
2. Click "New Project"
3. Select "Deploy from GitHub repo"

### Step 2: Create Projects
Create separate projects for each service:
- `logistics-config-server`
- `logistics-discovery-server`
- `logistics-gateway-service`
- `logistics-auth-service`
- `logistics-user-service`
- `logistics-transport-service`

### Step 3: Configure Each Project
For each project:
1. Set the **Root Directory** to the service folder (e.g., `config-server`)
2. Set **Build Command**: `mvn clean package -DskipTests`
3. Set **Start Command**: `java -jar target/*.jar`

### Step 4: Environment Variables
Set these variables for each service in Railway dashboard:

#### Common Variables (All Services)
```
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=your-super-secure-256-bit-secret-key-here
```

#### Config Server
```
PORT=8888
```

#### Discovery Server
```
PORT=8761
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
```

#### Gateway Service
```
PORT=8080
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
```

#### Auth Service
```
PORT=8081
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=auth_service
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
```

#### User Service
```
PORT=8082
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=user_service
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
```

#### Transport Service
```
PORT=8083
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=transport_service
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
```

---

## 🎯 **Recommended Next Steps**

1. **Try npx approach first**: `npx @railway/cli login`
2. **If npx works**: Use CLI commands to create and deploy
3. **If npx fails**: Use manual dashboard setup
4. **Set environment variables** in Railway dashboard
5. **Deploy services** in correct order (Config → Discovery → Gateway → Auth → User → Transport)

---

## 🔗 **Important URLs**

- **Railway Dashboard**: https://railway.app/dashboard
- **Railway Docs**: https://docs.railway.app/
- **CLI Documentation**: https://docs.railway.app/develop/cli

---

**Which approach would you like to try first?**