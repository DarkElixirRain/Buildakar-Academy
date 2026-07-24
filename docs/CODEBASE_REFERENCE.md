# BuildAcad — Complete Codebase Reference

> Coursera-like Learning Management System (LMS) — "Learn. Build. Achieve."
> Flutter Frontend + Node.js/Express/Prisma/PostgreSQL Backend

---

## 1. Project Structure

```
Buildacad/
├── backend/
│   ├── .env / .env.example
│   ├── package.json
│   ├── tsconfig.json
│   ├── check.ts                          # Cloudinary connection test script
│   ├── prisma/
│   │   ├── schema.prisma                 # Database schema (17 models)
│   │   └── migrations/                   # 21 migrations
│   └── src/
│       ├── index.ts                      # Server entry (listens on :8081)
│       ├── app.ts                        # Express app setup + middleware stack
│       ├── config/
│       │   └── env.ts                    # Zod-validated environment config
│       ├── lib/
│       │   ├── prisma.ts                 # Prisma client singleton
│       │   ├── firebase.ts               # Firebase Admin SDK init
│       │   └── resend.ts                 # Resend email client
│       ├── middleware/
│       │   ├── auth.middleware.ts         # JWT verification (access + refresh)
│       │   ├── role.middleware.ts         # Role-based access (STUDENT/INSTRUCTOR/ADMIN)
│       │   ├── ownership.middleware.ts    # Resource ownership check
│       │   ├── validation.middleware.ts   # Zod schema validation
│       │   ├── errorHandler.middleware.ts # Global error handler
│       │   └── notFound.middleware.ts     # 404 catch-all
│       ├── routes/
│       │   ├── auth.routes.ts
│       │   ├── category.routes.ts
│       │   ├── course.routes.ts
│       │   ├── enrollment.routes.ts
│       │   ├── instructor.routes.ts
│       │   ├── lesson.routes.ts
│       │   ├── liveClass.routes.ts
│       │   ├── notification.routes.ts
│       │   ├── payment.routes.ts
│       │   ├── review.routes.ts
│       │   ├── search.routes.ts
│       │   ├── section.routes.ts
│       │   ├── upload.routes.ts
│       │   └── admin.routes.ts
│       ├── controllers/
│       │   ├── auth.controller.ts
│       │   ├── googleAuth.controller.ts
│       │   ├── category.controller.ts
│       │   ├── course.controller.ts
│       │   ├── enrollment.controller.ts
│       │   ├── instructor.controller.ts
│       │   ├── lesson.controller.ts
│       │   ├── liveClass.controller.ts
│       │   ├── notification.controller.ts
│       │   ├── payment.controller.ts
│       │   ├── review.controller.ts
│       │   ├── search.controller.ts
│       │   ├── section.controller.ts
│       │   ├── upload.controller.ts
│       │   └── admin.controller.ts
│       ├── services/
│       │   ├── auth.services.ts
│       │   ├── googleAuth.service.ts
│       │   ├── verificaton.service.ts     # (note: typo in filename)
│       │   ├── email.service.ts
│       │   ├── category.services.ts
│       │   ├── course.service.ts
│       │   ├── section.service.ts
│       │   ├── lesson.service.ts
│       │   ├── enrollment.service.ts
│       │   ├── instructor.service.ts
│       │   ├── payment.service.ts
│       │   ├── review.service.ts
│       │   ├── notification.service.ts
│       │   ├── live.service.ts
│       │   ├── admin.service.ts
│       │   ├── storageService.ts          # Cloudinary storage
│       │   └── googleDriveStorage.ts      # Google Drive storage
│       ├── utils/
│       │   ├── AppError.ts               # Custom error class
│       │   ├── jwt.ts                    # JWT sign/verify
│       │   ├── password.ts               # bcrypt compare
│       │   ├── hash.ts                   # SHA-256 hashing (verification codes)
│       │   ├── esewa.ts                  # eSewa payment helpers
│       │   ├── rating.ts                 # Rating recalculation
│       │   ├── token.ts                  # Token generation
│       │   ├── logger.ts                 # Winston logger
│       │   ├── validation.ts             # Zod schemas
│       │   ├── generateVerificationCode.ts
│       │   └── generateRoomName.ts       # Jitsi room name generator
│       ├── types/
│       │   ├── api.ts                    # Shared API types
│       │   └── express.d.ts              # Express augmentation
│       └── templates/
│           └── verificationEmail.ts      # HTML email template
│
├── frontend/
│   ├── pubspec.yaml
│   ├── firebase.json
│   ├── android/ ios/ web/ linux/ macos/ windows/  # Platform shells
│   ├── assets/
│   │   ├── favicon.png                   # Light theme logo
│   │   └── white_favicon.png            # Dark theme logo
│   └── lib/
│       ├── main.dart                     # App entry, providers, Firebase init
│       ├── firebase_options.dart         # Firebase config (Android only)
│       ├── config/
│       │   └── app_config.dart           # API base URL + Google OAuth IDs
│       ├── constants/
│       │   ├── colors.dart               # AppColors (static methods, Brightness-based)
│       │   ├── api_endpoints.dart        # Route string constants
│       │   └── dummy_data.dart           # Static fallback data
│       ├── theme/
│       │   └── app_colors.dart           # AppColors (instance-based, alternate)
│       ├── types/
│       │   └── api_response.dart         # ApiResponse<T> generic wrapper
│       ├── models/
│       │   ├── auth_model.dart           # User, AuthResponse, LoginRequest, SignUpRequest, etc.
│       │   ├── course_model.dart         # Course, CourseSection, Lesson, Review, Instructor, NoteItem, StudyMaterial
│       │   ├── enrollment.dart           # Enrollment
│       │   ├── live_class_model.dart     # LiveClass
│       │   ├── search_results.dart       # SearchResults, CourseSearchResult, etc.
│       │   ├── search_suggestion.dart    # SearchSuggestion
│       │   ├── trending_data.dart        # TrendingData
│       │   └── trending_results.dart     # Duplicate of TrendingData
│       ├── providers/
│       │   ├── auth_provider.dart        # Auth state, login/signup/logout, JWT management
│       │   ├── theme_provider.dart       # Dark/light mode toggle + persistence
│       │   ├── search_provider.dart      # Search state, suggestions, trending
│       │   ├── live_class_provider.dart  # Live class CRUD, role-based
│       │   ├── instructor_dashboard_provider.dart  # Dashboard stats/analytics/students/earnings
│       │   └── instructor_course_provider.dart     # Instructor's courses/sections/lessons/reviews
│       ├── services/
│       │   ├── base_api_service.dart     # HTTP client with JWT injection + 401 retry
│       │   ├── api_service.dart          # Singleton facade aggregating all sub-services
│       │   ├── auth_api_service.dart     # Auth endpoints
│       │   ├── course_api_service.dart   # Course endpoints
│       │   ├── category_api_service.dart # Category endpoints
│       │   ├── enrollment_api_service.dart  # Enrollment endpoints
│       │   ├── instructor_api_service.dart  # Instructor endpoints
│       │   ├── learning_api_service.dart    # Sections/lessons/notes/progress
│       │   ├── live_class_api_service.dart  # Live class endpoints
│       │   ├── notes_materials_api_service.dart  # Notes CRUD
│       │   ├── notification_api_service.dart     # Notification endpoints
│       │   ├── review_api_service.dart    # Review endpoints
│       │   ├── search_api_service.dart    # Search endpoints
│       │   └── jitsi_service.dart         # Jitsi Meet SDK wrapper
│       ├── routes/
│       │   └── app_routes.dart           # Named route definitions
│       ├── screens/
│       │   ├── splash/
│       │   │   └── splash_screen.dart
│       │   ├── auth/
│       │   │   ├── login_screen.dart
│       │   │   ├── signup_screen.dart
│       │   │   ├── verify_email_screen.dart
│       │   │   └── forgot_password_screen.dart
│       │   ├── home/
│       │   │   ├── home_screen.dart       # Main tabbed shell (BottomNavBar)
│       │   │   ├── explore_screen.dart
│       │   │   └── search_screen.dart
│       │   ├── categories/
│       │   │   ├── categories_screen.dart
│       │   │   └── category_detail_screen.dart
│       │   ├── course/
│       │   │   ├── course_detail_screen.dart
│       │   │   └── course_learning.dart
│       │   ├── my_learning/
│       │   │   └── my_learning_screen.dart
│       │   ├── instructors/
│       │   │   ├── instructor_screen.dart
│       │   │   └── instructor_profile_screen.dart
│       │   ├── instructor_dashboard/
│       │   │   ├── instructor_dashboard_screens.dart  # Dashboard shell
│       │   │   ├── dashboard_home.dart
│       │   │   ├── instructor_courses_screen.dart
│       │   │   ├── instructor_analytics_screen.dart
│       │   │   ├── instructor_earnings_screen.dart
│       │   │   ├── instructor_students_screen.dart
│       │   │   ├── instructor_reviews_screen.dart
│       │   │   ├── instructor_live_classes_screen.dart
│       │   │   └── instructor_profile_screen.dart
│       │   ├── instructor_course_management/
│       │   │   ├── course_creation_screen.dart
│       │   │   ├── course_edit_screen.dart
│       │   │   └── instructor_course_detail_screen.dart
│       │   ├── live_classes/
│       │   │   ├── live_screen.dart
│       │   │   ├── create_live_class_screen.dart
│       │   │   └── live_class_room_screen.dart
│       │   ├── notifications/
│       │   │   └── notification_screen.dart
│       │   └── settings/
│       │       └── settings_screen.dart
│       ├── widgets/
│       │   ├── splash/
│       │   │   ├── splash_logo.dart
│       │   │   ├── splash_title.dart
│       │   │   └── splash_loading.dart
│       │   ├── bottom_nav_bar.dart       # Custom animated bottom nav
│       │   ├── main_layout.dart          # Scaffold with header + bottom nav
│       │   ├── home/
│       │   │   ├── home_header.dart       # Avatar, notification bell, search
│       │   │   ├── featured_course.dart
│       │   │   ├── categories.dart
│       │   │   ├── continue_learning.dart
│       │   │   ├── live_classes.dart
│       │   │   ├── popular_courses.dart
│       │   │   ├── recommended_courses.dart
│       │   │   ├── recently_viewed.dart
│       │   │   ├── top_instructors.dart
│       │   │   └── search_bar.dart
│       │   ├── explore/
│       │   │   ├── course_card.dart
│       │   │   ├── explore_widget.dart
│       │   │   └── explore_loading_skeleton.dart
│       │   ├── search/
│       │   │   ├── search_suggestions_dropdown.dart
│       │   │   ├── search_results.dart
│       │   │   └── search_bar.dart
│       │   ├── course/
│       │   │   ├── course_curriculum.dart
│       │   │   ├── course_reviews.dart
│       │   │   ├── custom_video_player.dart
│       │   │   ├── notes_list.dart
│       │   │   └── study_material_list.dart
│       │   ├── live_class/
│       │   │   ├── live_class_card.dart
│       │   │   ├── skeleton_loader.dart
│       │   │   ├── live_widgets.dart
│       │   │   └── live_loading_skeleton.dart
│       │   ├── common/
│       │   │   ├── error_state.dart
│       │   │   ├── empty_state.dart
│       │   │   ├── loading_widget.dart
│       │   │   ├── loading_skeleton.dart
│       │   │   ├── loading_shimmer.dart
│       │   │   ├── loading_indicator.dart
│       │   │   └── rating_stars.dart
│       │   └── auth/
│       │       ├── google_sign_in_button.dart
│       │       └── google_button.dart
│       ├── core/widgets/
│       │   ├── app_button.dart
│       │   ├── app_card.dart
│       │   ├── app_dialog.dart
│       │   ├── app_divider.dart
│       │   ├── app_error_banner.dart
│       │   ├── app_loading_overlay.dart
│       │   ├── app_section_header.dart
│       │   ├── app_text_field.dart
│       │   └── app_bottom_auth_link.dart
│       └── utils/
│           ├── validators.dart
│           ├── date_utils.dart
│           └── animations.dart
```

