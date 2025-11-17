#!/bin/bash

# Test script for CI/CD environment setup
# This script verifies that all services are running correctly

set -e

echo "🧪 Testing CI/CD Environment Setup"
echo "=================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Check if services are running
echo "📋 Checking service status..."

services=("harness-jenkins" "harness-gitlab" "harness-sonarqube" "harness-registry")

for service in "${services[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$service"; then
        echo "✅ $service is running"
    else
        echo "❌ $service is not running"
    fi
done

# Test Jenkins
echo ""
echo "🔍 Testing Jenkins..."
if curl -s http://localhost:8080 > /dev/null; then
    echo "✅ Jenkins is accessible at http://localhost:8080"
else
    echo "❌ Jenkins is not accessible"
fi

# Test GitLab
echo ""
echo "🔍 Testing GitLab..."
if curl -s http://localhost:8081 > /dev/null; then
    echo "✅ GitLab is accessible at http://localhost:8081"
else
    echo "❌ GitLab is not accessible (may still be starting up)"
fi

# Test SonarQube
echo ""
echo "🔍 Testing SonarQube..."
if curl -s http://localhost:9000 > /dev/null; then
    echo "✅ SonarQube is accessible at http://localhost:9000"
else
    echo "❌ SonarQube is not accessible"
fi

# Test Docker Registry
echo ""
echo "🔍 Testing Docker Registry..."
if curl -s http://localhost:5000/v2/ > /dev/null; then
    echo "✅ Docker Registry is accessible at http://localhost:5000"
else
    echo "❌ Docker Registry is not accessible"
fi

# Check Kubernetes
echo ""
echo "🔍 Testing Kubernetes..."
if command -v kubectl &> /dev/null; then
    if kubectl cluster-info &> /dev/null; then
        echo "✅ Kubernetes cluster is accessible"
        echo "   Nodes: $(kubectl get nodes --no-headers | wc -l)"
    else
        echo "❌ Kubernetes cluster is not accessible"
    fi
else
    echo "⚠️  kubectl is not installed"
fi

# Check sample app
echo ""
echo "🔍 Testing Sample Application..."
if [ -f "sample-app/package.json" ]; then
    echo "✅ Sample application found"
    
    # Test if it can be built
    cd sample-app
    if npm install --dry-run &> /dev/null; then
        echo "✅ Sample app dependencies can be installed"
    else
        echo "❌ Sample app has dependency issues"
    fi
    cd ..
else
    echo "❌ Sample application not found"
fi

echo ""
echo "🎯 Summary:"
echo "If all services show ✅, your environment is ready!"
echo "If any show ❌, check the troubleshooting section in the lesson guide."
echo ""
echo "📚 Next steps:"
echo "1. Follow the lesson guide in harness-ci-cd-realistic.md"
echo "2. Start with Jenkins setup and pipeline creation"
echo "3. Integrate GitLab and SonarQube"
echo ""
echo "✨ Happy learning!"

