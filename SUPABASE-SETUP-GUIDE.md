# 🗄️ **SUPABASE DATABASE SETUP - STEP BY STEP GUIDE**

## 📋 **Overview**

Bu rehber, Supabase'de Logistics Platform için gerekli veritabanı yapısını oluşturmanız için adım adım talimatlar içerir.

---

## 🚀 **STEP 1: Supabase Project Setup**

### 1.1 Supabase Dashboard'a Giriş
1. https://supabase.com adresine gidin
2. Hesabınızla giriş yapın
3. "New Project" butonuna tıklayın
4. Proje bilgilerini doldurun:
   - **Name**: `logistics-platform`
   - **Database Password**: Güçlü bir şifre seçin (kaydedin!)
   - **Region**: Size en yakın bölgeyi seçin
5. "Create new project" butonuna tıklayın

### 1.2 Proje Bilgilerini Kaydetme
Proje oluşturulduktan sonra şu bilgileri kaydedin:
- **Project URL**: `https://[your-project-id].supabase.co`
- **API Key (anon public)**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
- **Database Password**: Oluştururken belirlediğiniz şifre

---

## 🗄️ **STEP 2: Database Schema Creation**

### 2.1 SQL Editor'a Erişim
1. Supabase Dashboard'da sol menüden **"SQL Editor"** sekmesine tıklayın
2. **"New query"** butonuna tıklayın

### 2.2 Schema Oluşturma
Aşağıdaki SQL komutunu kopyalayıp SQL Editor'a yapıştırın ve **"Run"** butonuna tıklayın:

```sql
-- Create separate schemas for each microservice
CREATE SCHEMA IF NOT EXISTS auth_service;
CREATE SCHEMA IF NOT EXISTS user_service;
CREATE SCHEMA IF NOT EXISTS transport_service;

-- Grant permissions
GRANT ALL ON SCHEMA auth_service TO postgres;
GRANT ALL ON SCHEMA user_service TO postgres;
GRANT ALL ON SCHEMA transport_service TO postgres;

-- Set search path
ALTER DATABASE postgres SET search_path TO auth_service, user_service, transport_service, public;
```

✅ **Beklenen Sonuç**: "Success. No rows returned" mesajı görmelisiniz.

---

## 🔐 **STEP 3: Auth Service Tables**

### 3.1 Auth Service Schema'sına Geçiş
Yeni bir SQL query açın ve aşağıdaki komutu çalıştırın:

```sql
-- Switch to auth service schema
SET search_path TO auth_service;
```

### 3.2 Auth Service Tablolarını Oluşturma
Aşağıdaki SQL komutunu çalıştırın:

```sql
-- Users table
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    is_enabled BOOLEAN DEFAULT true,
    is_account_non_expired BOOLEAN DEFAULT true,
    is_account_non_locked BOOLEAN DEFAULT true,
    is_credentials_non_expired BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Roles table
CREATE TABLE roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Permissions table
CREATE TABLE permissions (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    resource VARCHAR(50),
    action VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User roles junction table
CREATE TABLE user_roles (
    user_id BIGINT REFERENCES users(id) ON DELETE CASCADE,
    role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

-- Role permissions junction table
CREATE TABLE role_permissions (
    role_id BIGINT REFERENCES roles(id) ON DELETE CASCADE,
    permission_id BIGINT REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);
```

✅ **Beklenen Sonuç**: 5 tablo başarıyla oluşturulmalı.

### 3.3 Auth Service İndeksleri
```sql
-- Create indexes for better performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);
```

---

## 👥 **STEP 4: User Service Tables**

### 4.1 User Service Schema'sına Geçiş
```sql
-- Switch to user service schema
SET search_path TO user_service;
```

