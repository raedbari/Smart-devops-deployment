# Smart DevOps Deployment  
**Building an Intelligent Infrastructure for Auto Deployment and Monitoring Using Modern DevOps Tools**

## Project Overview
This project aims to design and implement a smart and automated cloud infrastructure for deploying and monitoring containerized applications using modern DevOps tools such as **Terraform**, **Docker**, **Kubernetes**, **GitHub Actions**, and **AWS**.  
The infrastructure follows **Infrastructure-as-Code (IaC)** principles to ensure reproducibility, scalability, and maintainability.  

In later stages, additional tools such as **Ansible**, **Prometheus**, **Loki**, and **Chaos Mesh** will be integrated to provide configuration automation, advanced monitoring, centralized logging, and resilience testing.

---

## Implementation Summary

### 1. AWS Infrastructure Provisioning with Terraform
- Created a VPC, subnets, security groups, and an EC2 instance using **Terraform**.
- Used **root_block_device** configuration to define storage size and properties.
- Ensured that all infrastructure is reproducible and version-controlled.

### 2. EC2 Preparation
- Accessed the instance via SSH for environment setup.
- Installed **Docker** and **Kubernetes** manually to host and orchestrate containerized workloads.

### 3. Continuous Integration (CI) with GitHub Actions
- Configured a CI workflow that automatically builds a **Docker image** for the Node.js application from the repository [node.js-app](https://github.com/raedbari/node.js-app).
- The image is tagged with both:
  - `latest` (for quick deployment/testing)
  - The **commit SHA** (for traceability and rollback)
- Images are pushed to **Docker Hub** using secure credentials stored in GitHub Secrets.

### 4. Kubernetes Deployment
- The Node.js application is deployed to Kubernetes as a **Deployment** resource (manifest stored in a separate file).
- The Deployment ensures:
  - High availability through ReplicaSets
  - Rolling updates for zero-downtime deployments
  - Easy rollback to previous versions
- The application is exposed via a **NodePort Service** for both internal and external access.

---

## Challenges and Solutions

### 1. Node Taint – `node.kubernetes.io/disk-pressure`
- **Issue**: Kubernetes prevented scheduling due to disk pressure.
- **Cause**: Node reported low available storage.
- **Solution**:
  - Freed unused space.
  - Removed taint:
    ```bash
    kubectl taint nodes node1 node.kubernetes.io/disk-pressure:NoSchedule-
    ```

### 2. Node Volume Size Limitation (9 GB)
- **Issue**: EC2 instance had only 9 GB root volume, causing storage constraints.
- **Solution**:
  - Increased the volume size to **20 GB** by updating the Terraform configuration (`root_block_device` volume_size).

### 3. Pods Stuck in `ContainerStatusUnknown`
- **Issue**: Several pods were stuck and not terminating properly.
- **Cause**: Old pods from previous ReplicaSets and kubelet communication issues.
- **Solution**:
  - Forced deletion of stuck pods:
    ```bash
    kubectl delete pod <pod-name> --force --grace-period=0
    ```
  - Restarted the deployment:
    ```bash
    kubectl -n project-env rollout restart deploy/project-dep
    ```

---

## Next Steps
- Integrate **Ansible** for automated configuration management.
- Set up **Prometheus** for metrics collection and alerting.
- Implement **Loki** for centralized logging.
- Use **Chaos Mesh** for resilience and fault injection testing.
- Enhance security and cost optimization strategies on AWS.

---

## Repository Structure
```
terraform/         → Infrastructure-as-Code for AWS setup
node.js-app/       → Node.js application + Dockerfile + CI pipeline
k8s/               → Kubernetes manifests (Deployment, Service, etc.)
README.md          → Project documentation
```

---

## Status
- ✅ AWS infrastructure deployed via Terraform
- ✅ EC2 prepared with Docker & Kubernetes
- ✅ CI pipeline functional via GitHub Actions
- ✅ Node.js app deployed to Kubernetes
- ⏳ Advanced monitoring, logging, and automation planned
