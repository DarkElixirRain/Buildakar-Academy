import { Router } from 'express';
import authController from '../controllers/auth.controller';
import googleAuthController from '../controllers/googleAuth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';

const router = Router();

// Public Routes

router.post(
  '/register',
  validate(schemas.register),
  authController.register
);

router.post(
  '/login',
  validate(schemas.login),
  authController.login
);

// Google OAuth
router.post('/google', googleAuthController.googleAuth);

// Refresh Access Token 
router.post('/refresh', authController.refresh);

//    Protected Routes

router.get('/me', authenticate, authController.getMe);

router.put(
  '/role',
  authenticate,
  validate(schemas.updateRole),
  authController.updateRole
);

// Logout
router.post('/logout', authController.logout);

export default router;