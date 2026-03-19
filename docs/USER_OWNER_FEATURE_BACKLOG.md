# User + Owner Remaining Work (Flutter Backlog)

This is a **code-based backlog** of missing / incomplete / mismatched items for the Flutter app (`sports_studio_app`) for **User** and **Owner** roles.

Each item includes **why it matters**, where it lives in code, and what to implement.

---

## P0 (Must fix first: correctness / crashes / broken navigation)

### 1) Fix invalid Dart in `api_services.dart` (`?value` syntax)

- **Where**
  - `lib/core/network/api_services.dart`
  - Example occurrences:
    - query params: `'complex_id': ?complexId`
    - map payload: `'user_name': ?userName`
    - payload: `'dimensions': ?dimensions`
- **Why**
  - `?complexId` is **not valid Dart syntax** and will break compilation/analyze.
- **Implementation**
  - Replace with proper null-handling:
    - `if (complexId != null) 'complex_id': complexId`
    - or `'complex_id': complexId` and rely on Dio to omit nulls (but this must be confirmed).

### 2) Fix route mismatch: `/event-details` vs `/event-detail`

- **Where**
  - `lib/features/user/controller/events_controller.dart` navigates to `Get.toNamed('/event-details', ...)`
  - `lib/main.dart` only registers `/event-detail`
- **Why**
  - Event creation success flow navigates to a route that doesn’t exist → runtime error / blank page.
- **Implementation**
  - Standardize to `/event-detail` everywhere.

### 3) Fix `PaymentController` navigation routes that don’t exist

- **Where**
  - `lib/features/user/controller/payment_controller.dart`
    - `Get.offAllNamed('/landing')` (not registered; landing is `/`)
    - `Get.offAllNamed('/my-bookings')` (not registered; you have `/user-bookings` and `/owner-bookings`)
    - `Get.toNamed('/transaction-details')` (not registered)
- **Why**
  - Payment flow will succeed but then fail to navigate.
- **Implementation**
  - Replace:
    - `/landing` → `/`
    - `/my-bookings` → `/user-bookings` (for user) and/or conditional based on role
    - Implement `TransactionDetailPage` + route, or remove the call for now.

---

## P1 (User experience + backend correctness)

### 4) Booking slot UX: disable past slots + enforce opening/closing hours

- **Where**
  - Slot list is hard-coded in `BookingController.allSlots`
  - Availability is computed by overlaps in `BookingController.fetchAvailability`
- **Why**
  - Users should not be able to pick **past time slots** for today; also grounds should not show times outside their operating hours.
- **Implementation**
  - In `BookingSlotPage` (UI) and/or `BookingController.toggleSlot`, prevent selecting:
    - any slot earlier than current time (when selected date is today)
    - any slot outside `opening_time`–`closing_time` from ground details

### 5) Payments: ensure user payment finalization matches backend rules

- **Where**
  - `PaymentController.initiateSafepayPayment` calls `BookingApiService.finalizePayment(bookingId)`
  - Owner uses `POST /bookings/{id}/finalize-payment` (cash/COD) in `BookingsController.markAsPaid`
- **Why**
  - If backend restricts `finalize-payment` to owner/admin or expects Safepay webhook verification, user-side finalization may be invalid.
- **Implementation**
  - Align with backend:
    - For Safepay: after checkout return, call a backend `verify` endpoint (if exists) or re-fetch booking status.
    - For COD: ensure status stays `pending` until owner confirms.

### 6) Promo codes: move from client-side to server-side validation

- **Where**
  - `BookingController.applyPromoCode` downloads all deals (`GET /public/deals`) and validates locally.
- **Why**
  - Insecure + inefficient; users can spoof discounts by submitting a lower `total_price`.
- **Implementation**
  - Add backend endpoint like `POST /deals/validate` or include `deal_code` in booking create; backend calculates final price.
  - Flutter should send `promo_code` / `deal_id`, not modify `total_price` directly.

### 7) Transactions: add transaction details page

- **Where**
  - `TransactionsPage.onTap` is a placeholder
  - `PaymentController.getTransaction` navigates to `/transaction-details` (missing route/screen)
- **Why**
  - Users need a receipt: booking reference, gateway details, status timeline.
- **Implementation**
  - Create `TransactionDetailPage` and route; use `GET /transactions/{id}` if available.

### 8) Teams: implement membership checks (`isUserTeamMember`)

- **Where**
  - `TeamsController.isUserTeamMember` always returns `false`
- **Why**
  - UI logic like “Join/Leave” or “Member badge” will be wrong.
- **Implementation**
  - Use `ProfileController.userProfile['id']` and check `team.members` list (ensure `Team` model includes members).

### 9) Events: joining/payment statuses + private/public rules

- **Where**
  - `EventsController.joinEvent` sets `status: confirmed` immediately
- **Why**
  - Backend often uses `pending` then `accepted` for private events, and may require payment flows for paid events.
- **Implementation**
  - Align join payload with backend:
    - public event: accepted/confirmed
    - private event: pending + organizer approval flow
    - paid registration: initiate payment and only mark paid on verification

---

## P2 (Owner completeness)

### 10) Owner: Complex CRUD completeness and consistent response parsing

- **Where**
  - Owner uses `/complexes` in `OwnerController` and `ComplexApiService`
  - Some code expects `response.data['data']`, other code handles `List` vs `Map`
- **Why**
  - Breaks depending on backend shape; owners may see empty lists.
- **Implementation**
  - Centralize response parsing helper for paginated/non-paginated responses.
  - Ensure create/update/delete complex is wired in UI if missing.

### 11) Owner: Ground edit flow + image management

- **Where**
  - `GroundApiService.uploadGroundImages` uses `/grounds/{id}/images` with `_method: PUT`
  - `AddGroundController` uses `/upload` then POST `/grounds` with `images: [url]`
- **Why**
  - Two competing image flows; one might not exist on backend.
- **Implementation**
  - Pick a single approach matching backend:
    - either keep `/upload` + include urls in create/update
    - or implement `/grounds/{id}/images` backend route

### 12) Owner: Booking detail actions and consistent statuses

- **Where**
  - `BookingsController.updateBookingStatus` uses `PUT /bookings/{id}` with `status=confirmed/cancelled` and `payment_status=refunded`
- **Why**
  - Need consistency with backend allowed transitions and UI badge mapping.
- **Implementation**
  - Define exact status enum mapping (confirmed/pending/cancelled/completed) and enforce it in UI + API payloads.

---

## P3 (Polish / security / performance)

### 13) Reduce sensitive logging

- **Where**
  - Many controllers print raw responses (`AuthController`, `BookingsController`, `GroundsController`, etc.)
- **Why**
  - Logs can expose PII/tokens in production builds.
- **Implementation**
  - Gate logs by `kDebugMode` and avoid printing full response bodies.

### 14) Phone verification should be a true guard (optional)

- **Where**
  - `AuthController._navigateToHome` shows a dialog but doesn’t block navigation/actions.
- **Why**
  - If phone verification is required before booking/payment, users can bypass.
- **Implementation**
  - Add a shared guard wrapper (route middleware-like) or enforce on booking/payment entry points.

