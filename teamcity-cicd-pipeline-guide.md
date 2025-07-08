# TeamCity CI/CD Pipeline Implementation Guide

## Overview
Complete guide for implementing a TeamCity CI/CD pipeline with multi-technology hello world applications, security scanning, artifact management, and deployment to AWS ECS.

## 1. AWS TeamCity Instance Setup

### 1.1 Launch TeamCity EC2 Instance
```bash
# Create TeamCity instance with Terraform
resource "aws_instance" "teamcity_server" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 20.04 LTS
  instance_type = "t3.large"
  key_name      = "teamcity-key"
  
  vpc_security_group_ids = [aws_security_group.teamcity_sg.id]
  subnet_id              = aws_subnet.public_subnet.id
  
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io docker-compose
    systemctl start docker
    systemctl enable docker
    
    # Install TeamCity
    docker run -d --name teamcity-server \
      -p 8111:8111 \
      -v teamcity_data:/data/teamcity_server/datadir \
      -v teamcity_logs:/opt/teamcity/logs \
      jetbrains/teamcity-server
  EOF
  
  tags = {
    Name = "TeamCity-Server"
  }
}
```

### 1.2 Security Group Configuration
```hcl
resource "aws_security_group" "teamcity_sg" {
  name_prefix = "teamcity-sg"
  
  ingress {
    from_port   = 8111
    to_port     = 8111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## 2. Hello World Applications

### 2.1 Node.js/React Application
```javascript
// server.js
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/api/hello', (req, res) => {
  res.json({ message: 'Hello World from Node.js!' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

```json
// package.json
{
  "name": "nodejs-hello-world",
  "version": "1.0.0",
  "scripts": {
    "start": "node server.js",
    "test": "jest"
  },
  "dependencies": {
    "express": "^4.18.0"
  },
  "devDependencies": {
    "jest": "^29.0.0"
  }
}
```

### 2.2 Python FastAPI Application
```python
# main.py
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class HelloResponse(BaseModel):
    message: str

@app.get("/api/hello", response_model=HelloResponse)
async def hello_world():
    return HelloResponse(message="Hello World from Python FastAPI!")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

```txt
# requirements.txt
fastapi==0.68.0
uvicorn==0.15.0
pytest==6.2.4
```

### 2.3 Java Spring Boot Application
```java
// Application.java
@SpringBootApplication
public class HelloWorldApplication {
    public static void main(String[] args) {
        SpringApplication.run(HelloWorldApplication.class, args);
    }
}

@RestController
@RequestMapping("/api")
public class HelloController {
    @GetMapping("/hello")
    public Map<String, String> hello() {
        return Map.of("message", "Hello World from Java Spring Boot!");
    }
}
```

### 2.4 .NET Core Application
```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddControllers();

var app = builder.Build();
app.MapControllers();

[ApiController]
[Route("api/[controller]")]
public class HelloController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { message = "Hello World from .NET Core!" });
    }
}

app.Run();
```

## 3. TeamCity Build Configurations

### 3.1 Node.js Build Configuration
```xml
<!-- Node.js Build Steps -->
<build-type>
  <name>NodeJS Hello World</name>
  <steps>
    <step name="Install Dependencies" type="Command Line">
      <param name="script.content">npm install</param>
    </step>
    <step name="Run Tests" type="Command Line">
      <param name="script.content">npm test</param>
    </step>
    <step name="Build Application" type="Command Line">
      <param name="script.content">npm run build</param>
    </step>
    <step name="SonarQube Scan" type="SonarQube Scanner">
      <param name="sonar.projectKey">nodejs-hello-world</param>
    </step>
    <step name="Docker Build" type="Command Line">
      <param name="script.content">
        docker build -t nodejs-hello-world:latest .
        docker tag nodejs-hello-world:latest ${ECR_REPO}/nodejs-hello-world:${BUILD_NUMBER}
      </param>
    </step>
  </steps>
