#!/bin/bash

set -e

echo "🔧 Resolving Git Conflicts and Deploying..."

echo "📋 Current git status:"
git status

echo ""
echo "🗂️ Stashing any local changes..."
git stash push -m "Local changes before deployment - $(date)"

echo ""
echo "📥 Pulling latest changes..."
git pull origin devin/1749816948-efficiency-improvements

echo ""
echo "✅ Git conflicts resolved!"
echo ""
echo "🚀 Starting memory-optimized deployment..."

if [ -f .env.digitalocean.local ]; then
    echo "✅ Environment file found"
else
    echo "❌ .env.digitalocean.local not found!"
    echo "Creating from template..."
    cp .env.digitalocean .env.digitalocean.local
    echo "⚠️  Please edit .env.digitalocean.local with your database credentials"
    echo "Then run: ./deploy-memory-optimized.sh"
    exit 1
fi

echo ""
echo "🔨 Making scripts executable..."
chmod +x deploy-memory-optimized.sh build-sequential.sh fix-config-server.sh test-config-server.sh

echo ""
echo "🚀 Running memory-optimized deployment..."
./deploy-memory-optimized.sh
