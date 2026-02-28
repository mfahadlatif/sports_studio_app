# Sports Studio: Admin API Specification 🛡️

This document details the elevated privilege endpoints available only to the **Admin** role. These routes are protected by the `auth:sanctum` middleware and role-based checks.

---

## 1. System-Wide Dashboard 📈

### Global Stats
- **URL**: `GET /api/admin/stats`
- **Response**:
```json
{
  "total_users": 1500,
  "total_bookings": 8500,
  "total_events": 450,
  "total_grounds": 120,
  "total_revenue": 1500000,
  "pending_reviews": 12
}
```

---

## 2. User & Role Management 👥

### List All Users
- **URL**: `GET /api/admin/users`
- **Filters**:
  - `search`: `String` (Searches by Name, Email, or Phone)
  - `role`: `String` (user, owner, admin, organizer)
- **Pagination**: Supports `per_page` (Default 20).

### Update User Role/Status
- **URL**: `PUT /api/admin/users/{id}`
- **Payload**:
```json
{
  "role": "owner", // user, owner, admin, organizer
  "is_active": true
}
```

### Delete User
- **URL**: `DELETE /api/admin/users/{id}`
- **Constraint**: Cannot delete yourself.

---

## 3. Moderation & Cleanup 🧹

### Cleanup Old Data
- **URL**: `POST /api/admin/cleanup`
- **Payload**:
```json
{
  "target": "bookings", // bookings or events
  "days": 90,
  "status": "cancelled" // optional filter
}
```
- **Response**: `{"message", "deleted_count", "target"}`

### Moderate Reviews Across System
- **URL**: `GET /api/admin/reviews`
- **Response**: Paginated reviews including associated Ground and User data.
- **Action (Hide/Delete)**: Use standard `/api/reviews/{id}/status` or `DELETE` endpoints.

---

## 4. Maintenance Utilities 🛠️

### Fix Storage Symlink
- **URL**: `POST /api/admin/fix-storage`
- **Use Case**: Run this if images are not showing on production after a deployment.
- **Response**: Details on Artisan output and manual symlink status.

### Production Cleanup
- **URL**: `POST /api/admin/cleanup`
- **Fields**: `target` (bookings/events), `days` (int).

---

## 5. Global Facility Oversight 🏢

### View All Complexes
- **URL**: `GET /api/admin/complexes`
- **Filters**:
  - `search`: `String` (Search by facility name)
- **Relationships**: Automatically includes `owner` and `grounds` details.
