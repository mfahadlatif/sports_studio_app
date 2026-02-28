# Sports Studio: Master API Reference Guide 🏟️

This document is the definitive technical authority for interacting with the Sports Studio Backend. It specifies **Data Types**, **Validation Rules**, and **Exact Response Shapes**.

---

## 🟢 0. Core Data Objects (Type Definitions)
When these objects appear in responses, they follow these consistent structures:

### User Object
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Integer | Unique Identifier |
| `name` | String | User's full name |
| `email` | String | Unique email address |
| `role` | String | `user`, `owner`, `organizer`, or `admin` |
| `phone` | String | null | Phone number (e.g., "+923001234567") |
| `avatar` | String | null | Relative path (e.g., "uploads/avatars/1.jpg") or absolute URL |
| `is_phone_verified`| Boolean | Appended attribute (Backend: `phone_verified_at != null`) |

### Booking Object
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | Integer | Unique Identifier |
| `ground_id` | Integer | ID of the reserved ground |
| `start_time` | DateTime | Format: `YYYY-MM-DD HH:MM:SS` |
| `end_time` | DateTime | Format: `YYYY-MM-DD HH:MM:SS` |
| `total_price` | Decimal/String| e.g., "1500.00" |
| `status` | String | `pending`, `confirmed`, `rejected`, `cancelled`, `completed` |
| `payment_status` | String | `unpaid`, `paid`, `refunded` |

---

## 🔵 1. Authentication & Security 🔐

### User Registration
- **Endpoint**: `POST /api/register`
- **Request Type**: `JSON`
- **Fields**:
  - `name`: `String` (Required, Max 255)
  - `email`: `String` (Required, Unique, Email format)
  - `password`: `String` (Required, Min 8 chars)
  - `password_confirmation`: `String` (Required, Must match password)
  - `role`: `String` (Optional, `user` or `owner`)

### Login (Email/Password)
- **Endpoint**: `POST /api/login`
- **Request Body**: `{"email": "String", "password": "String"}`
- **Success Response (200 OK)**:
```json
{
  "access_token": "String",
  "token_type": "Bearer",
  "user": { "UserObject" }
}
```

---

## 🟣 2. Complex & Ground Management (Owner) 🏢

### Sports Complex (Create/Update)
- **Endpoint**: `POST /api/complexes` (Create) / `PUT /api/complexes/{id}` (Update)
- **Payload Data Types**:
  - `name`: `String` (Required)
  - `address`: `String` (Required)
  - `latitude`: `Float` (Nullable)
  - `longitude`: `Float` (Nullable)
  - `description`: `String` (Nullable)
  - `amenities`: `Array` (sent as `["Wifi", "Parking"]`) or `String` (JSON encoded)
  - `status`: `String` (`active` or `inactive`)
  - `images`: `Array` of Strings (URLs/Relative paths)

### Ground / Arena (Create/Update)
- **Endpoint**: `POST /api/grounds`
- **Payload Data Types**:
  - `complex_id`: `Integer` (Required)
  - `name`: `String` (Required)
  - `price_per_hour`: `Decimal/Float` (Required, Min 0)
  - `type`: `String` (Required, e.g., "Cricket", "Football")
  - `lighting`: `Boolean` (Nullable, defaults to false)
  - `dimensions`: `String` (Nullable)

---

## 🟡 3. Booking & Availability 🗓️

### Requesting a Booking
- **Endpoint**: `POST /api/bookings`
- **Payload Data Types**:
  - `ground_id`: `Integer` (Required)
  - `start_time`: `String` (Required, format: `Y-m-d H:i:s`)
  - `end_time`: `String` (Required, format: `Y-m-d H:i:s`)
  - `total_price`: `Decimal/Float` (Required)
  - `players`: `Integer` (Optional)
  - `customer_name`: `String` (Optional - for walk-ins/manual)
  - `customer_phone`: `String` (Optional)

### Slot Availability Check
- **Endpoint**: `GET /api/public/grounds/{id}/bookings?date=2024-03-01`
- **Success Response (Array of Busy Slots)**:
```json
[
  {
    "id": "Integer",
    "start_time": "2024-03-01 10:00:00",
    "end_time": "2024-03-01 11:00:00",
    "status": "confirmed",
    "event_id": "Integer|null"
  }
]
```

---

## 🟠 4. Reporting & Analytics 📊

### Dashboard Stats (`GET /api/owner/stats`)
- **JSON Structure**:
```json
{
  "total_complexes": 5, // Integer
  "total_grounds": 12, // Integer
  "total_bookings": 150, // Integer
  "total_revenue": 45000.0, // Float/Decimal
  "monthly_revenue": 12000.0, // Float/Decimal
  "recent_bookings": [ "Array of BookingObjects with User and Ground relationships" ]
}
```

---

## 🟥 5. Global Filtering & Sorting 🔍

All "List" endpoints (Paginated responses) support these basic query parameters:

### Pagination
| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `per_page` | Integer | 15 | Number of records per page (Max 100 recommended) |
| `page` | Integer | 1 | The page number to retrieve |

### Sorting (Defaults)
*   **Bookings**: Sorted by `created_at` DESC (Recent bookings first).
*   **Events**: Sorted by `start_time` DESC.
*   **Grounds/Complexes**: Sorted by `created_at` DESC.

### Common Filters 
*   **`owner_id`**: Used on `/complexes`, `/grounds` and `/events` to filter by a specific resource owner.
*   **`complex_id`**: Used on `/grounds` to filter pitches belonging to a specific complex.

---

## 🔴 6. General Response Rules & Errors ⚠️

### Standard Success (Pagination)
Used for all "List" endpoints (Complexes, Grounds, Events):
```json
{
  "current_page": "Integer",
  "data": [ "Array of Objects" ],
  "first_page_url": "String",
  "from": "Integer",
  "last_page": "Integer",
  "per_page": "Integer",
  "to": "Integer",
  "total": "Integer"
}
```

### Common Error Codes
| Code | Meaning | Response Payload |
| :--- | :--- | :--- |
| **401** | Unauthorized | `{"message": "Unauthenticated"}` |
| **403** | Forbidden | `{"message": "Unauthorized"}` |
| **422** | Validation Failed | `{"message": "The given data was invalid", "errors": { "field": ["Reason"] } }` |
| **404** | Not Found | `{"message": "Resource not found"}` |

---

## 🏁 6. Action Items for Integration
1. **Datetime Sync**: Ensure Mobile/Web apps send `YYYY-MM-DD HH:MM:SS`. 
2. **Numeric Fields**: Always send `price_per_hour` and `total_price` as numbers, though backend handles stringified numbers safely.
3. **Array Handling**: Use `JSON.stringify()` for `amenities` and `images` if sending via `multipart/form-data`.
