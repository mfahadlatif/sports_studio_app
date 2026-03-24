# Sports Studio Web - Complete API Documentation

## Overview

Sports Studio Web is a comprehensive sports facility management platform built with React (frontend) and Laravel (backend). This document provides complete API endpoints, parameters, and responses for the mobile app integration.

## Base URL

- **Development**: `http://localhost/cricket-oasis-bookings/backend/public/api`
- **Production**: `https://sportstudio.squarenex.com/backend/public/api`

## Authentication

All protected endpoints require Bearer token authentication:
```
Authorization: Bearer {token}
```

## User Roles

- **user**: Regular users who can book grounds and join events
- **owner**: Sports complex owners who manage facilities
- **admin**: System administrators

---

## Authentication Endpoints

### Register User
**POST** `/register`
**Rate Limit**: 6 requests per minute

**Request Body**:
```json
{
  "name": "string|required|max:255",
  "email": "string|required|email|max:255|unique:users",
  "password": "string|required|min:8|confirmed",
  "phone": "string|nullable|max:20",
  "role": "string|nullable|in:user,owner"
}
```

**Response** (201):
```json
{
  "access_token": "string",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "role": "user",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  }
}
```

### Login
**POST** `/login`
**Rate Limit**: 6 requests per minute

**Request Body**:
```json
{
  "email": "string|required",
  "password": "string|required"
}
```

**Response** (200):
```json
{
  "access_token": "string",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user"
  }
}
```

### Google Login
**POST** `/login/google`
**Rate Limit**: 6 requests per minute

**Request Body**:
```json
{
  "id_token": "string|required"
}
```

### Apple Login
**POST** `/login/apple`
**Rate Limit**: 6 requests per minute

**Request Body**:
```json
{
  "id_token": "string|required"
}
```

### Forgot Password
**POST** `/forgot-password`
**Rate Limit**: 6 requests per minute

**Request Body**:
```json
{
  "email": "string|required|email"
}
```

### Reset Password
**POST** `/reset-password`
**Rate Limit**: 6 requests per minute

**Request Body**:
```json
{
  "email": "string|required|email",
  "token": "string|required",
  "password": "string|required|min:8|confirmed"
}
```

---

## Protected User Endpoints

### Get Current User
**GET** `/me`

**Response** (200):
```json
{
  "id": 1,
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "role": "user",
  "email_verified_at": null,
  "phone_verified": false,
  "created_at": "2024-01-01T00:00:00.000000Z",
  "updated_at": "2024-01-01T00:00:00.000000Z"
}
```

### Update Profile
**PUT/POST** `/profile`

**Request Body**:
```json
{
  "name": "string|sometimes|max:255",
  "email": "string|sometimes|email|max:255|unique:users,email,{id}",
  "phone": "string|nullable|max:20"
}
```

### Change Password
**POST** `/profile/password`

**Request Body**:
```json
{
  "current_password": "string|required",
  "password": "string|required|min:8|confirmed"
}
```

### Logout
**POST** `/logout`

**Response** (200):
```json
{
  "message": "Logged out successfully"
}
```

---

## Phone Verification

### Request Phone Verification
**POST** `/request-phone-verification`

**Request Body**:
```json
{
  "phone": "string|required|max:20"
}
```

### Verify Phone
**POST** `/verify-phone`

**Request Body**:
```json
{
  "phone": "string|required|max:20",
  "code": "string|required|digits:6"
}
```

### Check Verification Status
**GET** `/phone-verification-status`

**Response** (200):
```json
{
  "phone_verified": true,
  "phone": "+1234567890"
}
```

---

## Sports Complexes

### Get Complexes (Public)
**GET** `/public/complexes`
**Rate Limit**: 60 requests per minute

