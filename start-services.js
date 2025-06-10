#!/usr/bin/env node

const { spawn, exec } = require('child_process');
const path = require('path');

// Check if we're in a WebContainer environment
function isWebContainer() {
  return process.env.WEBCONTAINER || 
         typeof window !== 'undefined' || 
         process.platform === 'browser';
}

// Function to check if Maven is available
function checkMavenAvailability() {
  return new Promise((resolve) => {
    exec('mvn --version', (error) => {
      resolve(!error);
    });
  });
}

// Service configuration
const services = [
  { name: 'config-server', port: 8888, dir: './config-server' },
  { name: 'discovery-server', port: 8761, dir: './discovery-server' },
  { name: 'gateway-service', port: 8080, dir: './gateway-service' },
  { name: 'auth-service', port: 8081, dir: './auth-service' },
  { name: 'user-service', port: 8082, dir: './user-service' },
  { name: 'transport-service', port: 8083, dir: './transport-service' }
];

// Function to display environment information
function displayEnvironmentInfo() {
  console.log('🏗️  Logistics Platform Services Startup\n');
  
  if (isWebContainer()) {
    console.log('⚠️  WebContainer Environment Detected');
    console.log('');
    console.log('This Spring Boot microservices project requires Java and Maven to run.');
    console.log('WebContainer is a browser-based Node.js runtime that cannot execute');
    console.log('native binaries like Java or Maven.');
    console.log('');
    console.log('📋 To run this project, you need:');
    console.log('   • Java 11 or higher');
    console.log('   • Apache Maven 3.6 or higher');
    console.log('   • A local development environment');
    console.log('');
    console.log('🔧 Setup Instructions:');
    console.log('   1. Install Java Development Kit (JDK) 11+');
    console.log('   2. Install Apache Maven from https://maven.apache.org/');
    console.log('   3. Clone this project to your local machine');
    console.log('   4. Run: npm run start-services');
    console.log('');
    console.log('🌐 Alternative: Use Docker');
    console.log('   • Run: docker-compose up');
    console.log('   • This will start all services in containers');
    console.log('');
    return false;
  }
  
  return true;
}

// Function to check if a port is available
function checkPort(port) {
  return new Promise((resolve) => {
    const { exec } = require('child_process');
    exec(`curl -s http://localhost:${port}/actuator/health`, (error, stdout, stderr) => {
      if (error) {
        resolve(false);
      } else {
        try {
          const response = JSON.parse(stdout);
          resolve(response.status === 'UP');
        } catch (e) {
          resolve(false);
        }
      }
    });
  });
}

// Function to wait for a service to be ready
async function waitForService(name, port, maxAttempts = 30) {
  console.log(`Waiting for ${name} to be ready on port ${port}...`);
  
  for (let i = 0; i < maxAttempts; i++) {
    const isReady = await checkPort(port);
    if (isReady) {
      console.log(`✅ ${name} is ready!`);
      return true;
    }
    
    console.log(`⏳ ${name} not ready yet, attempt ${i + 1}/${maxAttempts}`);
    await new Promise(resolve => setTimeout(resolve, 2000));
  }
  
  console.log(`❌ ${name} failed to start within timeout`);
  return false;
}

// Function to start a service
function startService(service) {
  return new Promise((resolve, reject) => {
    console.log(`🚀 Starting ${service.name}...`);
    
    const mvnProcess = spawn('mvn', ['spring-boot:run'], {
      cwd: service.dir,
      stdio: 'pipe'
    });
    
    mvnProcess.stdout.on('data', (data) => {
      const output = data.toString();
      if (output.includes('Started') && output.includes('Application')) {
        console.log(`✅ ${service.name} started successfully`);
        resolve(mvnProcess);
      }
    });
    
    mvnProcess.stderr.on('data', (data) => {
      console.error(`${service.name} error: ${data}`);
    });
    
    mvnProcess.on('error', (error) => {
      if (error.code === 'ENOENT') {
        console.error(`❌ Maven not found. Please install Apache Maven and ensure it's in your PATH.`);
        console.error(`   Download from: https://maven.apache.org/download.cgi`);
        reject(new Error(`Maven not available: ${error.message}`));
      } else {
        reject(error);
      }
    });
    
    mvnProcess.on('close', (code) => {
      if (code !== 0) {
        console.error(`❌ ${service.name} exited with code ${code}`);
        reject(new Error(`Service ${service.name} failed to start`));
      }
    });
    
    // Timeout after 60 seconds
    setTimeout(() => {
      console.log(`⏰ ${service.name} startup timeout, continuing...`);
      resolve(mvnProcess);
    }, 60000);
  });
}

// Main function to start all services
async function startAllServices() {
  // Check environment compatibility
  if (!displayEnvironmentInfo()) {
    process.exit(1);
  }
  
  // Check Maven availability
  const mavenAvailable = await checkMavenAvailability();
  if (!mavenAvailable) {
    console.log('❌ Maven is not installed or not in PATH');
    console.log('');
    console.log('📦 Install Maven:');
    console.log('   • macOS: brew install maven');
    console.log('   • Ubuntu/Debian: sudo apt install maven');
    console.log('   • Windows: Download from https://maven.apache.org/');
    console.log('   • Or use Docker: docker-compose up');
    console.log('');
    process.exit(1);
  }
  
  console.log('✅ Maven detected, starting services...\n');
  
  const runningProcesses = [];
  
  try {
    // Start services sequentially with dependency management
    for (const service of services) {
      const process = await startService(service);
      runningProcesses.push(process);
      
      // Wait for service to be ready before starting the next one
      const isReady = await waitForService(service.name, service.port);
      if (!isReady) {
        console.log(`⚠️  ${service.name} may not be fully ready, but continuing...`);
      }
      
      console.log(''); // Empty line for readability
    }
    
    console.log('🎉 All services have been started!');
    console.log('\n📋 Service Status:');
    services.forEach(service => {
      console.log(`   ${service.name}: http://localhost:${service.port}`);
    });
    
    console.log('\n🔗 Key URLs:');
    console.log('   Gateway: http://localhost:8080');
    console.log('   Discovery: http://localhost:8761');
    console.log('   Config Server: http://localhost:8888');
    
    console.log('\n✅ Ready for testing!');
    
  } catch (error) {
    console.error('❌ Failed to start services:', error.message);
    
    // Clean up any running processes
    runningProcesses.forEach(process => {
      if (process && !process.killed) {
        process.kill();
      }
    });
    
    process.exit(1);
  }
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down services...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('\n🛑 Shutting down services...');
  process.exit(0);
});

// Start the services
startAllServices();