---

## 2. Backend Architecture

### 2.1 Tech Stack

| Layer | Technology |
|---|---|
| Runtime | Node.js + TypeScript |
| Framework | Express.js |
| ORM | Prisma |
| Database | PostgreSQL (Neon serverless) |
| Auth | JWT (access + refresh tokens), Google OAuth |
| Email | Resend |
| Storage | Cloudinary (default) / Google Drive (alternative) |
| Payments | eSewa (Nepal) |
| Push Notifications | Firebase Cloud Messaging |
| Video Conferencing | Jitsi Meet (via room name generation) |

### 2.2 Middleware Stack (applied in order)

1. **Helmet** — Security headers
2. **CORS** — Allows `localhost:5173` and `buildacad-frontend.vercel.app`
3. **Compression** — gzip
4. **JSON parsing** — `express.json()`
5. **Cookie parsing** — `cookie-parser`
6. **Rate limiter** — 100 requests / 15 minutes (global)
7. **Nonce CSP** — Content Security Policy
8. **Static files** — `/uploads` directory
9. **404 catch-all** — `notFoundHandler`
10. **Error handler** — `errorHandler` (global)

### 2.3 Authentication Flow

```
Register:
  POST /api/auth/register → Creates PendingRegistration (with hashed 6-digit code)
  POST /api/auth/send-verification-code → Resends code via Resend email
  POST /api/auth/verify-email → Verifies code, creates User, deletes PendingRegistration

Login:
  POST /api/auth/login → Returns { user, accessToken } + HttpOnly refresh cookie

Refresh:
  POST /api/auth/refresh → Reads refresh cookie, validates, rotates tokens

Google:
  POST /api/auth/google → Google OAuth profile → upserts User → returns JWT + needsOnboarding

Logout:
  POST /api/auth/logout → Deletes refresh token, clears cookie
```

