# Flutter Implementation Plan - Cricket Oasis / Sport Studio

This document outlines the step-by-step plan to implement the core foundation of your Flutter mobile application. We will follow a **Clean Architecture** approach using **Provider** for state management.

## 1. Project Structure 🗂️

We will organize the `lib/` directory as follows:

```
lib/
├── core/                   # Global utilities and constants
│   ├── theme/              # AppColors, AppTextStyles, AppTheme
│   ├── constants/          # API endpoints, Asset paths
│   └── utils/              # Validators, Formatters
├── data/                   # Data layer
│   ├── models/             # Data models (User, Ground, Booking)
│   └── services/           # ApiService, AuthService, StorageService
├── domain/                 # Business logic
│   └── providers/          # AuthProvider, NavigationProvider
└── presentation/           # UI Layer
    ├── widgets/            # Reusable components (Buttons, Inputs)
    ├── navigation/         # AppRouter, BottomNavBar
    └── screens/            # Feature screens (Home, Profile, etc.)
```

## 2. Core Theme & Styling 🎨

We will implement the "Luxury Sports Dark Mode" aesthetic.

-   **`AppColors`**: Define the Emerald Green (`#22C55E`), Slate (`#0F172A`), and Glass Tokens.
-   **`AppTextStyles`**: Define text hierarchies using the **Outfit** Google Font.
-   **`AppTheme`**: Setup the `ThemeData` for `MaterialApp` to apply defaults globally.

## 3. Shared Widgets (The Building Blocks) 🧩

We will create highly reusable widgets to ensure consistency.

-   **`PrimaryButton`**: A customizable filled button with the gradient/solid primary color, loading state, and standardized height/radius.
-   **`AppOutlineButton`**: A bordered version for secondary actions.
-   **`GlassContainer`**: A wrapper widget that applies the blur/glassmorphism effect to any child (critical for the modern look).
-   **`CustomTextField`**: A styled text input for forms (Login, Search) with validation support.

## 4. Navigation & Layout 🧭

-   **`AppBottomBar`**: A custom `BottomNavigationBar` using our `GlassContainer`. It will float slightly above the bottom edge.
-   **`RootScreen`**: The main scaffold that holds the `AppBottomBar` and switches between the 4 main tabs (Home, Bookings, Explore, Profile).

## 5. Networking Layer (API) 🌐

-   **`ApiClient`**: A singleton wrapper around **Dio**.
    -   **Interceptors**: Automatically attach the `Bearer token` to requests.
    -   **Error Handling**: Standardize error parsing (e.g., catching 401 Unauthorized).
-   **`AuthService`**: Methods for `login()`, `register()`, `googleLogin()`, `appleLogin()`.
-   **`BaseModel`**: Abstract class for consistent JSON parsing.

## 6. Models 📦

We will create the initial Dart data models:
-   **`User`**: `id`, `name`, `email`, `role`, `avatar`.
-   **`ApiResponse<T>`**: A generic wrapper to handle your Laravel API's standard response format: `{ "success": true, "data": ... }`.

---

## 📅 Implementation Order

1.  **Phase 1: Foundation** (Theme, Colors, Project Structure).
2.  **Phase 2: UI Building Blocks** (Buttons, Inputs, Glass Components).
3.  **Phase 3: Networking** (Dio Setup, Auth Service).
4.  **Phase 4: Navigation** (Bottom Bar, Root Screen).

**Do you approve this plan?** Once approved, I will begin by setting up the folder structure and the Core Theme files.
