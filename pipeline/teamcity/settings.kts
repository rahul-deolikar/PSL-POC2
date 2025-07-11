import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.buildFeatures.dockerSupport
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.*
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs
import jetbrains.buildServer.configs.kotlin.v2019_2.vcs.GitVcsRoot

version = "2019.2"

project {
    
    val vcsRoot = GitVcsRoot {
        id("POC3_GitHubRepo")
        name = "POC3 GitHub Repository"
        url = "https://github.com/your-org/poc3-project"
        branch = "refs/heads/main"
        branchSpec = "+:refs/heads/*"
        authMethod = token {
            userName = "oauth2"
            tokenId = "tc_token_id:CID_github_token"
        }
    }
    
    vcsRoot(vcsRoot)
    
    // Build configurations for each application
    buildType(NodeJSApiBuild)
    buildType(ReactJSFrontendBuild)
    buildType(DotNetApiBuild)
    buildType(JavaApiBuild)
    buildType(PythonApiBuild)
    
    // Security scanning builds
    buildType(SecurityScanBuild)
    
    // Deployment builds
    buildType(DeployToECSEC2)
    buildType(DeployToECSFargate)
}

object NodeJSApiBuild : BuildType({
    id("NodeJSApiBuild")
    name = "Node.js API Build"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        script {
            name = "Install Dependencies"
            workingDir = "applications/nodejs-api"
            scriptContent = """
                npm ci
                npm audit --audit-level=moderate
            """.trimIndent()
        }
        
        script {
            name = "Run Tests"
            workingDir = "applications/nodejs-api"
            scriptContent = """
                npm run test:coverage
                npm run lint
            """.trimIndent()
        }
        
        dockerCommand {
            name = "Build Docker Image"
            commandType = build {
                source = file {
                    path = "applications/nodejs-api/Dockerfile"
                }
                contextDir = "applications/nodejs-api"
                namesAndTags = "%env.ECR_REGISTRY%/poc3-nodejs-api:%build.number%"
            }
        }
        
        script {
            name = "Push to ECR"
            scriptContent = """
                aws ecr get-login-password --region %env.AWS_REGION% | docker login --username AWS --password-stdin %env.ECR_REGISTRY%
                docker push %env.ECR_REGISTRY%/poc3-nodejs-api:%build.number%
            """.trimIndent()
        }
        
        script {
            name = "Upload Artifacts to S3"
            scriptContent = """
                aws s3 cp applications/nodejs-api/package.json s3://%env.S3_BUCKET%/nodejs-api/%build.number%/
                aws s3 cp applications/nodejs-api/Dockerfile s3://%env.S3_BUCKET%/nodejs-api/%build.number%/
            """.trimIndent()
        }
    }
    
    triggers {
        vcs {
            triggerRules = "+:applications/nodejs-api/**"
        }
    }
    
    features {
        dockerSupport {
            cleanupPushedImages = true
        }
    }
    
    params {
        param("env.AWS_REGION", "us-west-2")
        param("env.ECR_REGISTRY", "%teamcity.aws.ecr.registry%")
        param("env.S3_BUCKET", "%teamcity.aws.s3.bucket%")
    }
})

object ReactJSFrontendBuild : BuildType({
    id("ReactJSFrontendBuild")
    name = "React.js Frontend Build"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        script {
            name = "Install Dependencies"
            workingDir = "applications/reactjs-frontend"
            scriptContent = """
                npm ci
                npm audit --audit-level=moderate
            """.trimIndent()
        }
        
        script {
            name = "Run Tests and Build"
            workingDir = "applications/reactjs-frontend"
            scriptContent = """
                npm run test:coverage
                npm run lint
                npm run build
            """.trimIndent()
        }
        
        dockerCommand {
            name = "Build Docker Image"
            commandType = build {
                source = file {
                    path = "applications/reactjs-frontend/Dockerfile"
                }
                contextDir = "applications/reactjs-frontend"
                namesAndTags = "%env.ECR_REGISTRY%/poc3-reactjs-frontend:%build.number%"
            }
        }
        
        script {
            name = "Push to ECR"
            scriptContent = """
                aws ecr get-login-password --region %env.AWS_REGION% | docker login --username AWS --password-stdin %env.ECR_REGISTRY%
                docker push %env.ECR_REGISTRY%/poc3-reactjs-frontend:%build.number%
            """.trimIndent()
        }
    }
    
    triggers {
        vcs {
            triggerRules = "+:applications/reactjs-frontend/**"
        }
    }
    
    features {
        dockerSupport {
            cleanupPushedImages = true
        }
    }
})

object DotNetApiBuild : BuildType({
    id("DotNetApiBuild")
    name = ".NET API Build"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        dotnetRestore {
            name = "Restore Dependencies"
            workingDir = "applications/dotnet-api"
        }
        
        dotnetBuild {
            name = "Build Project"
            workingDir = "applications/dotnet-api"
            configuration = "Release"
        }
        
        dotnetTest {
            name = "Run Tests"
            workingDir = "applications/dotnet-api"
            configuration = "Release"
        }
        
        dockerCommand {
            name = "Build Docker Image"
            commandType = build {
                source = file {
                    path = "applications/dotnet-api/Dockerfile"
                }
                contextDir = "applications/dotnet-api"
                namesAndTags = "%env.ECR_REGISTRY%/poc3-dotnet-api:%build.number%"
            }
        }
        
        script {
            name = "Push to ECR"
            scriptContent = """
                aws ecr get-login-password --region %env.AWS_REGION% | docker login --username AWS --password-stdin %env.ECR_REGISTRY%
                docker push %env.ECR_REGISTRY%/poc3-dotnet-api:%build.number%
            """.trimIndent()
        }
    }
    
    triggers {
        vcs {
            triggerRules = "+:applications/dotnet-api/**"
        }
    }
})

