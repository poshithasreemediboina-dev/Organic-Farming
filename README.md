# GreenConnect – Organic Farming Community Application
> *"Growing Together, Naturally."*

GreenConnect is a comprehensive, production-grade Flutter mobile application built for sustainable agriculture, organic farming community networking, and government/administrative grievance redressal.

---

## 🌾 Table of Contents
1. [Overview & Category](#overview--category)
2. [10 Experiments & 20 Sub-Requirements Implementation](#10-experiments--20-sub-requirements-implementation)
3. [Design System & Color Palette](#design-system--color-palette)
4. [Architecture & Folder Structure](#architecture--folder-structure)
5. [State Management & Services](#state-management--services)
6. [Complaint Management System Workflow](#complaint-management-system-workflow)
7. [REST API Weather Integration](#rest-api-weather-integration)
8. [Testing & Quality Assurance](#testing--quality-assurance)
9. [Preloaded Demo Accounts](#preloaded-demo-accounts)
10. [Firebase Backend Configuration Guide](#firebase-backend-configuration-guide)
11. [How to Run the Application](#how-to-run-the-application)

---

## 1. Overview & Category
- **Application Name**: GreenConnect
- **Tagline**: Growing Together, Naturally.
- **Category**: Organic Farming, Agri-Commerce & Grievance Redressal
- **Target OS**: Android Mobile (Fully responsive from 320px to 430px and tablets)
- **Framework**: Flutter 3.44+ / Dart 3.12+ with Material Design 3

GreenConnect bridges the gap between certified organic farmers, cultivators transitioning from conventional chemical farming, agricultural extension specialists, and administration officers.

---

## 2. 10 Experiments & 20 Sub-Requirements Implementation

| # | Experiment | Sub-Requirement 1 | Sub-Requirement 2 | Implemented In |
|---|---|---|---|---|
| **1** | **UI/UX & Branding** | Organic color palette (#245C43 Forest, #68A357 Leaf, #FFF8E9 Cream) | Responsive single-column layouts, rounded cards, no overflows | `lib/core/theme/app_theme.dart`, `app_colors.dart` |
| **2** | **Splash & Auth** | 2.4s Animated Splash with Fade & Scale | Role-based Auth (Farmer, Member, Admin) with validation & Remember Me | `screens/splash/`, `screens/auth/` |
| **3** | **Farmer Dashboard** | Welcome banner, live agro-weather advisory, organic tips | Complaints status summary, quick action shortcuts, recent feeds | `screens/farmer/farmer_dashboard_screen.dart` |
| **4** | **Admin Dashboard** | Real database stats (total users, farmers, complaints) | Interactive `fl_chart` status breakdown pie chart & oversight | `screens/admin/admin_dashboard_screen.dart` |
| **5** | **Community Forum** | Farmer experiences, natural pest recipes, comments, likes | Admin moderation tools & author deletion controls | `screens/community/`, `community_provider.dart` |
| **6** | **Product Marketplace** | Organic produce, non-GMO seeds, bio-fertilizers listing | Category filters, direct seller dial/contact popup | `screens/products/`, `product_provider.dart` |
| **7** | **Complaint Submission** | 9 Agricultural categories, unique ID generation (e.g. #GC1025) | Damage photo attach simulation, village/acreage info | `screens/complaints/create_complaint_screen.dart` |
| **8** | **Complaint Tracking** | Color-coded status badges (Pending, In Progress, Resolved) | 3-Step timeline (Logged -> Under Review -> Closed with remarks) | `screens/complaints/complaint_detail_screen.dart` |
| **9** | **Admin Grievances** | Filter by category, status, location, and search by ID | PENDING → IN PROGRESS → RESOLVED transition modal | `screens/complaints/admin_complaints_screen.dart` |
| **10** | **Notification Engine** | Targeted in-app alerts sent directly to affected farmer | Badge count, unread filter, direct link to grievance tracking | `screens/notifications/`, `notification_service.dart` |
| **11** | **REST API Integration** | Real HTTP connection to Open-Meteo Weather API | Smart agronomic advice based on rain probability & humidity | `services/api_service.dart`, `weather_provider.dart` |
| **12** | **State Management** | MultiProvider with 6 dedicated ChangeNotifiers | Clean separation of business logic and UI presentation | `lib/providers/`, `lib/app.dart` |
| **13** | **Navigation Architecture** | Named routes (`/farmerDashboard`, `/adminDashboard`, etc.) | Role-based guards preventing farmers accessing admin tools | `lib/core/routes/app_routes.dart` |
| **14** | **Database Persistence** | SharedPreferences local cache backed by Firestore architecture | Instant offline readiness with pre-seeded realistic data | `services/database_service.dart` |
| **15** | **Unit & Widget Testing** | Form validators, state transitions, notification assertions | CustomButton, ComplaintCard, and App smoke tests passing | `test/unit_test.dart`, `test/widget_test.dart` |

---

## 3. Design System & Color Palette
- **Forest Green (`#245C43`)**: Primary brand color, headers, elevated buttons.
- **Fresh Leaf Green (`#68A357`)**: Secondary accent, icons, badges, success tags.
- **Mint Green (`#C8E6C9`)**: Avatar circles, input backgrounds, active chips.
- **Warm Cream (`#FFF8E9`)**: Info containers, advisory cards, demo credentials.
- **Earth Brown (`#8D6748`)**: Location pins, soil categories, marketplace elements.
- **Sunrise Orange (`#F29D49`)**: Pending grievance status badge, alert counters.
- **Sky Blue (`#76B9D3`)**: In Progress grievance status, humidity gauges.
- **Lavender (`#A99AD6`)**: Admin badges, user management cards.
- **Coral (`#F28B82`)**: Rejected complaints, error snackbars, delete actions.
- **Light Background (`#F6F8F2`)**: Calm, natural background for high readability.

---

## 4. Architecture & Folder Structure

```
lib/
├── app.dart                                # MultiProvider and MaterialApp route generator
├── main.dart                               # Binding initialization, DatabaseService init, runApp
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Strict palette definitions and gradient themes
│   │   ├── app_constants.dart              # Coordinates, timings, default API endpoints
│   │   └── app_strings.dart                # Categories, labels, and role constants
│   ├── routes/
│   │   └── app_routes.dart                 # Named route declarations
│   ├── theme/
│   │   └── app_theme.dart                  # Material 3 ThemeData with light theme
│   └── utils/
│       ├── date_formatter.dart             # TimeAgo, relative and absolute date formatting
│       └── validators.dart                 # Robust email, password, phone, and price validators
│
├── models/
│   ├── user_model.dart                     # User entity with role helpers (isFarmer, isAdmin)
│   ├── complaint_model.dart                # Complaint entity with timeline & remarks
│   ├── notification_model.dart             # User-targeted in-app notification entity
│   ├── community_model.dart                # Community post & comment models
│   ├── product_model.dart                  # Agri-marketplace produce entity
│   └── weather_model.dart                  # Open-Meteo REST response parser & agronomic advice
│
├── services/
│   ├── api_service.dart                    # REST API integration with Open-Meteo
│   ├── auth_service.dart                   # Authentication & session persistence
│   ├── database_service.dart               # Complete mock/cache database with seed data
│   ├── notification_service.dart           # Event-driven notification generator
│   └── storage_service.dart                # SharedPreferences session wrapper
│
├── providers/
│   ├── auth_provider.dart                  # User session, role state & demo toggles
│   ├── complaint_provider.dart             # Grievance CRUD, status workflow & statistics
│   ├── community_provider.dart             # Post feed, likes, comments, author deletion
│   ├── product_provider.dart               # Marketplace catalog, search & category filters
│   ├── notification_provider.dart          # Unread counts, mark read, user-scoped alerts
│   └── weather_provider.dart               # Live weather fetching with retry capability
│
├── widgets/
│   ├── custom_button.dart                  # Reusable button with loading indicators
│   ├── custom_text_field.dart              # Input field with built-in password toggle
│   ├── complaint_card.dart                 # Grievance summary card with status badges
│   ├── status_badge.dart                   # Color-coded status badge (Pending/Progress/Resolved)
│   ├── dashboard_card.dart                 # Colorful statistic and navigation card
│   ├── notification_card.dart              # Interactive notification item with unread dot
│   ├── community_post_card.dart            # Social card with likes, comments, and moderation
│   ├── product_card.dart                   # Produce card with price and direct seller dialer
│   ├── loading_widget.dart                 # Clean centered spinner
│   ├── empty_state_widget.dart             # Illustrated empty placeholder with action button
│   └── custom_app_bar.dart                 # Gradient app bar with back navigation & actions
│
└── screens/
    ├── splash/
    │   └── splash_screen.dart              # Animated logo scale and fade transition
    ├── auth/
    │   ├── login_screen.dart               # Sign in with validation, remember me, quick demo buttons
    │   ├── register_screen.dart            # Multi-field signup with role selection
    │   └── forgot_password_screen.dart     # Password reset dispatch simulation
    ├── farmer/
    │   └── farmer_dashboard_screen.dart    # 11-feature farmer home console
    ├── admin/
    │   ├── admin_dashboard_screen.dart     # 10-feature admin control center with fl_chart
    │   └── user_management_screen.dart     # Directory of all farmers and users
    ├── community/
    │   ├── community_screen.dart           # Community forum feed with category filter
    │   └── create_post_screen.dart         # Experience sharing form with image attach
    ├── products/
    │   ├── products_screen.dart            # Organic marketplace with category tabs
    │   └── add_product_screen.dart         # Direct produce listing form
    ├── complaints/
    │   ├── create_complaint_screen.dart    # Official grievance registration form
    │   ├── my_complaints_screen.dart       # Farmer's grievance tracking list
    │   ├── complaint_detail_screen.dart    # 3-Step timeline tracking & admin remarks
    │   └── admin_complaints_screen.dart    # Admin triage console with status transition modal
    ├── notifications/
    │   └── notifications_screen.dart       # In-app notification center with mark read
    └── profile/
        ├── profile_screen.dart             # Farmer profile with stats & shortcuts
        └── settings_screen.dart            # Offline caching, alerts & language preferences
```

---

## 5. Complaint Management System Workflow

```
[Farmer Logs Complaint]
       │
       ▼ (Generates unique #GC1025, status: Pending)
[Notification to Farmer: "Complaint Registered Successfully"]
       │
       ▼ (Admin opens Admin Complaint Console)
[Admin Reviews Evidence & Assigns Officer]
       │
       ▼ (Admin changes status to "In Progress", adds remarks)
[Targeted Notification to Farmer: "Status Updated to In Progress"]
       │
       ▼ (Field officer resolves water/seed/pest issue)
[Admin changes status to "Resolved", records resolution details]
       │
       ▼
[Targeted Notification to Farmer: "Complaint Resolved!: Your complaint #GC1025 has been successfully resolved"]
```

---

## 6. REST API Weather Integration
- **Endpoint**: `https://api.open-meteo.com/v1/forecast`
- **Parameters**: `latitude=18.5204`, `longitude=73.8567` (Pune Agricultural Belt), `current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m`, `daily=precipitation_probability_max,temperature_2m_max,temperature_2m_min`
- **Dynamic Agronomic Advisories Generated**:
  - *Rain > 50%*: "Rain expected: Postpone liquid bio-fertilizer and foliar spray applications to prevent runoff."
  - *Temp > 32°C*: "High temperature: Apply organic straw or leaf mulch to conserve soil moisture."
  - *Humidity > 75%*: "High relative humidity: Inspect crop foliage for signs of fungal blights or downy mildew."
- Full async/await error handling with retry button when offline.

---

## 7. Preloaded Demo Accounts

For rapid evaluation and testing, you can use the **One-Tap Demo Credentials** buttons directly on the Login screen, or enter:

| Role | Email | Password |
|---|---|---|
| **Farmer** | `farmer@greenconnect.org` | `password123` |
| **Administrator** | `admin@greenconnect.org` | `adminpassword` |
| **Farmer (Savitri)** | `savitri@greenconnect.org` | `password123` |
| **Community Member** | `ananya@greenconnect.org` | `password123` |

---

## 8. Testing & Quality Assurance

Both unit test and widget test suites have been implemented in `test/`:

```bash
# Run Static Code Analysis
flutter analyze
# Output: No issues found! (ran in 3.8s)

# Run Full Test Suite
flutter test
# Output:
# 00:00 +0: 1. Login form validation - valid and invalid email & password
# 00:00 +1: 2. Registration form validation - required fields and password matching
# 00:00 +2: 3. Complaint form validation - category and title requirements
# 00:00 +3: 4. Complaint status update workflow (Pending -> In Progress -> Resolved)
# 00:00 +4: 5. ComplaintProvider state management & statistics computation
# 00:00 +5: 6. Targeted notification generated upon complaint resolution
# 00:01 +6: 7. CustomButton renders text, responds to tap and shows loading spinner
# 00:03 +7: 8. ComplaintCard renders complaint ID, title, category, and status badge
# 00:03 +8: 9. GreenConnect app boots up to SplashScreen and displays branding
# 00:04 +9: All tests passed!
```

---

## 9. Firebase Backend Configuration Guide

The application is structured to seamlessly plug into Firebase Cloud Firestore and Firebase Cloud Messaging:

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/) and create a project named `green-connect`.
2. **Add Android App**:
   - Package name: `com.greenconnect.app`
   - Download `google-services.json` and place it in `android/app/google-services.json`.
3. **Firestore Security Rules**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read: if request.auth != null;
         allow write: if request.auth.uid == userId;
       }
       match /complaints/{complaintId} {
         allow read: if request.auth != null;
         allow create: if request.auth != null;
         allow update: if request.auth != null && request.auth.token.role == 'Administrator';
       }
       match /notifications/{notificationId} {
         allow read, update: if request.auth.uid == resource.data.userId;
         allow create: if request.auth != null;
       }
       match /community_posts/{postId} {
         allow read, create: if request.auth != null;
         allow delete: if request.auth.uid == resource.data.userId || request.auth.token.role == 'Administrator';
       }
       match /products/{productId} {
         allow read: if true;
         allow write: if request.auth != null;
       }
     }
   }
   ```
4. **Offline Local Engine**:
   - GreenConnect includes a built-in `DatabaseService` that immediately functions offline and caches all state to `SharedPreferences`, ensuring zero crashes if Firebase credentials are not yet supplied!

---

## 10. How to Run the Application

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Verify analyze
flutter analyze

# 3. Run test suite
flutter test

# 4. Run on an Android emulator or connected device
flutter run
```

---

*GreenConnect – Designed and developed with Flutter, Provider, Material 3, and Clean Architecture for the Organic Farming Community.*
