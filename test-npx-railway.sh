#!/bin/bash

echo "🧪 Testing npx @railway/cli availability..."
echo "=========================================="

# Test if npx is available
if command -v npx &> /dev/null; then
    echo "✅ npx is available"
    
    # Test if we can run railway cli via npx
    echo "🚂 Testing Railway CLI via npx..."
    npx @railway/cli --version 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Railway CLI works via npx!"
        echo ""
        echo "🚀 You can proceed with:"
        echo "   npx @railway/cli login"
        echo "   npx @railway/cli new --name your-project"
        echo "   npx @railway/cli up"
    else
        echo "⚠️  Railway CLI via npx needs to download first"
        echo "   This might work but will take some time"
        echo ""
        echo "🔄 Alternative: Use Railway Dashboard manually"
        echo "   Visit: https://railway.app/dashboard"
    fi
else
    echo "❌ npx is not available"
    echo "   Please use manual Railway Dashboard setup"
fi

echo ""
echo "📋 Next Steps:"
echo "1. Try: npx @railway/cli login"
echo "2. If that fails, use Railway Dashboard manually"
echo "3. Create projects for each microservice"
echo "4. Set environment variables"
echo "5. Deploy services"