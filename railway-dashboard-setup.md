# 🚂 **RAILWAY DASHBOARD SETUP - ADIM ADIM**

## 📋 **Mevcut Durum**
✅ Supabase Connection String: `postgresql://postgres:[PASSWORD]@db.mozqphxqzjbyrriskyth.supabase.co:5432/postgres`

## 🎯 **Railway'de Yapılacaklar**

### ADIM 1: Railway Dashboard'a Giriş
1. https://railway.app/dashboard adresine gidin
2. GitHub hesabınızla giriş yapın

### ADIM 2: Her Servis İçin Ayrı Proje Oluşturma
Railway'de **6 ayrı proje** oluşturacağız:

#### Proje 1: Config Server
1. **"New Project"** butonuna tıklayın
2. **"Deploy from GitHub repo"** seçin
3. Repository'nizi seçin
4. **Project Name**: `logistics-config-server`
5. **Root Directory**: `config-server`
6. **Build Command**: `mvn clean package -DskipTests`
7. **Start Command**: `java -jar target/*.jar`

#### Proje 2: Discovery Server
1. Yeni proje oluşturun
2. **Project Name**: `logistics-discovery-server`
3. **Root Directory**: `discovery-server`
4. **Build Command**: `mvn clean package -DskipTests`
5. **Start Command**: `java -jar target/*.jar`

#### Proje 3: Gateway Service
1. Yeni proje oluşturun
2. **Project Name**: `logistics-gateway-service`
3. **Root Directory**: `gateway-service`
4. **Build Command**: `mvn clean package -DskipTests`
5. **Start Command**: `java -jar target/*.jar`

#### Proje 4: Auth Service
1. Yeni proje oluşturun
2. **Project Name**: `logistics-auth-service`
3. **Root Directory**: `auth-service`
4. **Build Command**: `mvn clean package -DskipTests`
5. **Start Command**: `java -jar target/*.jar`

#### Proje 5: User Service
1. Yeni proje oluşturun
2. **Project Name**: `logistics-user-service`
3. **Root Directory**: `user-service`
4. **Build Command**: `mvn clean package -DskipTests`
5. **Start Command**: `java -jar target/*.jar`

#### Proje 6: Transport Service
1. Yeni proje oluşturun
2. **Project Name**: `logistics-transport-service`
3. **Root Directory**: `transport-service`
4. **Build Command**: `mvn clean package -DskipTests`
5. **Start Command**: `java -jar target/*.jar`

## 🔧 **Environment Variables Ayarlama**

Her proje için **"Variables"** sekmesine gidip şu değişkenleri ekleyin:

### Config Server Variables
```
PORT=8888
SPRING_PROFILES_ACTIVE=railway
```

### Discovery Server Variables
```
PORT=8761
SPRING_PROFILES_ACTIVE=railway
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
```

### Gateway Service Variables
```
PORT=8080
SPRING_PROFILES_ACTIVE=railway
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app
JWT_SECRET=mySecretKey123456789012345678901234567890
```

### Auth Service Variables
```
PORT=8081
SPRING_PROFILES_ACTIVE=railway
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.mozqphxqzjbyrriskyth.supabase.co:5432/postgres?currentSchema=auth_service
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
JWT_SECRET=mySecretKey123456789012345678901234567890
```

### User Service Variables
```
PORT=8082
SPRING_PROFILES_ACTIVE=railway
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.mozqphxqzjbyrriskyth.supabase.co:5432/postgres?currentSchema=user_service
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
JWT_SECRET=mySecretKey123456789012345678901234567890
```

### Transport Service Variables
```
PORT=8083
SPRING_PROFILES_ACTIVE=railway
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.mozqphxqzjbyrriskyth.supabase.co:5432/postgres?currentSchema=transport_service
EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/
JWT_SECRET=mySecretKey123456789012345678901234567890
```

## ⚠️ **ÖNEMLİ NOTLAR**

1. **[YOUR-PASSWORD]** kısmını Supabase şifrenizle değiştirin
2. **URL'ler** her deployment sonrası güncellenebilir
3. **Deployment sırası önemli**: Config → Discovery → Gateway → Auth → User → Transport
4. Her servis deploy olduktan sonra URL'sini alıp diğer servislerin environment variable'larında güncelleyin

## 🚀 **Deployment Sırası**

1. **Config Server** - İlk deploy edin
2. **Discovery Server** - Config server hazır olduktan sonra
3. **Gateway Service** - Discovery server hazır olduktan sonra
4. **Auth Service** - Gateway hazır olduktan sonra
5. **User Service** - Auth hazır olduktan sonra
6. **Transport Service** - Son olarak

## 🎯 **Sonraki Adım**

Railway Dashboard'da ilk olarak **Config Server** projesini oluşturun ve deploy edin. Hangi adımda yardıma ihtiyacınız var?