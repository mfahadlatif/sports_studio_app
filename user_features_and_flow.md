# User Features & Application Flow (Code-Matched) ⚽🏆

This document details the player-facing functionalities, UI components, and real-time mechanisms implemented in the **Sports Studio Web** application.

---

## 1. Authentication & Trust System 🛡️

### Identity Verification
- **Login Methods**:
  - Email/Password (Sanctum)
  - Google Social Auth (`@react-oauth/google`).
- **Phone Verification System (Mandatory)**:
  - **Component**: `PhoneVerificationDialog` and `PhoneVerificationGuard`.
  - **Logic**: Triggered before any booking. Sends 6-digit OTP via Firebase.
  - **Security**: Invisible reCAPTCHA to prevent bot spam.
  - **UX**: 60-second resend limit with a live countdown timer.

---

## 2. Discovery & Search UX 🔍
- **Page**: `UserHome.tsx` / `UserGrounds.tsx` / `ExploreGrounds`
- **Lucide Icons**:
  - `Search`: Primary interaction icon.
  - `MapPin`: Location-based discovery.
  - `Sparkles`: "Find your next match" badge.
  - `Filter`: Access to advanced sorting.
- **Search Features**:
  - **Location Autocomplete**: Powered by `LocationAutocomplete` component using `react-leaflet`.
  - **Sport Categories**: Scrollable pill-based filters for 8 primary sports.
  - **Advanced Filters**: Dropdown selection for Minimum Rating (4.0+, 4.5+, 4.8+) and Price Ranges (Under 1000, 1000-5000, etc.).

---

## 3. Ground Booking & The "20-Minute Lock" ⏳
- **Page**: `BookingSlot.tsx`
- **Mechanism**: Prevents "Slot Squatting" by temporarily reserving inventory.
1. **Initiation**: User selects a 1-hour slot and clicks "Book Now". 
2. **Backend Lock**: `POST /api/bookings` sets `payment_status = 'unpaid'` and `payment_expires_at = now() + 20 minutes`.
3. **Frontend Timer**: A real-time `CountdownTimer` (20:00) starts on the Payment page.
4. **Expiry**: If timer hits 0:00, the "Pay" button is disabled. The backend cron/query logic releases the slot automatically by ignoring bookings where `payment_expires_at < now()`.

---

## 4. Checkout & Payment 💳
- **Page**: `Payment.tsx`
- **Payment Options**:
  - **Online (Safepay)**: Redirects to secure checkout. Success is verified via backend signature recalculation (`/api/safepay/verify`).
  - **COD (Cash on Delivery)**: Bypasses immediate payment but keeps the booking in `pending` status. Requires manual Owner confirmation on-site.
- **Promo Codes**: Validates against the `deals` table for:
  - `applicable_sports` accuracy.
  - `valid_until` date expiry.
  - One-time usage (if logic applied).

---

## 5. Event Participation 🏅
- **Page**: `EventDetails.tsx` / `UserEvents.tsx`
- **Flow**:
  - **Joining**: Users join `Public` events instantly or request access for `Private` ones.
  - **Private Events**: Visible ONLY via a "Secure Link" shared by the organizer (Clipboard Logic).
  - **Capacity Check**: Progress bar showing `participants_count` / `max_participants`.
  - **Approval**: Users await Organizer approval (`pending` -> `accepted`).

---

## 6. Community & Teams 👥
- **Page**: `Teams.tsx` / `TeamDetail.tsx`
- **Features**:
  - **Create Team**: Add members by email/ID.
  - **Challenges**: (Logic for future leagues/challenges).

---

## 7. Icons & Visual Metadata 🎨

### Sport Categories (Emojis)
- 🏏 Cricket
- ⚽ Football
- 🎾 Tennis
- 🎾 Padel Arena
- 🏐 Volleyball
- 🏑 Hockey
- 🏀 Basketball
- 🏸 Badminton

### UI Components
- **Toasts**: `Sonner` used for error/success feedback (e.g., "OTP Sent!", "Locking your slot...").
- **Spinners**: `LoadingSpinner` with descriptive text ("Consulting our stadium directory...").
- **Glassmorphism**: Persistent use of `backdrop-blur-xl`, `bg-white/10`, and `blur-3xl` backgrounds.

---

## 8. Notifications 🔔
- **Component**: `Notifications.tsx`
- **Database**: `notifications` table.
- **Types**:
  - `Booking Confirmed`
  - `Event Approval`
  - `Payment Reminder`
  - `Promotional Offer` (based on `deals`).
