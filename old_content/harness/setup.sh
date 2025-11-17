#!/bin/bash

# Harness CI/CD Lesson Setup Script
# This script helps participants set up the Harness environment quickly

set -e

echo "🚀 Setting up Modern CI/CD Learning Environment"
echo "==============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if Git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    echo "✅ .env file created with default local learning configuration"
    echo "   - No external accounts or licenses required"
    echo "   - All services will run locally in Docker containers"
else
    echo "✅ .env file already exists"
fi

# Check if Kubernetes is available
if command -v kubectl &> /dev/null; then
    if kubectl cluster-info &> /dev/null; then
        echo "✅ Kubernetes cluster is available"
    else
        echo "⚠️  Kubernetes cluster is not accessible. Make sure Docker Desktop Kubernetes is enabled."
    fi
else
    echo "⚠️  kubectl is not installed. Install kubectl for Kubernetes deployments."
fi

echo ""
echo "🎯 Next Steps:"
echo "1. Run: docker-compose up -d"
echo "2. Access services:"
echo "   - Jenkins: http://localhost:8080"
echo "   - GitLab: http://localhost:8081"
echo "   - SonarQube: http://localhost:9000"
echo "3. Follow the lesson guide in harness-ci-cd-realistic.md"
echo ""
echo "📚 Lesson files:"
echo "- harness-ci-cd-realistic.md: Complete lesson content"
echo "- harness-ci-cd.md: Harness theory and concepts"
echo "- sample-app/: Sample application for practice"
echo ""
echo "🔧 Troubleshooting:"
echo "- Check service status: docker-compose ps"
echo "- View logs: docker-compose logs -f"
echo "- Stop services: docker-compose down"
echo ""
echo "✨ Setup complete! Happy learning!"
