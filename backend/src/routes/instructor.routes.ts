// backend/src/routes/instructor.routes.ts

import express from 'express';
import { authenticate, optionalAuthenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import { instructorController } from '../controllers/instructor.controller';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';

const router = express.Router();

const instructorOrAdmin = roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]);
const adminOnly = roleMiddleware([Role.ADMIN]);

// ============================================
// ✅ PUBLIC ROUTES - No authentication required
// ============================================

// GET /api/instructors/top - Get top instructors
router.get(
  '/top',
  optionalAuthenticate,
  instructorController.getTopInstructors
);

// GET /api/instructors - Get all instructors with filters
router.get(
  '/',
  optionalAuthenticate,
  instructorController.getInstructors
);

// GET /api/instructors/search - Search instructors
router.get(
  '/search',
  instructorController.searchInstructors
);

// ============================================
// 🔒 PROTECTED ROUTES - Specific paths before /:id
// ============================================

// GET /api/instructors/courses - Get instructor's own courses
router.get(
  '/courses',
  authenticate,
  instructorOrAdmin,
  instructorController.getInstructorCourses
);

// GET /api/instructors/stats - Get instructor stats
router.get(
  '/stats',
  authenticate,
  instructorOrAdmin,
  instructorController.getInstructorStats
);

// GET /api/instructors/analytics - Get instructor analytics
router.get(
  '/analytics',
  authenticate,
  instructorOrAdmin,
  instructorController.getCourseAnalytics
);

// PATCH /api/instructors/profile - Update instructor profile
router.patch(
  '/profile',
  authenticate,
  instructorOrAdmin,
  validate(schemas.updateInstructorProfile),
  instructorController.updateProfile
);

// GET /api/instructors/students - Get instructor's students
router.get(
  '/students',
  authenticate,
  instructorOrAdmin,
  instructorController.getStudents
);

// GET /api/instructors/earnings - Get instructor's earnings
router.get(
  '/earnings',
  authenticate,
  instructorOrAdmin,
  instructorController.getEarnings
);

// POST /api/instructors/:instructorId/follow - Follow/unfollow instructor
router.post(
  '/:instructorId/follow',
  authenticate,
  validate(schemas.instructorId, 'params'),
  instructorController.toggleFollow
);

// GET /api/instructors/:instructorId/followers - Get instructor's followers
router.get(
  '/:instructorId/followers',
  authenticate,
  validate(schemas.instructorId, 'params'),
  instructorController.getFollowers
);

// POST /api/instructors/:instructorId/reviews - Create instructor review
router.post(
  '/:instructorId/reviews',
  authenticate,
  validate(schemas.instructorId, 'params'),
  instructorController.createReview
);

// GET /api/instructors/:instructorId/reviews - Get instructor's reviews
router.get(
  '/:instructorId/reviews',
  optionalAuthenticate,
  validate(schemas.instructorId, 'params'),
  instructorController.getReviews
);

// ============================================
// ✅ PUBLIC CATCH-ALL - Must be last
// ============================================

// GET /api/instructors/:instructorId - Get instructor by ID
router.get(
  '/:instructorId',
  optionalAuthenticate,
  validate(schemas.instructorId, 'params'),
  instructorController.getInstructorById
);

export default router;
