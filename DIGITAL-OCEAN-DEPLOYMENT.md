# 🌊 **DIGITAL OCEAN DROPLET DEPLOYMENT GUIDE**

## 📋 **Adım 1: Digital Ocean Hesap Kurulumu**

### 1.1 API Token Oluştur
```bash
# Digital Ocean Dashboard'a git:
# https://cloud.digitalocean.com/account/api/tokens
# "Generate New Token" → "logistics-platform-token"
# Read & Write yetkisi ver
# Token'ı kaydet (sadece bir kez gösterilir)
```

### 1.2 SSH Key Ekle
```bash
# Local bilgisayarında SSH key oluştur (eğer yoksa)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Public key'i kopyala
cat ~/.ssh/id_rsa.pub

# Digital Ocean'da ekle:
# Account → Security → SSH Keys → Add SSH Key
```

---

## 🗄️ **Adım 2: Managed Database Oluştur**

### 2.1 PostgreSQL Database
```bash
# Digital Ocean Dashboard → Databases → Create Database
# Database Engine: PostgreSQL 15
# Plan: Basic ($15/month)
# Datacenter: Frankfurt (Avrupa'ya yakın)
# Database Name: logistics-db
# VPC Network: Default
```

### 2.2 Database Konfigürasyonu
```bash
# Database oluşturulduktan sonra:
# 1. Connection Details'i kaydet
# 2. Trusted Sources'a Droplet IP'sini ekle
# 3. Database kullanıcısı oluştur
```

---

## 💧 **Adım 3: Droplet Oluştur**

### 3.1 Droplet Spesifikasyonları
```bash
# Digital Ocean → Droplets → Create Droplet
# Image: Ubuntu 22.04 LTS
# Plan: Basic
# CPU: 2 vCPUs, 4GB RAM, 80GB SSD ($24/month)
# Datacenter: Frankfurt (Database ile aynı bölge)
# VPC Network: Default (Database ile aynı)
# SSH Keys: Daha önce eklediğin key'i seç
# Hostname: logistics-platform-server
```

### 3.2 Firewall Kuralları
```bash
# Networking → Firewalls → Create Firewall
# Name: logistics-platform-firewall
# Inbound Rules:
#   - SSH (22) - Your IP
#   - HTTP (80) - All IPv4, All IPv6
#   - HTTPS (443) - All IPv4, All IPv6
#   - Custom (8080) - All IPv4, All IPv6 (API Gateway)
# Apply to: logistics-platform-server
```

---

## 🔧 **Adım 4: Droplet'e Bağlan ve Kurulum**

### 4.1 SSH Bağlantısı
```bash
# Droplet IP'sini al (örnek: 164.90.xxx.xxx)
ssh root@YOUR_DROPLET_IP

# İlk güncelleme
apt update && apt upgrade -y
```

### 4.2 Docker Kurulumu
```bash
# Docker kurulumu
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Docker Compose kurulumu
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Docker servisini başlat
systemctl start docker
systemctl enable docker

# Test
docker --version
docker-compose --version
```

### 4.3 Git ve Diğer Araçlar
```bash
# Gerekli araçları kur
apt install -y git curl wget unzip htop

# Java 17 kurulumu (opsiyonel, Docker kullanacağız ama)
apt install -y openjdk-17-jdk

# Nginx kurulumu (reverse proxy için)
apt install -y nginx
systemctl start nginx
systemctl enable nginx
```

---

## 📁 **Adım 5: Proje Dosyalarını Yükle**

### 5.1 Git Repository (Eğer varsa)
```bash
# Eğer GitHub'da repository varsa
git clone https://github.com/YOUR_USERNAME/logistics-platform.git
cd logistics-platform
```

### 5.2 Manuel Dosya Yükleme
```bash
# Local bilgisayarından Droplet'e dosya kopyala
scp -r /path/to/logistics-platform root@YOUR_DROPLET_IP:/opt/
ssh root@YOUR_DROPLET_IP
cd /opt/logistics-platform
```

---

## 🔐 **Adım 6: Environment Konfigürasyonu**

### 6.1 Production Environment Dosyası
```bash
# /opt/logistics-platform/.env.production
cat > .env.production << 'EOF'
# Production Environment Configuration
SPRING_PROFILES_ACTIVE=production

# Database Configuration (Digital Ocean Managed Database)
DATABASE_HOST=your-db-host.db.ondigitalocean.com
DATABASE_PORT=25060
DATABASE_NAME=logistics-db
DATABASE_USERNAME=doadmin
DATABASE_PASSWORD=your-db-password
DATABASE_URL=postgresql://${DATABASE_USERNAME}:${DATABASE_PASSWORD}@${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_NAME}?sslmode=require

# JWT Configuration
JWT_SECRET=your-super-secure-jwt-secret-key-here-min-32-chars
JWT_EXPIRATION=86400000

# Service Discovery
EUREKA_DEFAULT_ZONE=http://discovery-server:8761/eureka/

# Security Settings
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
RATE_LIMIT_REQUESTS_PER_MINUTE=100

# Monitoring
MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,metrics
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_LOGISTICS=INFO

# Performance Settings
SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE=20
SPRING_DATASOURCE_HIKARI_MINIMUM_IDLE=5
SPRING_JPA_HIBERNATE_DDL_AUTO=update
EOF
```

