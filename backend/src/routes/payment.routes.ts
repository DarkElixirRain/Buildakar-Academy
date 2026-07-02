// src/routes/payment.routes.ts
import express from 'express';
import { authenticate } from '../middleware/auth.middleware';
import paymentController from '../controllers/payment.controller';

const router = express.Router();

// POST /api/payments/initiate
// Student initiates a course purchase
// Body: { courseId: string }
router.post('/initiate', authenticate, paymentController.initiatePayment);

// GET /api/payments/orders
// Student's full payment history
router.get('/orders', authenticate, paymentController.getOrders);

// GET /api/payments/orders/:id
// Single payment detail
router.get('/orders/:id', authenticate, paymentController.getOrderById);

// GET /api/payments/success
// eSewa redirects here after successful payment
// Query: { data: string } — base64 encoded JSON from eSewa
router.get('/success', paymentController.paymentSuccess);

// GET /api/payments/failure
// eSewa redirects here after failed/cancelled payment
// Query: { data: string } — base64 encoded JSON from eSewa
router.get('/failure', paymentController.paymentFailure);

export default router;