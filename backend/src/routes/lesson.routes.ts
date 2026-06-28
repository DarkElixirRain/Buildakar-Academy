// backend/src/routes/lesson.routes.ts
import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';
import { checkCourseOwnership, checkCourseOwnershipForLesson, checkLessonOwnership } from '../middleware/ownership.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';
import lessonController from '../controllers/lesson.controller';
import multer from 'multer';

const router = express.Router();
const upload = multer({ 
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 * 1024 }, // 5GB
});

// All routes require authentication
router.use(authenticate);

const instructorOrAdmin = roleMiddleware([Role.INSTRUCTOR, Role.ADMIN]);

// GET /api/sections/:sectionId/lessons - Get lessons for a section
router.get(
  '/sections/:sectionId/lessons',
  instructorOrAdmin,
  checkCourseOwnershipForLesson,
  lessonController.getLessonsBySection
);

// GET /api/courses/:courseId/lessons - Get all lessons for a course
router.get(
  '/courses/:courseId/lessons',
  instructorOrAdmin,
  checkCourseOwnership,
  lessonController.getLessonsByCourse
);

// POST /api/sections/:sectionId/lessons - Create lesson
router.post(
  '/sections/:sectionId/lessons',
  instructorOrAdmin,
  checkCourseOwnershipForLesson,
  validate(schemas.createLesson),
  lessonController.createLesson
);

// GET /api/lessons/:id - Get lesson by ID
router.get(
  '/lessons/:id',
  instructorOrAdmin,
  validate(schemas.lessonId),
  checkLessonOwnership,
  lessonController.getLessonById
);

// PATCH /api/lessons/:id - Update lesson
router.patch(
  '/lessons/:id',
  instructorOrAdmin,
  validate(schemas.lessonId),
  checkLessonOwnership,
  validate(schemas.updateLesson),
  lessonController.updateLesson
);

// DELETE /api/lessons/:id - Delete lesson
router.delete(
  '/lessons/:id',
  instructorOrAdmin,
  validate(schemas.lessonId),
  checkLessonOwnership,
  lessonController.deleteLesson
);

// POST /api/sections/:sectionId/lessons/reorder - Reorder lessons
router.post(
  '/sections/:sectionId/lessons/reorder',
  instructorOrAdmin,
  checkCourseOwnershipForLesson,
  validate(schemas.reorderLessons),
  lessonController.reorderLessons
);

// POST /api/lessons/:id/upload-video - Upload video for lesson
router.post(
  '/lessons/:id/upload-video',
  instructorOrAdmin,
  validate(schemas.lessonId),
  checkLessonOwnership,
  upload.single('video'),
  lessonController.uploadVideo
);

// DELETE /api/lessons/:id/video - Delete video from lesson
router.delete(
  '/lessons/:id/video',
  instructorOrAdmin,
  validate(schemas.lessonId),
  checkLessonOwnership,
  lessonController.deleteVideo
);

// GET /api/lessons/:id/stream-url - Get video stream URL
router.get(
  '/lessons/:id/stream-url',
  instructorOrAdmin,
  validate(schemas.lessonId),
  checkLessonOwnership,
  lessonController.getVideoStreamUrl
);

export default router;