# Monitoring in Smart DevOps Platform

The Smart DevOps Platform includes an integrated monitoring system based on **Prometheus**, **Grafana**, and **Alertmanager**.  
This monitoring stack helps users and administrators observe application health, resource usage, and infrastructure issues in a Kubernetes-based environment.

The monitoring system is an important part of the platform because it provides visibility into deployed applications and supports alert-based response when operational problems occur.

---

## 1. Monitoring Overview

The platform uses:

- **Prometheus** to collect metrics from Kubernetes resources and workloads
- **Grafana** to visualize these metrics through dashboards
- **Alertmanager** to manage and route alerts through email or webhooks

Together, these components allow the platform to monitor application status, namespace health, and resource consumption in real time.

---

## 2. Prometheus - Metrics Collection

**Prometheus** is responsible for collecting monitoring data from the Kubernetes environment.

In this platform, it is used to collect metrics related to:

- **Pod Status**
  - whether a Pod is running correctly or is in `Pending` or `Failed` state

- **Resource Usage**
  - CPU and memory consumption at Pod and Namespace level

- **Application Health**
  - operational data related to deployed applications and service availability

This data provides the foundation for both dashboards and alert rules.

---

## 3. Prometheus Alert Rules

The platform defines alert rules in Prometheus to detect important issues in the system.

Examples include:

1. **PodDown**
   - triggered when a Pod enters a failed or unhealthy state

2. **PodPendingTooLong**
   - triggered when a Pod remains in `Pending` longer than expected

3. **HighCPUUsage**
   - triggered when CPU usage in a Namespace exceeds 80%

4. **HighMemoryUsage**
   - triggered when memory usage in a Namespace exceeds 90%

5. **PrometheusDown**
   - triggered when Prometheus itself becomes unavailable

These alerts help detect both application-level and platform-level problems.

---

## 4. Alertmanager - Alert Handling

**Alertmanager** receives alerts fired by Prometheus and decides how they should be handled.

In the platform, Alertmanager is used to:

- send **critical alerts** by email
- forward selected alerts through **webhooks**
- reduce unnecessary noise by treating lower-priority alerts differently

This allows the platform to separate alert generation from alert delivery.

---

## 5. Grafana - Dashboard Visualization

**Grafana** is used to visualize the metrics collected by Prometheus.

It provides dashboards that allow users and administrators to monitor:

- application CPU usage
- memory usage
- pod availability
- namespace resource status
- general infrastructure health

Grafana makes the collected monitoring data easier to understand and use during normal operation or troubleshooting.

---

## 6. Dashboard Types

The platform supports different dashboard views depending on the monitoring purpose.

### Application Monitoring

These dashboards focus on a specific deployed application and typically show:

- CPU usage
- memory usage
- pod status
- available replicas

### Namespace Monitoring

These dashboards focus on the overall condition of a tenant namespace and may show:

- aggregated resource usage
- pod health
- workload status across the namespace

This helps provide both detailed application-level monitoring and broader namespace-level visibility.

---

## 7. Monitoring Flow

The monitoring flow in the platform works as follows:

1. **Prometheus** collects metrics from Kubernetes Pods and Namespaces
2. Prometheus stores and evaluates these metrics
3. If an alert condition is met, Prometheus fires an alert
4. **Alertmanager** receives the alert and routes it
5. **Grafana** displays the metrics in dashboards
6. Users and administrators monitor the environment and react when needed

This integration provides a complete monitoring and alerting workflow inside the platform.

---

## 8. Example Prometheus Alert Rule

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

## 9. Monitoring in a Multi-Tenant Platform

Because Smart DevOps Platform is a multi-tenant system, monitoring should respect tenant boundaries.

For this reason, monitoring views can be filtered by:

- namespace
- application
- tenant context

This helps ensure that each tenant only sees monitoring data related to its own environment, while administrators can access broader platform-level visibility.

## 10. Summary

The Smart DevOps Platform uses Prometheus, Grafana, and Alertmanager to provide monitoring, visualization, and alerting for Kubernetes-based applications.

Prometheus collects metrics and evaluates alert rules, Grafana displays monitoring dashboards, and Alertmanager routes important alerts through email and webhooks.

Together, these components help the platform detect failures early, track resource usage, and support more reliable application management.
