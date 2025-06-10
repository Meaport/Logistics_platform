#!/usr/bin/env node

const { exec } = require('child_process');
const fs = require('fs');

// Performance test configuration
const config = {
  baseUrl: 'http://localhost:8080',
  concurrentUsers: 10,
  testDuration: 30, // seconds
  requestDelay: 100, // milliseconds between requests
};

// Performance metrics tracking
let performanceMetrics = {
  totalRequests: 0,
  successfulRequests: 0,
  failedRequests: 0,
  responseTimes: [],
  errors: [],
  startTime: null,
  endTime: null
};

// Utility function to make timed HTTP requests
function makeTimedRequest(url, options = {}) {
  return new Promise((resolve) => {
    const startTime = Date.now();
    const method = options.method || 'GET';
    const headers = options.headers || {};
    const data = options.data ? JSON.stringify(options.data) : null;
    
    let curlCommand = `curl -s --connect-timeout 5 --max-time 10 -w "\\n%{http_code}\\n%{time_total}" -X ${method}`;
    
    // Add headers
    Object.entries(headers).forEach(([key, value]) => {
      curlCommand += ` -H "${key}: ${value}"`;
    });
    
    // Add data for POST/PUT requests
    if (data) {
      curlCommand += ` -d '${data}'`;
    }
    
    curlCommand += ` "${url}"`;
    
    exec(curlCommand, { timeout: 15000 }, (error, stdout, stderr) => {
      const endTime = Date.now();
      const responseTime = endTime - startTime;
      
      performanceMetrics.totalRequests++;
      
      if (error) {
        performanceMetrics.failedRequests++;
        performanceMetrics.errors.push({
          url,
          error: error.message,
          responseTime
        });
        resolve({ success: false, responseTime, error: error.message });
        return;
      }
      
      const lines = stdout.trim().split('\n');
      const statusCode = parseInt(lines[lines.length - 2]);
      const curlTime = parseFloat(lines[lines.length - 1]) * 1000; // Convert to ms
      
      if (statusCode >= 200 && statusCode < 400) {
        performanceMetrics.successfulRequests++;
      } else {
        performanceMetrics.failedRequests++;
      }
      
      performanceMetrics.responseTimes.push(responseTime);
      
      resolve({
        success: statusCode >= 200 && statusCode < 400,
        statusCode,
        responseTime,
        curlTime
      });
    });
  });
}

// Test scenarios
const testScenarios = [
  {
    name: 'Health Check Load Test',
    url: '/actuator/health',
    method: 'GET',
    weight: 30 // 30% of requests
  },
  {
    name: 'Public Tracking Load Test',
    url: '/api/transport/shipments/tracking/TRK123456789',
    method: 'GET',
    weight: 25 // 25% of requests
  },
  {
    name: 'Gateway Routes Load Test',
    url: '/actuator/gateway/routes',
    method: 'GET',
    weight: 20 // 20% of requests
  },
  {
    name: 'Service Discovery Load Test',
    url: 'http://localhost:8761/eureka/apps',
    method: 'GET',
    weight: 15 // 15% of requests
  },
  {
    name: 'Auth Login Load Test',
    url: '/api/auth/login',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    data: { username: 'admin', password: 'admin123' },
    weight: 10 // 10% of requests
  }
];

// Function to select random test scenario based on weights
function selectRandomScenario() {
  const totalWeight = testScenarios.reduce((sum, scenario) => sum + scenario.weight, 0);
  let random = Math.random() * totalWeight;
  
  for (const scenario of testScenarios) {
    random -= scenario.weight;
    if (random <= 0) {
      return scenario;
    }
  }
  
  return testScenarios[0]; // Fallback
}

