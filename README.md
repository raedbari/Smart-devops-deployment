# 🚀 SmartDevOps Platform

A smart platform for managing and deploying **multi-tenant applications** on **Kubernetes**,  
built with **FastAPI**, **Next.js**, and integrated **Prometheus / Grafana / Alertmanager** monitoring.

---

## 🧠 Overview

**SmartDevOps** is an intelligent DevOps platform designed to automate the full application lifecycle in Kubernetes.  
It bridges simplicity for **clients** and precision for **DevOps engineers**, providing each tenant with full control, monitoring, and instant alerting —  
while maintaining strict multi-tenant isolation and security.

---

## 💡 Problem & Solution

| Problem | Solution |
|----------|-----------|
| **Slow release deployments** | Implements **Blue-Green Deployment** for zero downtime updates. |
| **Hard rollback process** | One-click **Rollback** instantly restores the previous version. |
| **Temporary service outage during update** | Traffic is switched only after successful readiness probes. |
| **Clients unaware of failures** | **Alertmanager** sends real-time email alerts on failures. |
| **No visibility or monitoring** | **Grafana Dashboards** per tenant with metrics and status. |
| **Low port numbers cause failures** | Automatically replaces ports <1024 with **8080**. |
| **Shared access between clients** | Each tenant has its own **Namespace + RBAC + ResourceQuota**. |
| **Manual client provisioning** | Automated **tenant approval and namespace creation** from Admin panel. |
| **Complex operations** | Simple UI — click “Open App” → `https://<app>.<tenant>.apps.smartdevops.lat` |

---

## 🏗️ Architecture

