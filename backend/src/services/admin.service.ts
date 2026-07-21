import { PrismaClient, CourseStatus, PaymentStatus } from "@prisma/client";
import { prisma } from "../lib/prisma";

export const getStats = async () => {
    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const startOfLastMonth = new Date(now.getFullYear(), now.getMonth() - 1, 1);
    const endOfLastMonth = new Date(now.getFullYear(), now.getMonth(), 0);
 
    const [
      totalUsers,
      newUsersThisMonth,
      newUsersLastMonth,
      totalCourses,
      publishedCourses,
      pendingReviewCourses,
      totalEnrollments,
      enrollmentsThisMonth,
      revenueResult,
      revenueLastMonth,
      revenueThisMonth,
      totalInstructors,
      totalStudents,
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { createdAt: { gte: startOfMonth } } }),
      prisma.user.count({
        where: { createdAt: { gte: startOfLastMonth, lte: endOfLastMonth } },
      }),
      prisma.course.count(),
      prisma.course.count({ where: { status: CourseStatus.PUBLISHED } }),
      prisma.course.count({ where: { status: CourseStatus.UNDER_REVIEW } }),
      prisma.enrollment.count(),
      prisma.enrollment.count({ where: { enrolledAt: { gte: startOfMonth } } }),
      prisma.payment.aggregate({
        where: { status: PaymentStatus.SUCCEEDED },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: {
          status: PaymentStatus.SUCCEEDED,
          paidAt: { gte: startOfLastMonth, lte: endOfLastMonth },
        },
        _sum: { amount: true },
      }),
      prisma.payment.aggregate({
        where: {
          status: PaymentStatus.SUCCEEDED,
          paidAt: { gte: startOfMonth },
        },
        _sum: { amount: true },
      }),
      prisma.user.count({ where: { role: 'INSTRUCTOR' } }),
      prisma.user.count({ where: { role: 'STUDENT' } }),
    ]);
 
    const totalRevenue = revenueResult._sum.amount ?? 0;
    const mrr = revenueThisMonth._sum.amount ?? 0;
    const mrrLastMonth = revenueLastMonth._sum.amount ?? 0;
 
    // Growth percentages
    const userGrowth = newUsersLastMonth > 0
      ? ((newUsersThisMonth - newUsersLastMonth) / newUsersLastMonth) * 100
      : 0;
 
    const revenueGrowth = mrrLastMonth > 0
      ? ((mrr - mrrLastMonth) / mrrLastMonth) * 100
      : 0;
 
    return {
      users: {
        total: totalUsers,
        students: totalStudents,
        instructors: totalInstructors,
        newThisMonth: newUsersThisMonth,
        growthPercent: Math.round(userGrowth * 10) / 10,
      },
      courses: {
        total: totalCourses,
        published: publishedCourses,
        pendingReview: pendingReviewCourses,
      },
      enrollments: {
        total: totalEnrollments,
        thisMonth: enrollmentsThisMonth,
      },
      revenue: {
        total: totalRevenue,
        mrr,
        mrrLastMonth,
        growthPercent: Math.round(revenueGrowth * 10) / 10,
      },
    };
};

export const getChartData = async (
  period: "7d" | "30d" | "90d" = "30d"
) => {
  const days = period === '7d' ? 7 : period === '30d' ? 30 : 90;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);
 
    // Get daily revenue
    const payments = await prisma.payment.findMany({
      where: {
        status: PaymentStatus.SUCCEEDED,
        paidAt: { gte: startDate },
      },
      select: { amount: true, paidAt: true },
    });
 
    // Get daily signups
    const users = await prisma.user.findMany({
      where: { createdAt: { gte: startDate } },
      select: { createdAt: true },
    });
 
    // Get daily enrollments
    const enrollments = await prisma.enrollment.findMany({
      where: { enrolledAt: { gte: startDate } },
      select: { enrolledAt: true },
    });
 
    // Group by day
    const dayMap: Record<string, {
      date: string;
      revenue: number;
      signups: number;
      enrollments: number;
    }> = {};
 
    // Initialize all days
    for (let i = days - 1; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const key = d.toISOString().split('T')[0];
      dayMap[key] = { date: key, revenue: 0, signups: 0, enrollments: 0 };
    }
 
    // Fill revenue
    payments.forEach((p) => {
      if (!p.paidAt) return;
      const key = p.paidAt.toISOString().split('T')[0];
      if (dayMap[key]) dayMap[key].revenue += p.amount;
    });
 
    // Fill signups
    users.forEach((u) => {
      const key = u.createdAt.toISOString().split('T')[0];
      if (dayMap[key]) dayMap[key].signups += 1;
    });
 
    // Fill enrollments
    enrollments.forEach((e) => {
      const key = e.enrolledAt.toISOString().split('T')[0];
      if (dayMap[key]) dayMap[key].enrollments += 1;
    });
 
    return Object.values(dayMap);
};

export const getUsers = async (params: {
  page?: number;
  limit?: number;
  role?: string;
  search?: string;
  isActive?: boolean;
}) => {
  // implementation
};

export const updateUser = async (
  userId: string,
  data: {
    role?: string;
    isActive?: boolean;
    isVerified?: boolean;
  }
) => {
  // implementation
};

export const getCourses = async (params: {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
}) => {
  // implementation
};

export const updateCourseStatus = async (
  courseId: string,
  status: CourseStatus
) => {
  // implementation
};

export const getOrders = async (params: {
  page?: number;
  limit?: number;
  status?: string;
}) => {
  // implementation
};

export const refundOrder = async (paymentId: string) => {
  // implementation
};

export const getPayouts = async (params: {
  page?: number;
  limit?: number;
  status?: string;
}) => {
  // implementation
};