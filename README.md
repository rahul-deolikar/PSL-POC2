# TeamCity CI/CD Pipeline - Complete Implementation

A comprehensive CI/CD pipeline implementation using TeamCity, featuring multi-technology hello world applications with security scanning, artifact management, and AWS ECS deployment.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Source Code   │───▶│   TeamCity CI    │───▶│   Artifacts     │
│ (GitHub/GitLab) │    │                  │    │ (ECR/S3/JFrog)  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │                        │
                                ▼                        ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Security Scans  │    │  Octopus Deploy  │    │   AWS ECS       │
│(SAST/DAST/SCA) │    │      (CD)        │───▶│(EC2/Fargate)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 📱 Applications Included

- **Node.js/Express** - REST API with health checks
- **Python FastAPI** - API with automatic documentation  
- **Java Spring Boot** - Microservice with Swagger
- **.NET Core** - Web API with health endpoints

## 🚀 Quick Start

### Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured (`aws configure`)
- Terraform >= 1.0
- Docker installed and running
- SSH key pair (`ssh-keygen -t rsa -b 4096`)

### One-Command Deployment

```bash
# Clone the repository
git clone <repository-url>
cd poc3

# Make deployment script executable
chmod +x deploy.sh

# Run complete deployment
./deploy.sh
```

This will:
1. ✅ Deploy AWS infrastructure (VPC, ECS, ECR, S3, TeamCity)
2. ✅ Build and push Docker images to ECR
3. ✅ Create ECS task definitions
4. ✅ Configure environment variables
5. ✅ Generate deployment summary

## 📋 Manual Setup (Step by Step)

### 1. Infrastructure Deployment

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Deploy infrastructure
terraform apply -var="project_name=hello-world-cicd" -var="aws_region=us-west-2"

# Get TeamCity IP
TEAMCITY_IP=$(terraform output -raw teamcity_public_ip)
echo "TeamCity URL: http://$TEAMCITY_IP:8111"
```

### 2. Application Setup

Build and test applications locally:

```bash
# Node.js application
cd applications/nodejs-react
npm install && npm test && npm start

# Python application  
cd ../python-fastapi
pip install -r requirements.txt && uvicorn main:app --reload

# Java application
cd ../java-springboot
./mvnw spring-boot:run

# .NET application
cd ../dotnet-webapi
dotnet run
```

### 3. Docker Images

Build and push to ECR:

```bash
# Get ECR login
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-west-2.amazonaws.com

# Build and push each application
for app in nodejs-react python-fastapi java-springboot dotnet-webapi; do
    cd applications/$app
    docker build -t $app .
    docker tag $app:latest <ecr-registry>/$app:latest
    docker push <ecr-registry>/$app:latest
    cd ../..
done
```

### 4. TeamCity Configuration

1. Access TeamCity at `http://<teamcity-ip>:8111`
2. Complete initial setup wizard
3. Import build configurations:
   ```bash
   # Copy build configurations
   scp -r teamcity/build-configs/* ubuntu@<teamcity-ip>:/opt/teamcity/data/config/
   ```

### 5. Security Scanning Setup

#### SonarQube
```bash
# Deploy SonarQube (optional)
docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
```

#### OWASP Tools
```bash
# Install OWASP Dependency Check
dependency-check --project "Hello World" --scan . --format ALL --out reports/

# Install OWASP ZAP for DAST
docker run -t owasp/zap2docker-stable zap-baseline.py -t http://your-app-url
```

### 6. Octopus Deploy Setup

```bash
# Install Octopus Deploy
# Follow official documentation for installation
# Configure deployment projects for each application
```

## 🔧 Configuration Files

### Environment Variables
```bash
# AWS Configuration
AWS_REGION=us-west-2
PROJECT_NAME=hello-world-cicd

# TeamCity
TEAMCITY_URL=http://<ip>:8111

# ECR
ECR_REGISTRY=<account>.dkr.ecr.us-west-2.amazonaws.com

# ECS
ECS_CLUSTER=hello-world-cicd-cluster
```

