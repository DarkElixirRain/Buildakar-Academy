// src/routes/notification.routes.ts
import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import {getNotification,getUnreadCounts,deletenotification,markasRead,markallAsRead,removepushToken,savepushToken} from '../controllers/notification.controller';
import { deleteNotification } from '../services/notification.service';

const router = express.Router();

// All notification routes require auth
router.use(authenticate);

// ─── Feed ────────────────────────────────────

// GET /api/notifications

router.get('/',getNotification);

// GET /api/notifications/unread-count

router.get('/unread-count', getUnreadCounts);

// ─── Read / Delete ──────────────────────────

// PATCH /api/notifications/read-all

router.patch('/read-all', markallAsRead);

// PATCH /api/notifications/:id/read

router.patch('/:id/read', markasRead);

// DELETE /api/notifications/:id

router.delete('/:id', deletenotification);

// ─── Push token ──────────────────────────────

// POST /api/notifications/push-token
// Save FCM token on login / app open
router.post('/push-token',savepushToken);

// DELETE /api/notifications/push-token
// Remove FCM token on logout
router.delete('/push-token', removepushToken);

export default router;