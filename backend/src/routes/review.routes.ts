import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { CreateReview, DeleteReview, getCourseReview, getMyReviews, UpdateReview } from '../controllers/review.controller'; 
 
const router = express.Router();

// POST /api/courses/:courseId/reviews
// Create a review (enrolled students only)
router.post(
  '/courses/:courseId/reviews',
  authenticate,
  CreateReview
);

// PATCH /api/reviews/:id
// Update own review
router.patch(
  '/reviews/:id',
  authenticate,
  UpdateReview
);


// DELETE /api/reviews/:id
// Delete own review (or ADMIN)
router.delete(
  '/reviews/:id',
  authenticate,
  DeleteReview
);

// GET /api/courses/:courseId/my-review
// Get current user's own review for a course
router.get(
  '/courses/:courseId/my-review',
  authenticate,
 getMyReviews
);

// GET /api/courses/:courseId/reviews
router.get(
  '/courses/:courseId/reviews',
 getCourseReview
);

export default router