### TeamCity Build Parameters
```xml
<!-- Node.js Build Configuration -->
<param name="env.NODE_ENV" value="production" />
<param name="env.ECR_REGISTRY" value="%system.aws.ecr.registry%" />
<param name="sonar.projectKey" value="nodejs-hello-world" />
```

## 🔒 Security Features

### SAST (Static Application Security Testing)
- **SonarQube**: Code quality and security analysis
- **CodeQL**: GitHub's semantic code analysis
- **ESLint Security**: JavaScript security linting

### DAST (Dynamic Application Security Testing)  
- **OWASP ZAP**: Web application security testing
- **Burp Suite**: Professional security testing (optional)

### SCA (Software Composition Analysis)
- **OWASP Dependency Check**: Known vulnerability scanning
- **Snyk**: Dependency vulnerability management
- **npm audit**: Node.js dependency scanning

### Container Security
- **Trivy**: Container image vulnerability scanning
- **ECR Image Scanning**: AWS native scanning
- **Dockerfile Security**: Best practices enforcement

## 📊 Monitoring & Logging

### CloudWatch Integration
```bash
# View application logs
aws logs describe-log-groups --log-group-name-prefix "/ecs/hello-world"

# Real-time log streaming
aws logs tail /ecs/hello-world-cicd --follow
```

### Health Checks
All applications include health check endpoints:
- **Node.js**: `GET /health`
- **Python**: `GET /health`  
- **Java**: `GET /actuator/health`
- **.NET**: `GET /health`

## 🚀 Deployment Options

### ECS Fargate (Serverless)
```bash
aws ecs create-service \
  --cluster hello-world-cicd-cluster \
  --service-name hello-world-fargate \
  --task-definition nodejs-hello-world \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx]}"
```

### ECS EC2 (Container Instances)
```bash
aws ecs create-service \
  --cluster hello-world-cicd-cluster \
  --service-name hello-world-ec2 \
  --task-definition nodejs-hello-world \
  --desired-count 2 \
  --launch-type EC2
```

## 🧪 Testing

### Local Testing
```bash
# Test all applications
cd applications && find . -name "package.json" -execdir npm test \;
cd applications && find . -name "requirements.txt" -execdir python -m pytest \;
cd applications && find . -name "pom.xml" -execdir mvn test \;
cd applications && find . -name "*.csproj" -execdir dotnet test \;
```

### Integration Testing
```bash
# Test deployed applications
curl http://<alb-dns>/api/hello
curl http://<alb-dns>/health
```

## 📚 Documentation

- [TeamCity Documentation](./docs/teamcity-setup.md)
- [Security Scanning Guide](./docs/security-scanning.md)
- [Deployment Guide](./docs/deployment.md)
- [Troubleshooting](./docs/troubleshooting.md)

## 🛠️ Troubleshooting

### Common Issues

**TeamCity not accessible:**
```bash
# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxx

# Check TeamCity logs
ssh ubuntu@<teamcity-ip> "docker logs teamcity-server"
```

**ECR push failures:**
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <registry>
```

**ECS task failures:**
```bash
# Check task logs
aws ecs describe-tasks --cluster <cluster> --tasks <task-arn>
aws logs get-log-events --log-group-name "/ecs/hello-world-cicd"
```

## 🔄 Continuous Updates

### Pipeline Maintenance
- Regular security updates for base images
- Dependency updates and vulnerability patching
- Infrastructure state management with Terraform
- Backup and disaster recovery procedures

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/new-feature`)
3. Commit changes (`git commit -am 'Add new feature'`)
4. Push to branch (`git push origin feature/new-feature`)
5. Create Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Create an issue in the repository
- Check the troubleshooting guide
- Review AWS and TeamCity documentation

---

**Built with ❤️ for modern DevOps practices**
