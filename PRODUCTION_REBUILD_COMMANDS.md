# 🔧 Production Server Rebuild Commands

## Issue: Spring Boot YAML Configuration Error

The config-server is failing to start due to `InactiveConfigDataAccessException` caused by conflicting `spring.profiles.active` property in the production profile section.

## Solution Commands (Run on Production Server)

```bash
# 1. Pull latest code with the fix
cd /root
git pull origin devin/1749816948-efficiency-improvements

# 2. Stop all containers
docker compose -f docker-compose.digitalocean.yml down

# 3. Copy environment configuration
cp .env.digitalocean.local .env

# 4. Rebuild and start all services
docker compose -f docker-compose.digitalocean.yml up --build -d

# 5. Monitor container startup
docker ps | grep logistics
```

## Verification Commands

```bash
# Check config-server logs (should show no errors)
docker logs logistics-config-server --tail 20

# Test all service health endpoints
curl http://localhost:8888/actuator/health  # Config Server
curl http://localhost:8761/actuator/health  # Discovery Server
curl http://localhost:8080/actuator/health  # Gateway Service
curl http://localhost:8081/actuator/health  # Auth Service
curl http://localhost:8082/actuator/health  # User Service
curl http://localhost:8083/actuator/health  # Transport Service
```

## Expected Results

After successful rebuild:
- All 6 containers should be running and healthy
- Config-server logs should show successful startup without YAML errors
- All health endpoints should return `{"status":"UP"}`
- External connectivity should work from user's machine

## External Connectivity Test (User's Machine)

```powershell
# Test main services
Invoke-RestMethod -Uri "http://52.183.72.253:8080/actuator/health"
Invoke-RestMethod -Uri "http://52.183.72.253:8081/actuator/health"
Invoke-RestMethod -Uri "http://52.183.72.253:8082/actuator/health"
Invoke-RestMethod -Uri "http://52.183.72.253:8083/actuator/health"

# Access Eureka dashboard
Invoke-WebRequest -Uri "http://52.183.72.253:8761"
```

## Fix Details

- **Root Cause**: `spring.profiles.active: native` defined in inactive production profile section (line 30:13)
- **Error**: `InactiveConfigDataAccessException` - Spring Boot 3.x restriction violation
- **Solution**: Removed conflicting `spring.profiles.active` from production profile in application.yml (commit c3c0126)
- **Deployment**: Production server needs to rebuild containers with latest code
