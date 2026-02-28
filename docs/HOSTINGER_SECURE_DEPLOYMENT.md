# 🔐 Hostinger: Secure Production Deployment Guide

Moving your backend **OUTSIDE** the `public_html` folder is the #1 security best practice for Laravel. It prevents attackers from ever accessing your `.env` file or system source code via a browser.

---

## 1. The Secure Architecture 🏗️

On Hostinger (Shared/Business), your home directory looks like `/home/u12345/`.

### Current (Vulnerable)
*   `/home/u12345/public_html/backend/.env` (Accessible via `yoursite.com/backend/.env` ❌)

### New (Secure)
*   **System Files**: `/home/u12345/sports_api/` (Private, NOT accessible by browser ✅)
*   **Public Access**: `/home/u12345/public_html/api/` (Only contains `index.php` and assets)

---

## 2. Step-by-Step Migration 🚀

### Step 1: Move the Backend
1.  Use the Hostinger File Manager.
2.  Create a folder named `sports_api` in your **Home Directory** (one level above `public_html`).
3.  Move your entire backend folder content into `sports_api`.

### Step 2: Set Up the Entry Point
1.  Inside `public_html`, create a folder named `api`.
2.  Copy ONLY the contents of `sports_api/public/` into `public_html/api/`.
3.  You should now have `public_html/api/index.php`.

### Step 3: Update `index.php` (The Bridge)
Edit `public_html/api/index.php` to tell it where the private files are. Change these lines:

```php
// OLD
require __DIR__.'/../vendor/autoload.php';
$app = require_once __DIR__.'/../bootstrap/app.php';

// NEW (Points to the secure sports_api folder)
require __DIR__.'/../../sports_api/vendor/autoload.php';
$app = require_once __DIR__.'/../../sports_api/bootstrap/app.php';
```

---

## 3. Post-Migration Config 🛠️

### Update .env (In `sports_api/.env`)
Your URL has changed. Update it to match the new public path:

```env
APP_URL=https://yourdomain.com/api
```

### SSH Commands (Terminal)
Connect to Hostinger via SSH to fix links and performance:

```bash
cd ~/sports_api

# 1. Regenerate secure storage link
rm -rf ~/public_html/api/storage
ln -s /home/u12345/sports_api/storage/app/public /home/u12345/public_html/api/storage

# 2. Clear all caches
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## 4. Required API Key & URL Updates 🔑

### A. Mobile App (Flutter)
Open `lib/core/network/api_client.dart` and update the `baseUrl`:
```dart
static const String baseUrl = 'https://yourdomain.com/api/api'; 
// (Note: /api/ for folder + /api/ for Laravel routes)
```

### B. Web App (React)
Open `src/apiConfig.ts` and update:
```typescript
export const API_BASE_URL = "https://yourdomain.com/api/api";
```

### C. Safepay Dashboard
**Important**: If your URL changes, Safepay will stop working until you update their dashboard:
1.  Login to [Safepay Developer Portal](https://sandbox.api.getsafepay.com).
2.  Update **Webhook URL**: `https://yourdomain.com/api/api/safepay/verify`
3.  Update **Success/Redirect URL**: `https://yourdomain.com/api/api/safepay/success`

---

## 🧪 Verification Checklist
- [ ] Visit `https://yourdomain.com/api/api/public/events` -> Should show JSON.
- [ ] Visit `https://yourdomain.com/api/.env` -> Should show **404/Forbidden** (This means you are secure! ✅)
- [ ] Upload a profile picture -> Verify it shows up in `/api/storage/avatars/`.
