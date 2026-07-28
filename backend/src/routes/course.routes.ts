// backend/src/routes/course.routes.ts
import express from 'express';
import { authenticate, optionalAuthenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import { checkCourseOwnership } from '../middleware/ownership.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';
import courseController from '../controllers/course.controller';

const router = express.Router();

const instructorOrAdmin = roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]);

// ============================================
// ✅ PUBLIC ROUTES - No authentication required
// ============================================

// GET /api/courses/public - Get public courses (for students)
router.get(
  '/public',
  courseController.getPublicCourses
);

// ============================================
// ✅ SPECIFIC ROUTES - Must be before /:id to avoid shadowing
// ============================================

// GET /api/courses/stats - Get instructor stats (authenticated)
router.get(
  '/stats',
  authenticate,
  instructorOrAdmin,
  courseController.getInstructorStats
);

// ============================================
// ✅ PUBLIC PARAMETERIZED ROUTE - No auth required
// ============================================

// GET /api/courses/:id - Get course by ID (Public for published, authenticated for draft)
router.get(
  '/:id',
  optionalAuthenticate,
  courseController.getCourseById
);

// ============================================
// 🔒 PROTECTED ROUTES - Authentication required
// ============================================

router.use(authenticate);

// POST /api/courses - Create course (Instructor)
router.post(
  '/',
  instructorOrAdmin,
  validate(schemas.createCourse),
  courseController.createCourse
);

// GET /api/courses - Get courses (Instructor: own, Admin: all)
router.get(
  '/',
  instructorOrAdmin,
  courseController.getCourses
);

// PATCH /api/courses/:id - Update course
router.patch(
  '/:id',
  instructorOrAdmin,
  validate(schemas.courseId, 'params'),
  checkCourseOwnership,
  validate(schemas.updateCourse),
  courseController.updateCourse
);

// DELETE /api/courses/:id - Delete course
router.delete(
  '/:id',
  instructorOrAdmin,
  validate(schemas.courseId, 'params'),
  checkCourseOwnership,
  courseController.deleteCourse
);

// PATCH /api/courses/:id/status - Update course status
router.patch(
  '/:id/status',
  instructorOrAdmin,
  validate(schemas.courseId, 'params'),
  checkCourseOwnership,
  validate(schemas.updateCourseStatus),
  courseController.updateCourseStatus
);

// POST /api/courses/:id/duplicate - Duplicate course
router.post(
  '/:id/duplicate',
  instructorOrAdmin,
  validate(schemas.courseId, 'params'),
  checkCourseOwnership,
  courseController.duplicateCourse
);

export default router;