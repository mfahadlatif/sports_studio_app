# Owner Features – Deploy View (Website & App)

This document describes **each owner feature** on the **Cricket Oasis Bookings website** (`cricket-oasis-bookings`), with **flows** and **detail screens**. Your **Sport Studio app** uses the same backend and mirrors these features.

---

## 1. Entry & navigation

| Where | What |
|-------|------|
| **Website** | Owner login: `/owner/login` or `/owner/auth` → redirects to `/owner/dashboard`. |
| **Layout** | All owner pages use `OwnerLayout` with **OwnerSidebar** (Dashboard, Sports Complexes, My Grounds, Bookings, Reports, Settings, Hot Deals, Reviews). |
| **App** | Owner role at login → landing shows: Dashboard \| Manage (grounds) \| Bookings \| Settings \| Profile. |

---

## 2. Feature-by-feature: flows & detail screens

### 2.1 Auth (owner)

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **Login** | `/owner/login`, `/owner/auth` | Email/password → `POST /api/login` (role owner) → redirect `/owner/dashboard`. | `OwnerLogin.tsx` – form, forgot password link. |
| **Forgot password** | `/owner/forgot-password` | Submit email → backend sends reset link. | `OwnerForgotPassword.tsx`. |
| **Reset password** | `/owner/reset-password` | Token in URL → set new password → redirect to dashboard. | `OwnerResetPassword.tsx`. |

---

### 2.2 Dashboard

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **Dashboard** | `/owner/dashboard` | Load `GET /api/owner/stats` and `GET /api/complexes?owner_id=...`. | **OwnerDashboard.tsx**: “Current Status” strip (total bookings, monthly revenue, complexes, grounds); stat cards (Total Complexes, Total Grounds, Total Bookings, Total Revenue); “My Complexes” list with links to complex detail; “Recent Bookings” with link to booking detail; quick links (Reports, Complexes, Add Complex, Add Ground, Deals, Reviews). |

**Flow:** Login → Dashboard → click complex → Complex Detail; click booking → Booking Detail; click “Reports” / “Add Complex” etc. → respective screen.

---

### 2.3 Sports complexes

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **List** | `/owner/complexes` | `GET /api/complexes?owner_id=...` with pagination. | **SportsComplexes.tsx**: search, grid/list toggle, pagination; each card: name, location, ground count, status, image; actions: View, Edit, Delete. “Add complex” → `/owner/complexes/new`. |
| **Add complex** | `/owner/complexes/new` | Form submit → `POST /api/complexes`. | **AddEditComplex.tsx**: name, address, description, status, amenities, images (create mode). |
| **Complex detail** | `/owner/complexes/:slug` | `GET /api/complexes/:slug`. | **ComplexDetail.tsx**: complex info, image gallery, facilities, list of grounds; “Add ground” → `/owner/complexes/:complexSlug/grounds/new`; per ground: View → Ground Detail, Edit → edit ground. Edit complex → `/owner/complexes/:slug/edit`. |
| **Edit complex** | `/owner/complexes/:slug/edit` | Form submit → `PUT /api/complexes/:id`. | **AddEditComplex.tsx** (edit mode, same component). |

**Flow:** Dashboard / Sidebar “Sports Complexes” → List → Add new **or** open complex → Detail → Add/Edit ground or Edit complex.

---

### 2.4 My grounds

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **List** | `/owner/grounds` | `GET /api/complexes?owner_id=...` → flatten grounds. | **ManageGrounds.tsx**: search, grid/list, ground cards (name, location, price, sport, status); View → Ground Detail, Edit, Delete. “Add ground” → `/owner/grounds/new` (choose complex then redirect to add under that complex). |
| **Add ground (choose complex)** | `/owner/grounds/new` | Pick complex → navigate to `/owner/complexes/:complexSlug/grounds/new`. | **AddGround.tsx** – complex selector only. |
| **Add ground (form)** | `/owner/complexes/:complexSlug/grounds/new` | Form submit → `POST /api/grounds`. | **AddEditGroundArena.tsx**: name, type/sport, price, description, status, lighting, amenities, hours, images. |
| **Ground detail** | `/owner/grounds/:slug` | `GET /api/grounds/:slug`, `GET /api/bookings?ground_id=...&date=...`. | **GroundDetail.tsx**: ground info, gallery, sport, price, status; date picker; **bookings for selected date** (slots); “Edit ground” → `/owner/grounds/:slug/edit`. |
| **Edit ground** | `/owner/grounds/:slug/edit` | Form submit → `PUT /api/grounds/:id`. | **AddEditGroundArena.tsx** (edit mode). |

**Flow:** Sidebar “My Grounds” → List → Add ground (choose complex → add form) **or** open ground → Detail (see bookings by date) → Edit.

---