// Function to run a single user simulation
async function runUserSimulation(userId, duration) {
  console.log(`👤 Starting user ${userId} simulation...`);
  
  const endTime = Date.now() + (duration * 1000);
  let requestCount = 0;
  
  while (Date.now() < endTime) {
    const scenario = selectRandomScenario();
    const url = scenario.url.startsWith('http') ? scenario.url : config.baseUrl + scenario.url;
    
    const result = await makeTimedRequest(url, {
      method: scenario.method,
      headers: scenario.headers,
      data: scenario.data
    });
    
    requestCount++;
    
    if (requestCount % 10 === 0) {
      console.log(`👤 User ${userId}: ${requestCount} requests completed`);
    }
    
    // Add delay between requests
    await new Promise(resolve => setTimeout(resolve, config.requestDelay));
  }
  
  console.log(`✅ User ${userId} completed ${requestCount} requests`);
  return requestCount;
}

// Function to calculate performance statistics
function calculateStatistics() {
  const responseTimes = performanceMetrics.responseTimes;
  
  if (responseTimes.length === 0) {
    return {
      avgResponseTime: 0,
      minResponseTime: 0,
      maxResponseTime: 0,
      p95ResponseTime: 0,
      p99ResponseTime: 0
    };
  }
  
  const sorted = responseTimes.sort((a, b) => a - b);
  const avg = responseTimes.reduce((sum, time) => sum + time, 0) / responseTimes.length;
  const min = sorted[0];
  const max = sorted[sorted.length - 1];
  const p95Index = Math.floor(sorted.length * 0.95);
  const p99Index = Math.floor(sorted.length * 0.99);
  
  return {
    avgResponseTime: Math.round(avg),
    minResponseTime: min,
    maxResponseTime: max,
    p95ResponseTime: sorted[p95Index],
    p99ResponseTime: sorted[p99Index]
  };
}

// Function to check service availability before testing
async function checkServiceAvailability() {
  console.log('🔍 Checking service availability before performance testing...');
  
  const healthCheck = await makeTimedRequest(`${config.baseUrl}/actuator/health`);
  
  if (!healthCheck.success) {
    throw new Error('Gateway service is not available. Please ensure all services are running.');
  }
  
  console.log('✅ Gateway service is available');
  
  // Check a few more endpoints
  const endpoints = [
    '/actuator/gateway/routes',
    '/api/transport/shipments/tracking/TEST123'
  ];
  
  for (const endpoint of endpoints) {
    const result = await makeTimedRequest(`${config.baseUrl}${endpoint}`);
    console.log(`   ${endpoint}: ${result.success ? '✅' : '❌'} (${result.responseTime}ms)`);
  }
}

