# Monitoring in Smart DevOps Platform

The monitoring system in **Smart DevOps Platform** is designed to observe application health, infrastructure status, logs, and alert conditions inside the Kubernetes environment.

It is built using an integrated observability stack that includes **Prometheus**, **Grafana**, **Loki**, **Promtail**, and **Alertmanager**.  
Together, these components allow the platform to collect metrics, store logs, visualize system behavior, and trigger alerts when operational issues occur.

---

## 1. Monitoring Purpose

The purpose of the monitoring system is to give users and administrators better visibility into:

- application health
- pod status
- CPU and memory usage
- operational logs
- infrastructure issues
- alert conditions that require attention

This makes the platform more than just a deployment interface, because it also provides real operational observability.

---

## 2. Main Monitoring Components

The monitoring stack in the platform includes the following tools:

- **Prometheus**
  - collects metrics from Kubernetes and workloads

- **Grafana**
  - visualizes metrics and logs through dashboards

- **Loki**
  - stores logs collected from applications and containers

- **Promtail**
  - collects logs from pods and containers and forwards them to Loki

- **Alertmanager**
  - handles alert routing after alert rules are triggered by Prometheus

---

## 3. Prometheus

**Prometheus** is responsible for collecting metrics from the cluster and from deployed applications.

It is used to monitor data such as:

- pod status
- CPU usage
- memory usage
- namespace health
- service and component availability

Prometheus also evaluates alert rules and detects abnormal situations that may require operational response.

---

## 4. Grafana

**Grafana** is used as the visual dashboard layer of the monitoring system.

It helps display:

- infrastructure metrics
- application metrics
- namespace-level health information
- log views
- some billing-related views based on combined platform data

This allows users and administrators to understand system behavior more quickly through dashboards instead of raw metrics alone.

---

## 5. Loki

**Loki** is used to store logs coming from applications and containers inside the cluster.

This is important because monitoring in the platform is not limited to metrics only.  
Logs provide another operational layer that helps with:

- troubleshooting
- failure investigation
- understanding application behavior
- reviewing runtime events

---

## 6. Promtail

**Promtail** acts as the log collection agent.

It gathers logs from containers and pods, then sends them to Loki.

This creates the log pipeline:

**Promtail → Loki → Grafana**

As a result, logs can be collected, stored, and viewed through the same monitoring environment.

---

## 7. Alertmanager

**Alertmanager** receives alerts from Prometheus after alert rules become active.

It applies the routing logic for alerts and forwards important ones to the platform webhook.

In the working platform setup:
- important alerts are sent to the **platform webhook**
- less important alerts, such as some `info` alerts, can be ignored to reduce noise

This helps the platform focus on useful operational alerts instead of sending every possible notification.

---

## 8. Monitoring and Alert Flow

The overall monitoring and alerting behavior in the project can be summarized as:

- **Prometheus** collects metrics
- **Grafana** visualizes metrics
- **Promtail** collects logs
- **Loki** stores logs
- **Grafana** displays logs
- **Prometheus** evaluates alert rules
- **Alertmanager** routes alerts
- the **backend webhook** processes the alert and links it to the correct tenant
- the proper user can then be notified

This flow makes the monitoring system integrated with the platform’s multi-tenant design.

---

## 9. Why the Monitoring System Matters

This system is important because the platform does more than deploy applications.

It also provides:

- application status visibility
- resource monitoring
- log access
- alert generation
- tenant-aware operational response

This makes Smart DevOps Platform closer to a complete DevOps platform rather than only a deployment interface.

---

## Conclusion

The monitoring system in Smart DevOps Platform combines **Prometheus**, **Grafana**, **Loki**, **Promtail**, and **Alertmanager** to provide metrics, logs, dashboards, and alert routing in one integrated environment.

By connecting observability with tenant-aware alert handling, the platform supports more reliable and operationally aware application management inside Kubernetes.
