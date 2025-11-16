
---

# Tenant Isolation in Smart DevOps Platform

The Smart DevOps Platform is designed as a **multi-tenant environment** where each customer operates inside an isolated Kubernetes namespace.  
This ensures security, privacy, and resource separation between different clients.

This document explains how tenant isolation works across the entire platform.

---

## 1. Namespace-Based Tenant Separation

Every tenant is assigned a **dedicated Kubernetes namespace**, created automatically during the approval process.

Example:
- Tenant “acme”  
  → Namespace: `acme`
- Tenant “cr”  
  → Namespace: `cr`

All workloads, Deployments, Pods, Events, and metrics belonging to a tenant stay inside their namespace and cannot interact with others.

---

## 2. Automatic Tenant Routing on Signup

Smart DevOps includes smart tenant routing logic:

- If a company namespace already exists (e.g. `cr`)  
- And a new user signs up selecting the **same namespace name**  
- The user is **automatically added to that company’s tenant**  
- **No admin approval required**

This enables companies to onboard internal users instantly.

If the namespace **does not exist**, then:
- Signup enters the **Pending** state  
- Admin decides: **Approve** or **Reject**

---

## 3. Network Isolation (Calico GlobalNetworkPolicy)

Calico GlobalNetworkPolicy enforces strict network isolation:

### 🚫 Tenants cannot access resources of other tenants  
### 🚫 Tenants cannot scan neighboring namespaces  
### 🚫 Tenants cannot access internal cluster components  

Example policy:

```yaml
apiVersion: crd.projectcalico.org/v1
kind: GlobalNetworkPolicy
metadata:
  name: tenant-global-policy
spec:
  namespaceSelector: tenant == "true"
  types:
    - Ingress
    - Egress

  ingress:
  - action: Allow
    source:
      namespaceSelector: "app.kubernetes.io/name == 'ingress-nginx'"

  - action: Allow
    source:
      namespaceSelector: "tenant == 'true'"

  egress:
  - action: Allow
    destination:
      namespaceSelector: "app.kubernetes.io/name == 'ingress-nginx'"

  - action: Allow
    destination:
      namespaceSelector: "kubernetes.io/metadata.name == 'kube-system'"
      selector: "k8s-app == 'kube-dns'"

  - action: Deny
````

### Result:

* Tenants can reach only:

  * Their own namespace
  * Ingress controller
  * DNS
* **Nothing else**

---

## 4. RBAC Isolation for the Platform API

The backend (`platform-api`) must inspect Kubernetes deployments to show app status, events, pods, logs —
BUT it must **never** modify workloads.

This is enforced through a **read-only ClusterRole**:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: platform-api-readonly
rules:
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets"]
    verbs: ["get", "list", "watch"]

  - apiGroups: [""]
    resources: ["pods", "namespaces"]
    verbs: ["get", "list", "watch"]

  - apiGroups: ["events.k8s.io"]
    resources: ["events"]
    verbs: ["get", "list", "watch"]
```

Bound to service account:

```yaml
kind: ClusterRoleBinding
...
subjects:
  - kind: ServiceAccount
    name: platform-api
    namespace: default
```

### Result:

* Backend can **see** tenant resources
* Backend **cannot modify** anything in the cluster

---

## 5. Ingress-Level Isolation

Ingress rules ensure:

* A tenant can only access **its own** app URLs
* No cross-tenant API endpoint exposure
* Hosted apps remain isolated

Example URL patterns:

```
/apps/acme/*
/apps/cr/*
```

A tenant cannot access:

```
/apps/other-tenant/*
```

---

## 6. Monitoring Isolation (Prometheus/Grafana)

Monitoring respects tenant boundaries:

* Every metric query is filtered by **namespace**
* Every log query is filtered by **namespace**
* Grafana URLs include:

  ```
  var-namespace=<tenant>
  var-app=<app>
  ```
* Two monitoring modes:

  * **Client Dashboard** → simple & safe
  * **DevOps Dashboard** → full advanced charts

Tenants cannot see logs or metrics of any other namespace.

---

## 7. Container Security Controls

To prevent privilege escalation inside workloads:

### ❌ Tenants cannot deploy containers running on privileged ports (<1024)

If a customer enters port `80` or `443`:

* The platform automatically rewrites the port to `8080`
* This ensures apps run as **non-root**
* Protects cluster security

Example:

* User submits → `image: nginx:1.0` on port `80`
* Platform deploys → port `8080`

---

## 8. Summary of Tenant Isolation Features

| Layer           | Protection Provided                             |
| --------------- | ----------------------------------------------- |
| Namespace       | Hard separation per tenant                      |
| Calico Network  | No cross-tenant traffic allowed                 |
| RBAC            | Read-only API — backend cannot modify workloads |
| Ingress         | Per-tenant routing only                         |
| Monitoring      | Namespaced metrics/logs only                    |
| Container Ports | Prevent privileged containers                   |
| Signup Logic    | Auto-company-join if namespace exists           |

Smart DevOps Platform provides **full multi-tenant isolation** across network, compute, RBAC, monitoring, and routing layers — making it secure, scalable, and enterprise-ready.

```
 
