#!/bin/bash

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-17-jre wget gnupg2 nginx software-properties-common

# Install jenkins
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Wait for Jenkins
while [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)" != "403" ]; do
    echo "Waiting for Jenkins to start..."
    sleep 5
done

# Install Jenkins plugins
JENKINS_CLI_CMD="java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword)"
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar
while IFS= read -r plugin || [[ -n "$plugin" ]]; do
    $JENKINS_CLI_CMD install-plugin "$plugin"
done < /home/ubuntu/plugins.txt

# Restart Jenkins 
sudo systemctl restart jenkins

# Install certbot for Let's Encrypt
sudo add-apt-repository -y ppa:certbot/certbot
sudo apt-get update
sudo apt-get install -y certbot python3-certbot-nginx