
import { PaymentStatus, PaymentProvider, Enrollment } from '@prisma/client';
import { prisma } from '../lib/prisma';
import { createId } from '@paralleldrive/cuid2';
import {
  buildEsewaFormPayload,
  decodeEsewaResponse,
  verifyEsewaSignature,
  verifyEsewaPayment,
} from '../utils/esewa';
import { notifyEnrollment, notifyPaymentFailed, notifyPaymentSuccess } from './notification.service';

// types
export interface InitiatePaymentResult {
  isFree: boolean;
  paymentId: string | null;
  payload: Record<string, string> | null;
  esewaUrl: string | null;
  enrollment?: Enrollment;
}

export interface CompletePaymentResult {
  success: boolean;
  paymentId: string;
  courseId: string;
  enrollment: Enrollment;
}

interface EsewaMetadata {
  [key: string]: unknown;
  transactionUuid: string;
  esewaTransactionCode?: string;
  rawResponse?: Record<string, string>;
  note?: string;
}

// helper
function getEnvOrThrow(key: string): string {
  const value = process.env[key];
  if (!value) throw new Error(`Missing environment variable: ${key}`);
  return value;
}

function createError(message: string, statusCode: number): Error {
  return Object.assign(new Error(message), { statusCode });
}


export class PaymentService {

