# 🚀 Digital Ocean Deployment Checklist

## Pre-Deployment Setup

### 1. Digital Ocean Account Setup
- [ ] Create Digital Ocean account
- [ ] Generate API token
- [ ] Add SSH keys to account

### 2. Database Setup
- [ ] Create PostgreSQL 15 managed database
- [ ] Note connection details (host, port, username, password)
- [ ] Create database named `logistics-db`
- [ ] Configure firewall to allow connections from droplet

### 3. Droplet Setup
- [ ] Create Ubuntu 22.04 droplet (minimum 4GB RAM recommended)
- [ ] Install Docker and Docker Compose
- [ ] Clone repository to droplet
- [ ] Install Java 17 and Maven

## Environment Configuration

### 4. Environment Variables
- [ ] Copy `.env.digitalocean` to `.env.digitalocean.local`
- [ ] Update `DATABASE_HOST` with your managed database host
- [ ] Update `DATABASE_PORT` (usually 25060 for managed DB)
- [ ] Update `DATABASE_USERNAME` (usually doadmin)
- [ ] Update `DATABASE_PASSWORD` with your database password
- [ ] Generate secure `JWT_SECRET` (minimum 32 characters)
- [ ] Update `CORS_ALLOWED_ORIGINS` with your domain

### 5. Required Environment Variables
```bash
DATABASE_HOST=your-db-host.db.ondigitalocean.com
DATABASE_PORT=25060
DATABASE_NAME=logistics-db
DATABASE_USERNAME=doadmin
DATABASE_PASSWORD=your-actual-password
JWT_SECRET=your-secure-jwt-secret-min-32-chars
```

## Deployment Process

### 6. Build and Test
- [ ] Run `./test-local-build.sh` to verify builds work
- [ ] Run `./build-all-services.sh` to build all JAR files
- [ ] Verify all Docker images build successfully

### 7. Deploy Services
- [ ] Run `./deploy-digitalocean.sh`
- [ ] Wait for all services to start (approximately 2-3 minutes)
- [ ] Run `./health-check-digitalocean.sh` to verify deployment

### 8. Verify Deployment
- [ ] Check all services are healthy
- [ ] Test API endpoints
- [ ] Verify database connections
- [ ] Check service discovery is working

## Post-Deployment Testing

### 9. API Testing
```bash
# Replace YOUR_DROPLET_IP with actual IP
curl http://YOUR_DROPLET_IP:8080/actuator/health
curl http://YOUR_DROPLET_IP:8081/actuator/health
curl http://YOUR_DROPLET_IP:8082/actuator/health
curl http://YOUR_DROPLET_IP:8083/actuator/health
```

### 10. Service Discovery Testing
- [ ] Access Eureka dashboard: `http://YOUR_DROPLET_IP:8761`
- [ ] Verify all services are registered
- [ ] Check service health status

### 11. Database Testing
- [ ] Verify tables are created automatically by JPA
- [ ] Test user registration endpoint
- [ ] Test authentication flow

## Monitoring and Maintenance

### 12. Monitoring Setup
- [ ] Configure log aggregation
- [ ] Set up monitoring alerts
- [ ] Configure backup strategy for database

### 13. Security Hardening
- [ ] Configure firewall rules
- [ ] Set up SSL/TLS certificates
- [ ] Enable database SSL connections
- [ ] Review and rotate JWT secrets

## Troubleshooting

### Common Issues
1. **Database Connection Failed**
   - Check database credentials in `.env.digitalocean`
   - Verify database firewall allows droplet connections
   - Ensure SSL mode is enabled

2. **Service Won't Start**
   - Check logs: `docker-compose -f docker-compose.digitalocean.yml logs SERVICE_NAME`
   - Verify environment variables
   - Check memory/CPU resources

3. **Health Checks Failing**
   - Wait longer for services to start
   - Check service dependencies
   - Verify network connectivity

### Debug Commands
```bash
# Check container status
docker-compose -f docker-compose.digitalocean.yml ps

# View logs
docker-compose -f docker-compose.digitalocean.yml logs -f

# Restart specific service
docker-compose -f docker-compose.digitalocean.yml restart SERVICE_NAME

# Check system resources
docker stats
```

## Success Criteria
- [ ] All 6 microservices are running and healthy
- [ ] Database connections are working
- [ ] API Gateway is routing requests correctly
- [ ] Service discovery is functioning
- [ ] MapStruct optimizations are active
- [ ] All health checks pass
- [ ] API endpoints respond correctly

## Rollback Plan
If deployment fails:
1. Stop services: `docker-compose -f docker-compose.digitalocean.yml down`
2. Check logs for errors
3. Fix configuration issues
4. Rebuild and redeploy
5. If critical: restore from backup

---

**🎯 Deployment Goal**: Successfully deploy all 6 microservices with MapStruct optimizations to Digital Ocean with managed PostgreSQL database.
