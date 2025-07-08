#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io docker-compose curl wget unzip

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Install Octopus CLI
curl -L https://github.com/OctopusDeploy/cli/releases/latest/download/octopus-cli_linux_amd64 -o /usr/local/bin/octopus
chmod +x /usr/local/bin/octopus

# Install SonarQube Scanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip
unzip sonar-scanner-cli-4.8.0.2856-linux.zip
mv sonar-scanner-4.8.0.2856-linux /opt/sonar-scanner
ln -s /opt/sonar-scanner/bin/sonar-scanner /usr/local/bin/sonar-scanner

# Install OWASP Dependency Check
wget https://github.com/jeremylong/DependencyCheck/releases/download/v8.4.3/dependency-check-8.4.3-release.zip
unzip dependency-check-8.4.3-release.zip
mv dependency-check /opt/
ln -s /opt/dependency-check/bin/dependency-check.sh /usr/local/bin/dependency-check

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Java
apt-get install -y openjdk-17-jdk maven

# Install .NET Core
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
apt-get install -y dotnet-sdk-8.0

# Install Python
apt-get install -y python3 python3-pip

# Create directories
mkdir -p /opt/teamcity/data
mkdir -p /opt/teamcity/logs

# Start TeamCity in Docker
docker run -d --name teamcity-server \
  --restart unless-stopped \
  -p 8111:8111 \
  -v /opt/teamcity/data:/data/teamcity_server/datadir \
  -v /opt/teamcity/logs:/opt/teamcity/logs \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  jetbrains/teamcity-server:latest

# Wait for TeamCity to start
sleep 60

# Start TeamCity Agent
docker run -d --name teamcity-agent \
  --restart unless-stopped \
  -e SERVER_URL="http://localhost:8111" \
  -v /opt/teamcity/agent:/data/teamcity_agent/conf \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /usr/local/bin/aws:/usr/local/bin/aws \
  jetbrains/teamcity-agent:latest

# Install Trivy for container scanning
wget https://github.com/aquasecurity/trivy/releases/download/v0.46.1/trivy_0.46.1_Linux-64bit.deb
dpkg -i trivy_0.46.1_Linux-64bit.deb

# Create systemd service for TeamCity
cat > /etc/systemd/system/teamcity.service << 'EOF'
[Unit]
Description=TeamCity Server
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start teamcity-server teamcity-agent
ExecStop=/usr/bin/docker stop teamcity-server teamcity-agent

[Install]
WantedBy=multi-user.target
EOF

systemctl enable teamcity.service

# Log completion
echo "TeamCity installation completed at $(date)" >> /var/log/user-data.log
echo "TeamCity will be available at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8111" >> /var/log/user-data.log