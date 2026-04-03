# Blue-Green Deployment in Smart DevOps Platform

The Smart DevOps Platform supports **Blue-Green Deployment** as a safer release strategy for updating applications with minimal disruption.

Instead of replacing the currently running version directly, the platform prepares a second version of the application alongside the existing one. This allows validation before switching traffic and enables fast rollback if problems appear.

Within the platform, the two versions are represented as:

- **Active version** → the currently serving production traffic
- **Preview version** → the new candidate version prepared for testing

This approach improves deployment safety, reduces downtime risk, and gives users more control over application upgrades.

---

## 1. Why Blue-Green Deployment Was Used

Traditional in-place updates may cause service interruption or make rollback more difficult if the new version fails after deployment.

To reduce this risk, Smart DevOps Platform uses Blue-Green Deployment because it allows:

- running the old and new versions side by side
- validating the new version before full activation
- switching traffic in a controlled way
- restoring the previous version quickly if needed
- minimizing service disruption during updates

This makes it especially useful in a platform that aims to simplify deployment while still following safer DevOps practices.

---

## 2. Deployment Model in the Platform

Instead of using the literal names "blue" and "green", the platform uses:

- `app` for the current active deployment
- `app-preview` for the prepared next version

For example, if the application name is `nginx`, the platform may manage:

- `nginx` → active deployment
- `nginx-preview` → preview deployment

The active version continues serving users, while the preview version is prepared separately for validation and controlled promotion.

---

## 3. Main Blue-Green Actions

The platform provides three main actions:

### Prepare
Creates a preview version of the application while the current version remains active.

### Promote
Switches production traffic from the current active version to the preview version.

### Rollback
Reactivates the previous stable version if the promoted version fails or behaves incorrectly.

These actions are exposed through the platform workflow instead of requiring the user to manually manage Kubernetes update logic.

---

## 4. Prepare Phase

The **Prepare** phase creates a new preview deployment without interrupting the running application.

During this step:

- the currently active deployment remains available
- a new preview deployment is created using the updated image or version
- traffic continues to go to the active version
- the preview version can be inspected or validated before release

### Example

Assume the currently active application is:

- App name: `nginx`
- Image: `nginx`
- Tag: `1.0`

The user wants to prepare version `2.0`.

The platform creates:

- `nginx` → active version
- `nginx-preview` → preview version using `nginx:2.0`

### Result After Prepare

| Deployment | Version | Role | Receives Production Traffic |
|------------|---------|------|-----------------------------|
| `nginx` | `1.0` | Active | Yes |
| `nginx-preview` | `2.0` | Preview | No |

This phase allows the new version to exist safely beside the current one.

---

## 5. Promote Phase

The **Promote** phase activates the preview version and makes it the new production version.

During promotion, the platform updates the deployment state so that the preview version becomes the active one. At the same time, the previously active version is deactivated or scaled down.

The exact mechanism may involve:
- updating labels
- updating selectors
- adjusting replicas
- changing which deployment is considered active by the service logic

### Result After Promote

| Deployment | Version | Role | Receives Production Traffic |
|------------|---------|------|-----------------------------|
| `nginx-preview` | `2.0` | Active | Yes |
| `nginx` | `1.0` | Idle / Previous | No |

After promotion, the new version becomes the live production version.

---

## 6. Rollback Phase

If the promoted version fails, rollback can restore the previous version quickly.

During rollback:

- the previously stable version is reactivated
- the newer version is removed from active traffic
- application availability is preserved through controlled switching

### Result After Rollback

| Deployment | Version | Role | Receives Production Traffic |
|------------|---------|------|-----------------------------|
| `nginx` | `1.0` | Active | Yes |
| `nginx-preview` | `2.0` | Idle / Previous | No |

This makes rollback much safer and faster than rebuilding the old version from scratch.

---

## 7. How Traffic Switching Works

Traffic switching in Smart DevOps Platform is controlled through Kubernetes resource logic managed by the platform.

Rather than deleting the old deployment immediately, the platform keeps both versions logically separated and controls which one is active.

This can include:
- role-based labels such as `active`, `preview`, or `idle`
- service selection rules
- scaling behavior to keep only the intended version live
- controlled activation and deactivation during promote and rollback

Because traffic switching is managed by the platform, users do not need to manually edit low-level Kubernetes resources.

---

## 8. Benefits of the Platform Approach

The Blue-Green implementation in Smart DevOps Platform provides several benefits:

- safer upgrades
- lower risk of downtime
- controlled traffic switching
- easier rollback
- clearer release lifecycle
- better user experience for non-expert Kubernetes users

This is important because one of the platform’s goals is to hide operational complexity while still applying sound DevOps deployment practices.

---

## 9. Summary

Blue-Green Deployment in Smart DevOps Platform is implemented as a controlled application upgrade workflow based on two deployment states:

- an **active** production version
- a **preview** candidate version

Using the actions **Prepare**, **Promote**, and **Rollback**, the platform allows users to release updates more safely and recover quickly if something goes wrong.

This makes the platform more reliable, more user-friendly, and better suited for production-oriented Kubernetes application management.
