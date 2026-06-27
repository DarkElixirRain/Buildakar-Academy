import { Router } from 'express';
import authController from '../controllers/auth.controller';
import googleAuthController from '../controllers/googleAuth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';

const router = Router();

// Public routes with validation
router.post('/register', validate(schemas.register), authController.register);
router.post('/login', validate(schemas.login), authController.login);
// Google OAuth (receives authorization code from client)
router.post('/google', googleAuthController.googleAuth);

// Protected routes
router.get('/me', authenticate, authController.getMe);
router.post('/logout', authenticate, authController.logout);
router.put('/role', authenticate, validate(schemas.updateRole), authController.updateRole);

export default router;