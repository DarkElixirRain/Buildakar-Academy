// routes/enrollment.routes.ts
import { Router } from 'express';
import EnrollmentController from '../controllers/enrollment.controller';
import { authenticate } from '../middleware/auth.middleware';

const router = Router();
const enrollmentController = new EnrollmentController();

// All routes are relative to /api/enroll (from app.ts)
router.post('/:courseId', authenticate, enrollmentController.enroll);
router.delete('/:courseId', authenticate, enrollmentController.unenroll);
router.get('/:courseId/status', authenticate, enrollmentController.getStatus);
router.get('/my-enrollments', authenticate, enrollmentController.getMyEnrollments);
router.get('/continue-learning', authenticate, enrollmentController.getContinueLearning);
router.patch('/lessons/:id/progress', authenticate, enrollmentController.updateLessonProgress);
router.get('/courses/:courseId/progress', authenticate, enrollmentController.getCourseProgress);

export default router;