**Token strategy:**
- Access token: Short-lived, sent in response body, stored in `flutter_secure_storage`
- Refresh token: Long-lived, stored in `RefreshToken` table + HttpOnly cookie
- 401 responses trigger automatic refresh via `BaseApiService` in Flutter

### 2.4 Role-Based Access Control

| Role | Permissions |
|---|---|
| `STUDENT` | Enroll, review, follow instructors, join live classes, view learning content |
| `INSTRUCTOR` | Create/manage courses, sections, lessons, videos, live classes, view own analytics |
| `ADMIN` | Full access — manage users, courses, reviews, payments, payouts, notifications, stats |

---

## 3. Complete Database Schema (Prisma)

### User
| Field | Type | Notes |
|---|---|---|
| id | String (cuid) | PK |
| email | String | unique |
| password | String? | nullable (Google OAuth users) |
| firstName | String | |
| lastName | String | |
| profilePic | String? | URL |
| role | Role | STUDENT / INSTRUCTOR / ADMIN |
| isVerified | Boolean | email verified |
| isApproved | Boolean | instructor approved by admin |
| bio | String? | |
| expertise | String? | |
| socialLinks | Json? | |
| hasCompletedOnboarding | Boolean | |
| rating | Float | calculated average |
| totalReviews | Int | |
| createdAt | DateTime | |
| updatedAt | DateTime | |

### PendingRegistration
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| email | String | unique |
| firstName | String | |
| lastName | String | |
| passwordHash | String | |
| role | Role | |
| codeHash | String | SHA-256 of 6-digit code |
| expiresAt | DateTime | |
| isVerified | Boolean | |

### PendingEmailChange
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| userId | String | FK → User |
| newEmail | String | |
| codeHash | String | |
| expiresAt | DateTime | |

### RefreshToken
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| userId | String | FK → User |
| token | String | unique |
| userAgent | String? | |
| ip | String? | |
| expiresAt | DateTime | |

### Category
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| name | String | unique |
| slug | String | unique |
| description | String? | |
| imageUrl | String? | |

### Course
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| title | String | |
| slug | String | unique |
| description | String | |
| price | Float | |
| thumbnailUrl | String? | Cloudinary URL |
| instructorId | String | FK → User |
| categoryId | String | FK → Category |
| level | Level? | BEGINNER / INTERMEDIATE / ADVANCED |
| estimatedHours | Float? | |
| prerequisites | String? | |
| learningOutcomes | String? | |
| isPublished | Boolean | |
| publishedAt | DateTime? | |
| averageRating | Float | |
| totalReviews | Int | |
| totalStudents | Int | |
| createdAt | DateTime | |
| updatedAt | DateTime | |

### Section
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| title | String | |
| position | Int | ordering |
| courseId | String | FK → Course |

### Lesson
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| title | String | |
| type | LessonType | VIDEO / TEXT / QUIZ |
| content | String? | text content |
| videoUrl | String? | |
| videoFileId | String? | Cloudinary/Drive file ID |
| videoFileName | String? | |
| videoMimeType | String? | |
| videoSize | Int? | bytes |
| videoDuration | Float? | seconds |
| durationMinutes | Int? | |
| position | Int | ordering |
| sectionId | String | FK → Section |

### Enrollment
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| userId | String | FK → User |
| courseId | String | FK → Course |
| enrolledAt | DateTime | |
| completedAt | DateTime? | |
| isCompleted | Boolean | |
| lastAccessedAt | DateTime? | |

### Payment
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| userId | String | FK → User |
| courseId | String | FK → Course |
| amount | Float | |
| currency | String | NPR |
| paymentMethod | String | |
| transactionId | String? | |
| esewaRefId | String? | |
| status | PaymentStatus | PENDING / COMPLETED / FAILED / REFUNDED |
| paymentData | Json? | raw eSewa response |

### Review
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| userId | String | FK → User |
| courseId | String | FK → Course |
| rating | Int | 1-5 |
| comment | String? | |
| isInstructorReply | Boolean | |
| instructorReply | String? | |

### InstructorFollow
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| followerId | String | FK → User |
| instructorId | String | FK → User |
| createdAt | DateTime | |

### InstructorAnalytics
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| instructorId | String | FK → User (unique) |
| totalStudents | Int | |
| totalRevenue | Float | |
| averageRating | Float | |
| totalReviews | Int | |
| topCourses | Json? | |
| lastUpdated | DateTime | |

### LiveClass
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| title | String | |
| description | String? | |
| scheduledAt | DateTime | |
| duration | Int | minutes |
| roomName | String | unique, for Jitsi |
| courseId | String? | FK → Course |
| sectionId | String? | FK → Section |
| instructorId | String | FK → User |
| status | LiveClassStatus | SCHEDULED / LIVE / ENDED / CANCELLED |
| maxParticipants | Int? | |
| isRecorded | Boolean | |
| meetingUrl | String? | |
| thumbnailUrl | String? | |
| startedAt | DateTime? | |
| endedAt | DateTime? | |

### LiveClassParticipant
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| liveClassId | String | FK → LiveClass |
| userId | String | FK → User |
| joinedAt | DateTime | |
| leftAt | DateTime? | |
| duration | Int? | seconds |
| status | ParticipantStatus | JOINED / LEFT / TIMEOUT |

### Notification
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| userId | String | FK → User |
| title | String | |
| body | String | |
| type | String | e.g. "enrollment", "live_class" |
| read | Boolean | |
| data | Json? | |

### CourseAnalytics
| Field | Type | Notes |
|---|---|---|
| id | String | PK |
| courseId | String | FK → Course |
| date | DateTime | |
| views | Int | |
| enrollments | Int | |
| completions | Int | |
| revenue | Float | |
| averageWatchTime | Float | |
| dropoffRate | Float | |

---

## 4. Complete Backend API Routes


Base URL: `https://api.buildakar.com/api`

