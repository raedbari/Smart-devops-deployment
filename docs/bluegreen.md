# Blue-Green Deployment — Smart DevOps Platform

Blue-Green Deployment in **Smart DevOps Platform** allows users to upgrade an existing application with zero downtime by running two versions side-by-side:  
- **Active** → Current stable version  
- **Preview** → Upcoming version prepared for testing  

This mechanism ensures safe upgrades, instant rollback, and uninterrupted availability.

---

## 1. Real Example: Upgrading `nginx:1.0` → `nginx:2.0`

Assume the user already deployed:

- **App Name:** `nginx`  
- **Image:** `nginx`  
- **Tag:** `1.0`

Now the user wants to upgrade the application to version `2.0`.

---

# 2. Prepare Phase (Create Preview Version)

The **Prepare** step creates a new *preview* version of the application while keeping the current version running.

### During Prepare:

- The existing version (`nginx:1.0`) stays active and receives traffic.
- A new Deployment is created:
  - **Active:** `nginx`
  - **Preview:** `nginx-preview`
- User fills the Prepare form with:
  - **Name:** `nginx`
  - **Image:** `nginx`
  - **Tag:** `2.0`
  - Port, replicas, health path…

### Result After Prepare:

| Version              | Status     | Traffic |
|----------------------|------------|---------|
| `nginx:1.0`          | Active     | ✔ Yes |
| `nginx:2.0-preview`  | Preview    | ✖ No  |

This allows safe testing of the new version.

---

# 3. Promote Phase (Switch to New Version)

**Promote** switches production traffic from the old version to the new preview version.

### During Promote:

1. `nginx-preview`:
   - Role changes → `active`
   - Replicas set → `1`

2. Old Deployment `nginx`:
   - Role changes → `idle`
   - Replicas set → `0` (stopped)

### Result After Promote:

| Version     | Status     | Traffic |
|-------------|------------|---------|
| `nginx:2.0` | Active     | ✔ Yes |
| `nginx:1.0` | Idle       | ✖ No  |

---

# 4. Rollback Phase (Restore Previous Version)

If the new version fails or behaves incorrectly, rollback is instant.

### During Rollback:

- `nginx` (idle old version) becomes active:
  - Role → `active`
  - Replicas → `1`

- `nginx-preview` (current active) becomes idle:
  - Role → `idle`
  - Replicas → `0`

### Result After Rollback:

| Version     | Status     | Traffic |
|-------------|------------|---------|
| `nginx:1.0` | Active     | ✔ Yes |
| `nginx:2.0` | Idle       | ✖ No  |

Rollback is instant and restores the previous version with zero downtime.

---

# 5. Additional Notes

- Instead of “blue” and “green”, the platform uses:
  - Active Deployment → `app`
  - Preview Deployment → `app-preview`

- Only three actions exist:
  - **Prepare** → Create a preview version
  - **Promote** → Activate the preview version and shut down the old one
  - **Rollback** → Reactivate the previous version

- The system automatically manages:
  - Labels  
  - Selectors  
  - Replicas scaling  
  - Activation/deactivation  

ensuring a safe and reliable deployment process.

---

This file is ready to upload to GitHub as **`blue-green.md`** or **`README.md`**.