📘 Full diagram available here:  
[`/docs/architecture.drawio`](https://github.com/USERNAME/SmartDevOps/blob/main/docs/architecture.drawio)

Open it with **draw.io / diagrams.net** to view all connections:  
Frontend → FastAPI API → Kubernetes API → Prometheus / Grafana / Alertmanager

---

## ⚙️ Technologies

| Layer | Stack |
|-------|--------|
| **Frontend** | Next.js · TypeScript · TailwindCSS · Framer Motion |
| **Backend** | FastAPI · SQLAlchemy · PostgreSQL |
| **Monitoring** | Prometheus · Grafana · Alertmanager |
| **Containerization** | Docker · Kubernetes · Ingress NGINX |
| **Security** | JWT Auth · RBAC · Secrets · ConfigMaps |
| **CI/CD** | GitHub Actions · Blue-Green Deployment |

---

## 📂 Project Structure

### 🧩 Backend (FastAPI)

```bash
app/
├── auth.py            # JWT login & context
├── onboarding.py      # Tenant lifecycle (NS/Quota/RBAC)
├── k8s_ops.py         # Deploy/Service/Scale/Blue-Green
├── monitor.py         # Grafana URL endpoints
├── models.py          # Pydantic & SQLAlchemy models
├── config.py          # Env/ConfigMap settings
├── db.py              # SQLAlchemy engine/session
├── k8s_client.py      # Kubernetes client initialization
├── mailer.py          # SMTP email helper
├── main.py            # FastAPI app entrypoint
└── alerts/
    └── webhook.py     # Alertmanager → Email notifications
```

---

### 💻 Frontend (Next.js)

```bash
.github/
└── workflows/
    └── ci.yaml                     # GitHub Actions: Build & Deploy Frontend to Kubernetes

app/
├── apis/
│   └── bluegreen.ts                # REST calls to backend for Blue-Green operations
│
├── auth/                           # Authentication & onboarding pages
│   ├── contact/page.tsx            # Contact or support form
│   ├── docs/page.tsx               # User documentation / guide
│   ├── login/page.tsx              # Login form with JWT authentication
│   ├── pending/page.tsx            # Tenant pending approval
│   ├── signup/page.tsx             # Signup for new tenants
│   └── layout.tsx                  # Layout wrapper for auth pages
│
├── dashboard/                      # Main dashboard after login
│   ├── admin/tenants/page.tsx      # Admin page to approve/reject tenants
│   ├── apps/
│   │   ├── bluegreen/page.tsx      # Blue-Green deployment UI
│   │   ├── deploy/page.tsx         # Deploy new app interface
│   │   └── page.tsx                # Apps table (status, scale, open, Grafana)
│   ├── layout.tsx                  # Dashboard layout (header, sidebar)
│   └── page.tsx                    # Dashboard home
│
├── globals.css                     # Global TailwindCSS styles
└── layout.tsx                      # Root layout (theme, metadata)
│
components/
├── BlueGreenActions.tsx            # Actions (prepare/promote/rollback)
├── PrepareModal.tsx                # Modal for preparing new version
├── PromoteModal.tsx                # Modal for promoting version
├── RollbackModal.tsx               # Modal for rollback
├── RequireAuth.tsx                 # Route guard (JWT validation)
└── ui.tsx                          # Shared UI components
│
lib/                                # Helper utilities
├── (api.ts / auth.ts / adminClient.ts ...) # API wrappers, token helpers, etc.
│
public/                             # Static assets (logos, images)
│
.dockerignore
.gitignore
Dockerfile                          # Frontend image build
eslint.config.mjs                   # ESLint for TypeScript
middleware.ts                       # Auth middleware
next.config.ts                      # Next.js runtime config
package.json                        # Dependencies & scripts
package-lock.json
postcss.config.js / .mjs            # Tailwind/PostCSS setup
tailwind.config.js                  # Theme config
tsconfig.json                       # TypeScript config
README.md                           # Documentation
```

---

## 🚀 CI/CD Pipeline

All deployments are **automated** through **GitHub Actions** on every push to `main`.

### 🔹 Backend CI (`.github/workflows/backend-ci.yml`)

**Steps:**
1. **Build & Push Docker Image**
   ```bash
   docker buildx build -t raedbari/platform-api:${GITHUB_SHA} .
   docker push raedbari/platform-api:${GITHUB_SHA}
   ```

2. **Deploy to Kubernetes**
   ```bash
   kubectl -n default set image deploy/platform-api api=raedbari/platform-api:${GITHUB_SHA}
   kubectl -n default rollout status deploy/platform-api --timeout=300s
   ```

---

### 🔹 Frontend CI (`.github/workflows/ci.yaml`)

**Steps:**
1. **Build & Push Docker Image**
   ```bash
   docker buildx build -t raedbari/frontend:${GITHUB_SHA} .
   docker push raedbari/frontend:${GITHUB_SHA}
   ```

2. **Deploy to Kubernetes**
   ```bash
   kubectl -n default set image deploy/frontend frontend=raedbari/frontend:${GITHUB_SHA}
   kubectl -n default rollout status deploy/frontend --timeout=300s
   ```

---

## 📊 Monitoring & Alerting

* **Prometheus** — collects performance metrics (CPU, Memory, Pod status)
* **Alertmanager** — sends email alerts immediately when any service fails
* **Grafana Dashboards:**
  * *Client View* — simple overview for clients
  * *DevOps View* — advanced metrics and logs via Loki

---

## 🔐 Security

* Each tenant runs in an isolated **Namespace** with dedicated **ResourceQuota**.
* **RBAC** ensures strict permission separation.
* HTTPS enforced using **Let’s Encrypt certificates**.
* Authentication via **JWT tokens** for API and UI.

---

## 🧱 Key Features

✅ Multi-Tenant Isolation  
✅ Blue-Green Deployment  
✅ Prometheus Monitoring  
✅ Grafana Dashboards  
✅ Alertmanager Notifications  
✅ RBAC Security  
✅ Rollback & Scaling  
✅ Zero-Downtime Updates  

---

## 👤 About the Developer

**Name:** Raed Abdulbari Abdullah Alrubaidi  
**Role:** Junior DevOps Engineer  
**Email:** [raedbari203@gmail.com](mailto:raedbari203@gmail.com)  
**Website:** [https://smartdevops.lat](https://smartdevops.lat)

---

*Built with passion for automation, monitoring, and clean DevOps workflows.*
