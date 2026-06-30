// backend/src/routes/course.routes.ts
import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import { checkCourseOwnership } from '../middleware/ownership.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';
import courseController from '../controllers/course.controller';

const router = express.Router();

// ============================================
// ✅ PUBLIC ROUTES - No authentication required
// ============================================

// GET /api/courses/public - Get public courses (for students)
router.get(
  '/public',
  courseController.getPublicCourses
);

// GET /api/courses/:id - Get course by ID (Public for published courses)
// Removed validate middleware - we'll validate in controller
router.get(
  '/:id',
  courseController.getCourseById
);

// ============================================
// 🔒 PROTECTED ROUTES - Authentication required
// ============================================

// All routes below require authentication
router.use(authenticate);

const instructorOrAdmin = roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]);
const adminOnly = roleMiddleware([Role.ADMIN]);

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

// GET /api/courses/stats - Get instructor stats
router.get(
  '/stats',
  instructorOrAdmin,
  courseController.getInstructorStats
);

// PATCH /api/courses/:id - Update course
router.patch(
  '/:id',
  instructorOrAdmin,
  validate(schemas.courseId),
  checkCourseOwnership,
  validate(schemas.updateCourse),
  courseController.updateCourse
);

// DELETE /api/courses/:id - Delete course
router.delete(
  '/:id',
  instructorOrAdmin,
  validate(schemas.courseId),
  checkCourseOwnership,
  courseController.deleteCourse
);

// PATCH /api/courses/:id/status - Update course status
router.patch(
  '/:id/status',
  instructorOrAdmin,
  validate(schemas.courseId),
  checkCourseOwnership,
  validate(schemas.updateCourseStatus),
  courseController.updateCourseStatus
);

// POST /api/courses/:id/duplicate - Duplicate course
router.post(
  '/:id/duplicate',
  instructorOrAdmin,
  validate(schemas.courseId),
  checkCourseOwnership,
  courseController.duplicateCourse
);

export default router;