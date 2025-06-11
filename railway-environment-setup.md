# 🚂 **RAILWAY ENVIRONMENT VARIABLES SETUP**

After deploying services, you need to set these environment variables in Railway Dashboard.

## 🔗 **Service URLs (Update after deployment)**

```bash
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
DISCOVERY_SERVER_URL=https://logistics-discovery-server-production.railway.app
GATEWAY_SERVICE_URL=https://logistics-gateway-service-production.railway.app
AUTH_SERVICE_URL=https://logistics-auth-service-production.railway.app
USER_SERVICE_URL=https://logistics-user-service-production.railway.app
TRANSPORT_SERVICE_URL=https://logistics-transport-service-production.railway.app
```

## 🔧 **Environment Variables for Each Service**

### Config Server
```
PORT=8888
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[YOUR-JWT-SECRET]
```

### Discovery Server
```
PORT=8761
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[YOUR-JWT-SECRET]
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
```

### Gateway Service
```
PORT=8080
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[YOUR-JWT-SECRET]
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
```

### Auth Service
```
PORT=8081
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[YOUR-JWT-SECRET]
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=auth_service
```

### User Service
```
PORT=8082
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[YOUR-JWT-SECRET]
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=user_service
```

### Transport Service
```
PORT=8083
SPRING_PROFILES_ACTIVE=railway
JWT_SECRET=[YOUR-JWT-SECRET]
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
DATABASE_URL=postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=transport_service
```

## 📋 **How to Set Variables in Railway Dashboard**

1. Go to https://railway.app/dashboard
2. Click on each project
3. Go to "Variables" tab
4. Add each environment variable
5. Redeploy the service

## 🔑 **Important Notes**

- Replace `[YOUR-JWT-SECRET]` with the generated JWT secret
- Replace `[PASSWORD]` and `[PROJECT-ID]` with your Supabase credentials
- Update service URLs after each deployment
- Services must be deployed in order: Config → Discovery → Gateway → Auth → User → Transport