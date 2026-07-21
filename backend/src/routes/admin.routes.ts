import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import { isAdmin } from '../middleware/role.middleware';
import { validate } from '../middleware/validation.middleware';
import { z } from 'zod';
import {
  getChartdata, getstats, getusers, updateuser,
  getCoursesList, updateCourse,
  getReviewsList, removeReview,
  getInstructorsList, updateInstructorVerification,
  getPaymentsList,
  getRecentActivitiesList,
  getDashboard,
  getNotificationsList, createBroadcastNotification, cleanupNotifications,
  getPayoutsList, updatePayout,
  getAllLiveClassesList,
  getCourseAnalyticsData,
} from '../controllers/admin.controller';
import { CourseStatus, PayoutStatus, NotificationType } from '@prisma/client';

const router = express.Router();

router.use(authenticate);
router.use(isAdmin);

const updateUserSchema = z.object({
  role: z.enum(['STUDENT', 'INSTRUCTOR', 'ADMIN']).optional(),
  isActive: z.boolean().optional(),
  isVerified: z.boolean().optional(),
});

const updateCourseSchema = z.object({
  status: z.nativeEnum(CourseStatus),
  isBestseller: z.boolean().optional(),
  isTrending: z.boolean().optional(),
});

const verifyInstructorSchema = z.object({
  isVerifiedInstructor: z.boolean(),
});

// Dashboard overview
router.get('/dashboard', getDashboard);

// Stats
router.get('/stats', getstats);
router.get('/stats/chart', getChartdata);

// Users
router.get('/users', getusers);
router.patch('/users/:id', validate(updateUserSchema, 'body'), updateuser);

// Courses
router.get('/courses', getCoursesList);
router.patch('/courses/:id', validate(updateCourseSchema, 'body'), updateCourse);

// Reviews
router.get('/reviews', getReviewsList);
router.delete('/reviews/:id', removeReview);

// Instructors
router.get('/instructors', getInstructorsList);
router.patch('/instructors/:id/verify', validate(verifyInstructorSchema, 'body'), updateInstructorVerification);

// Payments
router.get('/payments', getPaymentsList);

const broadcastNotificationSchema = z.object({
  type: z.nativeEnum(NotificationType),
  title: z.string().min(1).max(200),
  body: z.string().min(1).max(2000),
  role: z.enum(['STUDENT', 'INSTRUCTOR', 'ADMIN']).optional(),
  userIds: z.array(z.string()).optional(),
});

const updatePayoutSchema = z.object({
  status: z.nativeEnum(PayoutStatus),
  providerReference: z.string().optional(),
  failureReason: z.string().optional(),
});

// Recent activities
router.get('/activities', getRecentActivitiesList);

// Notifications
router.get('/notifications', getNotificationsList);
router.post('/notifications/broadcast', validate(broadcastNotificationSchema, 'body'), createBroadcastNotification);
router.delete('/notifications/cleanup', cleanupNotifications);

// Payouts
router.get('/payouts', getPayoutsList);
router.patch('/payouts/:id', validate(updatePayoutSchema, 'body'), updatePayout);

// Live classes
router.get('/live-classes', getAllLiveClassesList);

// Course analytics
router.get('/courses/:id/analytics', getCourseAnalyticsData);

export default router
