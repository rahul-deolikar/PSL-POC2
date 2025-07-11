#!/bin/bash

# POC3 Setup Script
# This script initializes the POC3 environment

set -e

echo "🚀 POC3 - Comprehensive CI/CD Pipeline Setup"
echo "=============================================="

# Check prerequisites
echo "📋 Checking prerequisites..."

command -v terraform >/dev/null 2>&1 || { echo "❌ Terraform is required but not installed. Aborting." >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI is required but not installed. Aborting." >&2; exit 1; }
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed. Aborting." >&2; exit 1; }

echo "✅ Prerequisites check passed"

# Set default values
AWS_REGION=${AWS_REGION:-us-west-2}
PROJECT_NAME=${PROJECT_NAME:-poc3}
ENVIRONMENT=${ENVIRONMENT:-dev}

echo "📝 Configuration:"
echo "   AWS Region: $AWS_REGION"
echo "   Project Name: $PROJECT_NAME"
echo "   Environment: $ENVIRONMENT"

# Check AWS credentials
echo "🔐 Checking AWS credentials..."
aws sts get-caller-identity > /dev/null || { echo "❌ AWS credentials not configured. Run 'aws configure' first." >&2; exit 1; }
echo "✅ AWS credentials verified"

# Initialize Terraform
echo "🏗️  Initializing Terraform..."
cd infrastructure/terraform
terraform init

# Plan infrastructure
echo "📋 Planning infrastructure deployment..."
terraform plan \
  -var="aws_region=$AWS_REGION" \
  -var="project_name=$PROJECT_NAME" \
  -var="environment=$ENVIRONMENT" \
  -out=tfplan

echo "🎯 Infrastructure plan created. Review the plan above."
echo ""
echo "To deploy the infrastructure, run:"
echo "  terraform apply tfplan"
echo ""
echo "To deploy applications:"
echo "  1. Build and push Docker images to ECR"
echo "  2. Configure TeamCity with the generated URLs"
echo "  3. Set up Octopus Deploy with the deployment processes"
echo "  4. Trigger the CI/CD pipeline"
echo ""
echo "🔧 Next steps:"
echo "  1. Review and apply Terraform plan"
echo "  2. Configure CI/CD tools (TeamCity, Octopus Deploy)"
echo "  3. Set up security scanning tools (SonarQube, OWASP ZAP)"
echo "  4. Test the complete pipeline"
echo ""
echo "📚 For detailed instructions, see README.md"