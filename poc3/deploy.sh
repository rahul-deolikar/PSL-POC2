#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
AWS_REGION="us-west-2"
PROJECT_NAME="hello-world-cicd"
GITHUB_REPO="your-org/hello-world-cicd"

echo -e "${GREEN}🚀 Starting TeamCity CI/CD Pipeline Deployment${NC}"
echo "================================================="

# Function to print status
print_status() {
    echo -e "${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure'."
    exit 1
fi

print_success "All prerequisites met!"

# Generate SSH key if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    print_status "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    print_success "SSH key generated!"
fi

# Deploy infrastructure with Terraform
print_status "Deploying AWS infrastructure with Terraform..."
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var="project_name=${PROJECT_NAME}" -var="aws_region=${AWS_REGION}"

# Apply the infrastructure
terraform apply -auto-approve -var="project_name=${PROJECT_NAME}" -var="aws_region=${AWS_REGION}"

# Get outputs
TEAMCITY_IP=$(terraform output -raw teamcity_public_ip)
ECR_REGISTRY=$(aws ecr describe-registry --query 'registryId' --output text).dkr.ecr.${AWS_REGION}.amazonaws.com
ECS_CLUSTER=$(terraform output -raw ecs_cluster_name)
S3_BUCKET=$(terraform output -raw s3_artifacts_bucket)

cd ../..

print_success "Infrastructure deployed successfully!"
echo "TeamCity URL: http://${TEAMCITY_IP}:8111"

# Wait for TeamCity to be ready
print_status "Waiting for TeamCity to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -f -s "http://${TEAMCITY_IP}:8111" > /dev/null; then
        break
    fi
    echo "Waiting... (attempt $((attempt + 1))/${max_attempts})"
    sleep 30
    ((attempt++))
done

if [ $attempt -eq $max_attempts ]; then
    print_error "TeamCity did not become ready in time. Please check manually."
    exit 1
fi

print_success "TeamCity is ready!"

# Create ECR repositories and get login
print_status "Setting up ECR repositories..."
for app in nodejs-hello-world python-hello-world java-hello-world dotnet-hello-world; do
    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}
done

print_success "ECR setup complete!"

# Build and push Docker images
print_status "Building and pushing Docker images..."

# Node.js application
print_status "Building Node.js application..."
cd applications/nodejs-react
docker build -t nodejs-hello-world:latest .
docker tag nodejs-hello-world:latest ${ECR_REGISTRY}/nodejs-hello-world:latest
docker push ${ECR_REGISTRY}/nodejs-hello-world:latest
cd ../..

# Python application
print_status "Building Python application..."
cd applications/python-fastapi
docker build -t python-hello-world:latest .
docker tag python-hello-world:latest ${ECR_REGISTRY}/python-hello-world:latest
docker push ${ECR_REGISTRY}/python-hello-world:latest
cd ../..

# Java application
print_status "Building Java application..."
cd applications/java-springboot
docker build -t java-hello-world:latest .
docker tag java-hello-world:latest ${ECR_REGISTRY}/java-hello-world:latest
docker push ${ECR_REGISTRY}/java-hello-world:latest
cd ../..

# .NET application
print_status "Building .NET application..."
cd applications/dotnet-webapi
docker build -t dotnet-hello-world:latest .
docker tag dotnet-hello-world:latest ${ECR_REGISTRY}/dotnet-hello-world:latest
docker push ${ECR_REGISTRY}/dotnet-hello-world:latest
cd ../..

print_success "All Docker images built and pushed!"

# Create ECS task definitions
print_status "Creating ECS task definitions..."

