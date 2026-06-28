// backend/src/routes/section.routes.ts
import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import { checkCourseOwnership, checkCourseOwnershipForSection, checkSectionOwnership } from '../middleware/ownership.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';
import sectionController from '../controllers/section.controller';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

const instructorOrAdmin = roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]);

// GET /api/courses/:courseId/sections - Get sections for a course
router.get(
  '/courses/:courseId/sections',
  instructorOrAdmin,
  checkCourseOwnership,
  sectionController.getSectionsByCourse
);

// POST /api/courses/:courseId/sections - Create section
router.post(
  '/courses/:courseId/sections',
  instructorOrAdmin,
  checkCourseOwnershipForSection,
  validate(schemas.createSection),
  sectionController.createSection
);

// GET /api/sections/:id - Get section by ID
router.get(
  '/sections/:id',
  instructorOrAdmin,
  validate(schemas.sectionId),
  checkSectionOwnership,
  sectionController.getSectionById
);

// PATCH /api/sections/:id - Update section
router.patch(
  '/sections/:id',
  instructorOrAdmin,
  validate(schemas.sectionId),
  checkSectionOwnership,
  validate(schemas.updateSection),
  sectionController.updateSection
);

// DELETE /api/sections/:id - Delete section
router.delete(
  '/sections/:id',
  instructorOrAdmin,
  validate(schemas.sectionId),
  checkSectionOwnership,
  sectionController.deleteSection
);

// POST /api/courses/:courseId/sections/reorder - Reorder sections
router.post(
  '/courses/:courseId/sections/reorder',
  instructorOrAdmin,
  checkCourseOwnership,
  validate(schemas.reorderSections),
  sectionController.reorderSections
);

// PATCH /api/sections/:id/move - Move section to position
router.patch(
  '/sections/:id/move',
  instructorOrAdmin,
  validate(schemas.sectionId),
  checkSectionOwnership,
  sectionController.moveSection
);

export default router;