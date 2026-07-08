import { PrismaClient, NotificationType } from '@prisma/client';
import { messaging } from '../lib/firebase';
 
const prisma = new PrismaClient();
 
function createError(message: string, statusCode: number): Error {
  return Object.assign(new Error(message), { statusCode });
}
 

// types
export interface CreateNotificationParams {
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, string>;
}
 
export interface SendPushParams {
  pushToken: string;
  title: string;
  body: string;
  data?: Record<string, string>;
}

/**
 * Sends a push notification via FCM to a single device token.
 * Silently swallows errors — a failed push should never
 * break the calling business logic.
 */
async function sendPush(params: SendPushParams): Promise<void> {
  const { pushToken, title, body, data } = params;
 
  try {
    await messaging.send({
      token: pushToken,
      notification: { title, body },
      data: data ?? {},
      android: {
        notification: {
          sound: 'default',
          priority: 'high',
          channelId: 'default',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    });
 
    console.log(`[FCM] Push sent to token: ${pushToken.slice(0, 20)}...`);
  } catch (error: any) {
    // If token is invalid/expired, clear it from DB
    if (
      error.code === 'messaging/invalid-registration-token' ||
      error.code === 'messaging/registration-token-not-registered'
    ) {
      console.warn(`[FCM] Invalid token — clearing from DB`);
      await prisma.user
        .updateMany({
          where: { pushToken },
          data: { pushToken: null },
        })
        .catch(() => null);
    } else {
      console.error(` [FCM] Push failed:`, error.message);
    }
  }
}

export async function createAndSend(params:CreateNotificationParams){
    const {userId,type,title,body,data}= params;

    //noti save to DB
    await prisma.notification.create({
      data: {
        userId,
        type,
        title,
        body,
        data: data ?? {},
      },
    });

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { pushToken: true },
    });
 
    if (user?.pushToken) {
      await sendPush({
        pushToken: user.pushToken,
        title,
        body,
        data,
      });
    }
  
}


export async function createAndSendBulk(
    userIds:string[],
    params:Omit<CreateNotificationParams,'userId'>
){
     if (userIds.length === 0) return;
 
    // Bulk insert in-app notifications
    await prisma.notification.createMany({
      data: userIds.map((userId) => ({
        userId,
        type: params.type,
        title: params.title,
        body: params.body,
        data: params.data ?? {},
      })),
    });

     // Get push tokens for all users
    const users = await prisma.user.findMany({
      where: {
        id: { in: userIds },
        pushToken: { not: null },
      },
      select: { pushToken: true },
    });

    const tokens = users
      .map((u) => u.pushToken!)
      .filter(Boolean);
 
    if (tokens.length === 0) return;
    
    // Send FCM multicast
    try {
      const response = await messaging.sendEachForMulticast({
        tokens,
        notification: { title: params.title, body: params.body },
        data: params.data ?? {},
        android: {
          notification: {
            sound: 'default',
            priority: 'high',
            channelId: 'default',
          },
        },
        apns: {
          payload: { aps: { sound: 'default', badge: 1 } },
        },
      });
 
      console.log(
        `[FCM] Multicast: ${response.successCount} sent, ${response.failureCount} failed`
      );
 
      // Clear invalid tokens
      response.responses.forEach(async (resp:any, idx:number ) => {
        if (
          !resp.success &&
          (resp.error?.code === 'messaging/invalid-registration-token' ||
            resp.error?.code === 'messaging/registration-token-not-registered')
        ) {
          await prisma.user
            .updateMany({
              where: { pushToken: tokens[idx] },
              data: { pushToken: null },
            })
            .catch(() => null);
        }
      });
    } catch (error: any) {
      console.error('[FCM] Multicast failed:', error.message);
    }
  }


// Notification Function
export async function notifyEnrollment(userId: string, courseTitle: string, courseId: string){
     await createAndSend({
      userId,
      type: NotificationType.ENROLLMENT,
      title: '🎉 Enrollment Confirmed!',
      body: `You are now enrolled in "${courseTitle}". Start learning today!`,
      data: { courseId, type: 'ENROLLMENT' },
    });
}

// Add this function to notification.service.ts
// Place it after notifyCourseApproved

