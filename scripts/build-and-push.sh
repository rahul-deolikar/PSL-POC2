#!/bin/bash

# Build and Push Script for POC3 Applications
# This script builds Docker images and pushes them to ECR

set -e

# Configuration
AWS_REGION=${AWS_REGION:-us-west-2}
ECR_REGISTRY=${ECR_REGISTRY}
BUILD_NUMBER=${BUILD_NUMBER:-latest}

if [ -z "$ECR_REGISTRY" ]; then
    echo "❌ ECR_REGISTRY environment variable is required"
    echo "   Get it from: terraform output ecr_repository_urls"
    exit 1
fi

echo "🐳 POC3 - Build and Push Docker Images"
echo "======================================"
echo "AWS Region: $AWS_REGION"
echo "ECR Registry: $ECR_REGISTRY"
echo "Build Number: $BUILD_NUMBER"
echo ""

# Login to ECR
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Function to build and push image
build_and_push() {
    local app_name=$1
    local app_path=$2
    local dockerfile_path=${3:-Dockerfile}
    
    echo "🏗️  Building $app_name..."
    
    # Build image
    docker build -t $app_name:$BUILD_NUMBER -f $app_path/$dockerfile_path $app_path
    
    # Tag for ECR
    docker tag $app_name:$BUILD_NUMBER $ECR_REGISTRY/poc3-$app_name:$BUILD_NUMBER
    docker tag $app_name:$BUILD_NUMBER $ECR_REGISTRY/poc3-$app_name:latest
    
    # Push to ECR
    echo "📤 Pushing $app_name to ECR..."
    docker push $ECR_REGISTRY/poc3-$app_name:$BUILD_NUMBER
    docker push $ECR_REGISTRY/poc3-$app_name:latest
    
    echo "✅ $app_name pushed successfully"
    echo ""
}

# Build and push all applications
build_and_push "nodejs-api" "applications/nodejs-api"
build_and_push "reactjs-frontend" "applications/reactjs-frontend"
build_and_push "dotnet-api" "applications/dotnet-api"
build_and_push "java-api" "applications/java-api"
build_and_push "python-api" "applications/python-api"

echo "🎉 All images built and pushed successfully!"
echo ""
echo "Image tags:"
echo "  📦 $ECR_REGISTRY/poc3-nodejs-api:$BUILD_NUMBER"
echo "  📦 $ECR_REGISTRY/poc3-reactjs-frontend:$BUILD_NUMBER"
echo "  📦 $ECR_REGISTRY/poc3-dotnet-api:$BUILD_NUMBER"
echo "  📦 $ECR_REGISTRY/poc3-java-api:$BUILD_NUMBER"
echo "  📦 $ECR_REGISTRY/poc3-python-api:$BUILD_NUMBER"
echo ""
echo "Next steps:"
echo "  1. Trigger TeamCity builds or deploy manually"
echo "  2. Configure Octopus Deploy with these image tags"
echo "  3. Deploy to ECS (EC2 or Fargate)"