object JavaApiBuild : BuildType({
    id("JavaApiBuild")
    name = "Java API Build"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        maven {
            name = "Maven Build and Test"
            workingDir = "applications/java-api"
            goals = "clean compile test package"
            mavenVersion = bundled_3_6()
        }
        
        dockerCommand {
            name = "Build Docker Image"
            commandType = build {
                source = file {
                    path = "applications/java-api/Dockerfile"
                }
                contextDir = "applications/java-api"
                namesAndTags = "%env.ECR_REGISTRY%/poc3-java-api:%build.number%"
            }
        }
        
        script {
            name = "Push to ECR"
            scriptContent = """
                aws ecr get-login-password --region %env.AWS_REGION% | docker login --username AWS --password-stdin %env.ECR_REGISTRY%
                docker push %env.ECR_REGISTRY%/poc3-java-api:%build.number%
            """.trimIndent()
        }
    }
    
    triggers {
        vcs {
            triggerRules = "+:applications/java-api/**"
        }
    }
})

object PythonApiBuild : BuildType({
    id("PythonApiBuild")
    name = "Python API Build"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        script {
            name = "Setup Python Environment"
            workingDir = "applications/python-api"
            scriptContent = """
                python3 -m venv venv
                source venv/bin/activate
                pip install -r requirements.txt
            """.trimIndent()
        }
        
        script {
            name = "Run Tests and Security Checks"
            workingDir = "applications/python-api"
            scriptContent = """
                source venv/bin/activate
                pip install pytest pytest-cov bandit safety
                pytest --cov=app
                bandit -r app.py
                safety check
            """.trimIndent()
        }
        
        dockerCommand {
            name = "Build Docker Image"
            commandType = build {
                source = file {
                    path = "applications/python-api/Dockerfile"
                }
                contextDir = "applications/python-api"
                namesAndTags = "%env.ECR_REGISTRY%/poc3-python-api:%build.number%"
            }
        }
        
        script {
            name = "Push to ECR"
            scriptContent = """
                aws ecr get-login-password --region %env.AWS_REGION% | docker login --username AWS --password-stdin %env.ECR_REGISTRY%
                docker push %env.ECR_REGISTRY%/poc3-python-api:%build.number%
            """.trimIndent()
        }
    }
    
    triggers {
        vcs {
            triggerRules = "+:applications/python-api/**"
        }
    }
})

object SecurityScanBuild : BuildType({
    id("SecurityScanBuild")
    name = "Security Scanning"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        script {
            name = "SonarQube Analysis"
            scriptContent = """
                sonar-scanner \
                  -Dsonar.projectKey=poc3-project \
                  -Dsonar.sources=. \
                  -Dsonar.host.url=%env.SONAR_HOST_URL% \
                  -Dsonar.login=%env.SONAR_TOKEN%
            """.trimIndent()
        }
        
        script {
            name = "OWASP ZAP DAST Scan"
            scriptContent = """
                docker run -t owasp/zap2docker-stable zap-baseline.py -t http://localhost:3000 || true
            """.trimIndent()
        }
        
        script {
            name = "Dependency Scanning"
            scriptContent = """
                # Node.js dependencies
                cd applications/nodejs-api && npm audit --audit-level=moderate
                
                # Python dependencies
                cd ../python-api && pip install safety && safety check
                
                # .NET dependencies
                cd ../dotnet-api && dotnet list package --vulnerable
            """.trimIndent()
        }
    }
    
    triggers {
        vcs {}
    }
})

object DeployToECSEC2 : BuildType({
    id("DeployToECSEC2")
    name = "Deploy to ECS EC2"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        script {
            name = "Deploy via Octopus Deploy"
            scriptContent = """
                octo create-release \
                  --project="POC3-ECS-EC2" \
                  --version="%build.number%" \
                  --server="%env.OCTOPUS_SERVER_URL%" \
                  --apiKey="%env.OCTOPUS_API_KEY%" \
                  --deployto="Production"
            """.trimIndent()
        }
    }
    
    dependencies {
        dependency(NodeJSApiBuild) {
            snapshot {}
        }
        dependency(ReactJSFrontendBuild) {
            snapshot {}
        }
        dependency(DotNetApiBuild) {
            snapshot {}
        }
        dependency(JavaApiBuild) {
            snapshot {}
        }
        dependency(PythonApiBuild) {
            snapshot {}
        }
        dependency(SecurityScanBuild) {
            snapshot {}
        }
    }
})

object DeployToECSFargate : BuildType({
    id("DeployToECSFargate")
    name = "Deploy to ECS Fargate"
    
    vcs {
        root(DslContext.settingsRoot)
        cleanCheckout = true
    }
    
    steps {
        script {
            name = "Deploy via Octopus Deploy"
            scriptContent = """
                octo create-release \
                  --project="POC3-ECS-Fargate" \
                  --version="%build.number%" \
                  --server="%env.OCTOPUS_SERVER_URL%" \
                  --apiKey="%env.OCTOPUS_API_KEY%" \
                  --deployto="Production"
            """.trimIndent()
        }
    }
    
    dependencies {
        dependency(NodeJSApiBuild) {
            snapshot {}
        }
        dependency(ReactJSFrontendBuild) {
            snapshot {}
        }
        dependency(DotNetApiBuild) {
            snapshot {}
        }
        dependency(JavaApiBuild) {
            snapshot {}
        }
        dependency(PythonApiBuild) {
            snapshot {}
        }
        dependency(SecurityScanBuild) {
            snapshot {}
        }
    }
})