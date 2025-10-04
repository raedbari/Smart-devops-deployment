# Smart DevOps Deployment  
Here’s a clean, English version you can paste into your GitHub README:

---

# Smart DevOps — Graduation Project

A lightweight, cost-efficient DevOps platform running on a single AWS EC2 instance. It builds and deploys containerized apps to a self-managed Kubernetes cluster, exposes them securely via Ingress + TLS, and provides simple UI flows for **Deploy**, **Scale**, **Status**, and **Blue/Green** releases with direct links to **Grafana** dashboards.

---

## 1) Infrastructure (AWS)

* **EC2**: `t3.medium`, 30GB disk, public **Elastic IP**.
* **Networking**: custom **VPC** with a **Public Subnet**, **Internet Gateway**, and route table for internet access.
* **Security Group**: SSH (22), HTTP/HTTPS, and required ports for monitoring and experimental NodePorts.
* **Cost focus**: no ELB and no EKS. We run **Kubernetes manually on EC2** to stay flexible and minimize cost.
* **Stable DNS**: **DuckDNS** bound to the Elastic IP.

---

## 2) Kubernetes Layout

Namespaces used in the cluster:

* `project-env` — primary project apps (frontend/backend when promoted there).
* `monitoring` — Prometheus / Grafana / Loki + Promtail.
* `ingress-nginx` — Ingress controller.
* `cert-manager` — certificate automation.
* `default` — experimental or temporary workloads (currently includes `platform-api` in our setup).

Each app runs as a **Deployment → ReplicaSet → Pods**, fronted by a **Service** (`ClusterIP` for internal traffic; `NodePort` only used for early experiments).

---

## 3) Ingress & TLS

* **Controller**: `ingress-nginx`.
* **Public host**: `rango-project.duckdns.org`.
* **Rules**:

  * `/` → **frontend** Service on port **3000**.
  * `/api(/|$)(.*)` → **platform-api** Service on port **8000**, with:

    ```
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    ```
* **TLS**: `cert-manager` issues Let’s Encrypt certificates (staging & prod `ClusterIssuer`) via HTTP-01 on the nginx Ingress class.

---

## 4) Observability Stack

* **Prometheus** (via kube-prometheus-stack) for metrics.
* **Grafana** for dashboards (exposed through Ingress on the same host).
* **Loki + Promtail** for logs.
* The web UI links each app to its corresponding **Grafana dashboard** (either via a backend helper endpoint or a direct front-end redirect).

---

## 5) Backend — `platform-api` (FastAPI)

A single FastAPI service that manages Kubernetes resources and release flows.

### Key environment variables

* `ALLOWED_ORIGINS` (CORS), `FRONTEND_ORIGIN`, `DEFAULT_NAMESPACE`
* `GRAFANA_URL`, `GRAFANA_TOKEN`
* `PROM_URL`, `LOKI_URL`
* JWT settings: `JWT_SECRET`, `JWT_EXP_HOURS`

### Probes & Port

* Runs on **8000**, with `GET /healthz` for liveness/readiness.

### Main endpoints

* `GET /healthz` — health check
* `GET /` — welcome message
* `POST /_debug/validate-appspec` — validate an AppSpec (convenience)
* **Apps**

  * `POST /apps/deploy` — create/patch Deployment + Service for a given app spec
  * `POST /apps/scale` — scale Deployment replicas
  * `GET /apps/status` — list app status (namespace, image, desired/current/available/updated)
* **Blue/Green**

  * `POST /apps/bluegreen/prepare` — create a **preview** deployment and ensure Service targets **active**
  * `POST /apps/bluegreen/promote` — swap preview → active (labels/selectors)
  * `POST /apps/bluegreen/rollback` — revert to previously active

> Access to K8s is scoped via a dedicated **ServiceAccount** and **RBAC** (Role/ClusterRole + Bindings) to grant only the necessary permissions.

---

## 6) Frontend — Next.js

A minimal control plane UI with three flows:

* **Deploy App**: enter image/tag/port/health paths, namespace, env vars → calls `/apps/deploy`.
* **Apps Status**: table that fetches from `/apps/status`, shows (namespace/name/image/desired/current/available/updated), and provides:

  * **Scale** dialog → calls `/apps/scale`
  * **Open in Grafana** button → takes you to the app dashboard
* **Blue/Green**: three buttons (**Prepare / Promote / Rollback**) that call the corresponding backend endpoints.

### Environment

* `NEXT_PUBLIC_API_BASE=https://rango-project.duckdns.org/api`
* `SSR_API_BASE=http://platform-api.default.svc.cluster.local:8000`

---

## 7) CI/CD

There are **two repositories**:

* **Frontend (Next.js)**
* **Backend (FastAPI)**

For both:

* **GitHub Actions** on `main`:

  1. Build Docker image
  2. Push to **Docker Hub** (tagged by commit SHA)
  3. **kubectl** rollout to the EC2-hosted cluster:

     * Patch the Deployment image
     * Annotate with commit metadata
     * Wait for a successful **rollout**

---

## 8) Request Flow (End-to-End)

1. The browser calls `https://rango-project.duckdns.org/api/...`.
2. Ingress **rewrites** and forwards to the **platform-api** Service (`:8000`).
3. The backend talks to the K8s API to deploy/scale/list status or run Blue/Green flows.
4. The UI shows current state, allows scaling, and links to **Grafana** for dashboards.

---

## 9) Why this Design

* **Cost & control**: one EC2 + self-managed Kubernetes instead of managed services.
* **Simplicity**: a single public host with Ingress and TLS covers frontend, API, and observability.
* **Separation of concerns**: independent repos and pipelines for frontend and backend.
* **Safe releases**: Blue/Green handled by simple API calls and a clear UI.

---

## Quick Architecture Sketch

```
Internet
   │
   ▼
rango-project.duckdns.org (TLS via cert-manager)
   │
   ├── Ingress (nginx)
   │     ├── "/"      → Service: frontend :3000 → Next.js UI
   │     └── "/api/*" → Service: platform-api :8000 → FastAPI → K8s API
   │
   └── Grafana (same host via Ingress)
         └── Prometheus / Loki (+ Promtail) in "monitoring" namespace
```

---
