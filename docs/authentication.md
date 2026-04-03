# Authentication and Authorization in Smart DevOps Platform

Authentication and authorization are core parts of **Smart DevOps Platform** because they control who can access the platform and what each user is allowed to do after login.

Since the platform is **multi-tenant** and includes different types of users, it requires a clear and secure access model that connects each user to the correct role, tenant context, and permitted actions.

---

## 1. Purpose of the System

The main purpose of this system is to ensure that:

- only valid users can access the platform
- each user receives only the permissions appropriate to their role
- sensitive pages and operations are protected
- tenant boundaries are respected inside the platform

This makes authentication and authorization a foundational security and management layer in the project.

---

## 2. Authentication and Authorization

The system is based on two related stages:

- **Authentication**
  - verifies the identity of the user during login

- **Authorization**
  - determines what the user is allowed to access or execute after login

This separation helps keep the platform secure and organized.

---

## 3. Login Flow

Authentication starts from the **Login** page.

The flow works as follows:

1. The user enters email and password
2. The frontend sends the credentials to the backend
3. The backend validates the credentials
4. If the login is successful, the backend issues a **JWT token**
5. The token is then used in later requests to identify the user and validate access

This allows the platform to authenticate users without repeating the full login process on every request.

---

## 4. JWT Usage

The platform uses **JWT (JSON Web Token)** to carry user identity and access-related context between the frontend and backend.

The token can include information such as:

- user email
- user role
- tenant context
- sometimes the related namespace

This helps the platform link later requests to the correct user and tenant context in a secure and practical way.

---

## 5. Role-Based Access Control

Authorization is based on a role model.

The platform uses multiple roles to define access levels:

- **platform_admin**
  - manages platform-wide administrative tasks such as reviewing tenants and controlling platform-level functions

- **tenant_admin**
  - manages administrative actions inside a specific tenant context

- **devops**
  - has broader operational and technical visibility

- **client**
  - has limited access within the tenant’s own environment

This role structure supports separation of responsibilities and follows the principle of least privilege.

---

## 6. Route Protection

The system also applies **route protection**, especially in the frontend.

This means that:
- some pages are available only to authenticated users
- some pages are restricted to specific roles
- administrative pages are protected from unauthorized access

Route protection is important because page visibility should match the user’s authentication state and role, not just the existence of a URL.

---

## 7. Backend Authorization Logic

Authorization is not limited to the frontend.

The backend also validates the user context before allowing sensitive operations.  
This can include checking:

- the user role
- the tenant context
- the related namespace
- whether the requested action is permitted

This helps ensure that protected operations remain secure even if someone tries to bypass the frontend.

---

## 8. Functional Goals

The authentication and authorization system is designed to:

- allow valid users to log in
- issue a JWT after successful authentication
- include the necessary identity and role data in the token
- support multiple roles such as `platform_admin`, `tenant_admin`, `devops`, and `client`
- prevent users from accessing pages or operations outside their permissions
- connect requests to the correct user and tenant context

---

## 9. Non-Functional Goals

The system should also satisfy important non-functional requirements, including:

- **security**
  - protect credentials and generated tokens

- **reliability**
  - provide stable authentication and access validation

- **performance**
  - verify user identity and permissions with acceptable speed

- **scalability**
  - allow future extension with more roles or access policies

- **clarity**
  - keep permissions understandable and well organized

---

## 10. Value of the System

This system is essential because it connects:

- user identity
- role-based permissions
- tenant isolation
- protected pages
- controlled access to platform functions

As a result, authentication and authorization do not only support login, but also help protect the platform, organize user access, and preserve separation between tenants in a shared environment.

---

## Conclusion

The authentication and authorization system in Smart DevOps Platform is designed to provide secure login, role-based access control, route protection, and tenant-aware request handling.

By combining **Login**, **JWT**, **roles**, and **authorization logic** across both frontend and backend, the platform ensures that each user can access only the pages and operations that match their identity and responsibility.
