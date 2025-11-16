# 🔐 Smart DevOps Platform — Security Overview

This document explains how security is implemented inside the Smart DevOps Platform.  
The goal is to provide **tenant isolation**, **safe application deployment**, and **protected system access** with minimal complexity.

---

## 1. Role-Based Access Control (RBAC)

The platform uses Kubernetes RBAC + custom application roles to control access.

### 📌 Platform Roles
- **Client**  
  - Can deploy apps  
  - Can view metrics/logs  
  - Cannot restart, delete, or modify applications  
  - Cannot access other namespaces

- **DevOps**  
  - Same as client, but with **advanced monitoring dashboards**

- **Admin**  
  - Approves/rejects user sign-ups  
  - Manages tenants  
  - Manages namespaces  
  - Controls platform-wide configuration

### 📌 Backend Restrictions
The backend service account is **read-only** in the cluster:
- Cannot delete pods
- Cannot modify deployments
- Cannot access other namespaces except the tenant namespace

This ensures *no accidental or malicious damage* can occur.

---

## 2. TLS / HTTPS Security

All traffic to the platform is encrypted using **TLS certificates** via the NGINX Ingress Controller.

- All URLs use `https://`
- Certificates managed by **cert-manager** + **Let’s Encrypt**
- Prevents MITM attacks and credential leaks

---

## 3. Secrets Management

The platform uses Kubernetes **Secrets** to store sensitive data:

- JWT secret  
- Database credentials  
- SMTP credentials  
- Grafana tokens  

### 🚫 Not Allowed
- No secrets stored in GitHub  
- No secrets stored in config files  
- No secrets stored in frontend code  

Secrets are injected into pods using environment variables.

---

## 4. Tenant Isolation (Namespaces)

Each tenant gets **its own isolated Kubernetes namespace**.

### What is isolated?

| Resource | Isolated? |
|----------|-----------|
| Deployments | ✅ |
| Pods | ✅ |
| Services | ✅ |
| Network | ✅ |
| Monitoring Views | ✅ |
| Logs | ✅ |

This ensures tenants cannot:

- See other tenants’ applications  
- Access other namespaces  
- Read others' logs  
- Interfere with other workloads  

---

## 5. Network Isolation (Calico Policies)

Calico GlobalNetworkPolicies enforce strict isolation:

- Tenants **cannot** talk to each other  
- Tenants **can only** talk to:
  - Ingress controller  
  - DNS service  
- All cross-tenant communication is blocked by default  

This prevents:
- Data leaks  
- Unauthorized internal traffic  
- Namespace hopping  

---

## 6. Safe Application Deployment (Port Rewrite)

To prevent privilege escalation:

- If a user deploys an app with port `< 1024`  
  → The platform **automatically rewrites it to `8080`**

Why?

Ports < 1024 require root privileges.  
The platform enforces **non-root containers** only.

This prevents:
- Running containers as root  
- Privileged mode abuse  
- Host escape vectors  

---

## 7. Signup Approval Security

When a user signs up:

1. They enter **Pending** state  
2. No namespace is created  
3. No resources are created  
4. They cannot access the platform  

Only after admin approval:
- Namespace is created  
- RoleBindings applied  
- Network policies attached  

### Special Case  
If a user signs up with a namespace name matching an existing company:

Example:  
If company **cr** already exists → any user selecting **cr** joins automatically (no approval).

---

## 8. Monitoring Access Control

The monitoring stack (Prometheus + Grafana) is also isolated:

- Client role → simple dashboard  
- DevOps role → advanced dashboard  
- Each dashboard is filtered by `namespace=tenant_name`  
- Users only see metrics of **their own** apps

Logs (Loki) follow the same rule.

---

## ✔ Summary

The platform implements multiple layers of protection:

- RBAC controls permissions  
- TLS protects communication  
- Secrets stored securely  
- Tenants isolated via namespaces  
- Calico network policies prevent cross-access  
- No-root deployments enforced  
- Admin approval required  
- Monitoring is namespace-restricted  

This security model ensures a **safe**, **multi-tenant**, and **production-ready** DevOps platform.

