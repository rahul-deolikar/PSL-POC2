(cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF'
diff --git a/poc3/README.md b/poc3/README.md
--- a/poc3/README.md
+++ b/poc3/README.md
@@ -0,0 +1,450 @@
+# POC3 - Complete CI/CD Pipeline Implementation
+
+[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/your-org/poc3) [![Security Scan](https://img.shields.io/badge/security-scanned-blue)](https://github.com/your-org/poc3) [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
+
+A comprehensive **Proof of Concept (POC3)** demonstrating a complete CI/CD pipeline with multiple technology stacks, security scanning, and deployment to AWS ECS. This project showcases enterprise-grade DevOps practices including SAST, DAST, SCA, artifact management, and automated deployment.
+
+## 🏗️ Architecture Overview
+
+```
+┌─────────────────────────────────────────────────────────────────────────────────┐
+│                                    POC3 Architecture                            │
+├─────────────────────────────────────────────────────────────────────────────────┤
+│                                                                                 │
+│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
+│  │ Node.js/    │    │ Python      │    │ Java        │    │ .NET Core   │     │
+│  │ React       │    │ FastAPI     │    │ Spring Boot │    │ Web API     │     │
+│  │ (Port 3000) │    │ (Port 8000) │    │ (Port 8080) │    │ (Port 5000) │     │
+│  └─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘     │
+│         │                   │                   │                   │          │
+│         └───────────────────┼───────────────────┼───────────────────┘          │
+│                             │                   │                              │
+│  ┌─────────────────────────────────────────────────────────────────────────┐   │
+│  │                        CI/CD Pipeline                                  │   │
+│  │                                                                         │   │
+│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │   │
+│  │  │ GitHub/ │  │TeamCity │  │Security │  │Artifact │  │Octopus  │     │   │
+│  │  │ GitLab  │  │   CI    │  │ Scans   │  │Storage  │  │ Deploy  │     │   │
+│  │  │         │  │         │  │         │  │         │  │         │     │   │
+│  │  │• Source │  │• Build  │  │• SAST   │  │• ECR    │  │• CD     │     │   │
+│  │  │• VCS    │  │• Test   │  │• DAST   │  │• JFrog  │  │• ECS    │     │   │
+│  │  │         │  │• Package│  │• SCA    │  │• S3     │  │• Deploy │     │   │
+│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘     │   │
+│  └─────────────────────────────────────────────────────────────────────────┘   │
+│                                      │                                         │
+│  ┌─────────────────────────────────────────────────────────────────────────┐   │
+│  │                        AWS ECS Cluster                                  │   │
+│  │                                                                         │   │
+│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐                   │   │
+│  │  │ ECS     │  │ ECR     │  │ ALB     │  │CloudWch │                   │   │
+│  │  │Services │  │Registry │  │LoadBlnc │  │ Logs    │                   │   │
+│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘                   │   │
+│  └─────────────────────────────────────────────────────────────────────────┘   │
+└─────────────────────────────────────────────────────────────────────────────────┘
+```
+
+## 🚀 Technology Stack
+
+### **Applications (Hello World Services)**
+- **Node.js + React** - Frontend + REST API (Port 3000)
+- **Python FastAPI** - REST API with OpenAPI docs (Port 8000)
+- **Java Spring Boot** - Microservice with Actuator (Port 8080)
+- **.NET Core Web API** - REST API with Swagger (Port 5000)
+
+### **CI/CD Pipeline**
+- **Source Control**: GitHub/GitLab
+- **CI**: TeamCity build automation
+- **Security**: SonarQube (SAST), CodeQL (SAST), OWASP ZAP (DAST), Dependency Check (SCA)
+- **Artifacts**: Amazon ECR, JFrog Artifactory, S3
+- **CD**: Octopus Deploy
+- **Target**: AWS ECS on EC2
+
+### **Infrastructure**
+- **Container Orchestration**: Amazon ECS
+- **Compute**: EC2 instances
+- **Load Balancing**: Application Load Balancer
+- **Monitoring**: CloudWatch
+- **IaC**: Terraform
+
+## 📁 Project Structure
+
+```
+poc3/
+├── applications/                    # Hello World Applications
+│   ├── nodejs-react/               # Node.js + React app
+│   │   ├── package.json
+│   │   ├── server.js
+│   │   ├── public/index.html
+│   │   └── Dockerfile
+│   ├── python-fastapi/             # Python FastAPI service
+│   │   ├── main.py
+│   │   ├── requirements.txt
+│   │   ├── test_main.py
+│   │   └── Dockerfile
+│   ├── java-springboot/            # Java Spring Boot service
+│   │   ├── pom.xml
+│   │   ├── src/main/java/
+│   │   ├── src/main/resources/
+│   │   └── Dockerfile
+│   └── dotnet-webapi/              # .NET Core Web API
+│       ├── Program.cs
+│       ├── *.csproj
+│       ├── appsettings.json
+│       └── Dockerfile
+├── teamcity/                       # TeamCity CI Configuration
+│   ├── project-settings/
+│   └── build-configs/
+├── security/                       # Security Scanning Configuration
+│   ├── sonarqube/
+│   ├── codeql/
+│   ├── owasp-zap/
+│   └── dependency-check/
+├── artifacts/                      # Artifact Storage Configuration
+│   ├── ecr/
+│   ├── artifactory/
+│   └── s3/
+├── octopus/                        # Octopus Deploy Configuration
+│   ├── projects/
+│   ├── environments/
+│   └── deployments/
+├── infrastructure/                 # Enhanced Infrastructure
+│   ├── terraform/
+│   └── docker/
+└── docs/                          # Documentation
+```
+
+## 🛠️ Setup Instructions
+
+### **Prerequisites**
+
+- **AWS Account** with appropriate permissions
+- **Docker** installed locally
+- **Terraform** >= 1.0
+- **AWS CLI** configured
+- **TeamCity** server setup
+- **Octopus Deploy** instance
+- **Git** repository (GitHub/GitLab)
+
+### **1. Clone the Repository**
+
+```bash
+git clone https://github.com/your-org/poc3.git
+cd poc3
+```
+
+### **2. Infrastructure Setup**
+
+```bash
+# Set up S3 backend for Terraform
+chmod +x scripts/setup-s3-backend.sh
+./scripts/setup-s3-backend.sh
+
+# Configure variables
+cp terraform.tfvars.example terraform.tfvars
+# Edit terraform.tfvars with your settings
+
+# Deploy infrastructure
+chmod +x scripts/deploy.sh
+./scripts/deploy.sh deploy
+```
+
+### **3. Configure CI/CD Tools**
+
+#### **TeamCity Setup**
+1. Import project configuration from `teamcity/project-settings/`
+2. Configure VCS roots for your Git repository
+3. Set up build agents with required tools
+4. Configure parameters and secrets
+
+#### **Security Tools Setup**
+1. **SonarQube**: Configure server and import `security/sonarqube/sonar-project.properties`
+2. **CodeQL**: Set up GitHub Actions with `security/codeql/codeql-config.yml`
+3. **OWASP ZAP**: Configure scanning with `security/owasp-zap/zap-baseline-config.conf`
+4. **Dependency Check**: Use configuration from `security/dependency-check/`
+
+#### **Octopus Deploy Setup**
+1. Import project from `octopus/projects/poc3-project-config.json`
+2. Configure environments (Development, Staging, Production)
+3. Set up deployment targets (ECS cluster)
+4. Configure variables and AWS integration
+
+### **4. Build and Deploy Applications**
+
+#### **Local Development**
+```bash
+# Node.js/React
+cd poc3/applications/nodejs-react
+npm install
+npm start
+
+# Python FastAPI
+cd ../python-fastapi
+pip install -r requirements.txt
+uvicorn main:app --reload
+
+# Java Spring Boot
+cd ../java-springboot
+mvn spring-boot:run
+
+# .NET Core
+cd ../dotnet-webapi
+dotnet run
+```
+
+#### **Docker Build**
+```bash
+# Build all applications
+for app in nodejs-react python-fastapi java-springboot dotnet-webapi; do
+    cd poc3/applications/$app
+    docker build -t poc3-$app .
+    cd ../../..
+done
+```
+
+#### **Deploy via CI/CD**
+1. Push code changes to trigger TeamCity builds
+2. Monitor security scans and artifact creation
+3. Release via Octopus Deploy to ECS
+
+## 🔒 Security Scanning
+
+### **Static Application Security Testing (SAST)**
+- **SonarQube**: Code quality, security hotspots, vulnerabilities
+- **CodeQL**: Advanced semantic analysis for security issues
+
+### **Dynamic Application Security Testing (DAST)**
+- **OWASP ZAP**: Runtime security testing against live applications
+
+### **Software Composition Analysis (SCA)**
+- **OWASP Dependency Check**: Known vulnerabilities in dependencies
+- **Snyk**: Advanced dependency and container scanning
+
+### **Security Reports**
+All security scans generate reports in multiple formats:
+- JSON for programmatic processing
+- HTML for human review
+- SARIF for integration with security tools
+
+## 📦 Artifact Management
+
+### **Container Images**
+- **Amazon ECR**: Production container registry
+- Multi-architecture support
+- Vulnerability scanning
+- Lifecycle policies
+
+### **Build Artifacts**
+- **JFrog Artifactory**: Binary artifact repository
+- **S3 Buckets**: Static asset storage
+- Version management and retention policies
+
+## 🚀 Deployment Pipeline
+
+### **Environments**
+1. **Development**: Auto-deploy on commit to `develop` branch
+2. **Staging**: Manual promotion with automated testing
+3. **Production**: Approval-gated deployment with rollback capability
+
+### **Deployment Strategy**
+- **Blue-Green**: Zero-downtime deployments
+- **Health Checks**: Automated service health verification
+- **Rollback**: Automatic rollback on failure detection
+
+### **Monitoring**
+- **CloudWatch**: Logs and metrics collection
+- **Application Health**: Endpoint monitoring
+- **Performance**: Response time and throughput tracking
+
+## 🔄 CI/CD Workflow
+
+```mermaid
+graph TB
+    A[Code Commit] --> B[TeamCity Build]
+    B --> C[Unit Tests]
+    C --> D[Security Scans]
+    D --> E{Security Pass?}
+    E -->|Yes| F[Build Docker Images]
+    E -->|No| G[Block Deployment]
+    F --> H[Push to ECR]
+    H --> I[Store Artifacts]
+    I --> J[Octopus Release]
+    J --> K[Deploy to Dev]
+    K --> L[Integration Tests]
+    L --> M{Tests Pass?}
+    M -->|Yes| N[Deploy to Staging]
+    M -->|No| O[Rollback]
+    N --> P[Manual Approval]
+    P --> Q[Deploy to Production]
+    Q --> R[Health Checks]
+    R --> S{Health OK?}
+    S -->|Yes| T[Complete]
+    S -->|No| U[Auto Rollback]
+```
+
+## 📊 Service Endpoints
+
+After successful deployment, access the services:
+
+| Service | Port | Health Check | API Docs |
+|---------|------|--------------|----------|
+| **Node.js/React** | 3000 | `/health` | `/api/info` |
+| **Python FastAPI** | 8000 | `/health` | `/docs` |
+| **Java Spring Boot** | 8080 | `/actuator/health` | `/actuator` |
+| **.NET Core Web API** | 5000 | `/health` | `/swagger` |
+
+### **Load Balancer Endpoints**
+```
+http://your-alb-dns:3000  # Node.js/React
+http://your-alb-dns:8000  # Python FastAPI  
+http://your-alb-dns:8080  # Java Spring Boot
+http://your-alb-dns:5000  # .NET Core
+```
+
+## 🧪 Testing
+
+### **Local Testing**
+```bash
+# Run all application tests
+./scripts/run-tests.sh
+
+# Security scans
+./scripts/security-scan.sh
+
+# Integration tests
+./scripts/integration-tests.sh
+```
+
+### **Pipeline Testing**
+- **Unit Tests**: Automated per application
+- **Integration Tests**: Cross-service API testing
+- **Security Tests**: SAST, DAST, SCA validation
+- **Performance Tests**: Load testing via JMeter
+- **Health Checks**: Post-deployment verification
+
+## 📈 Monitoring and Observability
+
+### **Metrics**
+- Application performance metrics
+- Infrastructure utilization
+- Security scan results
+- Deployment success rates
+
+### **Logging**
+- Centralized logging via CloudWatch
+- Structured logging format
+- Log aggregation and analysis
+
+### **Alerting**
+- Failed deployments
+- Security vulnerabilities
+- Application health issues
+- Resource threshold breaches
+
+## 🛡️ Security Considerations
+
+### **Container Security**
+- Non-root user execution
+- Minimal base images
+- Security scanning in pipeline
+- Resource limitations
+
+### **Network Security**
+- VPC isolation
+- Security groups
+- ALB SSL termination
+- Private subnets for ECS
+
+### **Access Control**
+- IAM roles and policies
+- Least privilege principle
+- Service-to-service authentication
+- Secrets management
+
+## 🔧 Troubleshooting
+
+### **Common Issues**
+
+1. **Build Failures**
+   ```bash
+   # Check TeamCity logs
+   # Verify dependencies
+   # Review security scan results
+   ```
+
+2. **Deployment Issues**
+   ```bash
+   # Check ECS service status
+   aws ecs describe-services --cluster poc3-ecs-cluster --services poc3-nodejs-react
+   
+   # Review CloudWatch logs
+   aws logs get-log-events --log-group-name /ecs/poc3-nodejs-react
+   ```
+
+3. **Health Check Failures**
+   ```bash
+   # Test service endpoints
+   curl -f http://your-alb:3000/health
+   
+   # Check container logs
+   docker logs container-id
+   ```
+
+### **Debug Commands**
+```bash
+# Infrastructure status
+terraform output
+
+# ECS cluster status
+aws ecs describe-clusters --clusters poc3-ecs-cluster
+
+# Load balancer status
+aws elbv2 describe-load-balancers
+
+# Security group rules
+aws ec2 describe-security-groups --group-ids sg-xxxxx
+```
+
+## 🔄 Maintenance
+
+### **Regular Tasks**
+- Security vulnerability updates
+- Dependency updates
+- Infrastructure patches
+- Performance optimization
+
+### **Backup and Recovery**
+- Database backups (if applicable)
+- Configuration backups
+- Infrastructure state backups
+- Disaster recovery procedures
+
+## 📚 Additional Resources
+
+- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
+- [TeamCity Documentation](https://www.jetbrains.com/help/teamcity/)
+- [Octopus Deploy Documentation](https://octopus.com/docs)
+- [OWASP Security Guides](https://owasp.org/)
+- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/)
+
+## 🤝 Contributing
+
+1. Fork the repository
+2. Create a feature branch (`git checkout -b feature/amazing-feature`)
+3. Commit your changes (`git commit -m 'Add amazing feature'`)
+4. Push to the branch (`git push origin feature/amazing-feature`)
+5. Open a Pull Request
+
+## 📄 License
+
+This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
+
+## 📞 Support
+
+For support and questions:
+- 📧 Email: poc3-team@your-company.com
+- 💬 Slack: #poc3-support
+- 📝 Issues: [GitHub Issues](https://github.com/your-org/poc3/issues)
+
+---
+
+**POC3 Team** | **Built with ❤️ for Enterprise DevOps**
EOF
)
