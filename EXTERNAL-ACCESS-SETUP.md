# 🌐 External Access Configuration Guide

## Digital Ocean Firewall Setup

To enable external access to your Logistics Platform, configure Digital Ocean firewall rules:

### 1. Access Digital Ocean Control Panel
1. Go to **Networking > Firewalls**
2. Click **Create Firewall** or edit existing firewall

### 2. Configure Inbound Rules
Add the following inbound rules:

| Type | Protocol | Port Range | Sources |
|------|----------|------------|---------|
| HTTP | TCP | 80 | All IPv4, All IPv6 |
| HTTPS | TCP | 443 | All IPv4, All IPv6 |
| Custom | TCP | 8080 | All IPv4, All IPv6 |
| Custom | TCP | 8081 | All IPv4, All IPv6 |
| Custom | TCP | 8082 | All IPv4, All IPv6 |
| Custom | TCP | 8083 | All IPv4, All IPv6 |
| Custom | TCP | 8888 | All IPv4, All IPv6 |
| Custom | TCP | 8761 | All IPv4, All IPv6 |

### 3. Assign Firewall to Droplet
1. Select your logistics platform droplet
2. Apply the firewall rules

### 4. Test External Access

After firewall configuration, test external access:

```bash
# Test with your actual Digital Ocean IP
curl http://52.183.72.253:8080/actuator/health
curl http://52.183.72.253:8081/actuator/health
curl http://52.183.72.253:8082/actuator/health
curl http://52.183.72.253:8083/actuator/health
```

### 5. Access Web Dashboards

- **Eureka Service Discovery**: http://52.183.72.253:8761
- **Main API Gateway**: http://52.183.72.253:8080

## Security Considerations

- Consider restricting port 8888 (Config Server) to internal access only
- Use HTTPS in production with SSL certificates
- Implement rate limiting for public endpoints
- Monitor access logs for security threats

## Troubleshooting

If external access doesn't work:
1. Verify firewall rules are applied to the correct droplet
2. Check Digital Ocean networking logs
3. Verify services are bound to 0.0.0.0 (already configured)
4. Test local access first: `curl http://localhost:8080/actuator/health`

## Quick Verification Commands

### Test from External Machine
```bash
# Test main gateway
curl http://52.183.72.253:8080/actuator/health

# Test authentication
curl -X POST http://52.183.72.253:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Test public tracking (no auth required)
curl http://52.183.72.253:8080/api/transport/shipments/tracking/TRK17056789123456
```

### Test from Server (Local)
```bash
# Verify containers are running
docker ps | grep logistics

# Test local connectivity
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health
```

## Port Reference

| Service | Port | Purpose |
|---------|------|---------|
| Gateway Service | 8080 | Main API entry point |
| Auth Service | 8081 | Authentication & authorization |
| User Service | 8082 | User management |
| Transport Service | 8083 | Logistics operations |
| Config Server | 8888 | Configuration management |
| Discovery Server | 8761 | Service registry |
| Nginx | 80/443 | Load balancer |

## Next Steps

1. Configure firewall rules as described above
2. Test external access using the verification commands
3. Access the Eureka dashboard to verify all services are registered
4. Begin using the API endpoints documented in `API-DOCUMENTATION.md`
