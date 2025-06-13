#!/bin/bash

# Logistics Platform - Auth Services Setup Script
# This script sets up the authentication services for the logistics platform

set -e

echo "🚀 Setting up Logistics Platform Auth Services..."

# Create platform directory in the current project workspace
PLATFORM_DIR="./logistics-platform"
mkdir -p "$PLATFORM_DIR"

# Copy the script to the platform directory
cp ./create-auth-services.sh "$PLATFORM_DIR/create-auth-services.sh"

echo "✅ Auth services setup completed successfully!"
echo "📁 Platform directory created at: $PLATFORM_DIR"