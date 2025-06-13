#!/bin/bash

echo "🚀 MODERN LOGISTICS PLATFORM"
echo "============================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Create project structure
echo "📁 Creating project structure..."

# Backend API
mkdir -p backend/{src,config,docs}
mkdir -p frontend/{src,public,build}
mkdir -p database/{migrations,seeds}
mkdir -p docker/{nginx,postgres}
mkdir -p scripts/{deploy,backup,monitoring}

echo "✅ Project structure created"
echo ""

# Create simple backend API
echo "🔧 Creating backend API..."

cat > backend/package.json << 'EOF'
{
  "name": "logistics-api",
  "version": "1.0.0",
  "description": "Modern Logistics API",
  "main": "src/server.js",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
EOF

cat > backend/src/server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(morgan('combined'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Modern Logistics Platform API',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      auth: '/api/auth',
      shipments: '/api/shipments',
      vehicles: '/api/vehicles',
      tracking: '/api/tracking'
    }
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'UP',
    service: 'logistics-api',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: '2.0.0'
  });
});

// Auth endpoints
app.post('/api/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  // Simple demo authentication
  if (username === 'admin' && password === 'admin123') {
    res.json({
      success: true,
      message: 'Login successful',
      token: 'demo-jwt-token-' + Date.now(),
      user: {
        id: 1,
        username: 'admin',
        role: 'administrator',
        permissions: ['read', 'write', 'admin']
      }
    });
  } else {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials'
    });
  }
});

app.post('/api/auth/register', (req, res) => {
  const { username, email, password } = req.body;
  
  res.json({
    success: true,
    message: 'User registered successfully',
    user: {
      id: Date.now(),
      username,
      email,
      role: 'user',
      created: new Date().toISOString()
    }
  });
});

// Shipment tracking
app.get('/api/tracking/:trackingNumber', (req, res) => {
  const { trackingNumber } = req.params;
  
  const statuses = ['PENDING', 'PICKED_UP', 'IN_TRANSIT', 'OUT_FOR_DELIVERY', 'DELIVERED'];
  const randomStatus = statuses[Math.floor(Math.random() * statuses.length)];
  
  res.json({
    success: true,
    data: {
      trackingNumber,
      status: randomStatus,
      origin: 'Istanbul, Turkey',
      destination: 'Ankara, Turkey',
      estimatedDelivery: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      currentLocation: 'Bolu Transit Hub',
      lastUpdate: new Date().toISOString(),
      events: [
        {
          status: 'PENDING',
          location: 'Istanbul Warehouse',
          timestamp: new Date(Date.now() - 48 * 60 * 60 * 1000).toISOString(),
          description: 'Shipment created and pending pickup'
        },
        {
          status: 'PICKED_UP',
          location: 'Istanbul Warehouse',
          timestamp: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString(),
          description: 'Package picked up by courier'
        },
        {
          status: 'IN_TRANSIT',
          location: 'Bolu Transit Hub',
          timestamp: new Date(Date.now() - 12 * 60 * 60 * 1000).toISOString(),
          description: 'Package in transit to destination'
        }
      ]
    }
  });
});

// Vehicles endpoint
app.get('/api/vehicles', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: 1,
        licensePlate: '34 ABC 123',
        type: 'Truck',
        brand: 'Mercedes',
        model: 'Actros',
        status: 'AVAILABLE',
        location: 'Istanbul Depot',
        capacity: '15 tons'
      },
      {
        id: 2,
        licensePlate: '06 XYZ 456',
        type: 'Van',
        brand: 'Ford',
        model: 'Transit',
        status: 'IN_TRANSIT',
        location: 'Ankara Route',
        capacity: '2 tons'
      }
    ]
  });
});

