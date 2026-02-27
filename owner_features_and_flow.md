# Owner Features and Application Flow (Code-Matched) 🏟️

This document details the exact functionalities, UI components, and data structures implemented in the **Sports Studio Web** application for the **Owner** role.

---

## 1. Authentication & Portfolio Setup 🔐

### Login & Auth Details
- **Page**: `OwnerLogin.tsx`
- **Fields (Auth)**:
  - `email` (Input: Text)
  - `password` (Input: Password)
- **Database (Users Table)**:
  - `role`: Must be `owner`.
  - `business_name`: (Optional) Displayed in owner profiles.
  - `phone`: Verified mobile number.
  - `is_active`: Boolean status for account access.

### Security
- **Sanctum Token Auth**: Stores `access_token` in local storage.
- **Protected Routes**: All owner pages are wrapped in `<ProtectedRoute>` component.
- **Redirect Logic**: Handled in `OwnerAuth.tsx` to route users based on role.

---

## 2. Owner Dashboard (Overview) 📊
- **Page**: `OwnerDashboard.tsx`
- **Lucide Icons Used**:
  - `Building2`: Total Complexes
  - `MapPin`: Total Grounds
  - `Calendar`: Total Bookings
  - `DollarSign`: Total Revenue
  - `Layers`: Ground counter per complex card.
  - `ArrowRight` / `Plus`: Navigation to management pages.
- **Statistics Section** (Fetched from `/api/owner/stats`):
  - `total_complexes`: Count of complexes owned.
  - `total_grounds`: Total number of playing areas across all complexes.
  - `total_bookings`: Historical count of all reservations.
  - `total_revenue`: Sum of `total_price` for all finalized `paid` bookings.
  - `monthly_revenue`: Cumulative revenue for the active calendar month.
- **Quick Actions**:
  - `Add Sports Complex` -> `/owner/complexes/new`
  - `Add Ground` -> `/owner/grounds/new`
  - `Manage Complexes` -> `/owner/complexes`

---

## 3. Sports Complex Management 🏢
- **Controller**: `ComplexController.php`
- **Database Fields (`complexes`)**:
  - `id`, `owner_id`, `name`, `address` (Text), `description` (Text), `images` (JSON), `amenities` (JSON), `status` ('active'/'inactive'), `rating`.
- **Flow**:
  1. **Listing**: `SportsComplexes.tsx` shows cards with complex names, addresses, and ground counts.
  2. **Add/Edit**: `AddEditComplex.tsx`.
     - **Location Integration**: Uses `LocationAutocomplete` (via `react-leaflet`) to store `address`, `latitude`, and `longitude`.
     - **Status Toggle**: `Switch` component for `active`/`inactive`.
     - **Facility Selection**: Multi-select emoji grid based on `facilityConfigs`.

### Facility Set (Emoji-Based) 🅿️
Stored in `ownerMockData.ts`:
- `parking` -> 🅿️ Parking
- `washrooms` -> 🚻 Washrooms
- `changing-rooms` -> 🚿 Changing Rooms
- `seating` -> 💺 Seating Area
- `lighting` -> 💡 Floodlights
- `cafe` -> ☕ Café / Refreshments
- `first-aid` -> 🏥 First Aid
- `wifi` -> 📶 WiFi
- `lockers` -> 🔐 Lockers
- `equipment` -> 🎯 Equipment Rental

---

## 4. Ground / Arena Management 🏟️
A ground creation follows a **Two-Step UX Flow**.

### Step 1: Complex Mapping
- **Page**: `AddGround.tsx`
- **Logic**: Owners scan their portfolio using a `Search` input to select which `Complex` the new ground belongs to. 
- **Icons**: `Building2`, `CheckCircle2`, `ChevronRight`.

### Step 2: Arena Creation/Editing
- **Page**: `AddEditGroundArena.tsx`
- **Controller**: `GroundController.php`
- **Database Fields (`grounds`)**:
  - `complex_id`, `name`, `type` (Selected Sport), `description`, `price_per_hour`, `dimensions`, `images` (JSON), `amenities` (JSON), `lighting` (Boolean), `status` ('active'/'inactive').
- **UI Logic**:
  1. **Sport Selection**: `sportConfigs` grid with high-visibility emojis.
  2. **Operating Hours**: `Input type="time"` for start/end, with `Clock` icon interaction.
  3. **Pricing**: Base rate per hour (Default).
  4. **Media Module**: `MediaUpload` handling storage/retrieval via `/api/media/serve`.

### Sport Type Set (Emoji-Based) 🏏
- `cricket` -> 🏏 Cricket
- `football` -> ⚽ Football
- `tennis` -> 🎾 Tennis
- `padel` -> 🎾 Padel
- `volleyball` -> 🏐 Volleyball
- `hockey` -> 🏑 Hockey
- `basketball` -> 🏀 Basketball
- `badminton` -> 🏸 Badminton

---

## 5. Booking & Schedule Operations 📅
- **Page**: `OwnerBookings.tsx` / `BookingDetails.tsx`
- **Controller**: `BookingController.php`
- **Feature Set**:
  - **Status Badges**:
    - `paid`: Green UI (`bg-green-500/10`)
    - `unpaid`: Red UI (`bg-red-500/10`)
    - `pending`: Yellow UI (`bg-yellow-500/10`)
  - **Finalize Payment Logic**: A `Confirm Payment` action triggers the `/api/bookings/{booking}/finalize-payment` endpoint, marking COD bookings as `paid`.
  - **20-Minute Payment Lock**: The frontend acknowledges the `payment_expires_at` timestamp from the backend to mark slots as "Locked" in real-time.

---

## 6. Financial Ledger & Reports 📈
- **Page**: `OwnerReports.tsx` / `OwnerSettings.tsx`
- **Logic**:
  - Aggregating data from `transactions` table.
  - **Platform Fee**: Explicitly calculates 15% platform fee for event-related bookings.
  - **Settlement Tracking**: Status tags for "Sent to Bank", "Pending Settlement", etc.

---

## 7. Deals & Promotions 🏷️
- **Page**: `OwnerDeals.tsx`
- **Controller**: `DealController.php`
- **Management Fields**:
  - `title`: Name of promotion.
  - `code`: Custom string (e.g., `SUMMER2026`).
  - `discount_percentage`: Value (1-100%).
  - `valid_until`: Date picker with `Calendar` icon.
  - `ground_id`: (Optional) Limit a deal to a specific pitch.
- **Icons**: `Tag`, `Trash2`, `Edit`.

---

## 8. Review Moderation 💬
- **Page**: `ReviewModeration.tsx`
- **Controller**: `ReviewController.php`
- **Functionality**:
  - **Visibility Toggle**: `/api/reviews/{id}/status` allows switching between `active` and `hidden` to suppress spam.
  - **Deletion**: Permanent removal via `/api/reviews/{id}`.
  - **Search/Filter**: Search by comment content or filter by specific ground names.
- **Icons**: `Eye`, `EyeOff`, `MessageSquare`, `Star`.