for app in nodejs python java dotnet; do
    case $app in
        nodejs) port=3000; image_suffix="nodejs-hello-world" ;;
        python) port=8000; image_suffix="python-hello-world" ;;
        java) port=8080; image_suffix="java-hello-world" ;;
        dotnet) port=80; image_suffix="dotnet-hello-world" ;;
    esac

    cat > ${app}-task-definition.json << EOF
{
  "family": "${app}-hello-world",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/${PROJECT_NAME}-ecs-task-execution-role",
  "containerDefinitions": [
    {
      "name": "${app}-hello-world",
      "image": "${ECR_REGISTRY}/${image_suffix}:latest",
      "portMappings": [
        {
          "containerPort": ${port},
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/${PROJECT_NAME}",
          "awslogs-region": "${AWS_REGION}",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:${port}/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      }
    }
  ]
}
EOF

    aws ecs register-task-definition --cli-input-json file://${app}-task-definition.json
    rm ${app}-task-definition.json
done

print_success "ECS task definitions created!"

# Create environment configuration file
print_status "Creating environment configuration..."

cat > .env << EOF
# AWS Configuration
AWS_REGION=${AWS_REGION}
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Project Configuration
PROJECT_NAME=${PROJECT_NAME}
ENVIRONMENT=dev

# TeamCity Configuration
TEAMCITY_URL=http://${TEAMCITY_IP}:8111
TEAMCITY_IP=${TEAMCITY_IP}

# ECR Configuration
ECR_REGISTRY=${ECR_REGISTRY}

# ECS Configuration
ECS_CLUSTER=${ECS_CLUSTER}

# S3 Configuration
S3_ARTIFACTS_BUCKET=${S3_BUCKET}

# Repository Configuration
GITHUB_REPO=${GITHUB_REPO}
EOF

print_success "Environment configuration created!"

# Create deployment summary
print_status "Creating deployment summary..."

cat > DEPLOYMENT_SUMMARY.md << EOF
# TeamCity CI/CD Pipeline Deployment Summary

## 🎉 Deployment Completed Successfully!

### Infrastructure Details

| Component | Details |
|-----------|---------|
| **TeamCity Server** | http://${TEAMCITY_IP}:8111 |
| **AWS Region** | ${AWS_REGION} |
| **ECS Cluster** | ${ECS_CLUSTER} |
| **ECR Registry** | ${ECR_REGISTRY} |
| **S3 Artifacts Bucket** | ${S3_BUCKET} |

### Applications Deployed

1. **Node.js/Express API** - Port 3000
   - Image: \`${ECR_REGISTRY}/nodejs-hello-world:latest\`
   - Endpoint: \`GET /api/hello\`

2. **Python FastAPI** - Port 8000
   - Image: \`${ECR_REGISTRY}/python-hello-world:latest\`
   - Endpoint: \`GET /api/hello\`
   - Documentation: \`GET /docs\`

3. **Java Spring Boot** - Port 8080
   - Image: \`${ECR_REGISTRY}/java-hello-world:latest\`
   - Endpoint: \`GET /api/hello\`
   - Documentation: \`GET /swagger-ui.html\`

4. **.NET Core Web API** - Port 80
   - Image: \`${ECR_REGISTRY}/dotnet-hello-world:latest\`
   - Endpoint: \`GET /api/hello\`
   - Documentation: \`GET /swagger\`

### Next Steps

1. **Configure TeamCity:**
   - Access TeamCity at http://${TEAMCITY_IP}:8111
   - Complete initial setup wizard
   - Import build configurations from \`teamcity/build-configs/\`

2. **Setup Source Control:**
   - Push code to your Git repository
   - Configure VCS roots in TeamCity

3. **Configure Security Scanning:**
   - Setup SonarQube server
   - Configure OWASP tools
   - Enable security gates

4. **Setup Octopus Deploy:**
   - Install Octopus Deploy
   - Configure deployment projects
   - Link with TeamCity builds

5. **Deploy to ECS:**
   - Create ECS services using the task definitions
   - Configure load balancers
   - Setup monitoring and alerts

### Useful Commands

\`\`\`bash
# View TeamCity logs
ssh -i ~/.ssh/id_rsa ubuntu@${TEAMCITY_IP}
docker logs teamcity-server

# Push to ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Deploy to ECS
aws ecs create-service --cluster ${ECS_CLUSTER} --service-name hello-world-service --task-definition nodejs-hello-world

# Check ECS status
aws ecs describe-services --cluster ${ECS_CLUSTER} --services hello-world-service
\`\`\`

### Security Considerations

- Update default passwords
- Configure proper IAM roles and policies  
- Enable VPC flow logs
- Setup CloudTrail for auditing
- Configure backup strategies
EOF

print_success "Deployment summary created!"

# Final output
echo ""
echo "================================================="
print_success "🎉 TeamCity CI/CD Pipeline Deployment Complete!"
echo "================================================="
echo ""
echo "📋 Key Information:"
echo "   TeamCity URL: http://${TEAMCITY_IP}:8111"
echo "   AWS Region: ${AWS_REGION}"
echo "   ECS Cluster: ${ECS_CLUSTER}"
echo ""
echo "📖 Next Steps:"
echo "   1. Review DEPLOYMENT_SUMMARY.md for detailed information"
echo "   2. Access TeamCity and complete initial setup"
echo "   3. Configure your build pipelines"
echo "   4. Setup security scanning tools"
echo "   5. Configure Octopus Deploy for CD"
echo ""
echo "🔧 Configuration files created:"
echo "   - .env (environment variables)"
echo "   - DEPLOYMENT_SUMMARY.md (deployment details)"
echo ""
print_success "Happy CI/CD-ing! 🚀"