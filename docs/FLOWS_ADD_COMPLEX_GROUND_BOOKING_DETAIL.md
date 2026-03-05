# Deep flow: Add Complex, Add Ground, Booking Detail

This doc walks through **how each flow works** in the Cricket Oasis Bookings website: UI → API → backend. Use it to deploy, debug, or mirror the same flows in the app.

---

## 1. Add Complex flow

### 1.1 How you get there

- **Sidebar:** Owner → **Sports Complexes** → “Add complex” (or link from dashboard).
- **URL:** `/owner/complexes/new`.
- **Component:** `AddEditComplex.tsx` (create mode; no `slug` in URL).

### 1.2 UI steps

1. **Basic information**
   - **Complex name** (required).
   - **Location** via `LocationAutocomplete` (address + optional lat/lng).
   - **Description** (textarea).
   - **Status** toggle: Active / Inactive (default Active).

2. **Media**
   - `MediaUpload`: upload images for the complex; `modelType="Complex"`, `modelId` only when editing.

3. **Facilities**
   - Grid of facilities from `facilityConfigs` (e.g. parking, showers, cafe). User toggles selections; stored as `selectedFacilities` array.

4. **Actions**
   - **Cancel** → navigate to `/owner/complexes`.
   - **Save & Continue** → submit form.

### 1.3 Submit (create)

- **Method:** `POST`.
- **URL:** `API_BASE_URL/complexes` (e.g. `/api/complexes`).
- **Headers:** `Content-Type: application/json`, `Authorization: Bearer <token>`.
- **Body (from form):**
  - `name`, `address` (from `formData.location`), `latitude`, `longitude`, `description`
  - `status`: `'active'` or `'inactive'` from boolean
  - `amenities`: `formData.selectedFacilities` (array)
  - `images`: `formData.images` (array of paths)

### 1.4 Backend (ComplexController::store)

- **Auth:** `auth:sanctum` (logged-in user).
- **Validation:** `name` (required), `address` (required), `latitude`/`longitude` (nullable numeric), `description`, `amenities`, `status`, `images`.
- **Owner:** `owner_id = $request->user()->id` (current user becomes owner).
- **Create:** `Complex::create($validated)`.
- **Response:** `201` + created complex JSON.

### 1.5 After success

- Toast: “Complex created successfully!”
- **Navigate:** `/owner/complexes` (list).

### 1.6 Edit complex (same component, different route)

- **URL:** `/owner/complexes/:slug/edit`.
- **Load:** `GET /api/complexes/:slug` → fill form; if not found → toast + redirect to `/owner/complexes`.
- **Submit:** `PUT /api/complexes/:slug` with same body shape.
- **Backend:** `ComplexController::update` checks `complex->owner_id == auth()->id()` (or admin); then updates. On success, frontend navigates to `/owner/complexes`.

---

## 2. Add Ground flow

A ground **must** belong to a complex. There are two entry points.

### 2.1 Entry A: From “Add ground” (choose complex first)

- **URL:** `/owner/grounds/new`.
- **Component:** `AddGround.tsx`.

**Steps:**

1. **Load complexes:** `GET /api/complexes?owner_id={user.id}` (owner sees only their complexes).
2. **UI:** List of complexes (search by name/address). User **selects one**.
3. **“Continue to Details”** → navigate to  
   `/owner/complexes/{complex.slug}/grounds/new`  
   (or `complex.id` if no slug). So the **complex is chosen in step 1**; step 2 is the ground form.

### 2.2 Entry B: From complex detail

- **URL:** `/owner/complexes/:slug` (ComplexDetail).
- **Action:** “Add ground” → navigate to `/owner/complexes/:complexSlug/grounds/new`.
- No “choose complex” step; the complex comes from the URL.

### 2.3 Ground form (AddEditGroundArena)

- **URL (create):** `/owner/complexes/:complexSlug/grounds/new`.
- **Params:** `complexSlug` from route.

**Load:**

1. `GET /api/complexes/:complexSlug` → set `complex` (name, id, slug). If complex not found → “Complex not found” screen + link back to `/owner/complexes`.
2. If **editing** (`/owner/grounds/:slug/edit`): `GET /api/grounds/:slug` → fill form; optionally load complex by `complex_id` if not from URL.

### 2.4 Form fields (create/edit)

- **Basic:** Name *, Sport type * (grid from `sportConfigs`), Description, Dimensions (e.g. 100x40 ft).
- **Toggles:** Lighting (night play), Status (active = bookable).
- **Facilities:** Same pattern as complex — grid from `facilityConfigs`, stored as `selectedFacilities`.
- **Operating hours:** Start time, End time (e.g. 06:00–22:00). Sent in form; backend may or may not persist (check Ground model).
- **Pricing:** Base price per hour (required).
- **Images:** `MediaUpload` with `modelType="Ground"`, `modelId` when editing.

### 2.5 Submit (create)

- **Method:** `POST`.
- **URL:** `API_BASE_URL/grounds`.
- **Body:**
  - `complex_id`: from `complex.id` (required).
  - `name`, `type` (sportType), `description`, `dimensions`
  - `lighting`: `'1'` or `'0'`.
  - `price_per_hour`: string from `defaultPricing`
  - `amenities`: `selectedFacilities`
  - `status`: `'active'` or `'inactive'`
  - `images`: array

### 2.6 Backend (GroundController::store)

- **Validation:** `complex_id` (required, exists), `name`, `price_per_hour`, `type`, etc.
- **Auth check:** `Complex::find(complex_id)` → must have `complex->owner_id == auth()->id()` (or admin). Else `403 Unauthorized`.
- **Create:** `Ground::create($validated)`.
- **Response:** `201` + ground JSON.

### 2.7 After success

