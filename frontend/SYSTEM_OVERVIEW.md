# LearnHub System Overview

This document provides an overview of the LearnHub codebase, covering both the **Flutter frontend** and the **Node.js/TypeScript backend**. It is intended to help create a Software Requirements Specification (SRS) document by describing the architecture, key components, data flow, and features.

---

## Table of Contents
1. [System Overview](#system-overview)
2. [Frontend (Flutter)](#frontend-flutter)
   - [Project Structure](#project-structure)
   - [State Management](#state-management)
   - [API Communication](#api-communication)
   - [Firebase Integration](#firebase-integration)
   - [Navigation & Routing](#navigation--routing)
   - [Key Features](#key-features)
3. [Backend (Node.js/TypeScript)](#backend-nodetypescript)
   - [Project Structure](#project-structure-1)
   - [API Design](#api-design)
   - [Database Schema](#database-schema)
   - [Authentication & Authorization](#authentication--authorization)
   - [Core Services](#core-services)
   - [Middleware](#middleware)
   - [Key Features](#key-features-1)
4. [Data Flow](#data-flow)
5. [Development & Deployment Considerations](#development--deployment-considerations)
6. [Conclusion](#conclusion)

---

## System Overview
LearnHub is an online learning platform that allows users to browse courses, enroll in lessons, attend live classes, interact with instructors, and track their learning progress. The system consists of:

- **Frontend**: A cross‑platform Flutter application (supports Android, iOS, web, desktop) that provides the user interface and handles local state.
- **Backend**: A RESTful API built with Node.js, TypeScript, Express, and Prisma ORM, backed by a PostgreSQL database. The API exposes endpoints for authentication, course management, enrollment, payments, live classes, notifications, and more.

The frontend communicates with the backend via secure HTTP requests (using JWT‑style tokens stored in secure storage). Firebase is used for push notifications and analytics.

---

## Frontend (Flutter)

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration (generated)
├── constants/
│   ├── colors.dart           # App color palette
│   ├── api_endpoints.dart    # REST endpoint constants
│   └── dummy_data.dart       # Sample data for development
├── models/                   # Data models (mirroring backend entities)
│   ├── auth_model.dart
│   ├── course_model.dart
│   ├── live_class_model.dart
│   └── ... (other models)
├── providers/                # State management using Provider package
│   ├── auth_provider.dart    # Auth state (login, logout, user profile)
│   ├── theme_provider.dart   # Light/dark theme toggle
│   ├── search_provider.dart  # Search results & suggestions
│   └── live_class_provider.dart
├── services/                 # API service layer (wrapper around generated clients)
│   ├── api_service.dart      # Central aggregator of all service clients
│   ├── base_api_service.dart # Token storage, headers, helper methods
│   ├── auth_service.dart
│   ├── category_service.dart
│   ├── course_service.dart
│   ├── enrollment_service.dart
│   ├── instructor_service.dart
│   ├── learning_service.dart
│   ├── live_class_service.dart
│   ├── notification_service.dart
│   ├── review_service.dart
│   ├── search_service.dart
│   └── notes_material_service.dart
├── screens/                  # UI screens organized by feature
│   ├── auth/                 # Login, register, forgot password
│   ├── home/                 # Dashboard, browsing
│   ├── live/                 # Live class screens
│   ├── course/               # Course detail, player
│   ├── profile/              # User profile, settings
│   └── settings/
├── widgets/                  # Reusable UI components
│   ├── live/                 # Live class cards, etc.
│   └── ... (other widgets)
├── routes/                   # Route definitions (AppRoutes)
├── utils/                    # Helper functions (validators, date utils, animations)
└── types/                    # Shared TypeScript‑like interfaces (API responses)
```

### State Management
The app uses **Provider** (a Flutter‑recommended state‑management solution) for:
- **AuthProvider** – manages user login state, token storage, and user profile.
- **ThemeProvider** – toggles between light and dark themes.
- **SearchProvider** – depends on AuthProvider (via `ChangeNotifierProxyProvider`) to provide search functionality that requires an authenticated user.
- **LiveClassProvider** – manages live‑class‑related state.

Providers are instantiated at the root (`LearnHubApp`) via `MultiProvider` and are accessible throughout the widget tree.

### API Communication
All backend communication goes through `ApiService`, which aggregates individual service clients (e.g., `AuthApiService`, `CourseApiService`). Each service client extends `BaseApiService`, which handles:
- **Token management** (store/retrieve JWT in `SharedPreferences`).
- **Header construction** (adding `Authorization: Bearer <token>` when required).
- **Basic error handling** and utility methods.

Endpoint constants are defined in `lib/constants/api_endpoints.dart` and are prepended with the base URL (configured via environment variables or constants elsewhere—typically pointing to the backend server).

### Firebase Integration
- **Firebase Core** is initialized at app start.
- **Firebase Messaging (FCM)** is used for push notifications:
  - Background message handling via `firebaseMessagingBackgroundHandler`.
  - Foreground message listening.
  - Token retrieval and refresh handling.
  - Permission requests (non‑web platforms).
- Firebase options are generated from `firebase_options.dart` (created via `flutterfire configure`).

### Navigation & Routing
- Routes are defined in `lib/routes/app_routes.dart` (not shown but referenced).
- The app uses a `MaterialApp` with `initialRoute` and `onGenerateRoute` to navigate to named routes (e.g., `/splash`, `/home`, `/login`, `/course-detail`).
- Deep linking from notifications can be implemented by handling `FirebaseMessaging.onMessageOpenedApp`.

### Key Features (Frontend)
| Feature | Description |
|---------|-------------|
| **Authentication** | Email/password, Google sign‑in, token persistence, logout. |
| **Theme** | Light/dark mode persisted via `SharedPreferences`. |
| **Course Browsing** | Browse categories, view courses, filter/search, see featured/popular courses. |
| **Course Detail & Player** | View course details, enrollment status, lesson progression. |
| **Enrollment** | Enroll/unroll in courses, track progress, resume learning. |
| **Live Classes** | View upcoming live sessions, join live streams, interact (placeholder for future interactivity). |
| **Search** | Search courses, instructors, categories with debounced input. |
| **Notifications** | Receive push notifications (new course, live class start, reminders). |
| **Profile & Settings** | View/edit profile, manage notifications, logout. |
| **Reviews & Ratings** | Submit and view course reviews. |
| **Payments** | Integrated payment flow (likely via Stripe/Razorpay handled by backend). |
| **Analytics** | Firebase Analytics for usage tracking. |

---

## Backend (Node.js/TypeScript)

### Project Structure
```
backend/
├── src/
│   ├── app.ts                  # Express app setup (middleware, routes)
│   ├── index.ts                # Server entry point (listens on PORT)
│   ├── config/                 # Environment configuration
│   │   └── index.ts            # Loads .env variables
│   ├── controllers/            # Request handlers (one per resource)
│   │   ├── auth.controller.ts
│   │   ├── course.controller.ts
│   │   ├── ... (others)
│   ├── middleware/             # Custom Express middleware
│   │   ├── error.middleware.ts # Central error handling
│   │   └── auth.middleware.ts  # JWT verification, role checks
│   ├── routes/                 # Route definitions (Express routers)
│   │   ├── auth.routes.ts
│   │   ├── course.routes.ts
│   │   ├── ... (others)
│   ├── services/               # Business logic layer (calls Prisma models)
│   │   ├── auth.service.ts
│   │   ├── course.service.ts
│   │   ├── ... (others)
│   ├── utils/                  # Helper functions (password hashing, token generation)
│   │   ├── bcrypt.ts
│   │   └── jwt.ts
│   ├── types/                  # TypeScript interfaces/DTOs
│   │   ├── auth.types.ts
│   │   └── ... (others)
│   ├── lib/                    # Shared utilities (e.g., Prisma client wrapper)
│   └── prisma/                 # Prisma ORM configuration & migrations
│       ├── schema.prisma       # Database model definitions
│       └── migrations/         # Migration history
├── prisma/
│   └── schema.prisma
├── .env                        # Environment variables (not committed)
├── .env.example                # Example env file
├── package.json                # Dependencies & scripts
├── tsconfig.json               # TypeScript configuration
└── README.md
```

### API Design
The backend follows a **RESTful** resource‑oriented design:
- Base path: `/api`
- Versioning is not currently used but could be added via `/api/v1/...`.
- Each resource (Auth, Category, Course, Instructor, Enrollment, Lesson, Section, Payment, Review, Notification, LiveClass) has its own router mounted under `/api/:resource`.
- Standard HTTP verbs are used:
  - `GET` – retrieve list or single item.
  - `POST` – create new resource.
  - `PUT/PATCH` – update resource.
  - `DELETE` – remove resource.
- Responses follow a common format:
  ```json
  {
    "success": boolean,
    "message": string,
    "data": any,          // payload
    "pagination": {...}   // for list endpoints
  }
  ```
- Error handling is centralized in `error.middleware.ts`, returning JSON with appropriate HTTP status codes.

### Database Schema (Prisma)
The Prisma schema defines the following key models (simplified):
- **User** – authentication, profile, role (STUDENT/INSTRUCTOR/ADMIN), relationships to courses, enrollments, reviews, etc.
- **Category** – course categorization.
- **Course** – belongs to an instructor and a category; has price, level, status, etc.
- **Section** & **Lesson** – hierarchical structure for course content.
- **Enrollment** – links a user to a course, tracks progress, payment status.
- **Review** – user ratings and comments on courses.
- **InstructorFollow** – social following between users.
- **Notification** – in‑app notifications for users.
- **LiveClass** – scheduled live streaming events.
- **Payment** & **Payout** – financial transactions.
- **Search** – cached search results (optional).

Relationships are defined with `@relation` annotations and cascade rules where appropriate.

### Authentication & Authorization
- **Authentication**: JWT‑based. Upon successful login/register, the backend returns an `accessToken` (and optionally a `refreshToken`). The frontend stores this token in `SharedPreferences` and sends it as `Bearer` token in the `Authorization` header.
- **Middleware**: `auth.middleware.ts` verifies the token, attaches the `req.user` (the User model), and optionally checks roles (e.g., `requireInstructor`, `requireAdmin`).
- **Routes** are protected by applying the auth middleware where needed (e.g., `/api/enroll/*`, `/api/courses/*` for creation/update).

### Core Services
Each service encapsulates business logic and interacts with Prisma models:
- **AuthService**: registration, login, password reset, Google OAuth, token generation.
- **CourseService**: CRUD for courses, publishing, fetching published courses, instructor‑specific queries.
- **EnrollmentService**: enroll/unenroll, progress tracking, retrieving user enrollments.
- **SearchService**: full‑text search (likely using PostgreSQL `tsvector` or a dedicated search service).
- **PaymentService**: integration with payment gateways (Stripe/Razorpay), webhook handling.
- **LiveClassService**: scheduling, starting/ending live sessions, participant management.
- **NotificationService**: creating and sending notifications (in‑app and via FCM).
- **ReviewService**: adding, updating, deleting reviews, calculating aggregate ratings.
- **File Upload** (if present): handled via middleware (e.g., Multer) and stored locally or on cloud storage (AWS S3, Cloudinary).

### Middleware
- **CORS**: Configured to allow all origins in development (see `app.ts`). In production, restrict to trusted domains.
- **Helmet**: Adds security‑related HTTP headers.
- **Body Parsing**: `express.json()` and `urlencoded` with size limits.
- **Request Logging**: Custom middleware logs method, URL, timestamp, origin, and IP.
- **Error Handling**: Centralized error‑catching middleware formats errors and sends JSON responses.
- **Authentication**: JWT verification and role‑based guards.

### Key Features (Backend)
| Feature | Description |
|---------|-------------|
| **User Management** | Registration, email/password login, Google OAuth, role‑based access (student/instructor/admin). |
| **Course CRUD** | Create, read, update, publish courses; manage sections & lessons. |
| **Enrollment & Payment** | Enroll students, process payments, track progress, issue certificates. |
| **Search** | Full‑text search across courses, instructors, categories. |
| **Reviews & Ratings** | Users can rate and comment; aggregated ratings displayed. |
| **Notifications** | In‑app notifications; integration with Firebase Cloud Messaging for push. |
| **Live Classes** | Schedule live sessions, generate streaming links, manage participants, record sessions. |
| **Admin Dashboard** | (Implied) endpoints for managing users, courses, payments, etc. |
| **File Uploads** | Handling of course thumbnails, lesson videos, etc. |
| **Security** | JWT authentication, password hashing (bcrypt), CORS, Helmet, input validation. |

---

## Data Flow

1. **User Interaction (Frontend)**
   - User opens the app → `main.dart` initializes Firebase and providers.
   - `AuthProvider` checks local storage for a token; if present, attempts to auto‑login via `/api/auth/me`.
   - UI updates based on provider state (e.g., show home screen if logged in, else login screen).

2. **Request to Backend**
   - When a UI action requires data (e.g., “Load courses”), the relevant provider calls a method on `ApiService` (e.g., `ApiService().getPublicCourses()`).
   - `ApiService` delegates to the appropriate service client (e.g., `CourseApiService`).
   - The service client builds the URL using constants from `api_endpoints.dart`, adds headers (including auth token if needed), and makes an HTTP request via `dart:http` or a similar client.

3. **Backend Processing**
   - Express router receives the request, applies middleware (cors, helmet, logging, auth if required).
   - Controller validates input, calls the corresponding service.
   - Service interacts with Prisma models to query/mutate the PostgreSQL database.
   - Service returns a DTO or model to the controller.
   - Controller wraps the result in the standard response format and sends JSON back.

4. **Response Handling (Frontend)**
   - The service client receives the response, maps JSON to Dart models (using `fromJson` factories).
   - The provider updates its state with the new data.
   - UI rebuilds via `Consumer`/`Builder` widgets, reflecting the updated data.

5. **Real‑Time Updates (Push Notifications)**
   - Backend, upon certain events (new course, live class start, etc.), uses Firebase Admin SDK to send a push notification to the user’s device token stored in the `User` model.
   - Firebase Messaging delivers the message to the app; the app’s message handlers (`onMessage`, `onMessageOpenedApp`) can navigate to relevant screens or show local notifications.

---

## Development & Deployment Considerations

### Environment Configuration
- **Frontend**: Firebase configuration is generated via `flutterfire configure` and placed in `firebase_options.dart`. Other constants (like API base URL) can be defined via Dart constants or environment‑specific flavors.
- **Backend**: Environment variables are stored in `.env` (not committed). Key variables include:
  - `DATABASE_URL` – PostgreSQL connection string.
  - `JWT_SECRET` – secret for signing JWTs.
  - `PORT` – server port (default 8081).
  - `NODE_ENV` – development/production.
  - Firebase Admin credentials (for push notifications).
  - API keys for payment gateways, file storage, etc.

### Dependency Management
- **Frontend**: Managed via `pubspec.yaml`. Run `flutter pub get` to install.
- **Backend**: Managed via `npm`/`yarn`. Run `npm install` to install Node.js packages. Prisma migrations are run with `npx prisma migrate deploy`.

### State Persistence
- Frontend uses `SharedPreferences` for lightweight storage (auth token, user data, theme preference).
- Backend uses PostgreSQL for durable storage; Prisma handles migrations and type‑safe queries.

### Testing & Quality Assurance
- **Frontend**: Unit/widget tests can be written using `flutter_test`. Integration tests with `integration_test`.
- **Backend**: Unit tests with Jest or Vitest; integration tests using Supertest to hit endpoints.
- Linting: Dart uses `analysis_options.yaml`; Node.js uses ESLint/Prettier.

### Deployment Targets
- **Frontend**: Can be built for Android (APK/AAB), iOS (IPA), web (static files), and desktop (macOS/Windows/Linux) via Flutter’s build commands.
- **Backend**: Typically deployed as a Node.js server (e.g., on AWS Elastic Beanstalk, DigitalOcean App Platform, Render, or a traditional VPS). Uses PM2 or Docker for process management.

### Security Notes
- Ensure JWT secrets are strong and rotated periodically.
- Use HTTPS in production; enable secure cookies if using cookie‑based auth.
- Validate and sanitize all inputs to prevent injection attacks.
- Store sensitive files (e.g., video uploads) in secure storage with signed URLs.
- Implement rate limiting on auth endpoints to deter brute‑force attacks.

---

## Conclusion
The LearnHub platform is a well‑structured full‑stack application:
- The **Flutter frontend** delivers a responsive, cross‑platform UI with clean state management via Provider and seamless Firebase integration for messaging.
- The **Node.js/TypeScript backend** provides a robust, secure REST API with Prisma ORM, JWT authentication, and modular services covering all core educational features.
- Clear separation of concerns, consistent API response patterns, and thoughtful use of middleware make the system maintainable and extensible.

This overview captures the essential architecture and data flow needed to author a detailed Software Requirements Specification (SRS) document, covering functional and non‑functional requirements, system interfaces, and performance considerations.

--- 
*Document generated on 2026-07-09 based on the source code present in the repository.*