**Query Parameters**:
- `per_page`: integer (default: 10)
- `owner_id`: integer (filter by owner)

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "name": "Cricket Oasis",
      "address": "123 Main St",
      "latitude": 24.8607,
      "longitude": 67.0011,
      "description": "Premium cricket facility",
      "status": "active",
      "amenities": ["parking", "showers", "canteen"],
      "images": ["path/to/image1.jpg"],
      "owner_id": 1,
      "created_at": "2024-01-01T00:00:00.000000Z",
      "grounds": [
        {
          "id": 1,
          "name": "Ground A",
          "price_per_hour": 1000,
          "type": "cricket",
          "status": "active",
          "bookings_count": 25
        }
      ],
      "owner": {
        "id": 1,
        "name": "Owner Name"
      }
    }
  ],
  "links": {
    "first": "http://...",
    "last": "http://...",
    "prev": null,
    "next": "http://..."
  },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "per_page": 10,
    "to": 5,
    "total": 5
  }
}
```

### Get Complex (Protected)
**GET** `/complexes`

### Create Complex
**POST** `/complexes`

**Request Body**:
```json
{
  "name": "string|required|max:255",
  "address": "string|required",
  "latitude": "numeric|nullable",
  "longitude": "numeric|nullable",
  "description": "string|nullable",
  "amenities": "array|nullable",
  "status": "string|nullable|in:active,inactive",
  "images": "array|nullable"
}
```

### Get Single Complex
**GET** `/complexes/{idOrSlug}`

### Update Complex
**PUT** `/complexes/{idOrSlug}`

### Delete Complex
**DELETE** `/complexes/{idOrSlug}`

---

## Grounds/Arenas

### Get Grounds (Public)
**GET** `/public/grounds`
**Rate Limit**: 60 requests per minute

**Query Parameters**:
- `per_page`: integer (default: 15)
- `complex_id`: integer
- `type`: string
- `owner_id`: integer

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "name": "Ground A",
      "complex_id": 1,
      "price_per_hour": 1000,
      "type": "cricket",
      "description": "Premium cricket ground",
      "dimensions": "70x70 yards",
      "amenities": ["floodlights", "scoreboard"],
      "lighting": true,
      "images": ["path/to/image.jpg"],
      "status": "active",
      "bookings_count": 25,
      "complex": {
        "id": 1,
        "name": "Cricket Oasis",
        "address": "123 Main St"
      }
    }
  ]
}
```

### Get Single Ground (Public)
**GET** `/public/grounds/{slug}`

### Get Ground Bookings
**GET** `/public/grounds/{ground}/bookings`

### Get Grounds (Protected)
**GET** `/grounds`

### Create Ground
**POST** `/grounds`

**Request Body**:
```json
{
  "complex_id": "integer|required|exists:complexes,id",
  "name": "string|required|max:255",
  "price_per_hour": "numeric|required|min:0",
  "type": "string|required",
  "description": "string|nullable",
  "dimensions": "string|nullable",
  "amenities": "array|nullable",
  "lighting": "boolean|nullable",
  "images": "array|nullable",
  "images.*": "string"
}
```

### Get Single Ground
**GET** `/grounds/{idOrSlug}`

### Update Ground
**PUT** `/grounds/{idOrSlug}`

### Delete Ground
**DELETE** `/grounds/{idOrSlug}`

---

## Bookings

### Get Bookings
**GET** `/bookings`

**Query Parameters**:
- `per_page`: integer (default: 15)

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "ground_id": 1,
      "user_id": 1,
      "start_time": "2024-01-01T10:00:00.000000Z",
      "end_time": "2024-01-01T12:00:00.000000Z",
      "total_price": 2000,
      "players": 11,
      "status": "confirmed",
      "payment_status": "paid",
      "payment_method": "safepay",
      "customer_name": null,
      "customer_phone": null,
      "customer_email": null,
      "payment_expires_at": "2024-01-01T10:20:00.000000Z",
      "created_at": "2024-01-01T09:00:00.000000Z",
      "ground": {
        "id": 1,
        "name": "Ground A",
        "price_per_hour": 1000,
        "complex": {
          "id": 1,
          "name": "Cricket Oasis"
        }
      },
      "user": {
        "id": 1,
        "name": "John Doe"
      },
      "event": null
    }
  ]
}
```

### Create Booking
**POST** `/bookings`

**Request Body**:
```json
{
  "ground_id": "integer|required|exists:grounds,id",
  "start_time": "date|required",
  "end_time": "date|required|after:start_time",
  "total_price": "numeric|required",
  "players": "integer|sometimes",
  "user_id": "integer|sometimes|exists:users,id",
  "status": "string|sometimes",
  "customer_name": "string|sometimes|max:255",
  "customer_phone": "string|sometimes|max:20",
  "customer_email": "email|nullable|max:255",
  "payment_status": "string|sometimes",
  "payment_method": "string|sometimes"
}
```

### Get Single Booking
**GET** `/bookings/{id}`

### Update Booking
**PUT** `/bookings/{id}`

### Delete Booking
**DELETE** `/bookings/{id}`

### Finalize Payment
**POST** `/bookings/{booking}/finalize-payment`

---

## Events

### Get Events (Public)
**GET** `/public/events`
**Rate Limit**: 60 requests per minute

**Query Parameters**:
- `per_page`: integer (default: 24)
- `organizer_id`: integer
- `event_type`: string (public/private)

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "name": "Cricket Tournament",
      "description": "Annual cricket tournament",
      "start_time": "2024-01-15T09:00:00.000000Z",
      "end_time": "2024-01-15T18:00:00.000000Z",
      "registration_fee": 500,
      "max_participants": 50,
      "ground_id": 1,
      "organizer_id": 1,
      "latitude": 24.8607,
      "longitude": 67.0011,
      "rules": "Standard cricket rules apply",
      "safety_policy": "Safety equipment mandatory",
      "images": ["path/to/image.jpg"],
      "schedule": {"matches": []},
      "location": "Cricket Oasis",
      "event_type": "public",
      "status": "upcoming",
      "title": "Cricket Tournament",
      "date": "2024-01-15T09:00:00.000000Z",
      "user_joined": false,
      "participants_count": 15,
      "organizer": {
        "id": 1,
        "name": "John Doe"
      },
      "booking": {
        "id": 1,
        "ground": {
          "id": 1,
          "name": "Ground A",
          "complex": {
            "id": 1,
            "name": "Cricket Oasis"
          }
        }
      }
    }
  ]
}
```