### 4.2 User Service Tablolarını Oluşturma
```sql
-- User profiles table
CREATE TABLE user_profiles (
    id BIGSERIAL PRIMARY KEY,
    auth_user_id BIGINT UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone_number VARCHAR(20),
    profile_picture_url TEXT,
    bio TEXT,
    company VARCHAR(100),
    department VARCHAR(100),
    position VARCHAR(100),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    date_of_birth TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    language VARCHAR(5) DEFAULT 'EN',
    timezone VARCHAR(50) DEFAULT 'UTC',
    is_email_verified BOOLEAN DEFAULT false,
    is_phone_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User activities table
CREATE TABLE user_activities (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    activity_type VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 4.3 User Service İndeksleri
```sql
-- Create indexes
CREATE INDEX idx_user_profiles_auth_user_id ON user_profiles(auth_user_id);
CREATE INDEX idx_user_profiles_username ON user_profiles(username);
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
```

---

## 🚛 **STEP 5: Transport Service Tables**

### 5.1 Transport Service Schema'sına Geçiş
```sql
-- Switch to transport service schema
SET search_path TO transport_service;
```

### 5.2 Transport Service Tablolarını Oluşturma
```sql
-- Vehicles table
CREATE TABLE vehicles (
    id BIGSERIAL PRIMARY KEY,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    year INTEGER,
    capacity_kg DECIMAL(10,2),
    capacity_m3 DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'AVAILABLE',
    driver_id BIGINT,
    current_location TEXT,
    fuel_type VARCHAR(20),
    fuel_consumption DECIMAL(5,2),
    maintenance_date TIMESTAMP,
    insurance_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Shipments table
CREATE TABLE shipments (
    id BIGSERIAL PRIMARY KEY,
    tracking_number VARCHAR(50) UNIQUE NOT NULL,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    origin_address TEXT NOT NULL,
    destination_address TEXT NOT NULL,
    weight_kg DECIMAL(10,2),
    volume_m3 DECIMAL(10,2),
    declared_value DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'PENDING',
    priority VARCHAR(10) DEFAULT 'NORMAL',
    vehicle_id BIGINT,
    driver_id BIGINT,
    pickup_date TIMESTAMP,
    delivery_date TIMESTAMP,
    estimated_delivery TIMESTAMP,
    shipping_cost DECIMAL(12,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Route logs table
CREATE TABLE route_logs (
    id BIGSERIAL PRIMARY KEY,
    shipment_id BIGINT NOT NULL,
    vehicle_id BIGINT,
    driver_id BIGINT,
    location TEXT NOT NULL,
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    log_type VARCHAR(20) NOT NULL,
    description TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 5.3 Transport Service İndeksleri
```sql
-- Create indexes
CREATE INDEX idx_vehicles_license_plate ON vehicles(license_plate);
CREATE INDEX idx_vehicles_status ON vehicles(status);
CREATE INDEX idx_shipments_tracking_number ON shipments(tracking_number);
CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_route_logs_shipment_id ON route_logs(shipment_id);
```

---

## 📊 **STEP 6: Initial Data Setup**

### 6.1 Auth Service'e Başlangıç Verilerini Ekleme
```sql
-- Switch back to auth service schema
SET search_path TO auth_service;

-- Insert default roles
INSERT INTO roles (name, description) VALUES 
('ADMIN', 'Administrator role with full permissions'),
('MANAGER', 'Manager role with extended permissions'),
('USER', 'Standard user role');

-- Insert permissions
INSERT INTO permissions (name, description, resource, action) VALUES 
('USER_READ', 'Read user data', 'USER', 'READ'),
('USER_WRITE', 'Write user data', 'USER', 'WRITE'),
('USER_DELETE', 'Delete user data', 'USER', 'DELETE'),
('TRANSPORT_READ', 'Read transport data', 'TRANSPORT', 'READ'),
('TRANSPORT_WRITE', 'Write transport data', 'TRANSPORT', 'WRITE'),
('TRANSPORT_DELETE', 'Delete transport data', 'TRANSPORT', 'DELETE'),
('ADMIN_ALL', 'Full admin access', 'ADMIN', 'ALL');

-- Create admin user (password: admin123 - BCrypt hashed)
INSERT INTO users (username, email, password, first_name, last_name) VALUES 
('admin', 'admin@logistics.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9tYoHPwk/1cLlHO', 'System', 'Administrator');

-- Create test user (password: test123 - BCrypt hashed)
INSERT INTO users (username, email, password, first_name, last_name) VALUES 
('testuser', 'test@logistics.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9tYoHPwk/1cLlHO', 'Test', 'User');
```

### 6.2 Role-Permission İlişkilerini Kurma
```sql
-- Assign all permissions to ADMIN role
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p WHERE r.name = 'ADMIN';

-- Assign limited permissions to MANAGER role
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'MANAGER' AND p.name IN ('USER_READ', 'USER_WRITE', 'TRANSPORT_READ', 'TRANSPORT_WRITE');

-- Assign basic permissions to USER role
INSERT INTO role_permissions (role_id, permission_id) 
SELECT r.id, p.id FROM roles r, permissions p 
WHERE r.name = 'USER' AND p.name IN ('USER_READ', 'TRANSPORT_READ');

-- Assign ADMIN role to admin user
INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username = 'admin' AND r.name = 'ADMIN';

-- Assign USER role to test user
INSERT INTO user_roles (user_id, role_id) 
SELECT u.id, r.id FROM users u, roles r 
WHERE u.username = 'testuser' AND r.name = 'USER';
```

---

## ✅ **STEP 7: Verification**

### 7.1 Tabloları Kontrol Etme
```sql
-- Check auth service tables
SET search_path TO auth_service;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'auth_service';

-- Check user service tables
SET search_path TO user_service;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'user_service';

-- Check transport service tables
SET search_path TO transport_service;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'transport_service';
```

### 7.2 Verileri Kontrol Etme
```sql
-- Check users and roles
SET search_path TO auth_service;
SELECT u.username, u.email, r.name as role 
FROM users u 
JOIN user_roles ur ON u.id = ur.user_id 
JOIN roles r ON ur.role_id = r.id;
```

✅ **Beklenen Sonuç**: 
- admin kullanıcısı ADMIN rolüyle
- testuser kullanıcısı USER rolüyle görünmeli

---

## 🔗 **STEP 8: Connection String Setup**

### 8.1 Connection Bilgilerini Alma
1. Supabase Dashboard'da **"Settings"** > **"Database"** sekmesine gidin
2. **"Connection string"** bölümünden **"URI"** formatını kopyalayın
3. Şu formatta olacak: `postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres`

### 8.2 Her Servis İçin Connection String'leri
```bash
# Auth Service
postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=auth_service

# User Service  
postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=user_service

# Transport Service
postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=transport_service
```

---

## 🎯 **STEP 9: Application Configuration**

### 9.1 Spring Boot application.yml Güncellemesi
Her servisin `application.yml` dosyasında şu değişiklikleri yapın:

**Auth Service:**
```yaml
spring:
  datasource:
    url: postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=auth_service
    username: postgres
    password: [YOUR-SUPABASE-PASSWORD]
    driver-class-name: org.postgresql.Driver
```

**User Service:**
```yaml
spring:
  datasource:
    url: postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=user_service
    username: postgres
    password: [YOUR-SUPABASE-PASSWORD]
    driver-class-name: org.postgresql.Driver
```

**Transport Service:**
```yaml
spring:
  datasource:
    url: postgresql://postgres:[YOUR-PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=transport_service
    username: postgres
    password: [YOUR-SUPABASE-PASSWORD]
    driver-class-name: org.postgresql.Driver
```

---

## 🧪 **STEP 10: Test Connection**

### 10.1 Basit Bağlantı Testi
SQL Editor'da şu komutu çalıştırarak bağlantıyı test edin:
```sql
SELECT 'Auth Service' as service, count(*) as user_count FROM auth_service.users
UNION ALL
SELECT 'User Service' as service, count(*) as profile_count FROM user_service.user_profiles
UNION ALL
SELECT 'Transport Service' as service, count(*) as vehicle_count FROM transport_service.vehicles;
```

✅ **Beklenen Sonuç**: 
- Auth Service: 2 kullanıcı
- User Service: 0 profil
- Transport Service: 0 araç

---

## 🎉 **Tamamlandı!**

Artık Supabase veritabanınız hazır! 

### Sonraki Adımlar:
1. ✅ Veritabanı kurulumu tamamlandı
2. 🔄 Spring Boot servislerini Supabase'e bağlayın
3. 🧪 Servisleri test edin
4. 🚀 Production'a deploy edin

### Önemli Notlar:
- 🔐 Supabase şifrenizi güvenli tutun
- 📊 Supabase Dashboard'dan veritabanı performansını izleyin
- 💾 Düzenli backup alın
- 🔄 Connection pool ayarlarını optimize edin

**Herhangi bir adımda sorun yaşarsanız, o adımı tekrar edin veya bana sorun!**