### 4.1 Auth — `/api/auth`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| POST | `/register` | No | — | Register new user (creates PendingRegistration) |
| POST | `/send-verification-code` | No | — | Resend 6-digit OTP via email |
| POST | `/verify-email` | No | — | Verify OTP, create User account |
| POST | `/login` | No | — | Email/password login → JWT + refresh cookie |
| POST | `/refresh` | No | — | Rotate access/refresh tokens |
| POST | `/logout` | Yes | Any | Delete refresh token, clear cookie |
| GET | `/me` | Yes | Any | Get current user profile + needsOnboarding |
| POST | `/update-role` | Yes | Any | Update user role (STUDENT/INSTRUCTOR) |
| POST | `/google` | No | — | Google OAuth login/register |

### 4.2 Categories — `/api/categories`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | List all categories |
| GET | `/:id` | No | — | Get category by ID |
| POST | `/` | Yes | ADMIN | Create category |
| PUT | `/:id` | Yes | ADMIN | Update category |
| DELETE | `/:id` | Yes | ADMIN | Delete category |

### 4.3 Courses — `/api/courses`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | List courses (paginated, filterable) |
| GET | `/instructor/:instructorId` | No | — | Courses by instructor |
| GET | `/:id` | No | — | Get course by ID |
| GET | `/slug/:slug` | No | — | Get course by slug |
| POST | `/` | Yes | INSTRUCTOR | Create course |
| PUT | `/:id` | Yes | INSTRUCTOR* | Update course (ownership) |
| DELETE | `/:id` | Yes | INSTRUCTOR* | Delete course (ownership) |
| PATCH | `/:id/publish` | Yes | INSTRUCTOR* | Publish course |
| PATCH | `/:id/unpublish` | Yes | INSTRUCTOR* | Unpublish course |

### 4.4 Sections — `/api/courses/:courseId/sections`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | List sections for course |
| GET | `/:sectionId` | No | — | Get section by ID |
| POST | `/` | Yes | INSTRUCTOR* | Create section |
| PUT | `/:sectionId` | Yes | INSTRUCTOR* | Update section |
| DELETE | `/:sectionId` | Yes | INSTRUCTOR* | Delete section |
| PATCH | `/reorder` | Yes | INSTRUCTOR* | Reorder sections |

### 4.5 Lessons — `/api/courses/:courseId/sections/:sectionId/lessons`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | List lessons for section |
| GET | `/:lessonId` | No | — | Get lesson by ID |
| POST | `/` | Yes | INSTRUCTOR* | Create lesson |
| PUT | `/:lessonId` | Yes | INSTRUCTOR* | Update lesson |
| DELETE | `/:lessonId` | Yes | INSTRUCTOR* | Delete lesson |
| PATCH | `/reorder` | Yes | INSTRUCTOR* | Reorder lessons |

> `INSTRUCTOR*` = INSTRUCTOR + ownership middleware (must own the course)

### 4.6 Enrollments — `/api/enroll`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| POST | `/:courseId` | Yes | STUDENT | Enroll in course |
| GET | `/my-courses` | Yes | STUDENT | Get enrolled courses with progress |
| GET | `/course/:courseId/students` | Yes | INSTRUCTOR | Get students enrolled in course |
| PATCH | `/course/:courseId/complete` | Yes | STUDENT | Mark course as complete |

### 4.7 Instructors — `/api/instructors`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | List instructors (paginated, searchable) |
| GET | `/:id` | No | — | Get instructor by ID |
| POST | `/:id/follow` | Yes | STUDENT | Follow instructor |
| DELETE | `/:id/unfollow` | Yes | STUDENT | Unfollow instructor |
| GET | `/followed` | Yes | STUDENT | Get followed instructors |

### 4.8 Search — `/api/search`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | Full-text search across courses, instructors, categories |

### 4.9 Payments — `/api/payments`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| POST | `/initiate/:courseId` | Yes | STUDENT | Initiate eSewa payment |
| POST | `/success` | No | — | eSewa callback (success) |
| POST | `/failure` | No | — | eSewa callback (failure) |
| GET | `/my-payments` | Yes | Any | Get user's payment history |

### 4.10 Reviews — `/api/reviews`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/course/:courseId` | No | — | Get reviews for course |
| POST | `/course/:courseId` | Yes | STUDENT | Create review |
| PUT | `/:reviewId` | Yes | Owner | Update review |
| DELETE | `/:reviewId` | Yes | Owner | Delete review |
| POST | `/:reviewId/reply` | Yes | INSTRUCTOR* | Instructor reply to review |

### 4.11 Notifications — `/api/notifications`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | Yes | Any | Get notifications (paginated) |
| PATCH | `/:notificationId/read` | Yes | Any | Mark as read |
| PATCH | `/read-all` | Yes | Any | Mark all as read |
| DELETE | `/:notificationId` | Yes | Any | Delete notification |
| POST | `/fcm-token` | Yes | Any | Register FCM token |
| POST | `/test-push` | Yes | Any | Send test push notification |

### 4.12 Live Classes — `/api/live-classes`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/` | No | — | List live classes (paginated) |
| GET | `/:id` | No | — | Get live class by ID |
| POST | `/` | Yes | INSTRUCTOR | Create live class |
| PATCH | `/:id` | Yes | INSTRUCTOR* | Update live class |
| DELETE | `/:id` | Yes | INSTRUCTOR* | Delete live class |
| PATCH | `/:id/start` | Yes | INSTRUCTOR* | Start live class |
| PATCH | `/:id/end` | Yes | INSTRUCTOR* | End live class |
| POST | `/:id/join` | Yes | STUDENT | Join live class |
| POST | `/:id/leave` | Yes | STUDENT | Leave live class |
| GET | `/:id/participants` | Yes | INSTRUCTOR* | Get participants |

### 4.13 Upload — `/api/upload`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| POST | `/video` | Yes | INSTRUCTOR | Upload video (max 500MB, to Cloudinary) |
| POST | `/thumbnail` | Yes | INSTRUCTOR | Upload thumbnail image |

### 4.14 Admin — `/api/admin`

