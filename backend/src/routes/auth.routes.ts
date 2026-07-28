import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import authController from '../controllers/auth.controller';
import googleAuthController from '../controllers/googleAuth.controller';
import { authenticate } from '../middleware/auth.middleware';
import { validate } from '../middleware/validation.middleware';
import { schemas } from '../utils/validation';

const router = Router();

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many login attempts. Please try again later.' },
});

const refreshLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many refresh attempts. Please try again later.' },
});

const resendLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 1,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Please wait before requesting another code.' },
});

// Public Routes

router.post(
  '/register',
  loginLimiter,
  validate(schemas.register),
  authController.register
);

router.post(
  '/login',
  loginLimiter,
  validate(schemas.login),
  authController.login
);

// Google OAuth
router.post('/google', loginLimiter, googleAuthController.googleAuth);

// Refresh Access Token 
router.post('/refresh', refreshLimiter, authController.refresh);

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

//verification
router.post("/verify-email", authController.verifyEmail);

router.post(
  "/resend-verification",
  resendLimiter,
authController.resendVerification);

export default router;