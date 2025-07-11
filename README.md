# POC3: Comprehensive CI/CD Pipeline

This POC demonstrates a complete DevOps pipeline with multiple technology stacks, security scanning, and cloud deployment.

## Project Structure

```
├── applications/
│   ├── nodejs-api/          # Node.js REST API
│   ├── reactjs-frontend/    # React.js Frontend
│   ├── dotnet-api/          # .NET Core API
│   ├── java-api/            # Java Spring Boot API
│   └── python-api/          # Python Flask API
├── infrastructure/
│   ├── aws/                 # AWS Infrastructure as Code
│   ├── docker/              # Docker configurations
│   └── terraform/           # Terraform scripts
├── pipeline/
│   ├── teamcity/           # TeamCity configurations
│   ├── octopus/            # Octopus Deploy configurations
│   └── security/           # Security scanning configurations
└── deployment/
    ├── ecs-ec2/            # ECS EC2 deployment configs
    └── ecs-fargate/        # ECS Fargate deployment configs
```

## Technologies Used

- **Frontend**: React.js
- **Backend APIs**: Node.js, .NET Core, Java Spring Boot, Python Flask
- **CI/CD**: TeamCity, Octopus Deploy
- **Security**: SonarQube, CodeQL, OWASP ZAP
- **Artifacts**: AWS S3, ECR, JFrog Artifactory
- **Infrastructure**: AWS ECS (EC2 & Fargate), Terraform
- **Source Control**: GitHub/GitLab

## Quick Start

1. Deploy infrastructure: `terraform apply`
2. Configure TeamCity pipeline
3. Set up Octopus Deploy
4. Deploy applications to ECS

## Security Scanning

- **SAST**: SonarQube, GitHub CodeQL
- **DAST**: OWASP ZAP
- **SCA**: Dependency scanning

## Deployment Targets

- AWS ECS with EC2 instances
- AWS ECS with Fargate