export async function notifyCoursePublished(
  instructorId: string,
  courseTitle: string,
  courseId: string
) {
  await createAndSend({
    userId: instructorId,
    type: NotificationType.COURSE_PUBLISHED,
    title: '🚀 Course Published!',
    body: `Your course "${courseTitle}" is now live and available to students.`,
    data: { courseId, type: 'COURSE_PUBLISHED' },
  });
}

 export async function notifyPaymentSuccess(
    userId: string,
    courseTitle: string,
    courseId: string,
    amount: number,
    currency: string
  ) {
    await createAndSend({
      userId,
      type: NotificationType.PAYMENT_SUCCESS,
      title: 'Payment Successful',
      body: `Your payment of ${currency} ${amount} for "${courseTitle}" was successful.`,
      data: { courseId, type: 'PAYMENT_SUCCESS' },
    });
  }

   export async function notifyPaymentFailed(
    userId: string,
    courseTitle: string,
    courseId: string
  ) {
    await createAndSend({
      userId,
      type: NotificationType.PAYMENT_FAILED,
      title: ' Payment Failed',
      body: `Your payment for "${courseTitle}" was not completed. Please try again.`,
      data: { courseId, type: 'PAYMENT_FAILED' },
    });
  }

 export  async function notifyNewReview(
    instructorId: string,
    studentName: string,
    courseTitle: string,
    courseId: string,
    rating: number
  ) {
    await createAndSend({
      userId: instructorId,
      type: NotificationType.NEW_REVIEW,
      title: '⭐ New Review',
      body: `${studentName} gave your course "${courseTitle}" ${rating} stars.`,
      data: { courseId, type: 'NEW_REVIEW' },
    });
  }

  export async function notifyCourseApproved(
    instructorId: string,
    courseTitle: string,
    courseId: string,
    approved: boolean
  ) {
    await createAndSend({
      userId: instructorId,
      type: NotificationType.COURSE_APPROVED,
      title: approved ? ' Course Approved' : 'Course Rejected',
      body: approved
        ? `Your course "${courseTitle}" has been approved and published.`
        : `Your course "${courseTitle}" was not approved. Please review and resubmit.`,
      data: { courseId, type: 'COURSE_APPROVED', approved: String(approved) },
    });
  }


export async function sendSystemNotification(
    userIds: string[],
    title: string,
    body: string
  ) {
    await createAndSendBulk(userIds, {
      type: NotificationType.SYSTEM,
      title,
      body,
      data: { type: 'SYSTEM' },
    });
  }


// in app notification

export async function getUserNotification(userId:string,page:number =1,limit=20){
  const skip = (page - 1) * limit;
 
    const [notifications, total, unreadCount] = await Promise.all([
      prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
 
      prisma.notification.count({ where: { userId } }),
 
      prisma.notification.count({
        where: { userId, isRead: false },
      }),
    ]);
 
    return {
      data: notifications,
      total,
      unreadCount,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
}

export async function markAsRead(notificationId: string, userId: string) {
    const notification = await prisma.notification.findUnique({
     where: { id: notificationId },
    })

    if (!notification) throw createError('Notification not found', 404);
    if (notification.userId !== userId) throw createError('Forbidden', 403);

      await prisma.notification.update({
      where: { id: notificationId },
      data: { isRead: true },
    });
}

export  async function markAllAsRead(userId: string): Promise<void> {
    await prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }
 
export  async function deleteNotification(notificationId: string, userId: string): Promise<void> {
    const notification = await prisma.notification.findUnique({
      where: { id: notificationId },
    });
 
    if (!notification) throw createError('Notification not found', 404);
    if (notification.userId !== userId) throw createError('Forbidden', 403);
 
    await prisma.notification.delete({ where: { id: notificationId } });
  }
 
 export  async function getUnreadCount(userId: string): Promise<number> {
    return prisma.notification.count({
      where: { userId, isRead: false },
    });
  }

export  async function savePushToken(userId: string, pushToken: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { pushToken },
    });
  }
 
export  async function removePushToken(userId: string): Promise<void> {
    await prisma.user.update({
      where: { id: userId },
      data: { pushToken: null },
    });
  }


  // live class
export async function notifyLiveClassScheduled(
    userIds: string[],
    title: string,
    liveClassId: string,
    courseId: string,
    scheduledAt: Date | null
) {
    return createAndSendBulk(
        userIds,
        {
            type: "SYSTEM" ,
            title: " New Live Class Scheduled",
            body: `"${title}" has been scheduled for ${
                scheduledAt
                    ? scheduledAt.toLocaleString()
                    : "later"
            }.`,
            data: {
                type: "LIVE_CLASS_SCHEDULED",
                liveClassId,
                courseId,
            },
        }
    );
}

export async function notifyLiveClassStarted(
    userIds: string[],
    title: string,
    liveClassId: string,
    courseId: string
) {
    return createAndSendBulk(
        userIds,
        {
            type: "SYSTEM" ,
            title: " Live Class Started",
            body: `"${title}" is live now. Join now!`,
            data: {
                type: "LIVE_CLASS_STARTED",
                liveClassId,
                courseId,
            },
        }
    );
}

export async function notifyLiveClassUpdated(
    userIds: string[],
    title: string,
    liveClassId: string,
    courseId: string
) {
    return createAndSendBulk(
        userIds,
        {
            type: "SYSTEM" as any,
            title: " Live Class Updated",
            body: `"${title}" has been updated.`,
            data: {
                type: "LIVE_CLASS_UPDATED",
                liveClassId,
                courseId,
            },
        }
    );
}

export async function notifyLiveClassCancelled(
    userIds: string[],
    title: string,
    liveClassId: string,
    courseId: string
) {
    return createAndSendBulk(
        userIds,
        {
            type: "SYSTEM",
            title: "Live Class Cancelled",
            body: `"${title}" has been cancelled.`,
            data: {
                type: "LIVE_CLASS_CANCELLED",
                liveClassId,
                courseId,
            },
        }
    );
}