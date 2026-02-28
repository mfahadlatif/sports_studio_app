# Sports Studio: User API Specification 👕

This document details all API endpoints available for the **Regular User** role. It covers searching, booking, social features, and community participation.

---

## 1. Ground Search & Discovery 🔍

### List Grounds (Public/Auth)
- **URL**: `GET /api/public/grounds` (or `/api/grounds`)
- **Query Params**:
  - `complex_id`: `Integer` (Filter by facility)
  - `type`: `String` (e.g., "Cricket", "Football")
  - `owner_id`: `Integer` (Filter by owner/club)
  - `per_page`: `Integer`
- **Response**: Paginated standard Ground objects.

### Check Time Slot Availability
- **URL**: `GET /api/public/grounds/{id}/bookings`
- **Query**: `date=YYYY-MM-DD`
- **Response**: `[{"start_time", "end_time", "status"}]` 
- **Rule**: Use this to gray out slots in your calendar UI.

---

## 2. Booking System 🗓️

### Create a Reservation
- **URL**: `POST /api/bookings`
- **Payload**:
```json
{
  "ground_id": 1,
  "start_time": "2024-03-01 18:00:00",
  "end_time": "2024-03-01 20:00:00",
  "total_price": 3000,
  "players": 12
}
```
- **Response (201 Created)**: Returns the `Booking` object with `status: "pending"`.

### List My Bookings
- **URL**: `GET /api/bookings`
- **Response**: Paginated list of user's own bookings.

---

## 3. Events & Tournaments 🏆

### List All Public Events
- **URL**: `GET /api/public/events`
- **Filters**:
  - `organizer_id`: `Integer` (Filter by specific match organizer)
  - `event_type`: `public` | `private`
- **Sorting**: Events are automatically sorted by `start_time` DESC.

### Join an Event
- **URL**: `POST /api/event-participants`
- **Payload**: `{"event_id": Integer, "message": "String (Optional)"}`
- **Response**: Returns registration status.

---

## 4. Community & Social 👥

### Teams Management
- **List My Teams**: `GET /api/teams`
- **Create Team**: `POST /api/teams` -> `{"name", "sport", "description"}`
- **Add Team Member**: `POST /api/teams/{id}/members` -> `{"user_id", "role"}`

### Reviews & Ratings
- **Add Review**: `POST /public/reviews`
- **Payload**:
```json
{
  "ground_id": 5,
  "rating": 5,
  "comment": "Best turf in the city!",
  "user_name": "Optional Guest Name"
}
```

---

## 5. Favorites & Alerts 🔔

### Favorites
- **List Favorites**: `GET /api/favorites`
- **Add**: `POST /api/favorites` -> `{"ground_id": Int}`
- **Remove**: `DELETE /api/favorites/{ground_id}`

### Notifications
- **List**: `GET /api/notifications`
- **Mark Read**: `POST /api/notifications/{id}/read`
- **Read All**: `POST /api/notifications/read-all`

---

## 6. Payment Flow 💳 (Safepay)

### Step 1: Initialize Payment
- **URL**: `POST /api/safepay/init`
- **Payload**: `{"amount": 1500.0, "currency": "PKR"}`
- **Response**:
```json
{
  "tracker": "track_abc123...",
  "environment": "sandbox",
  "sandbox_url": "https://sandbox.api.getsafepay.com/checkout/pay",
  "production_url": "https://api.getsafepay.com/checkout/pay"
}
```

### Step 2: Mobile WebView Implementation
In your Flutter/React Native app, load the checkout URL in a WebView:
1. **Construct URL**: `{base_url}?tracker={tracker}&user_id={user_id}&source=mobile`
2. **Success Detection**: Listen for URL changes in the WebView. If the URL contains `sig=` or `success`, the payment is complete.
3. **Safety**: Always use the tracker returned by the backend; never hardcode environment URLs in the app.

### Step 3: Verify Transaction
- **URL**: `POST /api/safepay/verify`
- **Payload**: `{"tracker": "track_abc...", "reference": "order_123", "amount": 1500.0}`
- **Note**: The backend will return `{"status": "valid"}` if the signature matches.

---

## 7. Mobile Security & Stability 🛡️

### Secure Payments
1. **Never Hardcode Secret Keys**: Always perform Safepay `init` on the backend. The mobile app should only ever see the `tracker`.
2. **WebView Cleaning**: Ensure that the WebView in Flutter/React Native is disposed of immediately after the `sig=` parameter is detected.
3. **SSL Pinning (Recommended)**: For production, ensure your `ApiClient` is configured to trust only your server's certificate.

### Common Issue: Initialization Failure
If Safepay fails to initialize (`Error 400`), verify your `.env` keys:
- **SAFEPAY_PUBLIC_KEY**: Must start with `pk_`.
- **SAFEPAY_SECRET_KEY**: Must start with `sec_`.
- *Error Fix*: If your public key starts with `sec_`, initialization will fail. Swapping these to the correct format resolves most issues.
