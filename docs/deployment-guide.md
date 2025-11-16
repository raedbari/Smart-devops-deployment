
---


# Smart DevOps Platform — Deployment Guide

This guide explains how to deploy your **own instance** of the Smart DevOps Platform on your Kubernetes cluster.  
It is intended for platform owners, DevOps engineers, or administrators — **not end-users**.

---

## ✅ Prerequisites

Before deploying the platform, ensure you have:

- A running Kubernetes cluster  
  (EKS, GKE, AKS, or self-managed via kubeadm)
- `kubectl` configured and connected to the cluster
- Docker (if you plan to build custom images)
- A domain name for the platform frontend
- Basic knowledge of Kubernetes objects (Deployment, Service, Ingress)
- Access to:
  - Frontend repo (Next.js)
  - Backend repo (FastAPI)
  - Smart-DevOps deployment manifests

---

## 1. ⚙️ Set Up the Infrastructure

### 1.1 Create a Kubernetes Cluster

You may use:

**Option A — Managed Kubernetes**  
EKS / GKE / AKS (recommended)

**Option B — kubeadm installation**  
You can use the provided helper scripts:
> https://github.com/raedbari/install-k8s

Verify cluster connectivity:

```bash
kubectl get nodes
````

---

### 1.2 (Optional) Configure Persistent Storage

If your applications require persistence, ensure your cloud provider or cluster supports PV/PVC.

---

### 1.3 Install NGINX Ingress Controller

The platform uses Ingress for routing.

For example:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

Wait for the LoadBalancer IP to appear:

```bash
kubectl get svc -n ingress-nginx
```

---

## 2. 🔧 Setup CI/CD (Admin Only)

Only **the platform owner** uses CI/CD — not the tenants.

Your CI/CD pipeline should:

* Build & push the FastAPI backend image
* Build & push the Next.js frontend image
* Deploy updated images into the Kubernetes cluster

Typical tools:

* GitHub Actions
* GitLab CI
* Jenkins

Users of the platform **do not** have CI/CD access.

---

## 3. 🚀 Deploy the Platform Components

Clone the Smart DevOps deployment repo:

```bash
git clone https://github.com/raedbari/Smart-devops-deployment
cd Smart-devops-deployment
```

Apply all Kubernetes files:

```bash
kubectl apply -f k8s/
```

This deploys:

* Frontend (Next.js)
* Backend (FastAPI)
* Platform API RBAC
* Network Policies
* Namespace template logic
* Ingress routing
* Monitoring stack integration (Prometheus/Grafana)

---

## 4. 🌐 Configure DNS & Ingress

In the Ingress file, replace:

```
smartdevops.lat
```

with your **own domain**.

Example:

```yaml
rules:
  - host: platform.mycompany.dev
```

Then point DNS → ingress LoadBalancer IP.

---

## 5. 🔑 Configure Backend Environment Variables

Backend configuration file:

```
k8s/Backend/platform-api-config.yaml
```

Important variables:

* `JWT_SECRET`
* `DATABASE_URL`
* `GRAFANA_URL`
* `PROM_URL`
* `LOKI_URL`
* `API_BASE_URL`
* SMTP credentials (optional)
* Token expiration hours
* ALLOWED_NAMESPACES logic

These control authentication, monitoring, and tenants.

---

## 6. 👥 User Signup & Approval Workflow

After platform deployment:

1. User signs up → enters **Pending** state
2. Admin reviews request
3. Admin Approves or Rejects
4. Upon approval:

   * A **namespace is created** for that tenant
   * NetworkPolicies, RoleBindings, ResourceQuotas are applied
5. The user can now log in and deploy applications

Users **cannot** access the platform until approved.

If a company uses a special namespace like:

```
cr
```

and a new user signs up selecting namespace `cr` →
they automatically join **that company's environment** without admin approval.

---

## 7. 🚢 Deploying the First Application (User Perspective)

After login, the user can deploy an application:

* The platform creates a deployment YAML automatically
* Validates:

  * app name format
  * image name & tag
  * port validity (ports < 1024 are rewritten to 8080)
* Deploys the app inside the user's namespace
* Provides direct access via “Open App”
* Provides monitoring via Grafana (Client or DevOps dashboards)

---

## 8. 📊 Monitoring & Logs

The platform integrates with:

* **Prometheus**
* **Grafana**
* **Loki**
* **Kubernetes Events API**

Users can view:

* Pod status
* Restart count
* Logs
* Real-time CPU & memory
* Namespace-level metrics
* Basic dashboard (for Clients)
* Advanced dashboard (for DevOps users)

---

## 9. 🔄 Blue-Green Deployment (Optional)

Supported by the platform:

* **Prepare** → Deploys the new version (preview)
* **Promote** → Swap stable/preview and stop the old version
* **Rollback** → Bring back the previous version

This process ensures **zero downtime**.

---

## 10. 🛡 Security Notes

* Any container port **below 1024** will be auto-rewritten to **8080**
* Prevents running containers as root
* Tenants are completely isolated using:

  * Calico GlobalNetworkPolicy
  * Namespace isolation
  * Read-only RBAC for backend access

---

## 11. 🧯 Maintenance & Backups

As platform owner:

* Back up PostgreSQL database regularly
* Monitor cluster node resources
* Ensure Prometheus/Grafana are healthy
* Update backend/frontend images via CI/CD when needed

---

## ✅ Conclusion

You now have a fully deployed instance of the **Smart DevOps Platform**, including:

* Frontend & backend
* User onboarding & approval
* Tenant isolation
* Monitoring stack
* App deployment capabilities
* Blue/Green rollout support

Your installation is secure, scalable, and production-ready.

```