### Get Single Event (Public)
**GET** `/public/events/{id_or_slug}`

### Get Events (Protected)
**GET** `/events`

### Create Event
**POST** `/events`

**Request Body**:
```json
{
  "name": "string|required|max:255",
  "description": "string|nullable",
  "start_time": "date_format:Y-m-d H:i:s|required",
  "end_time": "date_format:Y-m-d H:i:s|required",
  "registration_fee": "numeric|required|min:0",
  "max_participants": "integer|required|min:1",
  "ground_id": "integer|required|exists:grounds,id",
  "latitude": "numeric|nullable",
  "longitude": "numeric|nullable",
  "rules": "string|nullable",
  "safety_policy": "string|nullable",
  "images": "array|nullable",
  "schedule": "array|nullable",
  "location": "string|nullable",
  "event_type": "string|nullable|in:public,private",
  "status": "string|nullable"
}
```

### Get Single Event
**GET** `/events/{id}`

### Update Event
**PUT** `/events/{id}`

### Delete Event
**DELETE** `/events/{id}`

---

## Event Participants

### Get Event Participants
**GET** `/event-participants`

### Join Event
**POST** `/event-participants`

**Request Body**:
```json
{
  "event_id": "integer|required|exists:events,id",
  "user_id": "integer|required|exists:users,id",
  "status": "string|sometimes|in:pending,confirmed,cancelled",
  "payment_status": "string|sometimes|in:paid,unpaid"
}
```

### Get Single Participant
**GET** `/event-participants/{id}`

### Update Participant
**PUT** `/event-participants/{id}`

### Delete Participant
**DELETE** `/event-participants/{id}`

---

## Teams

### Get Teams
**GET** `/teams`

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "name": "Strikers",
      "sport": "cricket",
      "description": "Competitive cricket team",
      "logo": "path/to/logo.png",
      "owner_id": 1,
      "created_at": "2024-01-01T00:00:00.000000Z",
      "owner": {
        "id": 1,
        "name": "John Doe"
      },
      "members": [
        {
          "id": 1,
          "team_id": 1,
          "user_id": 1,
          "role": "captain",
          "status": "active",
          "user": {
            "id": 1,
            "name": "John Doe"
          }
        }
      ]
    }
  ]
}
```

### Create Team
**POST** `/teams`

**Request Body**:
```json
{
  "name": "string|required|max:255",
  "sport": "string|nullable|max:100",
  "description": "string|nullable",
  "logo": "string|nullable"
}
```

### Get Single Team
**GET** `/teams/{id}`

### Update Team
**PUT** `/teams/{id}`

### Delete Team
**DELETE** `/teams/{id}`

### Add Team Member
**POST** `/teams/{team}/members`

**Request Body**:
```json
{
  "user_id": "integer|required|exists:users,id",
  "role": "string|required|in:player,captain,manager"
}
```

### Remove Team Member
**DELETE** `/teams/{team}/members/{user}`

---

## Favorites

### Get Favorites
**GET** `/favorites`

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "ground_id": 1,
      "user_id": 1,
      "created_at": "2024-01-01T00:00:00.000000Z",
      "ground": {
        "id": 1,
        "name": "Ground A",
        "price_per_hour": 1000,
        "complex": {
          "id": 1,
          "name": "Cricket Oasis"
        }
      }
    }
  ]
}
```