  /**
   * Step 1 — Initiate payment.
   *
   * For free courses: auto-enrolls and returns immediately.
   * For paid courses: creates a PENDING Payment record and
   * returns the signed eSewa form payload for the frontend WebView.
   *
   * transactionUuid is stored in Payment.metadata so we can look
   * up the Payment when eSewa redirects back to us.
   */
  async initiatePayment(
    userId: string,
    courseId: string
  ): Promise<InitiatePaymentResult> {

    // 1. Fetch course
    const course = await prisma.course.findUnique({
      where: { id: courseId },
      select: {
        id: true,
        title: true,
        price: true,
        currency: true,
        status: true,
        isPublished: true,
        instructor: {
          select: { id: true, firstName: true, lastName: true },
        },
      },
    });

    if (!course) {
      throw createError('Course not found', 404);
    }

    if (course.status !== 'PUBLISHED' || !course.isPublished) {
      throw createError('Course is not available for purchase', 400);
    }

    // 2. Check existing enrollment
    const existingEnrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });

    if (existingEnrollment) {
      throw createError('You are already enrolled in this course', 400);
    }

    // 3. Free course — enroll directly, skip payment
    if (!course.price || course.price === 0) {
      const enrollment = await prisma.$transaction(async (tx) => {
        const enroll = await tx.enrollment.create({
          data: { userId, courseId },
        });

        await tx.course.update({
          where: { id: courseId },
          data: { studentsCount: { increment: 1 } },
        });

        // Record a SUCCEEDED payment with zero amount for audit trail
        await tx.payment.create({
          data: {
            userId,
            courseId,
            amount: 0,
            currency: course.currency || 'NPR',
            status: PaymentStatus.SUCCEEDED,
            provider: PaymentProvider.ESEWA,
            enrollmentId: enroll.id,
            paidAt: new Date(),
            metadata: {
                note: 'Free course — no payment required',
                transactionUuid: ''
            } satisfies EsewaMetadata,
          },
        });

        return enroll;
      });

      console.log(`[Payment] Free enrollment: user=${userId} course=${courseId}`);

      notifyEnrollment(userId, course.title, courseId)
        .catch((err) =>
          console.error('[Notification] Free enrollment notify failed:', err)
        );

      return {
        isFree: true,
        paymentId: null,
        payload: null,
        esewaUrl: null,
        enrollment,
      };
    }

    // 4. Paid course — create PENDING payment record
    const transactionUuid = createId();

    const payment = await prisma.payment.create({
      data: {
        userId,
        courseId,
        amount: course.price,
        currency: course.currency || 'NPR',
        status: PaymentStatus.PENDING,
        provider: PaymentProvider.ESEWA,
        metadata: {
          transactionUuid,
        } satisfies EsewaMetadata,
      },
    });

    console.log(`📦 [Payment] Created PENDING payment: ${payment.id}`);

    // 5. Build signed eSewa payload
    const merchantCode = getEnvOrThrow('ESEWA_MERCHANT_CODE');
    const secretKey = getEnvOrThrow('ESEWA_SECRET_KEY');
    const backendUrl = getEnvOrThrow('BACKEND_URL');
    const esewaBaseUrl = getEnvOrThrow('ESEWA_BASE_URL');

    const payload = buildEsewaFormPayload({
      amount: course.price,
      transactionUuid,
      merchantCode,
      secretKey,
      successUrl: `${backendUrl}/api/payments/success`,
      failureUrl: `${backendUrl}/api/payments/failure`,
    });

    return {
      isFree: false,
      paymentId: payment.id,
      payload,
      esewaUrl: `${esewaBaseUrl}/api/epay/main/v2/form`,
    };
  }

  /**
   * Step 2 — Verify and complete payment.
   *
   * Called when eSewa redirects to our success URL with
   * ?data=BASE64_ENCODED_JSON in the query string.
   *
   * Flow:
   * 1. Decode + verify eSewa signature
   * 2. Find our Payment via transactionUuid in metadata
   * 3. Double-verify with eSewa status API
   * 4. In a transaction: mark SUCCEEDED + create Enrollment + update stats
   *
   * Idempotent: safe to call multiple times for the same payment.
   */
  async verifyAndCompletePayment(
    encodedData: string
  ): Promise<CompletePaymentResult> {
    const secretKey = getEnvOrThrow('ESEWA_SECRET_KEY');
    const merchantCode = getEnvOrThrow('ESEWA_MERCHANT_CODE');
    const esewaBaseUrl = getEnvOrThrow('ESEWA_BASE_URL');

    // 1. Decode eSewa base64 response
    let decoded: Record<string, string>;
    try {
      decoded = decodeEsewaResponse(encodedData);
      console.log('📦 [Payment] Decoded eSewa response:', decoded);
    } catch {
      throw createError('Invalid payment response from eSewa', 400);
    }

    // 2. Verify eSewa signature
    const isSignatureValid = verifyEsewaSignature(decoded, secretKey);
    if (!isSignatureValid) {
      throw createError('Invalid payment signature', 400);
    }

    // 3. Find our Payment record via transactionUuid stored in metadata
    const transactionUuid = decoded.transaction_uuid;
    if (!transactionUuid) {
      throw createError('Missing transaction ID in payment response', 400);
    }

    const payment = await prisma.payment.findFirst({
      where: {
        provider: PaymentProvider.ESEWA,
        metadata: {
          path: ['transactionUuid'],
          equals: transactionUuid,
        },
      },
      include: { course: true },
    });

    if (!payment) {
      throw createError('Payment record not found', 404);
    }

    // 4. Idempotency — already processed
    if (payment.status === PaymentStatus.SUCCEEDED) {
      console.log(`ℹ️ [Payment] Already succeeded: ${payment.id}`);

      const enrollment = await prisma.enrollment.findUniqueOrThrow({
        where: {
          userId_courseId: {
            userId: payment.userId,
            courseId: payment.courseId,
          },
        },
      });

      return {
        success: true,
        paymentId: payment.id,
        courseId: payment.courseId,
        enrollment,
      };
    }

    // 5. Verify with eSewa status API — never trust redirect alone
    let esewaStatus: Awaited<ReturnType<typeof verifyEsewaPayment>>;
    try {
      esewaStatus = await verifyEsewaPayment({
        baseUrl: esewaBaseUrl,
        merchantCode,
        totalAmount: payment.amount,
        transactionUuid,
      });
    } catch (error) {
      console.error('❌ [Payment] eSewa status API error:', error);

      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.FAILED,
          failureReason: 'eSewa status API unreachable',
        },
      });


      // ── NOTIFICATION: payment failed (API unreachable) ─────────
     notifyPaymentFailed(payment.userId, payment.course.title, payment.courseId)
        .catch((err) =>
          console.error('[Notification] Payment failed notify error:', err)
        );

      throw createError('Payment verification failed. Please contact support.', 400);
    }

    // 6. Confirm COMPLETE
    if (esewaStatus.status !== 'COMPLETE') {
      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.FAILED,
          failureReason: `eSewa returned status: ${esewaStatus.status}`,
        },
      });

         // ── NOTIFICATION: payment not completed ────────────────────
      notifyPaymentFailed(payment.userId, payment.course.title, payment.courseId)
        .catch((err) =>
          console.error('⚠️ [Notification] Payment failed notify error:', err)
        );

      throw createError(`Payment not completed. Status: ${esewaStatus.status}`, 400);
    }

    // 7. All verified — complete in a single atomic transaction
    const { enrollment } = await prisma.$transaction(async (tx) => {

      // Upsert enrollment — handles duplicate redirects gracefully
      const enroll = await tx.enrollment.upsert({
        where: {
          userId_courseId: {
            userId: payment.userId,
            courseId: payment.courseId,
          },
        },
        create: {
          userId: payment.userId,
          courseId: payment.courseId,
        },
        update: {
          updatedAt: new Date(),
        },
      });

      // Mark payment SUCCEEDED
      // providerReference = eSewa's own transaction_code
      await tx.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.SUCCEEDED,
          providerReference: decoded.transaction_code,
          enrollmentId: enroll.id,
          paidAt: new Date(),
          metadata: {
            transactionUuid,
            esewaTransactionCode: decoded.transaction_code,
            rawResponse: decoded,
          } satisfies EsewaMetadata,
        },
      });

      // Increment course student count
      await tx.course.update({
        where: { id: payment.courseId },
        data: { studentsCount: { increment: 1 } },
      });

      // Update instructor revenue + student count
      await tx.user.update({
        where: { id: payment.course.instructorId },
        data: {
          totalStudents: { increment: 1 },
          totalRevenue: { increment: payment.amount },
        },
      });

      return { enrollment: enroll };
    });

    console.log(
      `[Payment] SUCCEEDED: payment=${payment.id} user=${payment.userId} course=${payment.courseId}`
    );
    // ── NOTIFICATIONS: payment success + enrollment ─────────────
    // Both fire after transaction commits — non-blocking
  notifyPaymentSuccess(
        payment.userId,
        payment.course.title,
        payment.courseId,
        payment.amount,
        payment.currency
      )
      .catch((err) =>
        console.error('[Notification] Payment success notify error:', err)
      );

    notifyEnrollment(payment.userId, payment.course.title, payment.courseId)
      .catch((err) =>
        console.error('[Notification] Enrollment notify error:', err)
      );

    return {
      success: true,
      paymentId: payment.id,
      courseId: payment.courseId,
      enrollment,
    };
  }

  /**
   * Called when eSewa redirects to our failure URL.
   * Silently marks the payment FAILED — swallows all errors
   * since eSewa's failure redirect may have minimal data.
   */
  async handlePaymentFailure(encodedData?: string): Promise<void> {
    if (!encodedData) return;

    try {
      const decoded = decodeEsewaResponse(encodedData);
      const transactionUuid = decoded.transaction_uuid;
      if (!transactionUuid) return;

      const payment = await prisma.payment.findFirst({
        where: {
          provider: PaymentProvider.ESEWA,
          metadata: {
            path: ['transactionUuid'],
            equals: transactionUuid,
          },
        },
      });

      if (!payment || payment.status !== PaymentStatus.PENDING) return;

      await prisma.payment.update({
        where: { id: payment.id },
        data: {
          status: PaymentStatus.FAILED,
          failureReason: 'Payment cancelled or failed by user',
          metadata: {
            ...(payment.metadata as object),
            rawResponse: decoded,
          },
        },
      });

      console.log(` [Payment] Marked FAILED: ${payment.id}`);
       // ── NOTIFICATION: payment cancelled ────────────────────────

       const course = await prisma.course.findFirst({where:{id:payment.courseId }})

       if(!course){
        throw new Error("Course not found")
       }
    notifyPaymentFailed(
          payment.userId,
          course?.title,
          payment.courseId
        )
        .catch((err) =>
          console.error('⚠️ [Notification] Payment failure notify error:', err)
        );
    } catch (error) {
      console.error('⚠️ [Payment] Error in handlePaymentFailure:', error);
    }
  }

  /**
   * Student's full payment history with course + enrollment info.
   */
  async getStudentPayments(userId: string, page = 1, limit = 20) {
    const [data, total] = await Promise.all([
      prisma.payment.findMany({
        where: { userId },
        include: {
          course: {
            select: {
              id: true,
              title: true,
              thumbnail: true,
              price: true,
              instructor: {
                select: { firstName: true, lastName: true },
              },
            },
          },
          enrollment: {
            select: { id: true, progress: true, isCompleted: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.payment.count({ where: { userId } }),
    ]);
    return {
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasMore: page * limit < total,
      },
    };
  }

  /**
   * Single payment by ID — validates ownership.
   */
  async getPaymentById(paymentId: string, userId: string) {
    const payment = await prisma.payment.findUnique({
      where: { id: paymentId },
      include: {
        course: {
          select: { id: true, title: true, thumbnail: true, price: true },
        },
        enrollment: {
          select: { id: true, progress: true, isCompleted: true },
        },
      },
    });

    if (!payment) throw createError('Payment not found', 404);
    if (payment.userId !== userId) throw createError('Forbidden', 403);

    return payment;
  }
}

export default new PaymentService();