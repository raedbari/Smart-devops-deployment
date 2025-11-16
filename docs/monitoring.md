### **monitoring.md - Alerting System and Prometheus/Grafana Overview**

#### **Overview of Monitoring in the Platform**

The platform uses **Prometheus** and **Grafana** to monitor the status of applications and services within **Kubernetes**. **Prometheus** is used to collect performance and resource data from **Pods** and **Namespaces**, while this data is displayed on **Grafana** dashboards for effective monitoring.

#### **Prometheus - Data Collection System**

**Prometheus** is an open-source tool for gathering metrics from systems and applications. In this platform, **Prometheus** is used to collect data related to:

* **Pod Status**: Monitoring whether a Pod is running correctly, or if it's in **Pending** or **Failed** state.
* **Resource Consumption**: Tracking **CPU** and **memory** usage at the Pod and Namespace levels.
* **Applications**: Collecting data on the applications deployed in **Kubernetes**.

**Prometheus Alert Rules**:

1. **PodDown**: Alert when a Pod enters the **Failed** state.
2. **PodPendingTooLong**: Alert when a Pod stays in the **Pending** state for too long.
3. **HighCPUUsage**: Alert when **CPU** usage in a Namespace exceeds 80%.
4. **HighMemoryUsage**: Alert when **memory** usage in a Namespace exceeds 90%.
5. **PrometheusDown**: Alert when **Prometheus** itself is down.

#### **Alertmanager - Alert Management**

**Alertmanager** is a component of **Prometheus** that manages the alerts sent by **Prometheus**. Once **Alertmanager** receives an alert, it can forward it via various channels like email, **webhooks**, or other monitoring systems.

**Alertmanager Configuration**:

* **Email Notifications**: Critical alerts are sent to the registered email address.
* **Ignoring**: Alerts of lower priority (like warnings) are ignored or sent only to a **webhook**.

#### **Grafana - Data Visualization**

**Grafana** is an open-source tool used for visualizing and analyzing data from **Prometheus**. In this platform, **Grafana** is used to create interactive dashboards that enable users to monitor the health of applications and services in real-time.

**Types of Grafana Dashboards**:

1. **Application Monitoring**: Dashboards showing metrics like **CPU** usage, **memory** usage, and the number of available Pods.
2. **Namespace Monitoring**: Dashboards showing the status of an entire Namespace, including resource usage and Pod health.

#### **How Prometheus and Grafana Integrate**

1. **Prometheus** collects data from **Kubernetes** and stores it.
2. This data is fetched by **Grafana** to display it on interactive dashboards.
3. Users can monitor the data in real-time on **Grafana**, and alerts can be configured based on this data.

#### **Alerting System**

The platform uses an alerting system to notify users when issues occur in the infrastructure. Alerts include:

* **Critical Alerts**: For issues like **PodDown** or **PrometheusDown**, these are sent via email or **webhook**.
* **Warning Alerts**: For issues like **HighCPUUsage** or **HighMemoryUsage**, these are usually ignored but can be sent via **webhooks**.

#### **Example Prometheus Alert Configuration**

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
          summary: "💥 High memory usage detected"
          description: "Namespace {{ $labels.namespace }} is using more than 90% of its memory limit."
```

#### **Summary**

With **Prometheus** and **Grafana**, the system provides comprehensive monitoring of applications and infrastructure with immediate alerts for issues that could impact the system. The alerting system is based on the rules created in **Prometheus** and **Alertmanager** to distribute alerts via email and **webhooks**.
