# 🌊 Digital Ocean Quick Start Guide

## 1. Prerequisites (5 minutes)
```bash
# On your Digital Ocean droplet
sudo apt update
sudo apt install -y docker.io docker-compose maven openjdk-17-jdk git
sudo usermod -aG docker $USER
# Log out and back in for docker group to take effect
```

## 2. Clone and Setup (2 minutes)
```bash
git clone https://github.com/Meaport/Logistics_platform.git
cd Logistics_platform
git checkout devin/1749816948-efficiency-improvements
```

## 3. Configure Environment (3 minutes)
```bash
# Copy environment template
cp .env.digitalocean .env.digitalocean.local

# Edit with your Digital Ocean database details
nano .env.digitalocean.local
```

**Required changes:**
- `DATABASE_HOST`: Your managed DB host (e.g., `db-postgresql-nyc1-12345-do-user-123456-0.b.db.ondigitalocean.com`)
- `DATABASE_PASSWORD`: Your actual database password
- `JWT_SECRET`: Generate a secure 32+ character secret

## 4. Deploy (5 minutes)
```bash
# Make scripts executable
chmod +x *.sh

# Test build first
./test-local-build.sh

# Deploy to Digital Ocean
./deploy-digitalocean.sh
```

## 5. Verify (2 minutes)
```bash
# Run health checks
./health-check-digitalocean.sh

# Test API endpoints (replace with your droplet IP)
curl http://YOUR_DROPLET_IP:8080/actuator/health
```

## 6. Access Your Application
- **Main API**: `http://YOUR_DROPLET_IP:8080`
- **Service Discovery**: `http://YOUR_DROPLET_IP:8761`
- **Individual Services**: Ports 8081, 8082, 8083

## 🎉 That's it! Your logistics platform is now running on Digital Ocean!

### Next Steps
- Configure your domain name
- Set up SSL certificates
- Configure monitoring
- Set up automated backups

### Need Help?
- Check logs: `docker-compose -f docker-compose.digitalocean.yml logs -f`
- View detailed guide: [DIGITAL-OCEAN-DEPLOYMENT.md](./DIGITAL-OCEAN-DEPLOYMENT.md)
- Review checklist: [DEPLOYMENT-CHECKLIST.md](./DEPLOYMENT-CHECKLIST.md)