| Method | Path | Auth | Role | Description |
|---|---|---|---|---|
| GET | `/stats` | Yes | ADMIN | Dashboard statistics |
| GET | `/users` | Yes | ADMIN | List users (paginated, filterable) |
| GET | `/users/:id` | Yes | ADMIN | Get user by ID |
| PUT | `/users/:id` | Yes | ADMIN | Update user role |
| PATCH | `/users/:id/approve-instructor` | Yes | ADMIN | Approve instructor |
| PATCH | `/users/:id/ban` | Yes | ADMIN | Ban user |
| PATCH | `/users/:id/unban` | Yes | ADMIN | Unban user |
| DELETE | `/users/:id` | Yes | ADMIN | Delete user |
| GET | `/courses` | Yes | ADMIN | List all courses |
| GET | `/courses/:id` | Yes | ADMIN | Get course detail |
| PATCH | `/courses/:id/approve` | Yes | ADMIN | Approve course |
| PATCH | `/courses/:id/reject` | Yes | ADMIN | Reject course |
| DELETE | `/courses/:id` | Yes | ADMIN | Delete course |
| GET | `/courses/:id/analytics` | Yes | ADMIN | Course analytics |
| GET | `/reviews` | Yes | ADMIN | List all reviews |
| DELETE | `/reviews/:id` | Yes | ADMIN | Delete review |
| GET | `/instructors` | Yes | ADMIN | List all instructors |
| GET | `/instructors/:id/analytics` | Yes | ADMIN | Instructor analytics |
| GET | `/payments` | Yes | ADMIN | List all payments |
| PATCH | `/payments/:id/status` | Yes | ADMIN | Update payment status |
| GET | `/payouts` | Yes | ADMIN | List payouts |
| POST | `/payouts` | Yes | ADMIN | Create payout |
| GET | `/live-classes` | Yes | ADMIN | List all live classes |
| POST | `/notifications/send` | Yes | ADMIN | Send push notification |
| GET | `/notifications` | Yes | ADMIN | List all notifications |

---

## 5. Frontend Architecture

### 5.1 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) SDK >=3.8.0 |
| State Management | `provider` |
| HTTP | `http` package with custom `BaseApiService` |
| Auth Storage | `flutter_secure_storage` (JWT tokens) |
| Local Storage | `shared_preferences` (theme, recent searches) |
| Typography | `google_fonts` (Inter) |
| OAuth | `google_sign_in` |
| Push Notifications | `firebase_core` + `firebase_messaging` + `flutter_local_notifications` |
| Video Player | `video_player` + `chewie` |
| Voice Search | `speech_to_text` |
| Video Conferencing | `jitsi_meet_flutter_sdk` |
| Image Picker | `image_picker` |
| Sharing | `share_plus` |
| URL Launching | `url_launcher` |
| Serialization | `json_annotation` + `json_serializable` |

### 5.2 App Configuration

```
API Base URL:     https://api.buildakar.com/api
Google Client ID: 743824025812-...
Firebase Project: buildacad-22765 (Android only)
```

### 5.3 Provider Architecture

| Provider | Created In | State Managed |
|---|---|---|
| `ThemeProvider` | `main.dart` | Dark/light mode, persisted via `shared_preferences` |
| `AuthProvider` | `main.dart` | User object, JWT tokens, login/logout/signup, profile management |
| `SearchProvider` | `main.dart` | Search query, suggestions, trending, recent searches |
| `LiveClassProvider` | `main.dart` | Live classes list, CRUD operations |
| `InstructorDashboardProvider` | `main.dart` | Dashboard stats, analytics, students, earnings |
| `InstructorCourseProvider` | `main.dart` | Instructor's courses, sections, lessons, reviews |

### 5.4 Service Architecture

```
ApiService (Singleton Facade)
├── AuthApiService         → /api/auth/*
├── CourseApiService       → /api/courses/*
├── CategoryApiService     → /api/categories/*
├── EnrollmentApiService   → /api/enroll/*
├── InstructorApiService   → /api/instructors/*
├── LearningApiService     → sections, lessons, notes, progress
├── LiveClassApiService    → /api/live-classes/*
├── NotesMaterialsApiService → Notes CRUD
├── NotificationApiService → /api/notifications/*
├── ReviewApiService       → /api/reviews/*
├── SearchApiService       → /api/search/*
└── JitsiService           → Jitsi Meet SDK
```

All sub-services extend `BaseApiService` which provides:
- Automatic JWT token injection in headers
- 401 → automatic refresh token retry
- Generic `get/post/put/patch/delete/uploadMultipart` methods

### 5.5 Model Definitions

#### User (auth_model.dart)
```
id, email, name (computed: firstName + lastName), firstName, lastName,
role (STUDENT/INSTRUCTOR/ADMIN), profileImageUrl, isEmailVerified,
token, refreshToken
```

#### Course (course_model.dart)
```
id, title, subtitle, description, thumbnail, price, originalPrice,
rating, studentsCount, lessonsCount, instructor (Instructor),
category (Category), sections (List<CourseSection>),
reviews (List<Review>), status, level, duration, language,
isEnrolled, enrolledAt, completionPercentage, totalDuration
```

#### CourseSection
```
id, title, description, position, lessons (List<Lesson>), totalLessons,
completedLessons, duration
```

#### Lesson
```
id, title, description, type (VIDEO/TEXT/QUIZ), content, videoUrl,
videoThumbnail, duration, position, isCompleted, isLocked,
resources (List<StudyMaterial>), notes (List<NoteItem>)
```

#### Enrollment (enrollment.dart)
```
id, courseId, studentId, progress, enrolledAt, completedAt, status,
course (Course with title, thumbnail, instructor)
```

#### LiveClass (live_class_model.dart)
```
id, title, description, instructor, scheduledTime, duration, status,
participantsCount, maxParticipants, meetingUrl, courseId, courseName,
isRecorded, thumbnailUrl
```

#### SearchResults (search_results.dart)
```
courses (List<CourseSearchResult>), instructors (List<InstructorSearchResult>),
categories (List<CategorySearchResult>), meta (SearchMeta),
pagination (SearchPagination)
```

---

## 6. Frontend Screens — Complete Mapping

### 6.1 Named Routes (app_routes.dart)

| Route | Screen | Notes |
|---|---|---|
| `/` | `SplashScreen` | Entry point, auto-navigates after animation |
| `/login` | `LoginScreen` | |
| `/signup` | `SignupScreen` | |
| `/verify-email` | `VerifyEmailScreen` | |
| `/forgot-password` | `ForgotPasswordScreen` | |
| `/home` | `HomeScreen` | Main shell with BottomNavBar |
| `/instructor` | `InstructorProfileScreen` | |

> **Note:** Most navigation uses `Navigator.push(MaterialPageRoute(...))` instead of named routes.

### 6.2 All Screens with Descriptions

#### Splash
| Screen | File | Description |
|---|---|---|
| `SplashScreen` | `splash/splash_screen.dart` | Animated fade-in with pulsing logo, gradient title, loading spinner. Auto-navigates to `/home` after delay. |