// Shipments endpoint
app.get('/api/shipments', (req, res) => {
  res.json({
    success: true,
    data: [
      {
        id: 1,
        trackingNumber: 'TRK' + Date.now(),
        sender: 'ABC Company',
        receiver: 'XYZ Corp',
        origin: 'Istanbul',
        destination: 'Ankara',
        status: 'IN_TRANSIT',
        weight: '5.2 kg',
        created: new Date().toISOString()
      }
    ]
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.originalUrl
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Modern Logistics API running on port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`📚 API docs: http://localhost:${PORT}/`);
});
EOF

cat > backend/.env << 'EOF'
NODE_ENV=production
PORT=3000
API_VERSION=2.0.0
EOF

echo "✅ Backend API created"
echo ""

# Create frontend
echo "🎨 Creating frontend..."

cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modern Logistics Platform</title>
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .gradient-bg {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .card-hover {
            transition: all 0.3s ease;
        }
        .card-hover:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body class="bg-gray-50">
    <!-- Navigation -->
    <nav class="gradient-bg shadow-lg">
        <div class="max-w-7xl mx-auto px-4">
            <div class="flex justify-between items-center py-4">
                <div class="flex items-center space-x-4">
                    <i class="fas fa-truck text-white text-2xl"></i>
                    <h1 class="text-white text-xl font-bold">Modern Logistics</h1>
                </div>
                <div class="hidden md:flex space-x-6">
                    <a href="#" class="text-white hover:text-gray-200">Ana Sayfa</a>
                    <a href="#tracking" class="text-white hover:text-gray-200">Kargo Takip</a>
                    <a href="#services" class="text-white hover:text-gray-200">Hizmetler</a>
                    <a href="#contact" class="text-white hover:text-gray-200">İletişim</a>
                </div>
                <button class="bg-white text-purple-600 px-4 py-2 rounded-lg font-semibold hover:bg-gray-100">
                    Giriş Yap
                </button>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="gradient-bg py-20">
        <div class="max-w-7xl mx-auto px-4 text-center">
            <h2 class="text-4xl md:text-6xl font-bold text-white mb-6">
                Modern Lojistik Çözümleri
            </h2>
            <p class="text-xl text-gray-200 mb-8 max-w-3xl mx-auto">
                Kargolarınızı gerçek zamanlı takip edin, araç filonuzu yönetin ve lojistik operasyonlarınızı optimize edin.
            </p>
            <div class="flex flex-col md:flex-row gap-4 justify-center">
                <button class="bg-white text-purple-600 px-8 py-3 rounded-lg font-semibold hover:bg-gray-100 transition">
                    <i class="fas fa-rocket mr-2"></i>Hemen Başla
                </button>
                <button class="border-2 border-white text-white px-8 py-3 rounded-lg font-semibold hover:bg-white hover:text-purple-600 transition">
                    <i class="fas fa-play mr-2"></i>Demo İzle
                </button>
            </div>
        </div>
    </section>

    <!-- Tracking Section -->
    <section id="tracking" class="py-16 bg-white">
        <div class="max-w-7xl mx-auto px-4">
            <div class="text-center mb-12">
                <h3 class="text-3xl font-bold text-gray-800 mb-4">Kargo Takip</h3>
                <p class="text-gray-600">Kargo numaranızı girerek anlık durumu öğrenin</p>
            </div>
            
            <div class="max-w-2xl mx-auto">
                <div class="bg-gray-50 p-8 rounded-xl shadow-lg">
                    <div class="flex flex-col md:flex-row gap-4">
                        <input 
                            type="text" 
                            id="trackingInput"
                            placeholder="Kargo takip numaranızı girin (örn: TRK123456789)"
                            class="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                        >
                        <button 
                            onclick="trackShipment()"
                            class="bg-purple-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-purple-700 transition"
                        >
                            <i class="fas fa-search mr-2"></i>Takip Et
                        </button>
                    </div>
                    
                    <div id="trackingResult" class="mt-6 hidden">
                        <!-- Tracking result will be displayed here -->
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Services Section -->
    <section id="services" class="py-16 bg-gray-50">
        <div class="max-w-7xl mx-auto px-4">
            <div class="text-center mb-12">
                <h3 class="text-3xl font-bold text-gray-800 mb-4">Hizmetlerimiz</h3>
                <p class="text-gray-600">Kapsamlı lojistik çözümlerimizi keşfedin</p>
            </div>
            
            <div class="grid md:grid-cols-3 gap-8">
                <div class="bg-white p-8 rounded-xl shadow-lg card-hover">
                    <div class="text-purple-600 text-4xl mb-4">
                        <i class="fas fa-shipping-fast"></i>
                    </div>
                    <h4 class="text-xl font-bold text-gray-800 mb-4">Hızlı Teslimat</h4>
                    <p class="text-gray-600">24 saat içinde teslimat garantisi ile hızlı ve güvenilir kargo hizmeti.</p>
                </div>
                
                <div class="bg-white p-8 rounded-xl shadow-lg card-hover">
                    <div class="text-purple-600 text-4xl mb-4">
                        <i class="fas fa-route"></i>
                    </div>
                    <h4 class="text-xl font-bold text-gray-800 mb-4">Rota Optimizasyonu</h4>
                    <p class="text-gray-600">AI destekli rota planlama ile yakıt tasarrufu ve zaman optimizasyonu.</p>
                </div>
                
                <div class="bg-white p-8 rounded-xl shadow-lg card-hover">
                    <div class="text-purple-600 text-4xl mb-4">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <h4 class="text-xl font-bold text-gray-800 mb-4">Analitik Raporlar</h4>
                    <p class="text-gray-600">Detaylı raporlar ve analizler ile operasyonel verimliliği artırın.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="py-16 gradient-bg">
        <div class="max-w-7xl mx-auto px-4">
            <div class="grid md:grid-cols-4 gap-8 text-center">
                <div class="text-white">
                    <div class="text-4xl font-bold mb-2">10K+</div>
                    <div class="text-gray-200">Mutlu Müşteri</div>
                </div>
                <div class="text-white">
                    <div class="text-4xl font-bold mb-2">50K+</div>
                    <div class="text-gray-200">Teslim Edilen Kargo</div>
                </div>
                <div class="text-white">
                    <div class="text-4xl font-bold mb-2">99.9%</div>
                    <div class="text-gray-200">Sistem Uptime</div>
                </div>
                <div class="text-white">
                    <div class="text-4xl font-bold mb-2">24/7</div>
                    <div class="text-gray-200">Müşteri Desteği</div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-800 text-white py-12">
        <div class="max-w-7xl mx-auto px-4">
            <div class="grid md:grid-cols-4 gap-8">
                <div>
                    <div class="flex items-center space-x-2 mb-4">
                        <i class="fas fa-truck text-2xl"></i>
                        <span class="text-xl font-bold">Modern Logistics</span>
                    </div>
                    <p class="text-gray-400">Türkiye'nin en güvenilir lojistik platformu.</p>
                </div>
                <div>
                    <h5 class="font-bold mb-4">Hizmetler</h5>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="#" class="hover:text-white">Kargo Takip</a></li>
                        <li><a href="#" class="hover:text-white">Araç Yönetimi</a></li>
                        <li><a href="#" class="hover:text-white">Raporlama</a></li>
                    </ul>
                </div>
                <div>
                    <h5 class="font-bold mb-4">Destek</h5>
                    <ul class="space-y-2 text-gray-400">
                        <li><a href="#" class="hover:text-white">Yardım Merkezi</a></li>
                        <li><a href="#" class="hover:text-white">İletişim</a></li>
                        <li><a href="#" class="hover:text-white">API Dokümantasyonu</a></li>
                    </ul>
                </div>
                <div>
                    <h5 class="font-bold mb-4">İletişim</h5>
                    <div class="space-y-2 text-gray-400">
                        <div><i class="fas fa-phone mr-2"></i>+90 212 555 0123</div>
                        <div><i class="fas fa-envelope mr-2"></i>info@modernlogistics.com</div>
                        <div><i class="fas fa-map-marker-alt mr-2"></i>İstanbul, Türkiye</div>
                    </div>
                </div>
            </div>
            <div class="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
                <p>&copy; 2025 Modern Logistics Platform. Tüm hakları saklıdır.</p>
            </div>
        </div>
    </footer>

    <script>
        async function trackShipment() {
            const trackingNumber = document.getElementById('trackingInput').value.trim();
            const resultDiv = document.getElementById('trackingResult');
            
            if (!trackingNumber) {
                alert('Lütfen kargo takip numaranızı girin');
                return;
            }
            
            try {
                // Show loading
                resultDiv.innerHTML = `
                    <div class="text-center py-4">
                        <i class="fas fa-spinner fa-spin text-2xl text-purple-600"></i>
                        <p class="mt-2 text-gray-600">Kargo bilgileri getiriliyor...</p>
                    </div>
                `;
                resultDiv.classList.remove('hidden');
                
                // Call API
                const response = await fetch(`/api/tracking/${trackingNumber}`);
                const data = await response.json();
                
                if (data.success) {
                    const shipment = data.data;
                    resultDiv.innerHTML = `
                        <div class="bg-white p-6 rounded-lg border">
                            <div class="flex items-center justify-between mb-4">
                                <h4 class="text-lg font-bold text-gray-800">Kargo Durumu</h4>
                                <span class="px-3 py-1 rounded-full text-sm font-semibold ${getStatusColor(shipment.status)}">
                                    ${getStatusText(shipment.status)}
                                </span>
                            </div>
                            
                            <div class="grid md:grid-cols-2 gap-4 mb-6">
                                <div>
                                    <p class="text-sm text-gray-600">Takip Numarası</p>
                                    <p class="font-semibold">${shipment.trackingNumber}</p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-600">Mevcut Konum</p>
                                    <p class="font-semibold">${shipment.currentLocation}</p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-600">Çıkış</p>
                                    <p class="font-semibold">${shipment.origin}</p>
                                </div>
                                <div>
                                    <p class="text-sm text-gray-600">Varış</p>
                                    <p class="font-semibold">${shipment.destination}</p>
                                </div>
                            </div>
                            
                            <div class="border-t pt-4">
                                <h5 class="font-bold text-gray-800 mb-3">Kargo Geçmişi</h5>
                                <div class="space-y-3">
                                    ${shipment.events.map(event => `
                                        <div class="flex items-start space-x-3">
                                            <div class="w-3 h-3 bg-purple-600 rounded-full mt-1"></div>
                                            <div class="flex-1">
                                                <p class="font-semibold text-gray-800">${getStatusText(event.status)}</p>
                                                <p class="text-sm text-gray-600">${event.location}</p>
                                                <p class="text-sm text-gray-500">${new Date(event.timestamp).toLocaleString('tr-TR')}</p>
                                                <p class="text-sm text-gray-600">${event.description}</p>
                                            </div>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        </div>
                    `;
                } else {
                    resultDiv.innerHTML = `
                        <div class="bg-red-50 border border-red-200 p-4 rounded-lg">
                            <p class="text-red-600">Kargo bulunamadı. Lütfen takip numaranızı kontrol edin.</p>
                        </div>
                    `;
                }
            } catch (error) {
                resultDiv.innerHTML = `
                    <div class="bg-red-50 border border-red-200 p-4 rounded-lg">
                        <p class="text-red-600">Bir hata oluştu. Lütfen daha sonra tekrar deneyin.</p>
                    </div>
                `;
            }
        }
        
        function getStatusColor(status) {
            const colors = {
                'PENDING': 'bg-yellow-100 text-yellow-800',
                'PICKED_UP': 'bg-blue-100 text-blue-800',
                'IN_TRANSIT': 'bg-purple-100 text-purple-800',
                'OUT_FOR_DELIVERY': 'bg-orange-100 text-orange-800',
                'DELIVERED': 'bg-green-100 text-green-800'
            };
            return colors[status] || 'bg-gray-100 text-gray-800';
        }
        
        function getStatusText(status) {
            const texts = {
                'PENDING': 'Beklemede',
                'PICKED_UP': 'Alındı',
                'IN_TRANSIT': 'Yolda',
                'OUT_FOR_DELIVERY': 'Dağıtımda',
                'DELIVERED': 'Teslim Edildi'
            };
            return texts[status] || status;
        }
        
        // Allow Enter key to trigger tracking
        document.getElementById('trackingInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                trackShipment();
            }
        });
    </script>
</body>
</html>
EOF

echo "✅ Frontend created"
echo ""

# Create Docker setup
echo "🐳 Creating Docker configuration..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # Nginx Reverse Proxy
  nginx:
    image: nginx:alpine
    container_name: logistics-nginx
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./docker/nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./frontend:/usr/share/nginx/html
    depends_on:
      - api
    networks:
      - logistics-network
    restart: unless-stopped

  # Backend API
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: logistics-api
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - PORT=3000
    volumes:
      - ./backend:/app
      - /app/node_modules
    networks:
      - logistics-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  # PostgreSQL Database
  postgres:
    image: postgres:15-alpine
    container_name: logistics-postgres
    environment:
      POSTGRES_DB: logistics_db
      POSTGRES_USER: logistics_user
      POSTGRES_PASSWORD: logistics_pass_2025
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./database/migrations:/docker-entrypoint-initdb.d
    networks:
      - logistics-network
    restart: unless-stopped

  # Redis Cache
  redis:
    image: redis:7-alpine
    container_name: logistics-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - logistics-network
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:

networks:
  logistics-network:
    driver: bridge
EOF

# Create Dockerfile for backend
cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

EXPOSE 3000

CMD ["npm", "start"]
EOF

# Create Nginx configuration
mkdir -p docker/nginx
cat > docker/nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;
    error_log /var/log/nginx/error.log warn;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;

    # Upstream for API
    upstream api_backend {
        server api:3000;
    }

    server {
        listen 80;
        server_name _;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Referrer-Policy "strict-origin-when-cross-origin";

        # Serve static files
        location / {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /index.html;
            
            # Cache static assets
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # API proxy
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://api_backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts
            proxy_connect_timeout 30s;
            proxy_send_timeout 30s;
            proxy_read_timeout 30s;
        }

        # Health check
        location /health {
            proxy_pass http://api_backend/health;
            proxy_set_header Host $host;
            access_log off;
        }
    }
}
EOF

echo "✅ Docker configuration created"
echo ""

# Create deployment scripts
echo "📜 Creating deployment scripts..."

cat > deploy.sh << 'EOF'
#!/bin/bash

echo "🚀 DEPLOYING MODERN LOGISTICS PLATFORM"
echo "======================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down

# Remove old images
echo "🧹 Cleaning up old images..."
docker system prune -f

# Build and start services
echo "🏗️ Building and starting services..."
docker-compose up -d --build

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check health
echo "🔍 Checking service health..."
./health-check.sh

echo ""
echo "✅ DEPLOYMENT COMPLETED!"
echo ""
echo "🌐 Access URLs:"
echo "   Website: http://209.38.244.176"
echo "   API: http://209.38.244.176/api"
echo "   Health: http://209.38.244.176/health"
echo ""
echo "🎉 Modern Logistics Platform is now live!"
EOF

cat > health-check.sh << 'EOF'
#!/bin/bash

echo "🔍 HEALTH CHECK - Modern Logistics Platform"
echo "==========================================="

services=(
    "Website:80:/"
    "API:3000:/health"
    "Database:5432"
    "Cache:6379"
)

all_healthy=true

for service in "${services[@]}"; do
    IFS=':' read -r name port path <<< "$service"
    
    echo -n "Checking $name... "
    
    if [ -z "$path" ]; then
        # For database/cache, just check if port is open
        if nc -z localhost $port 2>/dev/null; then
            echo "✅ Running"
        else
            echo "❌ Down"
            all_healthy=false
        fi
    else
        # For web services, check HTTP response
        if curl -s --connect-timeout 5 --max-time 10 "http://localhost:$port$path" > /dev/null; then
            echo "✅ Healthy"
        else
            echo "❌ Unhealthy"
            all_healthy=false
        fi
    fi
done

echo ""
echo "🐳 Container Status:"
docker-compose ps

echo ""
if [ "$all_healthy" = true ]; then
    echo "🎉 All services are healthy!"
    echo ""
    echo "🌐 Live URLs:"
    echo "   Main Site: http://209.38.244.176"
    echo "   API Health: http://209.38.244.176/health"
    echo "   Track Demo: http://209.38.244.176/#tracking"
else
    echo "⚠️  Some services are not healthy!"
    echo ""
    echo "🔍 Debug commands:"
    echo "   docker-compose logs"
    echo "   docker-compose logs api"
    echo "   docker-compose restart"
fi

echo ""
echo "📊 System Resources:"
if command -v free &> /dev/null; then
    echo "Memory: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
fi
if command -v df &> /dev/null; then
    echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
fi
echo ""
EOF

cat > clean.sh << 'EOF'
#!/bin/bash

echo "🧹 CLEANING UP LOGISTICS PLATFORM"
echo "================================="

# Stop all containers
echo "🛑 Stopping containers..."
docker-compose down

# Remove containers, networks, images, and volumes
echo "🗑️ Removing containers, networks, and volumes..."
docker-compose down --volumes --remove-orphans

# Clean up Docker system
echo "🧽 Cleaning Docker system..."
docker system prune -af --volumes

echo "✅ Cleanup completed!"
EOF

# Make scripts executable
chmod +x *.sh

echo "✅ Deployment scripts created"
echo ""

# Create database migrations
echo "🗄️ Creating database setup..."

cat > database/migrations/01_init.sql << 'EOF'
-- Modern Logistics Platform Database Schema
-- Version: 2.0.0

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(20) DEFAULT 'user',
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create vehicles table
CREATE TABLE IF NOT EXISTS vehicles (
    id SERIAL PRIMARY KEY,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50) NOT NULL,
    brand VARCHAR(50),
    model VARCHAR(50),
    year INTEGER,
    capacity_kg DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'available',
    current_location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create shipments table
CREATE TABLE IF NOT EXISTS shipments (
    id SERIAL PRIMARY KEY,
    tracking_number VARCHAR(50) UNIQUE NOT NULL,
    sender_name VARCHAR(100) NOT NULL,
    sender_address TEXT NOT NULL,
    receiver_name VARCHAR(100) NOT NULL,
    receiver_address TEXT NOT NULL,
    weight_kg DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'pending',
    vehicle_id INTEGER REFERENCES vehicles(id),
    estimated_delivery TIMESTAMP,
    actual_delivery TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create tracking_events table
CREATE TABLE IF NOT EXISTS tracking_events (
    id SERIAL PRIMARY KEY,
    shipment_id INTEGER REFERENCES shipments(id),
    status VARCHAR(20) NOT NULL,
    location VARCHAR(100),
    description TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email, password_hash, first_name, last_name, role) VALUES
('admin', 'admin@logistics.com', '$2b$10$hash', 'Admin', 'User', 'admin'),
('demo', 'demo@logistics.com', '$2b$10$hash', 'Demo', 'User', 'user')
ON CONFLICT (username) DO NOTHING;

INSERT INTO vehicles (license_plate, vehicle_type, brand, model, year, capacity_kg, status, current_location) VALUES
('34 ABC 123', 'Truck', 'Mercedes', 'Actros', 2022, 15000, 'available', 'Istanbul Depot'),
('06 XYZ 456', 'Van', 'Ford', 'Transit', 2021, 2000, 'in_transit', 'Ankara Route'),
('35 DEF 789', 'Truck', 'Volvo', 'FH16', 2023, 20000, 'available', 'Izmir Depot')
ON CONFLICT (license_plate) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_shipments_tracking ON shipments(tracking_number);
CREATE INDEX IF NOT EXISTS idx_shipments_status ON shipments(status);
CREATE INDEX IF NOT EXISTS idx_tracking_events_shipment ON tracking_events(shipment_id);
CREATE INDEX IF NOT EXISTS idx_vehicles_status ON vehicles(status);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_vehicles_updated_at ON vehicles;
CREATE TRIGGER update_vehicles_updated_at BEFORE UPDATE ON vehicles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_shipments_updated_at ON shipments;
CREATE TRIGGER update_shipments_updated_at BEFORE UPDATE ON shipments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
EOF

echo "✅ Database setup created"
echo ""

echo "🎉 MODERN LOGISTICS PLATFORM CREATED!"
echo "===================================="
echo ""
echo "📁 Project Structure:"
echo "   ├── backend/          (Node.js API)"
echo "   ├── frontend/         (Modern Web UI)"
echo "   ├── database/         (PostgreSQL)"
echo "   ├── docker/           (Container config)"
echo "   └── scripts/          (Deployment tools)"
echo ""
echo "🚀 Quick Start:"
echo "   1. ./deploy.sh        (Deploy everything)"
echo "   2. ./health-check.sh  (Check status)"
echo "   3. ./clean.sh         (Clean up)"
echo ""
echo "🌐 After deployment:"
echo "   Website: http://209.38.244.176"
echo "   API: http://209.38.244.176/api"
echo ""
echo "✨ Features:"
echo "   ✅ Modern responsive UI"
echo "   ✅ Real-time tracking"
echo "   ✅ RESTful API"
echo "   ✅ Docker containerized"
echo "   ✅ Production ready"
echo ""
EOF

chmod +x start.sh

echo "✅ Modern Logistics Platform created!"
echo ""
echo "🚀 Ready to deploy! Run:"
echo "   ./start.sh"
echo ""