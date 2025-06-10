#!/usr/bin/env node

const { exec } = require('child_process');
const http = require('http');
const https = require('https');
const { URL } = require('url');

// Stress test configuration
const stressConfig = {
  baseUrl: 'http://localhost:8080',
  phases: [
    { name: 'Warm-up', users: 5, duration: 10 },
    { name: 'Ramp-up', users: 20, duration: 20 },
    { name: 'Peak Load', users: 50, duration: 30 },
    { name: 'Stress Test', users: 100, duration: 20 },
    { name: 'Cool-down', users: 10, duration: 10 }
  ]
};

// Stress test metrics
let stressMetrics = {
  phases: [],
  totalRequests: 0,
  totalErrors: 0,
  peakResponseTime: 0,
  systemStability: true
};

// Function to run stress test phase
async function runStressPhase(phase) {
  console.log(`🔥 Running ${phase.name} phase: ${phase.users} users for ${phase.duration}s`);
  
  const phaseMetrics = {
    name: phase.name,
    users: phase.users,
    duration: phase.duration,
    requests: 0,
    errors: 0,
    avgResponseTime: 0,
    maxResponseTime: 0,
    responseTimes: []
  };
  
  const startTime = Date.now();
  const endTime = startTime + (phase.duration * 1000);
  const userPromises = [];
  
  // Start concurrent users
  for (let i = 0; i < phase.users; i++) {
    userPromises.push(runStressUser(i, endTime, phaseMetrics));
  }
  
  // Wait for all users to complete
  await Promise.all(userPromises);
  
  // Calculate phase statistics
  if (phaseMetrics.responseTimes.length > 0) {
    phaseMetrics.avgResponseTime = Math.round(
      phaseMetrics.responseTimes.reduce((sum, time) => sum + time, 0) / phaseMetrics.responseTimes.length
    );
    phaseMetrics.maxResponseTime = Math.max(...phaseMetrics.responseTimes);
  }
  
  stressMetrics.phases.push(phaseMetrics);
  stressMetrics.totalRequests += phaseMetrics.requests;
  stressMetrics.totalErrors += phaseMetrics.errors;
  stressMetrics.peakResponseTime = Math.max(stressMetrics.peakResponseTime, phaseMetrics.maxResponseTime);
  
  console.log(`   ✅ ${phase.name} completed: ${phaseMetrics.requests} requests, ${phaseMetrics.errors} errors, ${phaseMetrics.avgResponseTime}ms avg`);
  
  // Check system stability
  const errorRate = phaseMetrics.requests > 0 ? (phaseMetrics.errors / phaseMetrics.requests) * 100 : 0;
  if (errorRate > 10 || phaseMetrics.avgResponseTime > 10000) {
    stressMetrics.systemStability = false;
    console.log(`   ⚠️  System instability detected in ${phase.name} phase`);
  }
  
  return phaseMetrics;
}

// Function to simulate a stress test user
async function runStressUser(userId, endTime, phaseMetrics) {
  while (Date.now() < endTime) {
    const startTime = Date.now();
    
    try {
      const result = await makeHttpRequest(`${stressConfig.baseUrl}/actuator/health`);
      const responseTime = Date.now() - startTime;
      
      phaseMetrics.requests++;
      phaseMetrics.responseTimes.push(responseTime);
      
      if (!result.success) {
        phaseMetrics.errors++;
      }
      
    } catch (error) {
      phaseMetrics.errors++;
    }
    
    // Small delay to prevent overwhelming
    await new Promise(resolve => setTimeout(resolve, 50));
  }
}

// Function to make HTTP requests using Node.js built-in modules
function makeHttpRequest(url) {
  return new Promise((resolve) => {
    try {
      const urlObj = new URL(url);
      const client = urlObj.protocol === 'https:' ? https : http;
      
      const options = {
        hostname: urlObj.hostname,
        port: urlObj.port || (urlObj.protocol === 'https:' ? 443 : 80),
        path: urlObj.pathname + urlObj.search,
        method: 'GET',
        timeout: 5000,
        headers: {
          'User-Agent': 'Logistics-Stress-Test/1.0'
        }
      };
      
      const req = client.request(options, (res) => {
        let data = '';
        
        res.on('data', (chunk) => {
          data += chunk;
        });
        
        res.on('end', () => {
          const success = res.statusCode >= 200 && res.statusCode < 400;
          resolve({ 
            success, 
            statusCode: res.statusCode,
            data: data.substring(0, 100) // Limit data for memory efficiency
          });
        });
      });
      
      req.on('error', (error) => {
        resolve({ success: false, error: error.message });
      });
      
      req.on('timeout', () => {
        req.destroy();
        resolve({ success: false, error: 'Request timeout' });
      });
      
      req.end();
      
    } catch (error) {
      resolve({ success: false, error: error.message });
    }
  });
}