#### Auth
| Screen | File | Description |
|---|---|---|
| `LoginScreen` | `auth/login_screen.dart` | Email/password login form + Google Sign-In button + forgot password link + sign up link |
| `SignupScreen` | `auth/signup_screen.dart` | First name, last name, email, password, confirm password + Google Sign-In + sign in link |
| `VerifyEmailScreen` | `auth/verify_email_screen.dart` | 6-digit OTP input with auto-submit on completion, resend timer |
| `ForgotPasswordScreen` | `auth/forgot_password_screen.dart` | 3-step: enter email → verify OTP → set new password |

#### Home & Explore
| Screen | File | Description |
|---|---|---|
| `HomeScreen` | `home/home_screen.dart` | Main tabbed shell with `BottomNavBar` (4 tabs: Home, Explore, Search, Profile) |
| `ExploreScreen` | `home/explore_screen.dart` | Category chips + filters (category/level/price/sort) + infinite scroll grid/list toggle |
| `SearchScreen` | `home/search_screen.dart` | Search input + suggestions + trending topics + recent searches |

#### Categories
| Screen | File | Description |
|---|---|---|
| `CategoriesScreen` | `categories/categories_screen.dart` | Grid of all categories with search filter |
| `CategoryDetailScreen` | `categories/category_detail_screen.dart` | Category info + course grid with sort options + grid/list toggle |

#### Course
| Screen | File | Description |
|---|---|---|
| `CourseDetailScreen` | `course/course_detail_screen.dart` | 3-tab view (Overview/Curriculum/Reviews) + enroll button + instructor info |
| `CourseLearning` | `course/course_learning.dart` | Video player + lesson sidebar + notes + study materials + progress tracking |

#### My Learning
| Screen | File | Description |
|---|---|---|
| `MyLearningScreen` | `my_learning/my_learning_screen.dart` | Enrolled courses with tabs (All/In Progress/Completed/Not Started) + search + pagination |

#### Instructors
| Screen | File | Description |
|---|---|---|
| `InstructorScreen` | `instructors/instructor_screen.dart` | Grid of all instructors with search + follow/unfollow |
| `InstructorProfileScreen` | `instructors/instructor_profile_screen.dart` | Instructor detail with 3 tabs (Courses/Reviews/About) + follow + stats |

#### Instructor Dashboard
| Screen | File | Description |
|---|---|---|
| `InstructorDashboardScreens` | `instructor_dashboard/instructor_dashboard_screens.dart` | Dashboard shell with `ValueListenableBuilder` for sub-screen routing |
| `DashboardHome` | `instructor_dashboard/dashboard_home.dart` | Stats cards (courses, students, revenue, rating) + quick actions + menu |
| `InstructorCoursesScreen` | `instructor_dashboard/instructor_courses_screen.dart` | Course list/grid with search + status filter |
| `InstructorAnalyticsScreen` | `instructor_dashboard/instructor_analytics_screen.dart` | Analytics cards (students, rating, completion, revenue, growth) |
| `InstructorEarningsScreen` | `instructor_dashboard/instructor_earnings_screen.dart` | Earnings overview with time range filter (week/month/quarter/year) |
| `InstructorStudentsScreen` | `instructor_dashboard/instructor_students_screen.dart` | Student list with search |
| `InstructorReviewsScreen` | `instructor_dashboard/instructor_reviews_screen.dart` | Reviews from students |
| `InstructorLiveClassesScreen` | `instructor_dashboard/instructor_live_classes_screen.dart` | Live classes management |
| `InstructorProfileScreen (Dashboard)` | `instructor_dashboard/instructor_profile_screen.dart` | Instructor's own profile view |

#### Instructor Course Management
| Screen | File | Description |
|---|---|---|
| `CourseCreationScreen` | `instructor_course_management/course_creation_screen.dart` | New course form (title, subtitle, description, category, level, language, price, discount, thumbnail) |
| `CourseEditScreen` | `instructor_course_management/course_edit_screen.dart` | Edit existing course (same form, pre-filled) |
| `InstructorCourseDetailScreen` | `instructor_course_management/instructor_course_detail_screen.dart` | 5-tab management (Overview/Content/Reviews/Q&A/Analytics) + section/lesson CRUD + video upload |

#### Live Classes
| Screen | File | Description |
|---|---|---|
| `LiveScreen` | `live_classes/live_screen.dart` | Tabs (Upcoming/Live/Past) + create button for instructors |
| `CreateLiveClassScreen` | `live_classes/create_live_class_screen.dart` | Create form (title, description, course, max participants, schedule) |
| `LiveClassRoomScreen` | `live_classes/live_class_room_screen.dart` | Jitsi Meet video conferencing room |

#### Notifications
| Screen | File | Description |
|---|---|---|
| `NotificationScreen` | `notifications/notification_screen.dart` | Notification list with filter + pagination + mark as read |

#### Settings
| Screen | File | Description |
|---|---|---|
| `SettingsScreen` | `settings/settings_screen.dart` | Appearance (dark mode), Account, Support, App Info sections + share + logout |

---

## 7. Frontend Widgets — Complete Inventory

### 7.1 Splash Widgets
| Widget | File | Description |
|---|---|---|
| `SplashLogo` | `splash/splash_logo.dart` | Animated pulsing logo (switches asset based on theme brightness) |
| `SplashTitle` | `splash/splash_title.dart` | "BuildAcad" gradient text + "Learn. Build. Achieve." tagline |
| `SplashLoading` | `splash/splash_loading.dart` | Rotating gradient spinner + loading bar + cycling messages |

### 7.2 Navigation Widgets
| Widget | File | Description |
|---|---|---|
| `BottomNavBar` | `bottom_nav_bar.dart` | Custom animated bottom navigation with haptic feedback |
| `MainLayout` | `main_layout.dart` | Scaffold wrapper with `HomeHeader` + `BottomNavBar` |

### 7.3 Home Section Widgets
| Widget | File | Description |
|---|---|---|
| `HomeHeader` | `home/home_header.dart` | User avatar + notification bell (with badge) + expandable search bar + voice input |
| `FeaturedCourses` | `home/featured_course.dart` | Horizontal scrollable cards with auto-play + auto-scroll timer |
| `Categories` | `home/categories.dart` | Horizontal scrollable category chips with icons/colors |
| `ContinueLearning` | `home/continue_learning.dart` | Enrolled course progress cards with "Continue Learning" CTA |
| `LiveClasses` | `home/live_classes.dart` | Live class cards with live status + attendee count + join button |
| `PopularCourses` | `home/popular_courses.dart` | Horizontal scrollable popular courses with pagination |
| `RecommendedCourses` | `home/recommended_courses.dart` | Horizontal scrollable recommended courses with bookmark |
| `RecentlyViewed` | `home/recently_viewed.dart` | Horizontal scrollable recently viewed courses |
| `TopInstructors` | `home/top_instructors.dart` | Horizontal scrollable instructor cards with follow/unfollow toggle |
| `SearchBar` | `home/search_bar.dart` | Animated search bar with recent searches + focus animation |

