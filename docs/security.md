# Security in Smart DevOps Platform

This document explains the main security mechanisms used in the **Smart DevOps Platform**.

The platform is designed to provide:
- controlled user access
- tenant isolation
- safer application deployment
- protected communication
- secure handling of sensitive configuration

Because the platform is built as a multi-tenant Kubernetes-based environment, security is implemented through multiple layers rather than a single control point.

---

## 1. Access Control

The platform uses a combination of **application-level roles** and **Kubernetes RBAC** to control access.

### Platform Roles

The platform defines different levels of user access, such as:

- **Client**
  - can deploy applications
  - can view basic monitoring information
  - cannot perform administrative platform actions

- **DevOps**
  - has broader monitoring and operational visibility
  - can access more advanced dashboards and operational views

- **Admin**
  - reviews and approves user requests
  - manages tenants and namespaces
  - controls platform-level configuration and access decisions

This role separation helps limit access based on operational responsibility.

---

## 2. Backend Access Restrictions

The backend interacts with Kubernetes to retrieve deployment and status information required by the platform.

To reduce risk, backend cluster access should remain limited to the permissions required for platform functionality.  
This helps ensure that backend services can inspect relevant resources without having unrestricted control over the cluster.

Such restrictions are especially important in shared environments where excessive permissions would increase security risk.

---

## 3. TLS and Secure Communication

Traffic to the platform is protected using **TLS/HTTPS**.

This is typically implemented through:
- **NGINX Ingress Controller**
- **cert-manager**
- certificate issuers such as **Let’s Encrypt**

Using HTTPS helps protect:
- login credentials
- session-related communication
- application access traffic
- administrative interactions with the platform

Encrypted communication reduces the risk of interception and improves overall platform security.

---

## 4. Secrets Management

Sensitive platform values should not be stored directly in public source files or exposed in frontend code.

The platform uses **Kubernetes Secrets** to manage sensitive information such as:

- JWT secrets
- database credentials
- SMTP credentials
- monitoring-related tokens
- other internal service secrets

These secrets are typically injected into workloads through environment variables or Kubernetes secret references.

This approach helps separate sensitive runtime configuration from application source code.

---

## 5. Tenant Isolation

A core security property of the platform is tenant separation.

Each tenant is assigned its own Kubernetes namespace, which acts as the main isolation boundary for tenant resources.

This helps isolate:
- deployments
- pods
- services
- monitoring context
- logs
- namespace-level operations

As a result, tenants are prevented from interacting directly with each other’s environments under normal platform operation.

Tenant isolation is described in more detail in the dedicated `tenant-isolation.md` document.

---

## 6. Network Isolation

The platform uses network-level controls, such as **Calico policies**, to reduce unwanted communication between tenants.

These controls are intended to:
- block cross-tenant traffic
- restrict access to unnecessary internal services
- allow only required communication paths such as ingress and DNS-related access

Network isolation is an important second layer after namespace separation, because namespace boundaries alone are not sufficient for full traffic control.

---

## 7. Safer Application Deployment

The platform includes deployment rules that help reduce risky workload behavior.

For example, if a user attempts to deploy an application using a privileged port below `1024`, the platform may rewrite the port to a safer non-privileged port such as `8080`.

This supports safer runtime behavior and helps reduce cases where containers would require elevated privileges.

The goal is to keep deployment simple for users while still applying safer defaults.

---

## 8. Controlled Onboarding and Approval

User access to the platform is not immediately granted after signup.

Instead, the onboarding process includes a controlled approval step:

1. the user signs up
2. the account remains in a pending state
3. access is not fully enabled until approval is granted
4. after approval, the required tenant environment and access configuration can be prepared

This reduces the risk of uncontrolled access and allows administrators to review who is allowed to use the platform.

More detailed onboarding logic can be documented separately in `authentication.md` or `platform-workflow.md`.

---

## 9. Monitoring Access Boundaries

Monitoring access is also treated as a security concern.

The platform separates monitoring visibility using:
- role-based dashboard access
- namespace-level filtering
- tenant-specific monitoring context

This helps ensure that:
- clients see only their own application data
- DevOps users can access broader operational visibility where permitted
- monitoring does not break tenant boundaries

The same principle applies to logs and other observability data where supported.

---

## 10. Multi-Layer Security Model

Security in Smart DevOps Platform is not based on a single mechanism.  
It is built through multiple layers working together, including:

- access control through roles and RBAC
- protected communication with TLS
- secure secret handling
- namespace-based tenant isolation
- network isolation policies
- safer deployment constraints
- controlled user onboarding
- filtered monitoring access

This layered model improves security while still keeping the platform usable for end users.

---

## Conclusion

The Smart DevOps Platform applies security through a combination of access control, secure communication, tenant isolation, deployment restrictions, and controlled operational visibility.

By combining these layers, the platform provides a more secure and manageable environment for multi-tenant Kubernetes-based application deployment and monitoring.
