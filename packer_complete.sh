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
