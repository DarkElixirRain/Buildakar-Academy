// backend/src/routes/instructor.routes.ts
import { Router } from 'express';
import { instructorController } from '../controllers/instructor.controller';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';

const router = Router();

// ============= PUBLIC ROUTES =============
// Anyone can view instructors
router.get('/top', instructorController.getTopInstructors);
router.get('/search', instructorController.searchInstructors);
router.get('/', instructorController.getInstructors);
router.get('/:id', instructorController.getInstructorById);

// ============= PROTECTED ROUTES =============
// All routes below require authentication
router.use(authenticate);

// Follow/Unfollow routes (any authenticated user)
router.post('/:instructorId/follow', instructorController.toggleFollow);
router.get('/:instructorId/followers', instructorController.getFollowers);

// ============= INSTRUCTOR ONLY ROUTES =============
// Routes that require INSTRUCTOR role
router.use(roleMiddleware(['INSTRUCTOR']));

// Instructor dashboard and profile
router.get('/stats/dashboard', instructorController.getInstructorStats);
router.get('/analytics/courses', instructorController.getCourseAnalytics);
router.put('/profile', instructorController.updateProfile);

export default router;