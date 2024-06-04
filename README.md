# Jenkins AMI Creation with Packer CR

This repository contains the necessary files and configurations to create a Jenkins AMI (Amazon Machine Image) using Packer. The AMI is preconfigured with Jenkins, Nginx, and Let's Encrypt SSL certificates.

## Prerequisites

Before getting started, ensure you have the following:

- AWS account with appropriate permissions
- Packer installed on your local machine
- AWS CLI configured with the necessary credentials

## Repository Structure

The repository has the following structure:
```
├── ami.pkr.hcl
├── certbot_initial.sh
├── certbot_renewal.sh
├── jenkins_nginx_final.conf
├── jenkins_nginx_initial.conf
├── packer_complete.sh
├── packer_init.sh
└── .github
└── workflows
├── merge.yml
└── pull.yml
```

- `ami.pkr.hcl`: The main Packer configuration file that defines the AMI creation process.
- `certbot_initial.sh`: Script to obtain the initial Let's Encrypt SSL certificate.
- `certbot_renewal.sh`: Script to renew the Let's Encrypt SSL certificate.
- `jenkins_nginx_final.conf`: Nginx configuration file with SSL enabled.
- `jenkins_nginx_initial.conf`: Initial Nginx configuration file without SSL.
- `packer_complete.sh`: Script to perform final configurations and cleanup.
- `packer_init.sh`: Script to install and initialize Jenkins, Nginx, and Certbot.
- `.github/workflows/merge.yml`: GitHub Actions workflow to build the AMI on merging with the main branch.
- `.github/workflows/pull.yml`: GitHub Actions workflow to validate Packer configuration on pull requests.

## AMI Creation Process

The AMI creation process involves the following steps:

1. Packer initializes the necessary plugins and validates the configuration.
2. Packer launches an EC2 instance based on the specified source AMI (Ubuntu 24.04 LTS).
3. The `packer_init.sh` script is executed to install Jenkins, Nginx, and Certbot.
4. The Nginx configuration files and Certbot scripts are uploaded to the EC2 instance.
5. The `packer_complete.sh` script is executed to perform final configurations and cleanup.
6. Packer creates an AMI from the configured EC2 instance.
7. The AMI is shared with the specified AWS account IDs.

## GitHub Actions Workflows

The repository includes two GitHub Actions workflows:

1. `merge.yml`: Triggered when changes are pushed to the main branch. It builds the AMI using Packer build command and pushes the latest AMI to AWS.
2. `pull.yml`: Triggered when a pull request is created against the main branch. It validates the Packer configuration.

## Usage

To create the Jenkins AMI, follow these steps:

1. Clone this repository to your local machine.
2. Ensure that you have Packer installed and the AWS CLI configured with the necessary credentials.
3. Review and modify the `ami.pkr.hcl` file if needed, such as updating the AWS region, instance type, or source AMI.
4. Run the commands to initialize Packer and download the required plugins.
```packer init ami.pkr.hcl```
5. If the validation is successful, run the following command to build the AMI:
```packer validate ami.pkr.hcl```
6. If the validation is successful, run build the AMI:
```packer build ami.pkr.hcl```
7. Packer will launch an EC2 instance, perform the necessary configurations, create the AMI, and share it with the specified AWS account IDs.

## Contributing

Please follow the standard GitHub workflow:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with descriptive messages.
4. Push your changes to your forked repository.
5. Submit a pull request to the main repository.

Please ensure that your code follows the existing style and conventions used in the project.