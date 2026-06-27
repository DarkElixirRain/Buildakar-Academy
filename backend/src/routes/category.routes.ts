// backend/src/routes/category.routes.ts
import express from 'express';
import categoryController from '../controllers/category.controller';
import { authenticate } from '../middleware/auth.middleware';
import { roleMiddleware } from '../middleware/role.middleware';
import { Role } from '@prisma/client';

const router = express.Router();

// Public routes
router.get('/', categoryController.getAllCategories);
router.get('/:id', categoryController.getCategoryById);
router.get('/slug/:slug', categoryController.getCategoryBySlug);
router.get('/:id/stats', categoryController.getCategoryStats);

// Admin only routes
router.post(
  '/',
  authenticate,
  roleMiddleware([Role.ADMIN]),
  categoryController.createCategory
);

router.put(
  '/:id',
  authenticate,
  roleMiddleware([Role.ADMIN]),
  categoryController.updateCategory
);

router.delete(
  '/:id',
  authenticate,
  roleMiddleware([Role.ADMIN]),
  categoryController.deleteCategory
);

export default router;