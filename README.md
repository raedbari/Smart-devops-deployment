# Smart-devops-deployment
 Building an Intelligent Infrastructure for Auto Deployment and Monitoring Using Modern DevOps Tools

## Project Overview

This project aims to design and implement a smart and automated cloud infrastructure for deploying and monitoring containerized applications using modern DevOps tools such as Terraform, Docker, Kubernetes, GitHub Actions, and AWS.

## Implementation Summary

### 1. AWS Setup
I started by creating an AWS account and configuring an IAM user. I generated the necessary security credentials (Access Key ID and Secret Access Key) to enable programmatic access via Terraform from Visual Studio Code.

### 2. Infrastructure as Code with Terraform
Using Terraform, I defined and deployed the core cloud infrastructure on AWS, including VPC, subnets, security groups, and an EC2 instance.  
You can find the infrastructure code in the `terraform/` folder of this repository.

### 3. Access to EC2 and System Preparation
I accessed the EC2 instance via SSH using the MobaXterm application.  
On the instance, I installed Docker and Kubernetes manually. The full installation steps and configuration can be found in my dedicated repository:  
🔗 [https://github.com/raedbari/install-k8s](https://github.com/raedbari/install-k8s)

### 4. CI Pipeline with GitHub Actions
I built a CI pipeline to create a Docker image for a Node.js application using GitHub Actions.  
The pipeline automatically builds and pushes the image to Docker Hub after every code update.  
The related configuration files are located in the `my-app/` folder of this repository.

### 5. Deployment to EC2
On the EC2 instance, I pulled the generated Docker image from Docker Hub and deployed it using a `docker-compose.yml` file.  
The Compose file is configured with the `restart: always` policy to ensure the container runs automatically on every EC2 reboot.

---

## Status

-  Infrastructure deployed using Terraform on AWS
-  EC2 instance prepared with Docker and Kubernetes
-  CI pipeline configured and working with GitHub Actions
-  Image successfully deployed on EC2 using Docker Compose