### Add Favorite
**POST** `/favorites`

**Request Body**:
```json
{
  "ground_id": "integer|required|exists:grounds,id"
}
```

### Remove Favorite
**DELETE** `/favorites/{ground_id}`

---

## Notifications

### Get Notifications
**GET** `/notifications`

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "title": "Booking Confirmed",
      "message": "Your booking has been confirmed",
      "type": "booking",
      "read_at": null,
      "created_at": "2024-01-01T10:00:00.000000Z"
    }
  ]
}
```

### Mark as Read
**POST** `/notifications/{id}/read`

### Mark All as Read
**POST** `/notifications/read-all`

### Delete Notification
**DELETE** `/notifications/{id}`

---

## Deals

### Get Public Deals
**GET** `/public/deals`
**Rate Limit**: 60 requests per minute

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "title": "Weekend Special",
      "description": "20% off on weekend bookings",
      "discount_percentage": 20,
      "valid_from": "2024-01-01",
      "valid_until": "2024-01-31",
      "complex_id": 1,
      "ground_id": null,
      "status": "active",
      "complex": {
        "id": 1,
        "name": "Cricket Oasis"
      }
    }
  ]
}
```

### Get Deals (Protected)
**GET** `/deals`

### Create Deal
**POST** `/deals`

**Request Body**:
```json
{
  "title": "string|required|max:255",
  "description": "string|required",
  "discount_percentage": "numeric|required|min:0|max:100",
  "valid_from": "date|required",
  "valid_until": "date|required|after:valid_from",
  "complex_id": "integer|nullable|exists:complexes,id",
  "ground_id": "integer|nullable|exists:grounds,id",
  "status": "string|nullable|in:active,inactive"
}
```

### Update Deal
**PUT** `/deals/{deal}`

### Delete Deal
**DELETE** `/deals/{deal}`

---

## Reviews

### Get Public Reviews
**GET** `/public/reviews`
**Rate Limit**: 60 requests per minute

### Create Review (Public)
**POST** `/public/reviews`
**Rate Limit**: 10 requests per minute

**Request Body**:
```json
{
  "ground_id": "integer|required|exists:grounds,id",
  "rating": "integer|required|min:1|max:5",
  "comment": "string|required",
  "user_name": "string|required|max:255",
  "user_email": "email|nullable|max:255"
}
```

### Get Reviews (Protected)
**GET** `/reviews`

### Update Review Status
**PUT** `/reviews/{id}/status`

**Request Body**:
```json
{
  "status": "string|required|in:approved,rejected,pending"
}
```

### Delete Review
**DELETE** `/reviews/{id}`

---

## Media Upload

### Upload File
**POST** `/upload`

**Request**: `multipart/form-data`
- `file`: file (required)

**Response** (200):
```json
{
  "path": "uploads/images/filename.jpg",
  "url": "http://domain.com/storage/uploads/images/filename.jpg"
}
```

### Delete Media
**DELETE** `/media/{id}`

### Delete Media by Path
**POST** `/media/delete-by-path`

**Request Body**:
```json
{
  "path": "string|required"
}
```

### Serve Media
**GET** `/media/serve`

---

## Owner Dashboard

### Get Owner Stats
**GET** `/owner/stats`

**Response** (200):
```json
{
  "total_complexes": 2,
  "total_grounds": 5,
  "total_bookings": 150,
  "total_revenue": 150000,
  "pending_bookings": 5,
  "today_bookings": 3,
  "monthly_revenue": 25000,
  "popular_grounds": [
    {
      "id": 1,
      "name": "Ground A",
      "bookings_count": 50
    }
  ]
}
```

---

## Admin Endpoints

### Get Admin Stats
**GET** `/admin/stats`

### Get Users
**GET** `/admin/users`

### Update User
**PUT** `/admin/users/{id}`

### Delete User
**DELETE** `/admin/users/{id}`

### Get Complexes
**GET** `/admin/complexes`

### Get Reviews
**GET** `/admin/reviews`

### Cleanup System
**POST** `/admin/cleanup`

### Fix Storage
**POST** `/admin/fix-storage`

---

## Reports

### Get Reports
**GET** `/owner/reports`

**Query Parameters**:
- `type`: string (bookings, revenue, occupancy)
- `start_date`: date
- `end_date`: date

