import { Request, Response, NextFunction } from 'express';
import {
  getChartData, getStats, getUsers, updateUser,
  getCourses, updateCourseStatus,
  getReviews, deleteReview,
  getInstructors, verifyInstructor,
  getPayments,
  getRecentActivities,
  getDashboardOverview,
  getNotifications, sendBroadcastNotification,
  getPayouts, updatePayoutStatus,
  getAllLiveClasses,
  getCourseAnalytics,
  cleanupOldNotifications,
  getInstructorDetail,
} from '../services/admin.service';

export async function getstats(req: Request, res: Response, next: NextFunction) {
  try {
    const stats = await getStats();
    return res.status(200).json({ success: true, data: stats });
  } catch (error) { next(error); }
}

export async function getChartdata(req: Request, res: Response, next: NextFunction) {
  try {
    const period = (req.query.period as '7d' | '30d' | '90d') ?? '30d';
    const data = await getChartData(period);
    return res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function getusers(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getUsers({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      role: req.query.role as string,
      search: req.query.search as string,
      isActive: req.query.isActive !== undefined
        ? req.query.isActive === 'true'
        : undefined,
    });

    return res.status(200).json({ success: true, ...result });
  } catch (error) {
    next(error);
  }
}

export async function updateuser(req: Request, res: Response, next: NextFunction) {
  try {
    const user = await updateUser(req.params.id, req.body);
    return res.status(200).json({ success: true, message: 'User updated', data: user });
  } catch (error) { next(error); }
}

export async function getCoursesList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getCourses({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      status: req.query.status as string,
      search: req.query.search as string,
      categoryId: req.query.categoryId as string,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function updateCourse(req: Request, res: Response, next: NextFunction) {
  try {
    const course = await updateCourseStatus(req.params.id, req.body);
    return res.status(200).json({ success: true, message: 'Course updated', data: course });
  } catch (error) { next(error); }
}

export async function getReviewsList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getReviews({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      rating: req.query.rating ? Number(req.query.rating) : undefined,
      search: req.query.search as string,
      courseId: req.query.courseId as string,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function removeReview(req: Request, res: Response, next: NextFunction) {
  try {
    await deleteReview(req.params.id);
    return res.status(200).json({ success: true, message: 'Review deleted' });
  } catch (error) { next(error); }
}

export async function getInstructorsList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getInstructors({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      search: req.query.search as string,
      isVerified: req.query.isVerified !== undefined
        ? req.query.isVerified === 'true'
        : undefined,
      isActive: req.query.isActive !== undefined
        ? req.query.isActive === 'true'
        : undefined,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function updateInstructorVerification(req: Request, res: Response, next: NextFunction) {
  try {
    const instructor = await verifyInstructor(req.params.id, req.body);
    const msg = instructor.isVerifiedInstructor ? 'Instructor verified' : 'Instructor verification revoked';
    return res.status(200).json({ success: true, message: msg, data: instructor });
  } catch (error) { next(error); }
}

export async function getPaymentsList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getPayments({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      status: req.query.status as string,
      startDate: req.query.startDate as string,
      endDate: req.query.endDate as string,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function getRecentActivitiesList(req: Request, res: Response, next: NextFunction) {
  try {
    const limit = Number(req.query.limit) || 20;
    const activities = await getRecentActivities(limit);
    return res.status(200).json({ success: true, data: activities });
  } catch (error) { next(error); }
}

export async function getDashboard(req: Request, res: Response, next: NextFunction) {
  try {
    const overview = await getDashboardOverview();
    return res.status(200).json({ success: true, data: overview });
  } catch (error) { next(error); }
}

export async function getNotificationsList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getNotifications({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      type: req.query.type as string,
      isRead: req.query.isRead !== undefined ? req.query.isRead === 'true' : undefined,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function createBroadcastNotification(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await sendBroadcastNotification(req.body);
    return res.status(201).json({
      success: true,
      message: `Notification sent to ${result.sentCount} users`,
      data: result,
    });
  } catch (error) { next(error); }
}

export async function getPayoutsList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getPayouts({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      status: req.query.status as string,
      instructorId: req.query.instructorId as string,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function updatePayout(req: Request, res: Response, next: NextFunction) {
  try {
    const payout = await updatePayoutStatus(req.params.id, req.body);
    return res.status(200).json({ success: true, message: 'Payout updated', data: payout });
  } catch (error) { next(error); }
}

export async function getAllLiveClassesList(req: Request, res: Response, next: NextFunction) {
  try {
    const result = await getAllLiveClasses({
      page: Number(req.query.page) || 1,
      limit: Number(req.query.limit) || 20,
      status: req.query.status as string,
      instructorId: req.query.instructorId as string,
      courseId: req.query.courseId as string,
    });
    return res.status(200).json({ success: true, ...result });
  } catch (error) { next(error); }
}

export async function cleanupNotifications(req: Request, res: Response, next: NextFunction) {
  try {
    const days = Number(req.query.days) || 30;
    const result = await cleanupOldNotifications(days);
    return res.status(200).json({
      success: true,
      message: `Deleted ${result.deletedCount} read notifications older than ${days} days`,
      data: result,
    });
  } catch (error) { next(error); }
}

export async function getInstructorDetailData(req: Request, res: Response, next: NextFunction) {
  try {
    const instructor = await getInstructorDetail(req.params.id);
    if (!instructor) {
      return res.status(404).json({ success: false, message: 'Instructor not found' });
    }
    return res.status(200).json({ success: true, data: instructor });
  } catch (error) { next(error); }
}

export async function getCourseAnalyticsData(req: Request, res: Response, next: NextFunction) {
  try {
    const analytics = await getCourseAnalytics(req.params.id);
    if (!analytics) {
      return res.status(404).json({ success: false, message: 'Course not found' });
    }
    return res.status(200).json({ success: true, data: analytics });
  } catch (error) { next(error); }
}
