#!/usr/bin/env node

const { exec, spawn } = require('child_process');
const fs = require('fs');

// Check if we're in a WebContainer environment
function isWebContainer() {
  return process.env.WEBCONTAINER || 
         typeof window !== 'undefined' || 
         process.platform === 'browser';
}

// Test configuration
const config = {
  baseUrl: 'http://localhost:8080',
  timeout: 10000,
  maxRetries: 3
};

// Service configuration
const services = [
  { name: 'Config Server', port: 8888, path: '/actuator/health' },
  { name: 'Discovery Server', port: 8761, path: '/actuator/health' },
  { name: 'Gateway Service', port: 8080, path: '/actuator/health' },
  { name: 'Auth Service', port: 8081, path: '/actuator/health' },
  { name: 'User Service', port: 8082, path: '/actuator/health' },
  { name: 'Transport Service', port: 8083, path: '/actuator/health' }
];

// Test results tracking
let testResults = {
  total: 0,
  passed: 0,
  failed: 0,
  errors: []
};

// Utility function to check if a service is running
function checkServiceHealth(port, path = '/actuator/health') {
  return new Promise((resolve) => {
    const curlCommand = `curl -s --connect-timeout 3 --max-time 5 http://localhost:${port}${path}`;
    
    exec(curlCommand, (error, stdout, stderr) => {
      if (error) {
        resolve({ running: false, error: error.message });
        return;
      }
      
      try {
        const response = JSON.parse(stdout);
        resolve({ 
          running: true, 
          healthy: response.status === 'UP',
          response: response 
        });
      } catch (e) {
        resolve({ running: false, error: 'Invalid JSON response' });
      }
    });
  });
}

// Function to check all services
async function checkAllServices() {
  console.log('🔍 Checking service availability...\n');
  
  const serviceStatuses = [];
  let allRunning = true;
  
  for (const service of services) {
    const status = await checkServiceHealth(service.port, service.path);
    serviceStatuses.push({ ...service, ...status });
    
    if (status.running && status.healthy) {
      console.log(`✅ ${service.name} (Port ${service.port}): Running and Healthy`);
    } else if (status.running) {
      console.log(`⚠️  ${service.name} (Port ${service.port}): Running but not healthy`);
      allRunning = false;
    } else {
      console.log(`❌ ${service.name} (Port ${service.port}): Not running`);
      allRunning = false;
    }
  }
  
  return { allRunning, serviceStatuses };
}

// Function to display startup instructions
function displayStartupInstructions() {
  console.log('\n🚀 How to Start the Services:\n');
  
  if (isWebContainer()) {
    console.log('⚠️  WebContainer Environment Detected');
    console.log('');
    console.log('This Spring Boot microservices project requires Java and Maven to run.');
    console.log('WebContainer cannot execute native binaries like Java or Maven.');
    console.log('');
    console.log('📋 To run this project, you need:');
    console.log('   • Java Development Kit (JDK) 17 or higher');
    console.log('   • Apache Maven 3.6 or higher');
    console.log('   • A local development environment');
    console.log('');
    console.log('🔧 Setup Instructions:');
    console.log('   1. Install Java Development Kit (JDK) 17+');
    console.log('   2. Install Apache Maven from https://maven.apache.org/');
    console.log('   3. Clone this project to your local machine');
    console.log('   4. Run: npm run start-services');
    console.log('');
    console.log('🐳 Alternative: Use Docker');
    console.log('   • Run: docker-compose up');
    console.log('   • This will start all services in containers');
    console.log('');
  } else {
    console.log('💻 Local Environment Options:');
    console.log('');
    console.log('Option 1: Using Node.js Scripts (Recommended)');
    console.log('   npm run start-services');
    console.log('');
    console.log('Option 2: Using Docker Compose');
    console.log('   docker-compose up');
    console.log('');
    console.log('Option 3: Manual Startup (Advanced)');
    console.log('   # Start services in order:');
    console.log('   cd config-server && mvn spring-boot:run &');
    console.log('   cd discovery-server && mvn spring-boot:run &');
    console.log('   cd gateway-service && mvn spring-boot:run &');
    console.log('   cd auth-service && mvn spring-boot:run &');
    console.log('   cd user-service && mvn spring-boot:run &');
    console.log('   cd transport-service && mvn spring-boot:run &');
    console.log('');
  }
  
  console.log('⏱️  Services typically take 2-3 minutes to fully start');
  console.log('🔄 Run this test again once all services are running');
}

