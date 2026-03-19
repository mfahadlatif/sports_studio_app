# User + Owner Feature Map (Flutter)

This document maps the **current, code-implemented** features for the Flutter app in `sports_studio_app`, focusing on **User** and **Owner** roles.

## App routing (GetX)

Defined in `lib/main.dart` via `GetMaterialApp(getPages: [...])`.

- **Core**
  - `/onboarding` → `OnboardingPage`
  - `/` → `LandingPage`
  - `/auth` → `AuthPage`
- **User**
  - `/ground-detail` → `GroundDetailPage`
  - `/book-slot` → `BookingSlotPage`
  - `/payment` → `PaymentPage`
  - `/user-bookings` → `UserBookingsPage`
  - `/transactions` → `TransactionsPage`
  - `/deals` → `DealsPage`
  - `/notifications` → `NotificationsPage`
  - `/favorites` → `FavoritesPage`
  - `/teams` → `TeamsPage`
  - `/managed-events` → `ManagedEventsPage`
  - `/event-detail` → `EventDetailPage`
  - `/create-match` → `CreateMatchPage`
  - `/edit-profile` → `EditProfilePage`
  - `/setting-detail` → `SettingDetailPage`
  - `/privacy-policy` → `PrivacyPolicyPage`
  - `/contact` → `ContactPage`
- **Owner**
  - `/owner-reports` → `OwnerReportsPage`
  - `/sports-complexes` → `SportsComplexesPage`
  - `/complex-detail` → `ComplexDetailPage`
  - `/add-complex` → `AddComplexPage`
  - `/add-ground` → `AddEditGroundPage` (also used by owner)
  - `/owner-ground-detail` → `OwnerGroundDetailPage`
  - `/owner-deals` → `OwnerDealsPage`
  - `/review-moderation` → `ReviewModerationPage`
  - `/booking-detail` → `BookingDetailPage`
  - `/owner-bookings` → `OwnerBookingsView`

## Networking basics

- **Base URL**: `lib/core/network/api_client.dart`
  - `ApiClient.baseUrl` points to a deployed backend (`.../backend/public/api`)
- **Auth token**: stored in `FlutterSecureStorage` key `auth_token`
  - Automatically attached as `Authorization: Bearer <token>` via Dio interceptor

## User features (current)

### Authentication (login/register + role)

- **Controller**: `lib/features/auth/controller/auth_controller.dart`
- **Endpoints**
  - `POST /login`
  - `POST /register`
- **Role persistence**
  - Saved in `FlutterSecureStorage` key `user_role`
  - Restored at app start in `main.dart` and applied to `LandingController.currentRole`

### Phone verification (Firebase OTP + backend flag)

- **Controller**: `lib/features/auth/controller/phone_verification_controller.dart`
- **Endpoints**
  - `GET /phone-verification-status`
  - `POST /verify-phone` with `{ phone, verified: true }`
- **Behavior**
  - After login/register, app navigates to `/` then *non-blocking* dialog is shown if not verified (`AuthController._navigateToHome`)

### Discovery / browsing grounds

- **Home**: `lib/features/user/controller/home_controller.dart`
  - `GET /public/grounds` (stores raw data)
  - Filter client-side by: category, search, locationQuery, price, minRating, amenities, sort
- **Ground list + filtering**: `lib/features/user/controller/ground_controller.dart`
  - `GET /public/grounds` (typed `Ground` list)
  - `GET /public/complexes` (for complex filter list)

### Ground details + reviews

- **Ground details**: `GroundController.fetchGroundBySlug`
  - `GET /public/grounds/{slug}`
- **Public reviews**
  - `GET /public/reviews?ground_id=...` (via `ReviewApiService`)
  - `POST /public/reviews` (via `ReviewApiService`)

### Booking slots (availability) + booking creation

- **Controller**: `lib/features/user/controller/booking_controller.dart`
- **Availability source**
  - `GET /public/grounds/{groundId}/bookings?date=YYYY-MM-DD` (via `DataFetchService.fetchGroundBookings`)
  - Client computes overlaps to mark `bookedSlots`
