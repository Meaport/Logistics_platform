# 🌊 Digital Ocean Deployment Guide

## Quick Start

### 1. Prerequisites
- Digital Ocean account with managed PostgreSQL database
- Docker and Docker Compose installed
- Maven 3.6+ and Java 17+
- Git access to this repository

### 2. Setup Digital Ocean Database
1. Create PostgreSQL 15 managed database on Digital Ocean
2. Note the connection details (host, port, username, password)
3. Create database named `logistics-db`

### 3. Configure Environment
```bash
# Copy and edit the Digital Ocean environment file
cp .env.digitalocean .env.digitalocean.local
# Edit with your actual Digital Ocean database credentials
nano .env.digitalocean.local
```

Required environment variables:
```bash
DATABASE_HOST=your-db-host.db.ondigitalocean.com
DATABASE_PORT=25060
DATABASE_NAME=logistics-db
DATABASE_USERNAME=doadmin
DATABASE_PASSWORD=your-actual-password
JWT_SECRET=your-secure-jwt-secret-min-32-chars
```

### 4. Deploy to Digital Ocean
```bash
# Make deployment script executable
chmod +x deploy-digitalocean.sh
chmod +x health-check-digitalocean.sh

# Deploy all services
./deploy-digitalocean.sh
```

### 5. Verify Deployment
```bash
# Run health checks
./health-check-digitalocean.sh

# Check individual services
curl http://YOUR_DROPLET_IP:8080/actuator/health
curl http://YOUR_DROPLET_IP:8081/actuator/health
curl http://YOUR_DROPLET_IP:8082/actuator/health
curl http://YOUR_DROPLET_IP:8083/actuator/health
```

## Architecture

### Microservices
- **Config Server** (8888): Centralized configuration
- **Discovery Server** (8761): Eureka service registry
- **Gateway Service** (8080): API Gateway with routing
- **Auth Service** (8081): Authentication and authorization
- **User Service** (8082): User management with MapStruct optimization
- **Transport Service** (8083): Logistics operations with MapStruct optimization

### Database
- **Digital Ocean Managed PostgreSQL**: Unified database `logistics-db`
- **SSL Required**: Secure connections to managed database
- **Connection Pooling**: HikariCP with optimized settings

### Optimizations
- **MapStruct Integration**: Eliminated 200+ lines of manual DTO conversion
- **Compile-time Mapping**: Better performance than runtime reflection
- **Production Profiles**: Environment-specific configurations
- **Health Checks**: Comprehensive service monitoring

## Management Commands

### View Logs
```bash
# All services
docker-compose -f docker-compose.digitalocean.yml logs -f

# Specific service
docker-compose -f docker-compose.digitalocean.yml logs -f auth-service
```

### Restart Services
```bash
# All services
docker-compose -f docker-compose.digitalocean.yml restart

# Specific service
docker-compose -f docker-compose.digitalocean.yml restart user-service
```

### Stop Deployment
```bash
docker-compose -f docker-compose.digitalocean.yml down
```

### Update Deployment
```bash
# Rebuild and redeploy
docker-compose -f docker-compose.digitalocean.yml up -d --build
```

## Troubleshooting

### Common Issues

1. **Database Connection Failed**
   - Verify Digital Ocean database credentials in `.env.digitalocean`
   - Check database firewall allows connections from your droplet
   - Ensure SSL mode is enabled

2. **Service Won't Start**
   - Check logs: `docker-compose -f docker-compose.digitalocean.yml logs SERVICE_NAME`
   - Verify environment variables are set correctly
   - Check memory/CPU resources on droplet

3. **Health Checks Failing**
   - Wait longer for services to start (especially first deployment)
   - Check service dependencies (config-server → discovery-server → others)
   - Verify network connectivity between containers

### Debug Commands
```bash
# Check container status
docker-compose -f docker-compose.digitalocean.yml ps

# Check system resources
docker stats

# Test database connection
docker-compose -f docker-compose.digitalocean.yml exec auth-service curl http://localhost:8081/actuator/health
```

## Security Notes

- JWT secrets are environment-specific
- Database credentials use Digital Ocean managed security
- SSL/TLS encryption for database connections
- Container network isolation
- Health check endpoints exposed for monitoring

## Performance

- **Memory**: Each service allocated 512MB-1GB
- **Connection Pooling**: 20 max connections, 5 minimum idle
- **MapStruct**: Compile-time DTO mapping for better performance
- **JVM Optimization**: OpenJDK 17 with optimized container settings

For detailed Digital Ocean setup instructions, see [DIGITAL-OCEAN-DEPLOYMENT.md](./DIGITAL-OCEAN-DEPLOYMENT.md).
