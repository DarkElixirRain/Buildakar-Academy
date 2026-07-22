# Instructor Dashboard Backend Capability Report

## Overview
This document outlines the existing backend capabilities that can be leveraged to build an instructor dashboard. All functionality described here is already implemented in the codebase and accessible through the frontend API service.

## Authentication & Authorization
- **Mechanism**: JWT (JSON Web Tokens)
- **Middleware**: `authenticate()` verifies tokens and sets `req.user`
- **Role System**: Three roles - `STUDENT`, `INSTRUCTOR`, `ADMIN` (defined in `@prisma/client`)
- **Role Protection**: `roleMiddleware()` restricts access to specific roles
- **Current User**: Available as `req.user` in all protected routes containing:
  - `id`, `email`, `role`, `firstName`, `lastName`, `isVerified`, `isActive`

## User Model (Prisma Schema)
```prisma
model User {
  id                     String   @id @default(cuid())
  email                  String   @unique
  password               String
  firstName              String
  lastName               String
  role                   Role     @default(STUDENT)
  isVerified             Boolean  @default(false)
  isActive               Boolean  @default(true)
  // ... other fields
  
  // Relations
  courses                Course[]   @relation("InstructorCourses")
  liveClasses            LiveClass[] @relation("InstructorLiveClasses")
  // ... other relations
}
```

## Available API Endpoints for Instructors

### 1. Instructor Profile & Stats
```
GET   /api/instructors/me             - Get current instructor profile
PATCH /api/instructors/profile        - Update instructor profile
GET   /api/instructors/stats          - Get instructor statistics
GET   /api/instructors/analytics      - Get instructor analytics (with optional courseId)
GET   /api/instructors/earnings       - Get instructor earnings
GET   /api/instructors/students       - Get instructor's students
```

### 2. Course Management
```
GET   /api/instructors/courses        - Get instructor's courses (with filtering)
POST  /api/courses                    - Create course
GET   /api/courses/:id                - Get course by ID
PATCH /api/courses/:id                - Update course
DELETE /api/courses/:id               - Delete course
PATCH /api/courses/:id/status         - Update course status (DRAFT/UNDER_REVIEW/PUBLISHED)
POST  /api/courses/:id/duplicate      - Duplicate course
```

### 3. Section Management
```
POST  /api/courses/:courseId/sections - Create section
GET   /api/courses/:courseId/sections - Get course sections
GET   /api/sections/:id               - Get section by ID
PATCH /api/sections/:id               - Update section
DELETE  /api/sections/:id             - Delete section
PATCH /api/sections/reorder           - Reorder sections
PATCH /api/sections/:id/move          - Move section to position
```

### 4. Lesson Management
```
POST  /api/sections/:sectionId/lessons - Create lesson
GET   /api/sections/:sectionId/lessons - Get section lessons
GET   /api/lessons/:id                 - Get lesson by ID
PUT   /api/lessons/:id                 - Update lesson
DELETE  /api/lessons/:id               - Delete lesson
PATCH /api/lessons/reorder             - Reorder lessons
POST  /api/lessons/:id/video           - Upload video to lesson
DELETE  /api/lessons/:id/video         - Delete video from lesson
GET   /api/lessons/:id/stream          - Get video stream URL
```

### 5. Live Class Management
```
POST  /api/live-classes               - Create live class
GET   /api/live-classes/instructor    - Get instructor's live classes
GET   /api/live-classes/:id           - Get live class by ID
PATCH /api/live-classes/:id           - Update live class
PATCH /api/live-classes/:id/start     - Start live class
PATCH /api/live-classes/:id/end       - End live class
PATCH /api/live-classes/:id/cancel    - Cancel live class
GET   /api/live-classes/course/:courseId - Get course live classes
POST  /api/live-classes/:id/join      - Join live class (returns Jitsi info)
```

### 6. Additional Features
```
# Reviews
POST  /api/reviews                    - Create review
PUT   /api/reviews/:id                - Update review
DELETE  /api/reviews/:id              - Delete review
GET   /api/courses/:courseId/reviews  - Get course reviews

# Notifications
GET   /api/notifications              - Get notifications
PATCH /api/notifications/:id/read     - Mark notification as read
PATCH /api/notifications/read-all     - Mark all as read
DELETE  /api/notifications/:id        - Delete notification
GET   /api/notifications/unread-count - Get unread count
```

## Data Models Available

### Course Model
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "thumbnail": "string",
  "price": "number",
  "originalPrice": "number",
  "level": "BEGINNER|INTERMEDIATE|ADVANCED",
  "language": "string",
  "duration": "string",
  "totalHours": "number",
  "status": "DRAFT|UNDER_REVIEW|PUBLISHED",
  "isPublished": "boolean",
  "instructorId": "string",
  "studentsCount": "number",
  "rating": "number",
  // ... relations to sections, lessons, reviews, enrollments
}
```

### Live Class Model
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "roomName": "string",
  "scheduledAt": "datetime",
  "startedAt": "datetime",
  "endedAt": "datetime",
  "status": "SCHEDULED|LIVE|ENDED|CANCELLED",
  "instructorId": "string",
  "courseId": "string (optional)",
  "maxParticipants": "number",
  // ... relations to course, instructor, participants
}
```

### Instructor Stats
```json
{
  "totalStudents": "number",
  "totalCourses": "number",
  "totalRevenue": "number",
  "averageRating": "number",
  "totalReviews": "number",
  "totalEarnings": "number"
}
```

## Frontend API Service Methods Available

The frontend `ApiService` provides direct access to all backend endpoints:

### Instructor Service Methods
- `getInstructors()`
- `getInstructorById(id)`
- `getInstructorStats()`
- `getInstructorAnalytics(courseId?)`
- `getInstructorStudents()`
- `getInstructorEarnings()`
- `getInstructorCourses()`
- `updateInstructorProfile(data)`

### Course Service Methods
- `getInstructorCourses(filters)`
- `getInstructorStats()`
- `createCourse(data)`
- `updateCourse(id, data)`
- `deleteCourse(id)`
- `updateCourseStatus(id, status)`
- `duplicateCourse(id)`

### Live Class Service Methods
- `getInstructorLiveClasses()`
- `createLiveClass(data)`
- `updateLiveClass(id, data)`
- `startLiveClass(id)`
- `endLiveClass(id)`
- `cancelLiveClass(id)`
- `joinLiveClass(id)`

## Security & Authorization
All endpoints properly enforce:
- Authentication requirement via `authenticate()` middleware
- Role-based access control via `roleMiddleware([Role.INSTRUCTOR, Role.ADMIN])`
- Ownership verification where appropriate (instructors can only access their own resources)
- Validation of state transitions (e.g., cannot start a non-scheduled class)

## Implementation Readiness
All necessary components for a fully functional instructor dashboard are already implemented:
1. **Backend APIs** - Complete and tested
2. **Frontend API Client** - Methods available for all endpoints
3. **UI Components** - Reusable patterns exist (cards, lists, forms, etc.)
4. **Navigation** - Bottom tab routing already supports instructor dashboard
5. **State Management** - Provider pattern already in use

## Recommendation
The instructor dashboard can be enhanced by leveraging the existing API service methods to display comprehensive information while maintaining consistency with the existing UI patterns in the application.