---

## Payment (Safepay)

### Initiate Payment
**POST** `/safepay/init`

**Request Body**:
```json
{
  "amount": "numeric|required",
  "booking_id": "integer|required|exists:bookings,id",
  "callback_url": "string|required"
}
```

**Response** (200):
```json
{
  "payment_url": "https://sandbox.safepay.co/...",
  "token": "payment_token"
}
```

### Verify Payment
**POST** `/safepay/verify`

**Request Body**:
```json
{
  "token": "string|required"
}
```

**Response** (200):
```json
{
  "status": "success",
  "booking_id": 1,
  "transaction_id": "txn_123456"
}
```

---

## Transactions

### Get Transactions
**GET** `/transactions`

**Response** (200):
```json
{
  "data": [
    {
      "id": 1,
      "booking_id": 1,
      "user_id": 1,
      "amount": 2000,
      "status": "completed",
      "payment_method": "safepay",
      "transaction_id": "txn_123456",
      "created_at": "2024-01-01T10:00:00.000000Z"
    }
  ]
}
```

---

## Contact

### Submit Contact Form
**POST** `/contact`

**Request Body**:
```json
{
  "name": "string|required|max:255",
  "email": "string|required|email",
  "subject": "string|required|max:255",
  "message": "string|required"
}
```

---

## Error Responses

### Validation Error (422)
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

### Unauthorized (401)
```json
{
  "message": "Unauthenticated."
}
```

### Forbidden (403)
```json
{
  "message": "Unauthorized"
}
```

### Not Found (404)
```json
{
  "message": "Resource not found"
}
```

### Server Error (500)
```json
{
  "message": "Internal server error"
}
```

---

## Rate Limiting

- **Auth endpoints**: 6 requests per minute
- **Public endpoints**: 60 requests per minute  
- **Protected endpoints**: 60 requests per minute
- **Review submission**: 10 requests per minute

Rate limit headers are included in responses:
- `X-RateLimit-Limit`: Maximum requests
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Reset time (Unix timestamp)

---

## Web App Features

### User Features
- **Authentication**: Email/password, Google OAuth, Apple OAuth
- **Ground Discovery**: Browse and search sports grounds
- **Booking System**: Real-time slot booking with payment
- **Events**: Create and join sports events/tournaments
- **Teams**: Create and manage sports teams
- **Favorites**: Save preferred grounds
- **Reviews**: Rate and review facilities
- **Notifications**: Real-time booking and event updates
- **Payment Integration**: Safepay payment gateway

### Owner Features
- **Complex Management**: Add/edit sports complexes
- **Ground Management**: Manage multiple grounds/arenas
- **Booking Management**: View, confirm, and manage bookings
- **Revenue Analytics**: Financial reports and statistics
- **Deal Management**: Create promotional deals
- **Review Moderation**: Approve/reject user reviews
- **Dashboard**: Comprehensive business overview

### Admin Features
- **User Management**: Manage all platform users
- **System Analytics**: Platform-wide statistics
- **Content Moderation**: Review management
- **System Maintenance**: Cleanup and storage management

### Technical Features
- **Real-time Updates**: WebSocket notifications
- **Media Management**: Image upload and serving
- **Phone Verification**: SMS verification system
- **Multi-role Support**: User, owner, admin roles
- **Responsive Design**: Mobile-first approach
- **PWA Support**: Progressive web app capabilities

---

## Integration Notes for Mobile App

1. **Authentication Flow**: Use token-based authentication, store token securely
2. **Image Handling**: Use `/upload` endpoint for image uploads
3. **Real-time Updates**: Implement WebSocket for live notifications
4. **Error Handling**: Implement proper error handling for all API responses
5. **Pagination**: Use provided pagination links for large datasets
6. **Rate Limiting**: Respect rate limits to avoid being blocked
7. **File Downloads**: Use `/media/serve` for media file serving
8. **Payment Flow**: Implement Safepay webview for payment processing

---

## Environment Configuration

### Development Setup
- Backend: Laravel with MySQL database
- Frontend: React with Vite
- Authentication: Laravel Sanctum
- File Storage: Local storage (development), Cloud storage (production)
- Payment: Safepay (sandbox mode)

### Production Setup
- Hosted on Hostinger
- SSL certificate enabled
- Production database optimized
- CDN for static assets
- Monitoring and logging enabled

---

*This documentation covers all available API endpoints as of the current version. For any additional features or modifications, please refer to the latest API updates.*