### 7.4 Explore Widgets
| Widget | File | Description |
|---|---|---|
| `CourseCard` | `explore/course_card.dart` | Dual-mode card (grid vertical / list horizontal) with thumbnail, rating, price, instructor |
| `ExploreWidgets` | `explore/explore_widget.dart` | `ExploreSearchBar`, `CategoryChips`, `SortFilterSheet`, `LevelBadge`, `RatingPill` |
| `ExploreLoadingSkeleton` | `explore/explore_loading_skeleton.dart` | Skeleton loading placeholder |

### 7.5 Search Widgets
| Widget | File | Description |
|---|---|---|
| `SearchSuggestionsDropdown` | `search/search_suggestions_dropdown.dart` | Dropdown with suggestions + recent searches + clear |
| `SearchResults` | `search/search_results.dart` | Results display (categories grid, courses grid, instructors grid) |
| `CustomSearchBar` | `search/search_bar.dart` | Search input with clear + tap handling |

### 7.6 Course Widgets
| Widget | File | Description |
|---|---|---|
| `CourseCurriculum` | `course/course_curriculum.dart` | Expandable section/lesson tree with lock icons + play buttons |
| `CourseReviews` | `course/course_reviews.dart` | Rating summary bar chart + individual reviews list |
| `CustomVideoPlayer` | `course/custom_video_player.dart` | Full-screen video player with controls overlay |
| `NotesList` | `course/notes_list.dart` | CRUD notes with lesson assignment + bottom sheet editor |
| `StudyMaterialList` | `course/study_material_list.dart` | Study materials list with download simulation |

### 7.7 Live Class Widgets
| Widget | File | Description |
|---|---|---|
| `LiveClassCard` | `live_class/live_class_card.dart` | Card with status badge + join/remind/start buttons |
| `SkeletonLoader` | `live_class/skeleton_loader.dart` | Shimmer effect + skeleton placeholders |
| `LiveWidgets` | `live/live_widgets.dart` | `LiveSearchBar`, `LiveFilterChips`, `LiveEmptyState`, `LiveErrorState` |
| `LiveLoadingSkeleton` | `live/live_loading_skeleton.dart` | Responsive skeleton grid |

### 7.8 Common Widgets
| Widget | File | Description |
|---|---|---|
| `ErrorState` | `common/error_state.dart` | Error icon + message + retry button |
| `EmptyState` | `common/empty_state.dart` | Empty icon + title + description + action button |
| `LoadingWidget` | `common/loading_widget.dart` | Centered spinner with optional message |
| `LoadingSkeleton` | `common/loading_skeleton.dart` | Full-page skeleton layout |
| `LoadingShimmer` | `common/loading_shimmer.dart` | Shimmer effects + card skeletons |
| `LoadingIndicator` | `common/loading_indicator.dart` | Simple `CircularProgressIndicator` wrapper |
| `RatingStars` | `common/rating_stars.dart` | Star rating display (full/half/empty) |

### 7.9 Auth Widgets
| Widget | File | Description |
|---|---|---|
| `GoogleSignInButton` | `auth/google_sign_in_button.dart` | Google OAuth orchestrator |
| `GoogleButton` | `auth/google_button.dart` | Visual Google button with custom painter |

### 7.10 Core Reusable Widgets (`core/widgets/`)
| Widget | File | Description |
|---|---|---|
| `AppButton` | `app_button.dart` | Primary elevated button |
| `AppSocialButton` | `app_button.dart` | Outlined social login button |
| `AppCard` | `app_card.dart` | Themed container card with shadow |
| `AppStatCard` | `app_card.dart` | Icon + value + label stat card |
| `AppSuccessDialog` | `app_dialog.dart` | Success dialog overlay |
| `OrDivider` | `app_divider.dart` | Horizontal line with "or continue with" text |
| `AppErrorBanner` | `app_error_banner.dart` | Inline error message |
| `AppLoadingOverlay` | `app_loading_overlay.dart` | Semi-transparent overlay with spinner |
| `AppSectionHeader` | `app_section_header.dart` | Title + optional "See All" button |
| `AppTextField` | `app_text_field.dart` | Themed text input with label, error, password toggle |
| `AppBottomAuthLink` | `app_bottom_auth_link.dart` | "Already have an account?" style link |

---

## 8. Navigation Flow

```
                        SplashScreen
                             |
               ┌─────────────┴─────────────┐
               │                           │
          Auth Check                   Auto-navigate
               │                           │
        ┌──────┴──────┐                    │
        │             │                    ▼
   Not Auth      Authenticated        HomeScreen
        │             │
        ▼             ▼
   LoginScreen    HomeScreen
        │
   ┌────┼────┐────────────┐
   │    │    │            │
   ▼    ▼    ▼            ▼
Signup Forgot  Google     HomeScreen
   │   Password  OAuth
   │    │         │
   ▼    ▼         ▼
Verify Reset   HomeScreen
 Email  Pwd

HomeScreen (BottomNavBar):
├── Tab 0: Home
│   ├── ContinueLearning → CourseLearningScreen
│   ├── FeaturedCourses → CourseDetailScreen
│   ├── Categories → CategoryDetailScreen
│   ├── LiveClasses → LiveClassRoomScreen
│   ├── TopInstructors → InstructorProfileScreen
│   ├── PopularCourses → CourseDetailScreen
│   └── RecommendedCourses → CourseDetailScreen
│
├── Tab 1: Explore
│   ├── CourseCard → CourseDetailScreen
│   └── CategoryChips → CategoryDetailScreen
│
├── Tab 2: Search
│   └── Suggestions → CourseDetailScreen / InstructorProfileScreen / CategoryDetailScreen
│
└── Tab 3: Profile
    ├── MyLearningScreen → CourseLearningScreen
    ├── NotificationScreen
    ├── SettingsScreen
    └── InstructorDashboardScreen (if INSTRUCTOR role)

CourseDetailScreen
├── Overview / Curriculum / Reviews tabs
├── Enroll → CourseLearningScreen
└── Instructor info → InstructorProfileScreen

CourseLearningScreen
├── Video player (full-screen CustomVideoPlayer)
├── Notes (NotesList)
├── Study Materials (StudyMaterialList)
└── Lesson navigation

InstructorDashboardScreen (ValueListenableBuilder sub-routing):
├── DashboardHome
├── InstructorCoursesScreen → CourseCreationScreen
│                              CourseEditScreen
│                              InstructorCourseDetailScreen
├── InstructorLiveClassesScreen → LiveClassRoomScreen
├── InstructorStudentsScreen
├── InstructorAnalyticsScreen
├── InstructorEarningsScreen
├── InstructorReviewsScreen
└── InstructorProfileScreen (own profile)

InstructorCourseDetailScreen (5 tabs):
├── Overview → Edit course
├── Content → Section/Lesson CRUD dialogs
├── Reviews
├── Q&A (local mock data only)
└── Analytics
```