- **Booking create**
  - `POST /bookings` with:
    - `ground_id`
    - `start_time` / `end_time` as `YYYY-MM-DD HH:mm:ss`
    - `total_price`
    - `players`

### Promo code (client-side validation)

- **Controller**: `BookingController.applyPromoCode`
- **Endpoint**
  - `GET /public/deals`
- **Behavior**
  - Finds deal by `code`
  - Checks `isActive`, `validUntil`, and `applicableSports` client-side
  - Discount is applied by reducing `total_price` sent to `POST /bookings`

### Payments (Safepay)

- **Controller**: `lib/features/user/controller/payment_controller.dart`
- **Safepay service**: `lib/core/services/safepay_service.dart`
- **Behavior**
  - Starts Safepay checkout via `SafepayService.initiateCheckout(amount)`
  - Opens `SafepayPaymentWidget`
  - On success, calls `BookingApiService.finalizePayment(bookingId)`

### Transactions (payment history)

- **Page**: `lib/features/user/presentation/pages/transactions_page.dart`
- **Controller**: `PaymentController.fetchTransactions`
  - `GET /transactions` (via `TransactionApiService.getUserTransactions`)
- **Known gap**
  - Transaction detail view is a placeholder (`onTap` does nothing)

### Favorites

- **Controller**: `lib/features/user/controller/favorites_controller.dart`
- **Endpoints**
  - `GET /favorites`
  - `POST /favorites` (add)
  - `DELETE /favorites/{groundId}` (remove)
- **Behavior**
  - Maintains `favorites` and `favoriteGrounds` lists

### Notifications

- **Controller**: `ProfileController.fetchNotifications` (see `lib/features/user/controller/profile_controller.dart`)
- **Endpoint**
  - `GET /notifications`

### Teams

- **Controller**: `lib/features/user/controller/teams_controller.dart`
- **Endpoints**
  - `GET /teams`
  - `POST /teams`
  - `GET /teams/{id}`
  - `PUT /teams/{id}`
  - `DELETE /teams/{id}`
  - `POST /teams/{id}/members`
  - `DELETE /teams/{id}/members/{userId}`
- **Known gap**
  - `isUserTeamMember(...)` is currently hardcoded `false` (placeholder)

### Events

- **Controller**: `lib/features/user/controller/events_controller.dart`
- **Endpoints**
  - `GET /public/events`
  - `GET /public/events/{idOrSlug}`
  - `POST /events` (create)
  - `PUT /events/{slug}` (update)
  - `DELETE /events/{slug}` (delete)
  - `POST /event-participants` (join)
  - `DELETE /event-participants/{participantId}` (leave)

## Owner features (current)

### Owner dashboard (stats + recent bookings + complexes)

- **View**: `lib/features/owner/presentation/widgets/owner_dashboard_view.dart`
- **Controller**: `lib/features/owner/controller/owner_controller.dart`
- **Endpoints**
  - `GET /owner/stats`
  - `GET /complexes`

### Grounds management (owner list + create + delete)

- **Controller**: `lib/features/owner/controller/grounds_controller.dart`
- **Endpoints**
  - `GET /grounds`
  - `GET /complexes`
  - `POST /grounds`
  - `DELETE /grounds/{id}`

### Add Ground (with image upload)

- **Controller**: `lib/features/owner/controller/add_ground_controller.dart`
- **Endpoints**
  - `POST /upload` (uploads single image, expects `{ url }`)
  - `POST /grounds` (creates ground; includes `images: [url, ...]`)

### Bookings management (owner)

- **View**: `lib/features/owner/presentation/widgets/owner_bookings_view.dart`
- **Controller**: `lib/features/owner/controller/bookings_controller.dart`
- **Endpoints**
  - `GET /bookings` (supports `?search=...`)
  - `PUT /bookings/{id}` (accept/decline with optional reason + `payment_status: refunded`)
  - `POST /bookings/{id}/finalize-payment` (mark COD as paid)
  - Manual booking uses `POST /bookings` with customer info + `payment_method: cash`

### Owner settings hub

- **View**: `lib/features/owner/presentation/widgets/owner_settings_view.dart`
- Provides navigation entry points to Reports, Complexes, Deals, Bookings, Review moderation, Profile edit, Payment history, etc.

