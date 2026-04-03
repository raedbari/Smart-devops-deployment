# Alerting in Smart DevOps Platform

The alerting system is a core operational component in **Smart DevOps Platform**.  
Its purpose is to detect important problems inside the Kubernetes environment and notify the correct user or administrator automatically, instead of relying only on manual monitoring through Grafana dashboards.

Because the platform is **multi-tenant**, the alerting system is designed to route alerts based on the affected **namespace**, so that each tenant receives only alerts related to its own applications.

---

## 1. Alerting Purpose

The main goal of the alerting system is to detect abnormal situations such as:

- pod failure
- pods staying in `Pending` for too long
- high CPU usage
- high memory usage
- Prometheus becoming unavailable

This helps reduce detection time, improve response speed, and make platform operations more reliable.

---

## 2. Main Components

The alerting workflow in the platform is built using:

- **Prometheus**
  - collects metrics and evaluates alert rules

- **Alertmanager**
  - receives alerts and applies routing logic

- **Webhook Backend**
  - receives alert data from Alertmanager

- **PostgreSQL**
  - stores tenant and user information used to identify the correct recipient

- **SMTP Email**
  - sends the alert notification to the appropriate user

This design makes the alerting system integrated with the platform itself, not just a static monitoring configuration.

---

## 3. Alert Flow

The alerting flow can be summarized as:

**Prometheus → Alertmanager → Webhook Backend → Database Lookup → Email**

The workflow is as follows:

1. Prometheus collects metrics from the cluster
2. Prometheus evaluates alert rules
3. If a condition remains true for the defined period, the alert enters the **Firing** state
4. Alertmanager receives the alert and applies routing rules
5. Alertmanager sends the alert to the backend webhook
6. The backend extracts the namespace from the alert
7. The backend looks up the matching tenant and users in PostgreSQL
8. The correct recipient is selected
9. An email notification is sent through SMTP

---

## 4. Why Webhook Was Used

The platform does not send alert emails directly from Alertmanager to a fixed email address.

This is important because the platform is **multi-tenant**:

- each tenant has its own namespace
- each namespace may belong to a different customer
- the recipient must be selected dynamically

For this reason, the platform uses:

**Alertmanager → Webhook → Backend → Database Lookup → Email**

This approach provides:

- tenant-aware alert delivery
- dynamic recipient selection
- easier future extension to other channels such as Slack or Microsoft Teams
- better separation of responsibilities between monitoring and notification logic

---

## 5. Alert Processing in the Backend

When the backend receives an alert from Alertmanager, it processes it as follows:

- reads the incoming alert payload
- extracts values such as:
  - alert name
  - severity
  - namespace
  - alert state (`firing` or `resolved`)
- searches for the matching tenant using the namespace
- retrieves the related users from the database
- selects the most appropriate recipient based on role priority
- prepares and sends the email notification

If no suitable user is found, a fallback email can be used.

---

## 6. Recipient Selection Logic

The recipient is determined dynamically based on the namespace included in the alert labels.

The backend matches:

- `tenants.k8s_namespace == alert namespace`

After finding the correct tenant, it selects the appropriate user from the related users table.

This makes the system suitable for a shared platform environment where different tenants must remain isolated from each other.

---

## 7. Alert Types Used in the Platform

The platform supports alerts such as:

- **PodDown**
  - detects pods that fail

- **PodPendingTooLong**
  - detects pods that remain pending longer than expected

- **HighCPUUsage**
  - detects CPU usage above a configured threshold

- **HighMemoryUsage**
  - detects memory usage above a configured threshold

- **PrometheusDown**
  - detects failure of the monitoring system itself

These alerts cover both workload issues and monitoring-layer failures.

---

## 8. Reducing Alert Noise

To reduce false or temporary alerts, the platform uses:

- **severity levels**
- **`for:` durations** in Prometheus alert rules

This means an alert is not always fired immediately.  
Instead, the condition must remain active for a defined time, such as:

- 1 minute
- 3 minutes
- 5 minutes

This helps reduce noise caused by short-lived changes.

---

## 9. Routing Policy

Alert routing is managed through **Alertmanager** configuration within the monitoring stack.

The routing logic can distinguish between alert severities, for example:

- **critical** and **warning**
  - forwarded to the platform webhook

- **info**
  - ignored or routed to a null receiver to reduce unnecessary noise

This helps keep the alerting system focused on useful operational events.

---

## 10. Value of the Alerting System

The alerting system improves the platform by:

- detecting problems early
- reducing manual monitoring effort
- linking alerts to the correct tenant
- protecting tenant isolation in notifications
- improving operational response
- providing a strong foundation for future notification channels

This makes alerting an important part of the platform’s operational architecture.

---

## Conclusion

The alerting system in Smart DevOps Platform is built as a tenant-aware operational workflow that connects **Prometheus**, **Alertmanager**, the **backend**, **PostgreSQL**, and **SMTP email**.

By routing alerts through the backend and identifying recipients dynamically from the database, the platform can deliver alerts to the correct tenant in a secure and scalable way.
