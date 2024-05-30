#!/bin/bash

# Moving required files
sudo mv /home/ubuntu/jenkins_nginx_initial.conf /etc/nginx/sites-available/jenkins
sudo mv /home/ubuntu/certbot_initial.sh /usr/local/bin/certbot_initial.sh
sudo mv /home/ubuntu/certbot_renewal.sh /usr/local/bin/certbot_renewal.sh
sudo chmod 755 /usr/local/bin/certbot_initial.sh
sudo chmod 755 /usr/local/bin/certbot_renewal.sh

# Configure Nginx
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/

# Add service
sudo sh -c "echo '[Unit]
Description=Run Certbot Initial Script at Boot
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/certbot_initial.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target' >> /lib/systemd/system/certbot.service"
sudo systemctl daemon-reload
sudo systemctl enable certbot

# Schedule Certbot renewal
sudo crontab -l > /tmp/cron
echo '0 3 * * * /usr/local/bin/certbot_renewal.sh' >> /tmp/cron
sudo crontab /tmp/cron

# Wait for Jenkins
while [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)" != "403" ]; do
    echo "Waiting for Jenkins to start..."
    sleep 5
done

# Jenkins CLI
sudo wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar

# Install Jenkins plugins
sudo java -jar /tmp/jenkins-cli.jar -s http://localhost:8080/ -auth admin:$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword) install-plugin git github github-api

# Restart Jenkins
sudo systemctl restart jenkins
echo "Jenkins restarted and all done!"