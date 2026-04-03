# Alerting in Smart DevOps Platform

The Smart DevOps Platform includes an alerting system designed to detect important operational problems and notify users or administrators when action may be required.

This alerting workflow is built around **Prometheus**, **Alertmanager**, and the platform backend, with notifications delivered through **webhooks** and **email**.

The goal of this system is to move from passive monitoring to active notification, so that critical issues are not only visible in dashboards, but also reported through alert channels.

---

## 1. Alerting Purpose

Monitoring dashboards are useful for observing system health, but they require someone to check them manually.

For this reason, the platform includes an alerting mechanism that automatically reacts when predefined conditions are met, such as:

- pod failure
- workloads remaining pending for too long
- high resource usage
- monitoring service failure
- other important operational conditions

This helps the platform respond more quickly to infrastructure and application-level problems.

---

## 2. Main Alerting Components

The alerting system is based on the following components:

- **Prometheus**
  - evaluates alert rules based on collected metrics

- **Alertmanager**
  - receives firing alerts and applies routing logic

- **Webhook**
  - forwards selected alerts to the platform backend

- **Backend**
  - processes alert data and prepares notification logic

- **SMTP Email**
  - sends alert notifications by email when required

Together, these components create an end-to-end alerting pipeline inside the platform.

---

## 3. Alert Flow

The alerting workflow can be summarized as follows:

**Prometheus Rule → Firing Alert → Alertmanager → Webhook → Backend → SMTP Email**

This means:

1. Prometheus evaluates alert rules continuously
2. When a rule condition is met, an alert enters the firing state
3. Alertmanager receives the alert
4. Alertmanager routes it based on configuration
5. A webhook sends the alert data to the backend
6. The backend processes the alert
7. If required, an email notification is sent through SMTP

This workflow allows the platform to connect infrastructure alerts with application-level notification behavior.

---

## 4. Prometheus Alert Rules

Prometheus is responsible for detecting alert conditions using predefined rules.

Examples of alerts used in the platform include:

- **PodDown**
  - triggered when a pod becomes unhealthy or fails

- **PodPendingTooLong**
  - triggered when a pod remains in `Pending` longer than expected

- **HighCPUUsage**
  - triggered when namespace CPU usage exceeds a defined threshold

- **HighMemoryUsage**
  - triggered when namespace memory usage exceeds a defined threshold

- **PrometheusDown**
  - triggered when the monitoring system itself is unavailable

These alerts help identify both workload issues and platform-level monitoring failures.

---

## 5. Alertmanager Role

**Alertmanager** acts as the routing and handling layer for alerts fired by Prometheus.

Its role includes:

- receiving alerts from Prometheus
- grouping or filtering alerts
- applying severity-based behavior
- forwarding alerts to webhook endpoints
- sending or triggering email-related notification workflows

This helps separate:
- alert detection
from
- alert delivery and notification behavior

---

## 6. Webhook and Backend Integration

A key part of the Smart DevOps Platform alerting design is the integration between **Alertmanager** and the **backend** through webhooks.

When Alertmanager forwards an alert through a webhook:

- the backend receives the alert payload
- the alert information can be interpreted in a platform-specific way
- notification actions can be triggered
- the system can decide how to handle different alert types

This makes the alerting system more flexible than relying on direct monitoring-tool notifications alone.

---

## 7. Email Notifications

The platform supports alert delivery by email using **SMTP**.

Email notifications are especially useful for important operational events that should reach a user or administrator without requiring them to watch the dashboard continuously.

Typical use cases include:

- critical pod failures
- important infrastructure alerts
- monitoring service outages
- other high-priority operational conditions

This gives the platform a practical notification mechanism beyond dashboard visibility.

---

## 8. Alert Severity Handling

Not all alerts should be treated in the same way.

The platform can distinguish between different alert severities, for example:

- **Critical alerts**
  - may trigger email notifications and webhook delivery

- **Warning alerts**
  - may be logged, grouped, or forwarded with lower urgency

This helps reduce alert noise while keeping important incidents visible.

---

## 9. Example Alert Rule

The following example shows a Prometheus alert rule for high memory usage:

```yaml
groups:
  - name: smartdevops-alerts
    rules:
      - alert: HighMemoryUsage
        expr: sum(container_memory_usage_bytes{container!=""}) by (namespace) / sum(kube_pod_container_resource_limits_memory_bytes{container!=""}) by (namespace) > 0.9
        for: 3m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected"
          description: "Namespace {{ $labels.namespace }} is using more than 90% of its memory limit."
```

This rule allows the platform to detect resource pressure at the namespace level before it becomes a more serious issue.

---

## 10. Operational Value of Alerting

The alerting system adds an active operational layer to the platform.

Instead of relying only on dashboards, the platform can:

- detect issues automatically
- notify relevant users or administrators
- respond faster to failures
- improve operational awareness
- support more reliable application management

This is especially important in multi-tenant environments where manual observation alone is not enough.

---

## Conclusion

The Smart DevOps Platform uses an integrated alerting workflow based on **Prometheus**, **Alertmanager**, **webhooks**, the **backend**, and **SMTP email** to detect and report important operational problems.

By combining rule-based detection with platform-level notification handling, the alerting system helps transform monitoring data into actionable alerts and improves the overall reliability of the platform.