// Utility function to make HTTP requests
function makeRequest(url, options = {}) {
  return new Promise((resolve, reject) => {
    const method = options.method || 'GET';
    const headers = options.headers || {};
    const data = options.data ? JSON.stringify(options.data) : null;
    
    let curlCommand = `curl -s --connect-timeout 5 --max-time 10 -w "\\n%{http_code}" -X ${method}`;
    
    // Add headers
    Object.entries(headers).forEach(([key, value]) => {
      curlCommand += ` -H "${key}: ${value}"`;
    });
    
    // Add data for POST/PUT requests
    if (data) {
      curlCommand += ` -d '${data}'`;
    }
    
    curlCommand += ` "${url}"`;
    
    exec(curlCommand, { timeout: config.timeout }, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(`Request failed: ${error.message}`));
        return;
      }
      
      const lines = stdout.trim().split('\n');
      const statusCode = parseInt(lines[lines.length - 1]);
      const body = lines.slice(0, -1).join('\n');
      
      resolve({
        statusCode,
        body: body ? (body.startsWith('{') || body.startsWith('[') ? 
          (() => { try { return JSON.parse(body); } catch { return body; } })() : body) : null
      });
    });
  });
}

// Test function wrapper
async function runTest(testName, testFunction) {
  testResults.total++;
  console.log(`🧪 Running: ${testName}`);
  
  try {
    await testFunction();
    testResults.passed++;
    console.log(`✅ PASSED: ${testName}`);
  } catch (error) {
    testResults.failed++;
    testResults.errors.push({ test: testName, error: error.message });
    console.log(`❌ FAILED: ${testName} - ${error.message}`);
  }
}

// Health check tests
async function testHealthChecks() {
  for (const service of services) {
    await runTest(`${service.name} Health Check`, async () => {
      const response = await makeRequest(`http://localhost:${service.port}${service.path}`);
      if (response.statusCode !== 200) {
        throw new Error(`Expected 200, got ${response.statusCode}`);
      }
      if (!response.body || response.body.status !== 'UP') {
        throw new Error(`Service not healthy: ${JSON.stringify(response.body)}`);
      }
    });
  }
}

// Service discovery tests
async function testServiceDiscovery() {
  await runTest('Service Discovery Check', async () => {
    const response = await makeRequest('http://localhost:8761/eureka/apps');
    if (response.statusCode !== 200) {
      throw new Error(`Expected 200, got ${response.statusCode}`);
    }
    // Check if response contains service registrations
    if (!response.body || (typeof response.body === 'string' && !response.body.includes('application'))) {
      throw new Error('No services registered with Eureka');
    }
  });
  
  await runTest('Gateway Routes Check', async () => {
    const response = await makeRequest('http://localhost:8080/actuator/gateway/routes');
    if (response.statusCode !== 200) {
      throw new Error(`Expected 200, got ${response.statusCode}`);
    }
  });
}

// Authentication tests
async function testAuthentication() {
  let userToken = '';
  let adminToken = '';
  
  // Test user registration
  await runTest('User Registration', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      data: {
        username: 'testuser',
        email: 'test@logistics.com',
        password: 'test123',
        firstName: 'Test',
        lastName: 'User'
      }
    });
    
    if (response.statusCode !== 200 && response.statusCode !== 201) {
      throw new Error(`Registration failed with status ${response.statusCode}: ${JSON.stringify(response.body)}`);
    }
  });
  
  // Test user login
  await runTest('User Login', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      data: {
        username: 'testuser',
        password: 'test123'
      }
    });
    
    if (response.statusCode !== 200) {
      throw new Error(`Login failed with status ${response.statusCode}: ${JSON.stringify(response.body)}`);
    }
    
    if (response.body && response.body.data && response.body.data.token) {
      userToken = response.body.data.token;
    }
  });
  
  // Test admin login
  await runTest('Admin Login', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      data: {
        username: 'admin',
        password: 'admin123'
      }
    });
    
    if (response.statusCode !== 200) {
      throw new Error(`Admin login failed with status ${response.statusCode}: ${JSON.stringify(response.body)}`);
    }
    
    if (response.body && response.body.data && response.body.data.token) {
      adminToken = response.body.data.token;
    }
  });
  
  return { userToken, adminToken };
}