// Function to check if services are available
async function checkServiceAvailability() {
  console.log('🔍 Checking service availability...');
  
  const services = [
    { name: 'Gateway Service', url: `${stressConfig.baseUrl}/actuator/health` },
    { name: 'Discovery Server', url: 'http://localhost:8761/actuator/health' },
    { name: 'Config Server', url: 'http://localhost:8888/actuator/health' }
  ];
  
  const results = [];
  
  for (const service of services) {
    try {
      const result = await makeHttpRequest(service.url);
      results.push({
        name: service.name,
        available: result.success,
        status: result.statusCode || 'N/A'
      });
    } catch (error) {
      results.push({
        name: service.name,
        available: false,
        status: 'Error'
      });
    }
  }
  
  console.log('\n📊 Service Status:');
  results.forEach(result => {
    const status = result.available ? '✅ UP' : '❌ DOWN';
    console.log(`   ${result.name}: ${status} (${result.status})`);
  });
  
  const availableServices = results.filter(r => r.available).length;
  console.log(`\n📈 Services Available: ${availableServices}/${results.length}`);
  
  if (availableServices === 0) {
    console.log('\n⚠️  No services are available. Please start the services before running stress tests.');
    console.log('💡 Note: Docker is not available in this environment. Please use alternative service startup methods.');
    return false;
  }
  
  return availableServices > 0;
}

// Main stress test function
async function runStressTest() {
  console.log('🔥 LOGISTICS PLATFORM - STRESS TESTING');
  console.log('======================================\n');
  
  // Check service availability first
  const servicesAvailable = await checkServiceAvailability();
  
  if (!servicesAvailable) {
    console.log('\n❌ Stress test aborted due to service unavailability.');
    return;
  }
  
  console.log('\n📋 Stress Test Plan:');
  stressConfig.phases.forEach(phase => {
    console.log(`   ${phase.name}: ${phase.users} users for ${phase.duration}s`);
  });
  console.log('');
  
  try {
    // Run each stress test phase
    for (const phase of stressConfig.phases) {
      await runStressPhase(phase);
      
      // Brief pause between phases
      if (phase !== stressConfig.phases[stressConfig.phases.length - 1]) {
        console.log('   ⏸️  Pausing 5 seconds between phases...');
        await new Promise(resolve => setTimeout(resolve, 5000));
      }
    }
    
    // Generate stress test report
    console.log('\n📊 Stress Test Results:');
    console.log('=======================');
    
    console.log(`\n🎯 Overall Performance:`);
    console.log(`   Total Requests: ${stressMetrics.totalRequests}`);
    console.log(`   Total Errors: ${stressMetrics.totalErrors}`);
    
    const overallErrorRate = stressMetrics.totalRequests > 0 ? 
      ((stressMetrics.totalErrors / stressMetrics.totalRequests) * 100).toFixed(2) : '0.00';
    
    console.log(`   Error Rate: ${overallErrorRate}%`);
    console.log(`   Peak Response Time: ${stressMetrics.peakResponseTime}ms`);
    console.log(`   System Stability: ${stressMetrics.systemStability ? '✅ STABLE' : '❌ UNSTABLE'}`);
    
    console.log(`\n📈 Phase-by-Phase Results:`);
    stressMetrics.phases.forEach(phase => {
      const errorRate = phase.requests > 0 ? ((phase.errors / phase.requests) * 100).toFixed(2) : '0.00';
      console.log(`   ${phase.name}:`);
      console.log(`     Users: ${phase.users}, Requests: ${phase.requests}, Errors: ${phase.errors} (${errorRate}%)`);
      console.log(`     Avg Response: ${phase.avgResponseTime}ms, Max Response: ${phase.maxResponseTime}ms`);
    });
    
    // System recommendations
    console.log(`\n💡 Recommendations:`);
    if (stressMetrics.systemStability && stressMetrics.peakResponseTime < 5000) {
      console.log('   ✅ System performs well under stress');
      console.log('   ✅ Ready for production deployment');
    } else if (stressMetrics.peakResponseTime > 10000) {
      console.log('   ⚠️  High response times detected');
      console.log('   💡 Consider optimizing database queries and adding caching');
    } else if (parseFloat(overallErrorRate) > 5) {
      console.log('   ⚠️  High error rate detected');
      console.log('   💡 Review error logs and increase resource allocation');
    }
    
    console.log(`\n📝 Environment Notes:`);
    console.log('   ℹ️  Running in WebContainer environment (Docker not available)');
    console.log('   ℹ️  Services must be started using alternative methods');
    
  } catch (error) {
    console.error('\n💥 Stress test failed:', error.message);
  }
}

// Run the stress test
runStressTest();