### 6.2 Docker Compose Production
```bash
# Production için optimize edilmiş docker-compose
cat > docker-compose.production.yml << 'EOF'
version: '3.8'

services:
  # Config Server
  config-server:
    build: ./config-server
    container_name: logistics-config-server
    ports:
      - "8888:8888"
    environment:
      - SPRING_PROFILES_ACTIVE=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8888/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Discovery Server
  discovery-server:
    build: ./discovery-server
    container_name: logistics-discovery-server
    ports:
      - "8761:8761"
    depends_on:
      config-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8761/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Gateway Service
  gateway-service:
    build: ./gateway-service
    container_name: logistics-gateway-service
    ports:
      - "8080:8080"
    depends_on:
      discovery-server:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 5

  # Auth Service
  auth-service:
    build: ./auth-service
    container_name: logistics-auth-service
    ports:
      - "8081:8081"
    depends_on:
      gateway-service:
        condition: service_healthy
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped

  # User Service
  user-service:
    build: ./user-service
    container_name: logistics-user-service
    ports:
      - "8082:8082"
    depends_on:
      - auth-service
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped

  # Transport Service
  transport-service:
    build: ./transport-service
    container_name: logistics-transport-service
    ports:
      - "8083:8083"
    depends_on:
      - auth-service
    environment:
      - SPRING_PROFILES_ACTIVE=production
      - SPRING_DATASOURCE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    restart: unless-stopped

networks:
  default:
    name: logistics-network
EOF
```

---

## 🚀 **Adım 7: Deployment**

### 7.1 Build ve Deploy
```bash
# Production environment'ı yükle
set -a
source .env.production
set +a

# Docker images'ları build et
docker-compose -f docker-compose.production.yml build

# Servisleri başlat
docker-compose -f docker-compose.production.yml up -d

# Logları kontrol et
docker-compose -f docker-compose.production.yml logs -f
```

### 7.2 Nginx Reverse Proxy
```bash
# Nginx konfigürasyonu
cat > /etc/nginx/sites-available/logistics-platform << 'EOF'
server {
    listen 80;
    server_name YOUR_DOMAIN_OR_IP;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # API Gateway proxy
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Site'ı aktif et
ln -s /etc/nginx/sites-available/logistics-platform /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

---

## 🔍 **Adım 8: Test ve Doğrulama**

### 8.1 Servis Durumu Kontrolü
```bash
# Container'ları kontrol et
docker ps

# Servis health check'leri
curl http://localhost:8080/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health

# Public erişim testi
curl http://YOUR_DROPLET_IP/actuator/health
```

### 8.2 API Testleri
```bash
# User registration testi
curl -X POST http://YOUR_DROPLET_IP/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"test123"}'

# Login testi
curl -X POST http://YOUR_DROPLET_IP/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Public tracking testi
curl http://YOUR_DROPLET_IP/api/transport/shipments/tracking/TEST123
```

---

## 🔧 **Adım 9: Monitoring ve Maintenance**

### 9.1 Log Monitoring
```bash
# Real-time log monitoring
docker-compose -f docker-compose.production.yml logs -f

# Specific service logs
docker logs logistics-auth-service -f

# System resource monitoring
htop
docker stats
```

### 9.2 Backup Script
```bash
# Otomatik backup script'i oluştur
cat > /opt/backup-logistics.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/backups"
mkdir -p $BACKUP_DIR

# Database backup (Digital Ocean'da otomatik backup var ama)
echo "Creating backup: $DATE"

# Application files backup
tar -czf $BACKUP_DIR/logistics-app-$DATE.tar.gz /opt/logistics-platform

# Keep only last 7 backups
find $BACKUP_DIR -name "logistics-app-*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR/logistics-app-$DATE.tar.gz"
EOF

chmod +x /opt/backup-logistics.sh

# Crontab'a ekle (günlük backup)
echo "0 2 * * * /opt/backup-logistics.sh" | crontab -
```

---

## 🌐 **Adım 10: Domain ve SSL (Opsiyonel)**

### 10.1 Domain Bağlama
```bash
# Domain DNS ayarları:
# A Record: @ → YOUR_DROPLET_IP
# A Record: www → YOUR_DROPLET_IP
```

### 10.2 SSL Certificate (Let's Encrypt)
```bash
# Certbot kurulumu
apt install -y certbot python3-certbot-nginx

# SSL certificate al
certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Otomatik yenileme
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -
```

---

## ✅ **Deployment Checklist**

- [ ] Digital Ocean hesabı açıldı
- [ ] API Token oluşturuldu
- [ ] SSH Key eklendi
- [ ] Managed Database oluşturuldu
- [ ] Droplet oluşturuldu
- [ ] Firewall kuralları ayarlandı
- [ ] Docker kuruldu
- [ ] Proje dosyaları yüklendi
- [ ] Environment konfigürasyonu yapıldı
- [ ] Servisler deploy edildi
- [ ] Nginx reverse proxy kuruldu
- [ ] Health check'ler geçti
- [ ] API testleri başarılı
- [ ] Monitoring kuruldu
- [ ] Backup script'i oluşturuldu

---

## 🆘 **Troubleshooting**

### Common Issues:
1. **Container başlamıyor**: `docker logs container-name`
2. **Database bağlantı hatası**: Connection string'i kontrol et
3. **Port erişim sorunu**: Firewall kurallarını kontrol et
4. **Memory yetersizliği**: Droplet'i upgrade et

### Useful Commands:
```bash
# Sistem durumu
systemctl status docker
systemctl status nginx

# Container yeniden başlatma
docker-compose -f docker-compose.production.yml restart service-name

# Disk kullanımı
df -h
docker system df

# Network bağlantısı
netstat -tulpn | grep :8080
```

---

**🎉 Digital Ocean'da production deployment tamamlandı!**

Şimdi bu adımları takip ederek Digital Ocean hesabını kur ve ilk adımları atalım!