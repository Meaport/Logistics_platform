# 🔧 Production Deployment Troubleshooting Guide

## Current Issue: Spring Boot YAML Configuration Error

### Problem Description
Config-server failing to start with `InactiveConfigDataAccessException` due to conflicting `spring.profiles.active` property in inactive production profile section.

### Error Details
```
InactiveConfigDataAccessException: Inactive property source 'Config resource 'class path resource [application.yml]' via location 'optional:classpath:/' (document #1)' imported from location 'class path resource [application.yml]' cannot contain property 'spring.profiles.active' [origin: class path resource [application.yml] from app.jar - 30:13]
```

### Root Cause
Spring Boot 3.x has stricter YAML configuration validation. The `spring.profiles.active` property cannot be defined within an inactive profile section.

### Solution Applied
1. **Fixed YAML Configuration** (commit c3c0126):
   - Removed conflicting `spring.profiles.active: native` from production profile section
   - Kept main profile configuration intact
   - Maintained environment variable support

2. **Production Deployment Commands**:
   ```bash
   cd /root
   git pull origin devin/1749816948-efficiency-improvements
   docker compose -f docker-compose.digitalocean.yml down
   cp .env.digitalocean.local .env
   docker compose -f docker-compose.digitalocean.yml up --build -d
   ```

## Common Issues & Solutions

### 1. Container Build Failures
**Symptoms**: Docker build fails with memory errors
**Solution**: Use sequential build approach
```bash
./build-sequential.sh
```

### 2. Service Discovery Issues
**Symptoms**: Services can't register with Eureka
**Solution**: Ensure config-server is healthy first
```bash
# Check config-server health
curl http://localhost:8888/actuator/health

# Wait for config-server before starting other services
docker compose -f docker-compose.digitalocean.yml up config-server -d
# Wait 2-3 minutes, then start others
docker compose -f docker-compose.digitalocean.yml up -d
```

### 3. External Connectivity Issues
**Symptoms**: Services work locally but not externally
**Common Causes**:
- Firewall applied to wrong droplet
- Services bound to 127.0.0.1 instead of 0.0.0.0
- Ports not exposed in Docker configuration

**Solution**:
```bash
# Verify firewall is applied to correct droplet in Digital Ocean
# Check service binding in application.yml files
# Verify docker-compose port mappings
```

### 4. Database Connection Issues
**Symptoms**: Services fail to connect to PostgreSQL
**Solution**: Verify environment variables
```bash
# Check environment configuration
docker compose -f docker-compose.digitalocean.yml config

# Test database connectivity
docker exec -it logistics-auth-service bash
# Inside container: test database connection
```

### 5. Health Check Failures
**Symptoms**: Containers show "unhealthy" status
**Solution**: Adjust health check timing
```bash
# Use health check timing script
./fix-health-check-timing.sh
```

## Diagnostic Commands

### Container Status
```bash
docker ps | grep logistics
docker compose -f docker-compose.digitalocean.yml ps
```

### Service Logs
```bash
docker logs logistics-config-server --tail 50
docker logs logistics-discovery-server --tail 50
docker logs logistics-gateway-service --tail 50
docker logs logistics-auth-service --tail 50
docker logs logistics-user-service --tail 50
docker logs logistics-transport-service --tail 50
```

### Health Checks
```bash
curl http://localhost:8888/actuator/health  # Config
curl http://localhost:8761/actuator/health  # Discovery
curl http://localhost:8080/actuator/health  # Gateway
curl http://localhost:8081/actuator/health  # Auth
curl http://localhost:8082/actuator/health  # User
curl http://localhost:8083/actuator/health  # Transport
```

### Network Connectivity
```bash
# Test internal connectivity
docker network ls
docker network inspect logistics_platform_default

# Test external connectivity
curl -I http://52.183.72.253:8080/actuator/health
```

## Recovery Procedures

### Complete Reset
```bash
# Stop all services
docker compose -f docker-compose.digitalocean.yml down

# Remove containers and volumes
docker compose -f docker-compose.digitalocean.yml down -v

# Rebuild from scratch
docker compose -f docker-compose.digitalocean.yml up --build -d
```

### Selective Service Restart
```bash
# Restart specific service
docker compose -f docker-compose.digitalocean.yml restart config-server

# Restart dependent services in order
docker compose -f docker-compose.digitalocean.yml restart discovery-server
docker compose -f docker-compose.digitalocean.yml restart gateway-service
docker compose -f docker-compose.digitalocean.yml restart auth-service
docker compose -f docker-compose.digitalocean.yml restart user-service
docker compose -f docker-compose.digitalocean.yml restart transport-service
```

## Prevention Measures

1. **Always test configuration changes locally first**
2. **Use health checks to verify service startup**
3. **Monitor logs during deployment**
4. **Verify external connectivity after deployment**
5. **Keep backup of working configuration**

## Support Resources

- **Deployment Documentation**: `DIGITAL-OCEAN-QUICK-START.md`
- **API Usage Guide**: `API-USAGE-GUIDE.md`
- **External Access Setup**: `EXTERNAL-ACCESS-SETUP.md`
- **Production Commands**: `PRODUCTION_REBUILD_COMMANDS.md`
- **Verification Checklist**: `FINAL_VERIFICATION_CHECKLIST.md`
