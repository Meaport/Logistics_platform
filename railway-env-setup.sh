#!/bin/bash

echo "🔧 RAILWAY ENVIRONMENT VARIABLES SETUP"
echo "======================================"

# Check if Railway CLI is available
if ! command -v railway &> /dev/null && ! command -v npx &> /dev/null; then
    echo "❌ Error: Neither Railway CLI nor npx is available"
    exit 1
fi

RAILWAY_CMD="railway"
if ! command -v railway &> /dev/null; then
    RAILWAY_CMD="npx @railway/cli"
fi

echo "⚠️  IMPORTANT: You need to set environment variables manually in Railway Dashboard"
echo "   This script will show you what variables to set for each service."
echo ""

# Generate a strong JWT secret
JWT_SECRET=$(openssl rand -base64 64 | tr -d '\n' 2>/dev/null || echo "mySecretKey123456789012345678901234567890")

echo "🔑 Generated JWT Secret (use this for all services):"
echo "JWT_SECRET=$JWT_SECRET"
echo ""

echo "📝 Environment Variables for each service:"
echo "=========================================="

echo ""
echo "🔧 CONFIG SERVER:"
echo "PORT=8888"
echo "SPRING_PROFILES_ACTIVE=railway"
echo ""

echo "🔍 DISCOVERY SERVER:"
echo "PORT=8761"
echo "SPRING_PROFILES_ACTIVE=railway"
echo "CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app"
echo ""

echo "🌐 GATEWAY SERVICE:"
echo "PORT=8080"
echo "SPRING_PROFILES_ACTIVE=railway"
echo "JWT_SECRET=$JWT_SECRET"
echo "EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/"
echo "CONFIG_SERVER_URL=https://logistics-config-server-production.railway.app"
echo ""

echo "🔐 AUTH SERVICE:"
echo "PORT=8081"
echo "SPRING_PROFILES_ACTIVE=railway"
echo "JWT_SECRET=$JWT_SECRET"
echo "DATABASE_URL=[YOUR-SUPABASE-AUTH-CONNECTION-STRING]"
echo "EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/"
echo ""

echo "👤 USER SERVICE:"
echo "PORT=8082"
echo "SPRING_PROFILES_ACTIVE=railway"
echo "JWT_SECRET=$JWT_SECRET"
echo "DATABASE_URL=[YOUR-SUPABASE-USER-CONNECTION-STRING]"
echo "EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/"
echo ""

echo "🚛 TRANSPORT SERVICE:"
echo "PORT=8083"
echo "SPRING_PROFILES_ACTIVE=railway"
echo "JWT_SECRET=$JWT_SECRET"
echo "DATABASE_URL=[YOUR-SUPABASE-TRANSPORT-CONNECTION-STRING]"
echo "EUREKA_DEFAULT_ZONE=https://logistics-discovery-server-production.railway.app/eureka/"
echo ""

echo "📋 MANUAL STEPS:"
echo "1. Go to Railway Dashboard: https://railway.app/dashboard"
echo "2. For each project, go to Variables tab"
echo "3. Add the environment variables shown above"
echo "4. Replace [YOUR-SUPABASE-*-CONNECTION-STRING] with your actual Supabase URLs"
echo ""
echo "🔗 Supabase Connection String Format:"
echo "postgresql://postgres:[PASSWORD]@db.[PROJECT-ID].supabase.co:5432/postgres?currentSchema=[SCHEMA-NAME]"
echo ""
echo "📝 Schema names:"
echo "   Auth Service: auth_service"
echo "   User Service: user_service"
echo "   Transport Service: transport_service"
echo ""
echo "🚀 After setting variables, run: ./railway-deploy.sh"