---

## 9. Backend Service Layer — Key Methods

### Auth Services
- `registerUser(data)` → PendingRegistration
- `loginUser(email, password)` → { user, accessToken, refreshToken }
- `refreshAccessToken(refreshToken)` → { accessToken, refreshToken }
- `getCurrentUser(userId)` → user + needsOnboarding
- `updateUserRole(userId, role)` → updated user
- `deleteRefreshToken(token)` → void

### Google Auth Service
- `authenticateWithGoogle(profile)` → { user, accessToken, needsOnboarding }

### Verification Service
- `sendVerificationCode(email)` → void (sends 6-digit code via Resend)
- `verifyVerificationCode(email, code)` → { user, accessToken }

### Course Service
- `getCourses(filters, page, limit)` → paginated courses
- `getCoursesByInstructor(instructorId)` → courses
- `getCourseById(id)` → full course with sections/lessons
- `getCourseBySlug(slug)` → full course
- `createCourse(data)` → course
- `updateCourse(id, data)` → course
- `deleteCourse(id)` → void
- `publishCourse(id)` → course
- `unpublishCourse(id)` → course

### Section Service
- CRUD + `reorderSections(courseId, sectionIds)`

### Lesson Service
- CRUD + `reorderLessons(sectionId, lessonIds)`

### Enrollment Service
- `enrollInCourse(userId, courseId)` → enrollment
- `getMyEnrollments(userId)` → enrollments with progress
- `getEnrolledStudents(courseId)` → students
- `markCourseComplete(userId, courseId)` → void

### Instructor Service
- `getInstructors(filters)` → paginated instructors
- `getInstructorById(id)` → instructor with stats
- `followInstructor(userId, instructorId)` → follow
- `unfollowInstructor(userId, instructorId)` → void
- `getFollowedInstructors(userId)` → instructors

### Payment Service
- `initiatePayment(userId, courseId)` → eSewa form data
- `paymentSuccess(callbackData)` → enrollment + payment record
- `paymentFailure(callbackData)` → void
- `getMyPayments(userId)` → payments

### Review Service
- CRUD + `instructorReply(reviewId, reply)` + automatic rating recalculation

### Notification Service
- `getMyNotifications(userId, page, limit)` → notifications
- `markAsRead(notificationId)` → void
- `markAllAsRead(userId)` → void
- `deleteNotification(notificationId)` → void
- `sendPushNotification(userId, title, body, data)` → FCM send
- `saveFcmToken(userId, token)` → void

### Live Class Service
- Full lifecycle: create, update, delete, start, end, join, leave
- `getParticipants(liveClassId)` → participants

### Admin Service
- `getDashboardStats()` → aggregate stats
- Full CRUD on: users, courses, reviews, instructors, payments, payouts, live classes
- `sendNotification(data)` → FCM + Notification record

### Storage Services
- `CloudinaryStorageService`: upload (stream, retry 3x), delete, signed URL
- `GoogleDriveStorage`: upload, delete, getUrl via Google Drive API
- Selected via `STORAGE_PROVIDER` env var (default: `google-drive`)

---

## 10. External Integrations

| Service | Purpose | Config |
|---|---|---|
| **PostgreSQL (Neon)** | Primary database | `DATABASE_URL` |
| **eSewa** | Payment gateway (Nepal) | `ESEWA_MERCHANT_ID`, `ESEWA_SECRET_KEY`, `ESEWA_BASE_URL`, `ESEWA_PRODUCT_CODE` |
| **Firebase Cloud Messaging** | Push notifications | `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY` |
| **Resend** | Transactional emails (OTP) | `RESEND_API_KEY` |
| **Cloudinary** | Image/video storage | `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET` |
| **Google Drive** | Alternative video storage | `GOOGLE_DRIVE_CLIENT_EMAIL`, `GOOGLE_DRIVE_PRIVATE_KEY`, `GOOGLE_DRIVE_ROOT_FOLDER_ID` |
| **Google OAuth** | Social login | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` |
| **Jitsi Meet** | Live video conferencing | Room names generated server-side; client uses `jitsi_meet_flutter_sdk` |
| **JWT** | Access + refresh tokens | `JWT_SECRET`, `JWT_EXPIRES_IN` |

---

## 11. Known Issues & Notes for Redesign

1. **Dual AppColors**: Two implementations exist — `lib/constants/colors.dart` (static methods, used everywhere) and `lib/theme/app_colors.dart` (instance-based, used by notes/study material/review widgets). **Recommendation:** Consolidate to one.

2. **Mixed Navigation**: Named routes defined in `app_routes.dart` but rarely used. Most navigation is `Navigator.push(MaterialPageRoute(...))`. **Recommendation:** Pick one approach.

3. **Instructor Dashboard Sub-routing**: Uses `ValueNotifier<String?>` pattern instead of proper routing. Keeps sub-screens in memory. **Recommendation:** Consider proper routing or a state machine.

4. **Duplicate Models**: `trending_data.dart` and `trending_results.dart` define the same `TrendingData` class. **Recommendation:** Remove duplicate.

5. **Q&A Feature**: Mock/local data only — no backend API exists for Q&A.

6. **Admin Dashboard**: Backend has full admin routes (`/api/admin/*`) but **no admin screens exist in the Flutter frontend**.

7. **Payment Flow**: Backend has eSewa integration but **payment screens are not fully implemented** in Flutter — enrollment appears to be free/direct via `POST /api/enroll/:courseId`.

8. **Notes/Study Materials**: Backend has note CRUD endpoints but the `NotesList` and `StudyMaterialList` widgets in course learning appear to use local/mock data primarily.

9. **Video Storage**: Backend supports both Cloudinary and Google Drive via `STORAGE_PROVIDER` env var. Frontend's `uploadThumbnail()` calls Cloudinary directly.

10. **Currency**: Prices display Nepali Rupee (`रु`) in instructor forms.

11. **Responsive Design**: Frontend is mobile-first Flutter. `web/` directory exists but Firebase is only configured for Android. Web/desktop support would need additional setup.

12. **Search**: Backend has a single `GET /api/search` endpoint with full-text search. Frontend has rich search UI with suggestions, trending, and recent searches — these appear to be partially client-side.