// Transport service tests
async function testTransportService(tokens) {
  const { adminToken } = tokens;
  
  if (!adminToken) {
    console.log('⚠️  Skipping transport tests - no admin token available');
    return;
  }
  
  // Test public tracking (no auth required)
  await runTest('Public Shipment Tracking', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/transport/shipments/tracking/TRK17056789123456`);
    
    // Accept 404 as valid response for non-existent tracking number
    if (response.statusCode !== 200 && response.statusCode !== 404) {
      throw new Error(`Unexpected status code: ${response.statusCode}`);
    }
  });
  
  // Test vehicle listing
  await runTest('Vehicle Listing', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/transport/vehicles`, {
      headers: { 'Authorization': `Bearer ${adminToken}` }
    });
    
    if (response.statusCode !== 200) {
      throw new Error(`Vehicle listing failed with status ${response.statusCode}: ${JSON.stringify(response.body)}`);
    }
  });
}

// Error handling tests
async function testErrorHandling() {
  // Test invalid login
  await runTest('Invalid Login Credentials', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      data: {
        username: 'invalid',
        password: 'wrong'
      }
    });
    
    if (response.statusCode === 200) {
      throw new Error('Expected login to fail with invalid credentials');
    }
  });
  
  // Test unauthorized access
  await runTest('Unauthorized Access', async () => {
    const response = await makeRequest(`${config.baseUrl}/api/users`);
    
    if (response.statusCode !== 401 && response.statusCode !== 403) {
      throw new Error(`Expected 401/403, got ${response.statusCode}`);
    }
  });
}

// Performance test (simplified)
async function testPerformance() {
  await runTest('Concurrent Health Checks', async () => {
    const promises = [];
    const concurrentRequests = 5;
    
    for (let i = 0; i < concurrentRequests; i++) {
      promises.push(makeRequest(`${config.baseUrl}/actuator/health`));
    }
    
    const results = await Promise.allSettled(promises);
    const successful = results.filter(r => r.status === 'fulfilled' && r.value.statusCode === 200);
    
    if (successful.length < concurrentRequests * 0.8) {
      throw new Error(`Only ${successful.length}/${concurrentRequests} requests succeeded`);
    }
  });
}

// Main test execution
async function runAllTests() {
  console.log('🚀 Logistics Platform Test Runner\n');
  
  // First, check if services are running
  const { allRunning, serviceStatuses } = await checkAllServices();
  
  if (!allRunning) {
    console.log('\n❌ Not all services are running!');
    displayStartupInstructions();
    process.exit(1);
  }
  
  console.log('\n✅ All services are running and healthy!\n');
  console.log('🧪 Starting comprehensive tests...\n');
  
  try {
    // Phase 1: Health Checks
    console.log('📋 Phase 1: Health Checks');
    await testHealthChecks();
    console.log('');
    
    // Phase 2: Service Discovery
    console.log('🔍 Phase 2: Service Discovery');
    await testServiceDiscovery();
    console.log('');
    
    // Phase 3: Authentication
    console.log('🔐 Phase 3: Authentication');
    const tokens = await testAuthentication();
    console.log('');
    
    // Phase 4: Transport Service
    console.log('🚛 Phase 4: Transport Service');
    await testTransportService(tokens);
    console.log('');
    
    // Phase 5: Error Handling
    console.log('🛡️  Phase 5: Error Handling');
    await testErrorHandling();
    console.log('');
    
    // Phase 6: Performance
    console.log('⚡ Phase 6: Performance');
    await testPerformance();
    console.log('');
    
  } catch (error) {
    console.error('💥 Test execution failed:', error.message);
  }
  
  // Print results
  console.log('📊 Test Results Summary:');
  console.log(`   Total Tests: ${testResults.total}`);
  console.log(`   Passed: ${testResults.passed} ✅`);
  console.log(`   Failed: ${testResults.failed} ❌`);
  console.log(`   Success Rate: ${((testResults.passed / testResults.total) * 100).toFixed(1)}%`);
  
  if (testResults.errors.length > 0) {
    console.log('\n❌ Failed Tests:');
    testResults.errors.forEach(error => {
      console.log(`   - ${error.test}: ${error.error}`);
    });
  }
  
  if (testResults.passed === testResults.total) {
    console.log('\n🎉 All tests passed! The logistics platform is working correctly.');
  } else {
    console.log('\n⚠️  Some tests failed. Please check the services and try again.');
  }
  
  console.log('\n🏁 Test execution completed!');
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Test execution interrupted');
  process.exit(0);
});

// Run the tests
runAllTests();