- Toast: “Ground created successfully!”
- **Navigate:** `/owner/complexes/{complexSlug}` (complex detail) or `/owner/complexes` if no ref.

### 2.8 Edit ground

- **URL:** `/owner/grounds/:slug/edit`.
- **Load:** `GET /api/grounds/:slug`; complex loaded by `complex_id` if not in URL.
- **Submit:** `PUT /api/grounds/:slug`; backend checks `ground->complex->owner_id == auth()->id()` then updates.

---

## 3. Booking detail flow (owner view)

This is the **single-booking screen** where the owner sees full info and can Accept/Decline or mark cash paid.

### 3.1 How you get there

- From **Owner Bookings** list (`/owner/bookings`) → click “View” on a row → `/owner/bookings/:id`.
- Or from **Dashboard** “Recent Bookings” → link to same URL.
- **Component:** `BookingDetails.tsx`.

### 3.2 Load booking

- **Request:** `GET /api/bookings/:id`.
- **Headers:** `Authorization: Bearer <token>`.

**Backend (BookingController::show):**

- Resolve booking (with `user`, `ground.complex`).
- **Access:** Allowed only if:
  - current user is **owner** of the booking’s ground’s complex (`booking->ground->complex->owner_id === user->id`), or
  - current user is the **customer** (`booking->user_id === user->id`), or
  - current user is **admin**.
- Else `403 Unauthorized`.
- **Response:** Full booking object (with `user`, `ground`, `ground.complex`).

### 3.3 What the detail screen shows

- **Status card:** Booking status (pending / confirmed / cancelled / completed), ground name, type, total price, payment status badge.
- **Booking info:** Date, time slot (start–end), players, total price.
- **Customer details:** Name (from `user` or `customer_name`), email, phone (or “Walk-in” if no user).
- **Pending actions (sidebar):**
  - If **status === 'pending'**: buttons **Accept Booking** and **Decline Booking**.
  - If **payment_status === 'unpaid'**: button **Mark as Paid (Cash)**.
- **Activity timeline:** Created at; if status changed, updated at.

### 3.4 Accept booking

- **Action:** Click “Accept Booking” → confirm dialog.
- **Request:** `PUT /api/bookings/:id` with body `{ "status": "confirmed" }`.
- **Backend (BookingController::update):**
  - Same owner/customer/admin check.
  - User can only set status to `cancelled`; owner (or admin) can set `confirmed` / `cancelled`.
  - Update booking; if status changed to `confirmed`, optional email (BookingConfirmed) and in-app notification to customer.
- **Frontend:** Toast “Booking accepted”; response replaces local `booking` state.

### 3.5 Decline booking

- **Action:** Click “Decline Booking” → confirm.
- **Request:** `PUT /api/bookings/:id` with body `{ "status": "cancelled" }` (or backend may use `rejection_reason` if sent).
- **Backend:** Same update logic; owner can set status to cancelled; notification to customer if implemented.
- **Frontend:** Toast “Booking declined”; state updated.

### 3.6 Mark as paid (cash / COD)

- **Action:** Click “Mark as Paid (Cash)” → confirm.
- **Request:** `POST /api/bookings/:id/finalize-payment` (no body needed).
- **Headers:** `Authorization: Bearer <token>`.

**Backend (BookingController::finalizePayment):**

- Allowed only if `booking->ground->complex->owner_id === user->id` or admin.
- Updates: `payment_status = 'paid'`, `payment_method = 'cash'`, `payment_expires_at = null`.
- Returns updated booking (e.g. in `updated.booking` or full response depending on implementation).

**Frontend:** Toast “Payment finalized successfully”; sets `booking` from response so “Mark as Paid” hides and badge shows paid.

### 3.7 Navigation

- “Back to Bookings” → `navigate(-1)` or `/owner/bookings`.
- If booking not found (404 or 403): message + link to “View All Bookings” (`/owner/bookings`).

---

## 4. Quick reference

| Flow            | Entry route(s)                          | Main API (create/update)              | Success redirect / stay      |
|----------------|------------------------------------------|----------------------------------------|------------------------------|
| Add complex    | `/owner/complexes/new`                   | `POST /api/complexes`                  | → `/owner/complexes`         |
| Edit complex   | `/owner/complexes/:slug/edit`            | `PUT /api/complexes/:slug`             | → `/owner/complexes`         |
| Add ground     | `/owner/grounds/new` → choose complex → `/owner/complexes/:slug/grounds/new` | `POST /api/grounds` (with `complex_id`) | → `/owner/complexes/:slug`   |
| Edit ground    | `/owner/grounds/:slug/edit`              | `PUT /api/grounds/:slug`               | → complex or `/owner/complexes` |
| Booking detail | `/owner/bookings/:id`                    | `GET /api/bookings/:id`                | Same page                    |
| Accept booking | From booking detail                     | `PUT /api/bookings/:id` `{ status: 'confirmed' }` | Same page                    |
| Decline booking| From booking detail                     | `PUT /api/bookings/:id` `{ status: 'cancelled' }` | Same page                    |
| Finalize cash  | From booking detail                     | `POST /api/bookings/:id/finalize-payment` | Same page                    |

---

## 5. Data flow summary

- **Complex:** Owner creates complex → `owner_id` = current user; list/filter by `owner_id` for owner.
- **Ground:** Always has `complex_id`; backend ensures `complex->owner_id` = current user (or admin) on create/update/delete.
- **Booking:** Owner sees bookings where `booking->ground->complex->owner_id` = current user; can confirm/cancel and finalize cash. Manual owner-created bookings are stored with `status = 'confirmed'` by backend.

Use this doc to trace each step from UI to API to backend when deploying or replicating these flows (e.g. in the Flutter app).
