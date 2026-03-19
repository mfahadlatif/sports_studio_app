# User + Owner Implementation Plan (Flutter)

Goal: implement missing items in the Flutter app in the **right order**, so core flows (booking + payment + owner operations) are stable before adding new features.

This plan is derived from:
- `lib/main.dart` routes
- User controllers: `booking_controller.dart`, `payment_controller.dart`, `events_controller.dart`, `teams_controller.dart`, `favorites_controller.dart`, `home_controller.dart`
- Owner controllers: `bookings_controller.dart`, `owner_controller.dart`, `grounds_controller.dart`, `add_ground_controller.dart`
- Network layer: `api_client.dart`, `api_services.dart`

---

## Phase 0 — Stabilize the app (1–2 sessions)

### A) Fix broken routes + navigation targets

- Standardize **events** route:
  - Replace any `/event-details` with `/event-detail`
- Fix payment redirects:
  - `/landing` → `/`
  - `/my-bookings` → `/user-bookings` (or conditional: owner → `/owner-bookings`)
  - Decide: add `/transaction-details` route (recommended) or remove navigation until implemented

### B) Fix invalid Dart syntax in `api_services.dart`

- Replace all `?variable` occurrences inside maps with real Dart null-handling.
- Run `flutter analyze` after fixing.

Deliverable: user can create an event / pay / navigate without runtime route errors; project analyzes cleanly.

---

## Phase 1 — Make booking + payment correct (2–4 sessions)

### A) Booking slot rules (past time + operating hours)

- Disable selecting time slots in the past when booking date is “today”
- If ground contains `opening_time`/`closing_time`, only show/select slots within that range

### B) Promo code security (server-side)

Recommended approach:
- Flutter sends `promo_code` (or `deal_id`) in booking create request.
- Backend returns final computed totals (subtotal/discount/total).
- Flutter UI shows totals from backend response and never trusts client computed totals for payment.

### C) Safepay flow alignment

Decide a single “source of truth”:
- either Safepay success means: call backend verify endpoint then fetch booking status
- or rely solely on webhook + poll booking status

Deliverable: booking cannot be underpaid by editing client totals; payment success leads to correct booking status in UI.

---

## Phase 2 — Finish “missing screens” and placeholders (1–3 sessions)

### A) Transaction details screen

- Create `TransactionDetailPage`
- Add GetX route `/transaction-detail` (or `/transaction-details` but keep it consistent)
- Wire `TransactionsPage.onTap` to navigate and show:
  - amount, status, date/time, method, booking reference, gateway metadata (if present)

### B) Teams membership correctness

- Update `Team` model to include members (if backend returns them)
- Implement `TeamsController.isUserTeamMember`
- Update Teams UI to show correct Join/Leave/Member states

### C) Events joining states

- Support private event “request” → “pending” → “accepted”
- For paid events:
  - add a payment flow similar to bookings, or block join until paid (depending on backend)

Deliverable: transactions are usable, teams behave correctly, events flows match backend statuses.

---

## Phase 3 — Owner feature hardening (1–3 sessions)

### A) Complex and ground response-shape consistency

- Add a shared helper to parse backend list responses (Map pagination vs raw List)
- Ensure **owner dashboard complexes** works regardless of response shape

### B) Ground image management consistency

- Decide one image strategy:
  - (1) `/upload` + store URLs in `images`
  - (2) `/grounds/{id}/images` endpoint
- Remove/replace the unused strategy to avoid future confusion.

### C) Booking status transitions + display

- Create a single status mapping table in Flutter:
  - booking status: pending/confirmed/cancelled/completed
  - payment status: unpaid/paid/refunded
- Ensure OwnerBookingsView filters and badges match these definitions.

Deliverable: owner dashboard + grounds + bookings are consistent and predictable.

---

## What we implement first

**Start with Phase 0A + 0B**, because these are fast fixes that unblock everything else and prevent runtime errors.