### 2.5 Bookings

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **List** | `/owner/bookings` | `GET /api/bookings` (owner-scoped) with filters (all / confirmed / cancelled / completed), search, pagination. | **OwnerBookings.tsx**: filters, search, “Manual booking” button; table/cards: customer, ground, complex, date, time, amount, status, payment; actions: View, Confirm, Reject, Cancel. Manual booking opens **ManualBookingDialog** (ground, customer name/phone/email, date, time, players, total price) → `POST /api/bookings` (owner-created = confirmed). |
| **Booking detail** | `/owner/bookings/:id` | `GET /api/bookings/:id`. | **BookingDetails.tsx**: full booking info (customer, contact, ground, date/time, players, amount, status, payment status); actions: **Confirm** / **Reject** (`PUT /api/bookings/:id`), **Finalize payment (COD)** (`POST /api/bookings/:id/finalize-payment`), optional rejection reason. |

**Flow:** Dashboard “Recent Bookings” or Sidebar “Bookings” → List → filter/search → View → Detail → Confirm/Reject or Finalize COD; or create **Manual booking** from list.

---

### 2.6 Reports & analytics

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **Reports** | `/owner/reports` | `GET /api/owner/reports?period=today|week|month|year`. | **OwnerReports.tsx**: period selector (Today / This Week / This Month / This Year); stats (total revenue, total bookings, avg booking value, unique customers, pending settlement); **revenue trend** chart; **top games**; **duration stats**; **payment breakdown**; **Export** (e.g. CSV). |

**Flow:** Sidebar “Reports” → choose period → view charts and export.

---

### 2.7 Settings

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **Settings** | `/owner/settings` | Load `GET /api/me`; update profile / password via API if available. | **OwnerSettings.tsx**: **Profile** (name, email, phone, business name), **Password** (current, new, confirm), **Notifications** (email bookings/payments, SMS bookings/reminders – stored locally or from backend); Logout. |

**Flow:** Sidebar “Settings” → edit profile / password / notifications → save.

---

### 2.8 Hot deals

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **Deals** | `/owner/deals` | `GET /api/deals?owner_id=...`; create/update/delete via API. | **OwnerDeals.tsx**: list of deals (title, description, discount %, valid until, code, optional ground); **Create/Edit** in dialog: title, description, discount %, valid until, code, optional ground; Delete with confirm. |

**Flow:** Sidebar “Hot Deals” → list → Add deal (dialog) or Edit/Delete existing.

---

### 2.9 Reviews (moderation)

| Item | Website | Flow | Detail screen |
|------|---------|------|----------------|
| **Reviews** | `/owner/reviews` | Load owner’s grounds → for each ground `GET /api/public/reviews?ground_id=...` → merge; `PUT /api/reviews/:id/status`, `DELETE /api/reviews/:id`. | **ReviewModeration.tsx**: filter by ground; list reviews (user, rating, comment, ground, date); **Toggle active/hidden**; **Delete** with confirm. |

**Flow:** Sidebar “Reviews” → filter by ground → show/hide or delete review.

---

## 3. Website owner routes summary

| Route | Screen | Purpose |
|-------|--------|---------|
| `/owner/login`, `/owner/auth` | OwnerLogin | Login |
| `/owner/forgot-password` | OwnerForgotPassword | Request reset |
| `/owner/reset-password` | OwnerResetPassword | Set new password |
| `/owner/dashboard` | OwnerDashboard | Overview, stats, quick links |
| `/owner/complexes` | SportsComplexes | List complexes |
| `/owner/complexes/new` | AddEditComplex | Create complex |
| `/owner/complexes/:slug` | ComplexDetail | Complex detail + grounds |
| `/owner/complexes/:slug/edit` | AddEditComplex | Edit complex |
| `/owner/complexes/:complexSlug/grounds/new` | AddEditGroundArena | Add ground to complex |
| `/owner/grounds/new` | AddGround | Choose complex for new ground |
| `/owner/grounds` | ManageGrounds | List all grounds |
| `/owner/grounds/:slug` | GroundDetail | Ground detail + bookings by date |
| `/owner/grounds/:slug/edit` | AddEditGroundArena | Edit ground |
| `/owner/bookings` | OwnerBookings | List bookings + manual booking |
| `/owner/bookings/:id` | BookingDetails | Booking detail, confirm/reject, finalize COD |
| `/owner/reports` | OwnerReports | Analytics, period, export |
| `/owner/settings` | OwnerSettings | Profile, password, notifications |
| `/owner/deals` | OwnerDeals | CRUD deals |
| `/owner/reviews` | ReviewModeration | Moderate reviews |

---

## 4. App vs website (owner)

- **Backend:** Same API (`cricket-oasis-bookings/backend`). App uses production Hostinger API or local XAMPP.
- **Screens:** App has equivalent owner screens (dashboard, grounds, bookings, settings, reports, deals, review moderation, complexes, add/edit complex/ground, booking detail).
- **Flows:** Same logical flows (complex → grounds → bookings; confirm/reject/finalize; reports by period; deal CRUD; review show/hide/delete).

Use this doc as the **deploy view**: for each owner feature, you have the **website route**, **flow**, and **detail screen** in one place.
