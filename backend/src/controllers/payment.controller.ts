// src/controllers/payment.controller.ts
import { Request, Response, NextFunction } from 'express';
import paymentService from '../services/payment.service';

export class PaymentController {

  async initiatePayment(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { courseId } = req.body;

      if (!courseId || typeof courseId !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'courseId is required',
        });
      }

      const result = await paymentService.initiatePayment(userId, courseId);

      // Free course — already enrolled
      if (result.isFree) {
        return res.status(200).json({
          success: true,
          isFree: true,
          message: 'Enrolled successfully',
          data: {
            enrollment: result.enrollment,
          },
        });
      }

      // Paid course — return eSewa form payload for frontend WebView
      return res.status(200).json({
        success: true,
        isFree: false,
        message: 'Payment initiation successful',
        data: {
          paymentId: result.paymentId,
          payload: result.payload,
          esewaUrl: result.esewaUrl,
        },
      });
    } catch (error) {
      next(error);
    }
  }


  async paymentSuccess(req: Request, res: Response, next: NextFunction) {
    const frontendUrl = process.env.FRONTEND_URL || 'exp://localhost:8081';

    try {
      const { data } = req.query;

      if (!data || typeof data !== 'string') {
        return res.redirect(
          `${frontendUrl}/payment/failure?reason=missing_data`
        );
      }

      const result = await paymentService.verifyAndCompletePayment(data);

      // Redirect WebView to frontend success screen
      // Expo's onNavigationStateChange detects this URL and closes the WebView
      return res.redirect(
        `${frontendUrl}/payment/success?courseId=${result.courseId}&paymentId=${result.paymentId}`
      );
    } catch (error: any) {
      const reason = encodeURIComponent(error.message || 'verification_failed');
      return res.redirect(
        `${frontendUrl}/payment/failure?reason=${reason}`
      );
    }
  }

 
  async paymentFailure(req: Request, res: Response, next: NextFunction) {
    const frontendUrl = process.env.FRONTEND_URL || 'exp://localhost:8081';

    try {
      const { data } = req.query;

      // Silently handle — failure data from eSewa may be minimal or absent
      await paymentService.handlePaymentFailure(
        typeof data === 'string' ? data : undefined
      );

      return res.redirect(
        `${frontendUrl}/payment/failure?reason=payment_cancelled`
      );
    } catch (error: any) {
      return res.redirect(
        `${frontendUrl}/payment/failure?reason=unknown`
      );
    }
  }

 
  async getOrders(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;

      const result = await paymentService.getStudentPayments(userId, page, limit);

      return res.status(200).json({
        success: true,
        message: 'Payment history retrieved successfully',
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  }

  /**
   * GET /api/payments/orders/:id
   * Auth required — returns a single payment by ID.
   */
  async getOrderById(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { id } = req.params;

      if (!id) {
        return res.status(400).json({
          success: false,
          message: 'Payment ID is required',
        });
      }

      const payment = await paymentService.getPaymentById(id, userId);

      return res.status(200).json({
        success: true,
        message: 'Payment retrieved successfully',
        data: payment,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new PaymentController();