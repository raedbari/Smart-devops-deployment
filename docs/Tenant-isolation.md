# Tenant Isolation in Smart DevOps Platform

The Smart DevOps Platform is built as a **multi-tenant Kubernetes-based environment** where each tenant operates inside an isolated workspace.  
The purpose of this design is to ensure **security, privacy, controlled access, and resource separation** across all tenants using the platform.

This document explains how tenant isolation is enforced across the platform architecture.

---

## 1. Namespace-Based Isolation

Each tenant is assigned a **dedicated Kubernetes namespace**.  
This namespace acts as the primary boundary for isolating workloads and resources.

Examples:
- Tenant `acme` → namespace `acme`
- Tenant `cr` → namespace `cr`

Inside each namespace, the tenant’s applications, pods, services, events, and related resources are kept separate from other tenants.

This ensures that:
- workloads are logically separated
- resource names do not conflict across tenants
- operational visibility can be scoped safely per tenant

---

## 2. Tenant Provisioning and Assignment

Tenant isolation begins during the onboarding and approval workflow.

When a new tenant is approved, the platform prepares an isolated tenant environment, including:
- a dedicated namespace
- the required access configuration
- routing and monitoring context
- security controls related to that tenant

This controlled provisioning process ensures that tenant environments are created in a consistent and secure way.

---

## 3. Network Isolation

The platform enforces network-level separation using **Calico policies** to restrict communication across namespaces.

This prevents:
- cross-tenant communication
- unauthorized access to neighboring namespaces
- direct access to sensitive internal cluster components

Only the required traffic is allowed, such as:
- ingress traffic through the ingress controller
- DNS access for service discovery
- traffic that is explicitly allowed by policy

As a result, each tenant is limited to its own permitted communication paths.

---

## 4. RBAC and Platform API Access

The backend platform API needs visibility into tenant resources in order to display:
- application status
- pod information
- events
- deployment health

However, this access must remain controlled.

For this reason, Kubernetes RBAC is used to grant the backend only the permissions required for platform functionality.  
Sensitive operations are restricted, and access is managed through service accounts and role bindings.

This ensures that cluster access is controlled and aligned with the platform’s security model.

---

## 5. Routing and Access Isolation

Ingress and platform routing are designed so that tenants can access only their own application paths and services.

This helps ensure:
- tenant-specific application access
- no accidental exposure of other tenant routes
- cleaner separation at the platform entry layer

The routing layer works together with namespaces and policies to keep application access isolated.

---

## 6. Monitoring Isolation

Monitoring is also scoped per tenant.

Prometheus and Grafana are used in a way that respects namespace boundaries by filtering tenant views using namespace and application context.

This allows:
- tenant-specific dashboards
- tenant-specific metrics visibility
- safer operational views for clients
- more advanced internal monitoring for DevOps administrators

As a result, one tenant cannot view another tenant’s monitoring data.

---

## 7. Runtime Security Controls

The platform also applies runtime-oriented controls that support safe tenant execution.

For example:
- application deployment is constrained through platform rules
- unsafe or privileged runtime behavior is reduced
- port handling can be adjusted to align with safer non-root container execution

These controls help protect the cluster while still providing a simple deployment experience for tenants.

---

## 8. Isolation Layers Summary

| Layer | Role in Isolation |
|-------|-------------------|
| Namespace | Primary boundary for tenant resources |
| Network Policy | Prevents unauthorized cross-tenant traffic |
| RBAC | Controls how platform components access cluster resources |
| Routing / Ingress | Restricts tenant access to their own application paths |
| Monitoring | Limits metrics and dashboards to tenant scope |
| Runtime Controls | Reduces unsafe workload behavior |

---

## Conclusion

Tenant isolation in Smart DevOps Platform is not implemented through a single mechanism, but through multiple coordinated layers.

By combining:
- namespace-based separation
- network isolation
- controlled RBAC
- isolated routing
- monitoring boundaries
- runtime safety controls

the platform provides a secure and scalable multi-tenant environment suitable for shared Kubernetes-based application management.