</build-type>
```

### 3.2 Security Scanning Integration

#### SonarQube Configuration
```yaml
# sonar-project.properties
sonar.projectKey=hello-world-apps
sonar.projectName=Hello World Applications
sonar.projectVersion=1.0
sonar.sources=.
sonar.exclusions=**/node_modules/**,**/target/**,**/bin/**,**/obj/**
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.python.coverage.reportPaths=coverage.xml
sonar.java.coveragePlugin=jacoco
sonar.jacoco.reportPath=target/jacoco.exec
```

#### CodeQL Workflow
```yaml
# .github/workflows/codeql-analysis.yml
name: "CodeQL"
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  analyze:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        language: [ 'javascript', 'python', 'java', 'csharp' ]
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v3
    
    - name: Initialize CodeQL
      uses: github/codeql-action/init@v2
      with:
        languages: ${{ matrix.language }}
    
    - name: Perform CodeQL Analysis
      uses: github/codeql-action/analyze@v2
```

#### OWASP Dependency Check
```xml
<!-- TeamCity Build Step -->
<step name="OWASP Dependency Check" type="Command Line">
  <param name="script.content">
    dependency-check --project "Hello World Apps" \
    --scan . \
    --format ALL \
    --out reports/dependency-check/
  </param>
</step>
```

## 4. Artifact Management

### 4.1 Amazon ECR Setup
```hcl
resource "aws_ecr_repository" "app_repositories" {
  for_each = toset(["nodejs-hello", "python-hello", "java-hello", "dotnet-hello"])
  
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}
```

### 4.2 JFrog Artifactory Configuration
```yaml
# artifactory-config.yml
repositories:
  - key: hello-world-npm
    type: npm
    description: "NPM packages for Hello World apps"
  
  - key: hello-world-pypi
    type: pypi
    description: "Python packages for Hello World apps"
  
  - key: hello-world-maven
    type: maven
    description: "Maven artifacts for Hello World apps"
  
  - key: hello-world-nuget
    type: nuget
    description: "NuGet packages for Hello World apps"
```

### 4.3 S3 Bucket for Static Assets
```hcl
resource "aws_s3_bucket" "hello_world_artifacts" {
  bucket = "hello-world-artifacts-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_versioning" "hello_world_artifacts" {
  bucket = aws_s3_bucket.hello_world_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}
```

## 5. Octopus Deploy Configuration

### 5.1 Project Setup
```json
{
  "Name": "Hello World Applications",
  "ProjectGroupId": "ProjectGroups-1",
  "LifecycleId": "Lifecycles-1",
  "DeploymentProcessId": "deploymentprocess-hello-world-apps",
  "VariableSetId": "variableset-hello-world-apps"
}
```

### 5.2 Deployment Process
```json
{
  "Steps": [
    {
      "Name": "Deploy to ECS",
      "PackageRequirement": "LetOctopusDecide",
      "Actions": [
        {
          "ActionType": "Octopus.AwsRunTask",
          "Name": "Deploy Hello World Apps",
          "Properties": {
            "Octopus.Action.Aws.Region": "#{AWS.Region}",
            "Octopus.Action.Aws.EcsClusterName": "#{ECS.ClusterName}",
            "Octopus.Action.Aws.EcsServiceName": "#{ECS.ServiceName}",
            "Octopus.Action.Aws.EcsTaskDefinition": "#{ECS.TaskDefinition}"
          }
        }
      ]
    }
  ]
}
```

## 6. ECS Deployment Configuration

### 6.1 ECS Cluster Setup
```hcl
resource "aws_ecs_cluster" "hello_world_cluster" {
  name = "hello-world-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# EC2 Launch Configuration
resource "aws_ecs_capacity_provider" "ec2_capacity_provider" {
  name = "hello-world-ec2-capacity-provider"
  
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    
    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
    }
  }
}

# Fargate Alternative
resource "aws_ecs_service" "hello_world_fargate" {
  name            = "hello-world-fargate-service"
  cluster         = aws_ecs_cluster.hello_world_cluster.id
  task_definition = aws_ecs_task_definition.hello_world_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets         = [aws_subnet.private_subnet.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
}
```

### 6.2 Task Definitions
```json
{
  "family": "hello-world-apps",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nodejs-hello",
      "image": "#{ECR.Repository}/nodejs-hello:#{Octopus.Release.Number}",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/hello-world-apps",
          "awslogs-region": "us-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

## 7. Complete Pipeline Implementation

### 7.1 TeamCity Pipeline Script
```bash
#!/bin/bash
# complete-pipeline.sh

echo "Starting Complete CI/CD Pipeline"

# Build and Test
echo "Step 1: Building applications..."
cd applications/nodejs-react && npm install && npm test && npm run build
cd ../python-fastapi && pip install -r requirements.txt && pytest
cd ../java-springboot && mvn clean test package
cd ../dotnet-webapi && dotnet build && dotnet test

# Security Scanning
echo "Step 2: Running security scans..."
sonar-scanner
dependency-check --project "Hello World" --scan . --format ALL
owasp-zap-baseline.py -t http://localhost:3000

# Build Docker Images
echo "Step 3: Building Docker images..."
docker build -t nodejs-hello ./applications/nodejs-react
docker build -t python-hello ./applications/python-fastapi
docker build -t java-hello ./applications/java-springboot
docker build -t dotnet-hello ./applications/dotnet-webapi

# Push to ECR
echo "Step 4: Pushing to ECR..."
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${ECR_REGISTRY}
docker tag nodejs-hello:latest ${ECR_REGISTRY}/nodejs-hello:${BUILD_NUMBER}
docker push ${ECR_REGISTRY}/nodejs-hello:${BUILD_NUMBER}

# Trigger Octopus Deploy
echo "Step 5: Triggering deployment..."
octo create-release --project="Hello World Applications" --version=${BUILD_NUMBER} --server=${OCTOPUS_SERVER} --apiKey=${OCTOPUS_API_KEY}

echo "Pipeline completed successfully!"
```

## 8. Monitoring and Logging

### 8.1 CloudWatch Setup
```hcl
resource "aws_cloudwatch_log_group" "hello_world_logs" {
  name              = "/ecs/hello-world-apps"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "hello-world-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ecs cpu utilization"
  
  dimensions = {
    ServiceName = aws_ecs_service.hello_world_fargate.name
    ClusterName = aws_ecs_cluster.hello_world_cluster.name
  }
}
```

## Next Steps

1. **Initialize Infrastructure**: Deploy AWS resources using Terraform
2. **Setup TeamCity**: Configure build agents and projects
3. **Create Applications**: Implement hello world applications in each technology
4. **Configure Security**: Set up SonarQube, CodeQL, and OWASP tools
5. **Setup Artifacts**: Configure ECR, Artifactory, and S3
6. **Deploy Octopus**: Configure deployment processes
7. **Test Pipeline**: Run end-to-end pipeline validation
8. **Monitor**: Set up CloudWatch dashboards and alerts

This guide provides a complete foundation for implementing a robust CI/CD pipeline with TeamCity, covering all aspects from infrastructure to deployment.