// Main performance test function
async function runPerformanceTest() {
  console.log('⚡ LOGISTICS PLATFORM - PERFORMANCE TESTING');
  console.log('==========================================\n');
  
  try {
    // Check service availability
    await checkServiceAvailability();
    console.log('');
    
    console.log('📊 Performance Test Configuration:');
    console.log(`   Concurrent Users: ${config.concurrentUsers}`);
    console.log(`   Test Duration: ${config.testDuration} seconds`);
    console.log(`   Request Delay: ${config.requestDelay}ms`);
    console.log(`   Base URL: ${config.baseUrl}`);
    console.log('');
    
    console.log('🚀 Starting performance test...\n');
    
    performanceMetrics.startTime = Date.now();
    
    // Start concurrent user simulations
    const userPromises = [];
    for (let i = 1; i <= config.concurrentUsers; i++) {
      userPromises.push(runUserSimulation(i, config.testDuration));
    }
    
    // Wait for all users to complete
    const userResults = await Promise.all(userPromises);
    
    performanceMetrics.endTime = Date.now();
    
    console.log('\n📈 Performance Test Results:');
    console.log('============================');
    
    const totalDuration = (performanceMetrics.endTime - performanceMetrics.startTime) / 1000;
    const stats = calculateStatistics();
    const requestsPerSecond = performanceMetrics.totalRequests / totalDuration;
    const successRate = (performanceMetrics.successfulRequests / performanceMetrics.totalRequests) * 100;
    
    console.log(`\n📊 Overall Metrics:`);
    console.log(`   Total Requests: ${performanceMetrics.totalRequests}`);
    console.log(`   Successful Requests: ${performanceMetrics.successfulRequests}`);
    console.log(`   Failed Requests: ${performanceMetrics.failedRequests}`);
    console.log(`   Success Rate: ${successRate.toFixed(2)}%`);
    console.log(`   Requests/Second: ${requestsPerSecond.toFixed(2)}`);
    console.log(`   Test Duration: ${totalDuration.toFixed(2)} seconds`);
    
    console.log(`\n⏱️  Response Time Statistics:`);
    console.log(`   Average: ${stats.avgResponseTime}ms`);
    console.log(`   Minimum: ${stats.minResponseTime}ms`);
    console.log(`   Maximum: ${stats.maxResponseTime}ms`);
    console.log(`   95th Percentile: ${stats.p95ResponseTime}ms`);
    console.log(`   99th Percentile: ${stats.p99ResponseTime}ms`);
    
    console.log(`\n👥 User Performance:`);
    userResults.forEach((requestCount, index) => {
      console.log(`   User ${index + 1}: ${requestCount} requests`);
    });
    
    if (performanceMetrics.errors.length > 0) {
      console.log(`\n❌ Errors (${performanceMetrics.errors.length}):`);
      const errorSummary = {};
      performanceMetrics.errors.forEach(error => {
        const key = error.error.substring(0, 50);
        errorSummary[key] = (errorSummary[key] || 0) + 1;
      });
      
      Object.entries(errorSummary).forEach(([error, count]) => {
        console.log(`   ${error}: ${count} occurrences`);
      });
    }
    
    // Performance assessment
    console.log('\n🎯 Performance Assessment:');
    if (successRate >= 95 && stats.avgResponseTime <= 2000) {
      console.log('   ✅ EXCELLENT: High success rate and fast response times');
    } else if (successRate >= 90 && stats.avgResponseTime <= 5000) {
      console.log('   ✅ GOOD: Acceptable performance for production use');
    } else if (successRate >= 80) {
      console.log('   ⚠️  FAIR: Performance issues detected, optimization recommended');
    } else {
      console.log('   ❌ POOR: Significant performance issues, immediate attention required');
    }
    
    // Save results to file
    const reportData = {
      timestamp: new Date().toISOString(),
      config,
      metrics: performanceMetrics,
      statistics: stats,
      overallMetrics: {
        totalDuration,
        requestsPerSecond,
        successRate
      }
    };
    
    fs.writeFileSync('performance-test-results.json', JSON.stringify(reportData, null, 2));
    console.log('\n💾 Results saved to: performance-test-results.json');
    
  } catch (error) {
    console.error('\n💥 Performance test failed:', error.message);
    process.exit(1);
  }
}

// Memory usage monitoring
function startMemoryMonitoring() {
  const interval = setInterval(() => {
    const usage = process.memoryUsage();
    console.log(`📊 Memory: ${Math.round(usage.heapUsed / 1024 / 1024)}MB used, ${Math.round(usage.heapTotal / 1024 / 1024)}MB total`);
  }, 10000); // Every 10 seconds
  
  return interval;
}

// Handle process termination
process.on('SIGINT', () => {
  console.log('\n🛑 Performance test interrupted');
  if (performanceMetrics.startTime) {
    performanceMetrics.endTime = Date.now();
    const stats = calculateStatistics();
    console.log(`\n📊 Partial Results:`);
    console.log(`   Requests completed: ${performanceMetrics.totalRequests}`);
    console.log(`   Average response time: ${stats.avgResponseTime}ms`);
  }
  process.exit(0);
});

// Start memory monitoring
const memoryInterval = startMemoryMonitoring();

// Run the performance test
runPerformanceTest().finally(() => {
  clearInterval(memoryInterval);
});