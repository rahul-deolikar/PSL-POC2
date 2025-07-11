# POC3 Deployment Guide

This guide provides step-by-step instructions for deploying the complete POC3 CI/CD pipeline.

## Prerequisites

Before starting, ensure you have the following tools installed:

- **AWS CLI** (v2.0+)
- **Terraform** (v1.0+)
- **Docker** (v20.0+)
- **Node.js** (v18+)
- **Java** (v17+)
- **Python** (v3.11+)
- **.NET SDK** (v8.0+)

## Infrastructure Deployment

### 1. Configure AWS Credentials

```bash
aws configure
# Provide your AWS Access Key ID, Secret Access Key, and default region
```

### 2. Deploy Infrastructure

```bash
# Make setup script executable
chmod +x deployment/setup.sh

# Run setup script
./deployment/setup.sh

# Apply Terraform plan
cd infrastructure/terraform
terraform apply tfplan
```

### 3. Note Important Outputs

After deployment, save these outputs for CI/CD configuration:

```bash
terraform output
```

Key outputs:
- ECR repository URLs
- ECS cluster name
- Load balancer DNS
- S3 bucket name
- IAM role ARNs

## Application Setup

### 1. Build and Test Applications Locally

#### Node.js API
```bash
cd applications/nodejs-api
npm install
npm test
npm start
```

#### React.js Frontend
```bash
cd applications/reactjs-frontend
npm install
npm test
npm run build
npm start
```

#### .NET API
```bash
cd applications/dotnet-api
dotnet restore
dotnet build
dotnet test
dotnet run
```

#### Java API
```bash
cd applications/java-api
mvn clean install
mvn spring-boot:run
```

#### Python API
```bash
cd applications/python-api
pip install -r requirements.txt
python app.py
```

### 2. Build and Push Docker Images

```bash
# Get ECR login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-registry-url>

# Build and push each application
./scripts/build-and-push.sh
```

## CI/CD Pipeline Setup

### 1. TeamCity Configuration

1. **Create New Project**
   - Import from VCS (GitHub/GitLab)
   - Use the configuration from `pipeline/teamcity/settings.kts`

2. **Configure Build Agents**
   - Install Docker on agents
   - Configure AWS credentials
   - Install required tools (Node.js, Java, .NET, Python)

3. **Set Environment Variables**
   ```
   AWS_REGION=us-west-2
   ECR_REGISTRY=<your-ecr-registry>
   S3_BUCKET=<your-s3-bucket>
   SONAR_HOST_URL=<your-sonarqube-url>
   SONAR_TOKEN=<your-sonar-token>
   ```

### 2. Octopus Deploy Configuration

1. **Create Project**
   - Import deployment processes from `pipeline/octopus/`
   - Configure environments (Development, Staging, Production)

2. **Set Variables**
   ```
   AWS.Region = us-west-2
   ECS.ClusterName = <your-cluster-name>
   ECS.TaskExecutionRoleArn = <task-execution-role-arn>
   ECS.TaskRoleArn = <task-role-arn>
   ECR.Registry = <your-ecr-registry>
   ```

3. **Configure Environments**
   - Add target machines/AWS accounts
   - Set environment-specific variables

## Security Scanning Setup

### 1. SonarQube Configuration

1. **Install SonarQube Server**
   ```bash
   docker run -d --name sonarqube -p 9000:9000 sonarqube:community
   ```

2. **Create Project**
   - Use configuration from `pipeline/security/sonar-project.properties`
   - Generate authentication token

3. **Configure Quality Gates**
   - Set code coverage thresholds
   - Configure security hotspot rules

### 2. OWASP ZAP DAST Scanning

1. **Configure ZAP Baseline Scan**
   ```bash
   docker run -t owasp/zap2docker-stable zap-baseline.py -t http://your-app-url
   ```

2. **Integrate with CI Pipeline**
   - Add to TeamCity build steps
   - Configure failure thresholds

## Deployment Targets

### 1. ECS EC2 Deployment

- Uses bridge networking
- Dynamic port mapping
- Auto Scaling Group managed instances
- Cost-effective for predictable workloads

### 2. ECS Fargate Deployment

- Serverless container execution
- awsvpc networking mode
- No infrastructure management
- Pay-per-use pricing

## Monitoring and Logging

### 1. CloudWatch Logs

All applications send logs to CloudWatch:
```
/ecs/poc3-nodejs-api
/ecs/poc3-reactjs-frontend
/ecs/poc3-dotnet-api
/ecs/poc3-java-api
/ecs/poc3-python-api
```

### 2. Application Load Balancer

- Health checks configured for all services
- Target group routing based on paths
- SSL termination (if configured)

## Testing the Pipeline

### 1. Trigger Builds

1. **Commit changes** to trigger individual service builds
2. **Verify security scans** pass quality gates
3. **Check artifact storage** in S3 and ECR
4. **Monitor deployment** progress in Octopus Deploy

### 2. Verify Deployment

1. **Check ECS Services**
   ```bash
   aws ecs list-services --cluster poc3-cluster
   aws ecs describe-services --cluster poc3-cluster --services <service-name>
   ```

2. **Test Applications**
   ```bash
   curl http://<load-balancer-dns>/
   curl http://<load-balancer-dns>/api/hello?name=POC3
   ```

## Troubleshooting

### Common Issues

1. **ECR Authentication**
   ```bash
   aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <registry>
   ```

2. **ECS Task Failures**
   - Check CloudWatch logs
   - Verify IAM permissions
   - Check security group rules

3. **Load Balancer Health Checks**
   - Ensure applications respond on health endpoints
   - Check target group settings

### Useful Commands

```bash
# Check ECS cluster status
aws ecs describe-clusters --clusters poc3-cluster

# View running tasks
aws ecs list-tasks --cluster poc3-cluster

# Check task logs
aws logs tail /ecs/poc3-nodejs-api --follow

# View load balancer status
aws elbv2 describe-load-balancers
```

## Security Considerations

1. **IAM Roles**: Use least-privilege principle
2. **Network Security**: Private subnets for applications
3. **Secrets Management**: Use AWS Secrets Manager or Parameter Store
4. **Image Scanning**: Enable ECR vulnerability scanning
5. **Security Groups**: Restrict access to necessary ports only

## Cost Optimization

1. **Fargate vs EC2**: Choose based on workload patterns
2. **Auto Scaling**: Configure based on metrics
3. **Reserved Instances**: For predictable EC2 workloads
4. **Lifecycle Policies**: Clean up old artifacts automatically

## Next Steps

1. **Add SSL/TLS**: Configure HTTPS listeners
2. **Custom Domains**: Route 53 for DNS management
3. **Advanced Monitoring**: CloudWatch dashboards and alarms
4. **Multi-Region**: Deploy across multiple AWS regions
5. **Blue-Green Deployment**: Advanced deployment strategies