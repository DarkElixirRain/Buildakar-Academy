import { CourseStatus, PaymentStatus, NotificationType, PayoutStatus } from "@prisma/client";
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

    const [revenueByDay, signupsByDay, enrollmentsByDay] = await Promise.all([
      prisma.$queryRaw<Array<{ date: string; revenue: number }>>`
        SELECT DATE(paid_at) as date, COALESCE(SUM(amount), 0) as revenue
        FROM payments
        WHERE status = 'SUCCEEDED' AND paid_at >= ${startDate}
        GROUP BY DATE(paid_at)
        ORDER BY date ASC
      `,
      prisma.$queryRaw<Array<{ date: string; count: bigint }>>`
        SELECT DATE(created_at) as date, COUNT(*) as count
        FROM users
        WHERE created_at >= ${startDate}
        GROUP BY DATE(created_at)
        ORDER BY date ASC
      `,
      prisma.$queryRaw<Array<{ date: string; count: bigint }>>`
        SELECT DATE(enrolled_at) as date, COUNT(*) as count
        FROM enrollments
        WHERE enrolled_at >= ${startDate}
        GROUP BY DATE(enrolled_at)
        ORDER BY date ASC
      `,
    ]);

    const dayMap: Record<string, {
      date: string;
      revenue: number;
      signups: number;
      enrollments: number;
    }> = {};

    for (let i = days - 1; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const key = d.toISOString().split('T')[0];
      dayMap[key] = { date: key, revenue: 0, signups: 0, enrollments: 0 };
    }

    for (const row of revenueByDay) {
      if (dayMap[row.date]) dayMap[row.date].revenue = Number(row.revenue);
    }
    for (const row of signupsByDay) {
      if (dayMap[row.date]) dayMap[row.date].signups = Number(row.count);
    }
    for (const row of enrollmentsByDay) {
      if (dayMap[row.date]) dayMap[row.date].enrollments = Number(row.count);
    }

    return Object.values(dayMap);
};

export const getUsers = async (params: {
  page?: number;
  limit?: number;
  role?: string;
  search?: string;
  isActive?: boolean;
}) => {
 const { page = 1, limit = 20, role, search, isActive } = params;
    const where: any = {};

    if (role) where.role = role;
    if (isActive !== undefined) where.isActive = isActive;
    if (search) {
      where.OR = [
        { email: { contains: search, mode: 'insensitive' } },
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          email: true,
          firstName: true,
          lastName: true,
          role: true,
          isActive: true,
          isVerified: true,
          photo: true,
          createdAt: true,
          _count: {
            select: { enrolledCourses: true, courses: true, reviews: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.user.count({ where }),
    ]);

    return {
      data,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
};

export const updateUser = async (
  userId: string,
  data: { role?: string; isActive?: boolean; isVerified?: boolean }
) => {
    if (!userId) {
        throw new Error("Unauthorized");
    }

    const cleanData: Record<string, unknown> = {};
    if (data.role !== undefined) cleanData.role = data.role;
    if (data.isActive !== undefined) cleanData.isActive = data.isActive;
    if (data.isVerified !== undefined) cleanData.isVerified = data.isVerified;

    return prisma.user.update({
      where: { id: userId },
      data: cleanData,
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        role: true,
        isActive: true,
        isVerified: true,
      },
    });
};

export const getCourses = async (params: {
  page?: number;
  limit?: number;
  status?: string;
  search?: string;
  categoryId?: string;
}) => {
  const { page = 1, limit = 20, status, search, categoryId } = params;
  const where: any = {};

  if (status && Object.values(CourseStatus).includes(status as CourseStatus)) {
    where.status = status;
  }
  if (categoryId) where.categoryId = categoryId;
  if (search) {
    where.OR = [
      { title: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.course.findMany({
      where,
      select: {
        id: true,
        title: true,
        price: true,
        status: true,
        isPublished: true,
        isBestseller: true,
        isTrending: true,
        studentsCount: true,
        rating: true,
        level: true,
        thumbnail: true,
        createdAt: true,
        category: { select: { id: true, name: true } },
        instructor: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
        _count: { select: { enrollments: true, lessons: true, reviews: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.course.count({ where }),
  ]);

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
};

export const updateCourseStatus = async (
  courseId: string,
  data: { status: CourseStatus; isBestseller?: boolean; isTrending?: boolean }
) => {
  const updateData: Record<string, unknown> = { status: data.status };
  if (data.isBestseller !== undefined) updateData.isBestseller = data.isBestseller;
  if (data.isTrending !== undefined) updateData.isTrending = data.isTrending;
  if (data.status === CourseStatus.PUBLISHED) {
    updateData.isPublished = true;
  }

  return prisma.course.update({
    where: { id: courseId },
    data: updateData,
    select: {
      id: true,
      title: true,
      status: true,
      isPublished: true,
      isBestseller: true,
      isTrending: true,
    },
  });
};

export const getReviews = async (params: {
  page?: number;
  limit?: number;
  rating?: number;
  search?: string;
  courseId?: string;
}) => {
  const { page = 1, limit = 20, rating, search, courseId } = params;
  const where: any = {};

  if (rating) where.rating = rating;
  if (courseId) where.courseId = courseId;
  if (search) {
    where.OR = [
      { comment: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.review.findMany({
      where,
      select: {
        id: true,
        rating: true,
        comment: true,
        createdAt: true,
        user: { select: { id: true, firstName: true, lastName: true, email: true, photo: true } },
        course: { select: { id: true, title: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.review.count({ where }),
  ]);

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
};

export const deleteReview = async (reviewId: string) => {
  return prisma.review.delete({
    where: { id: reviewId },
  });
};

export const getInstructors = async (params: {
  page?: number;
  limit?: number;
  search?: string;
  isVerified?: boolean;
  isActive?: boolean;
}) => {
  const { page = 1, limit = 20, search, isVerified, isActive } = params;
  const where: any = { role: 'INSTRUCTOR' };

  if (isVerified !== undefined) where.isVerifiedInstructor = isVerified;
  if (isActive !== undefined) where.isActive = isActive;
  if (search) {
    where.OR = [
      { email: { contains: search, mode: 'insensitive' } },
      { firstName: { contains: search, mode: 'insensitive' } },
      { lastName: { contains: search, mode: 'insensitive' } },
    ];
  }

  const [data, total] = await Promise.all([
    prisma.user.findMany({
      where,
      select: {
        id: true,
        email: true,
        firstName: true,
        lastName: true,
        photo: true,
        bio: true,
        expertise: true,
        title: true,
        isVerifiedInstructor: true,
        isActive: true,
        totalCourses: true,
        totalStudents: true,
        totalRevenue: true,
        averageRating: true,
        createdAt: true,
        _count: { select: { courses: true, reviews: true, followers: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.user.count({ where }),
  ]);

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
};

export const verifyInstructor = async (
  instructorId: string,
  data: { isVerifiedInstructor: boolean }
) => {
  return prisma.user.update({
    where: { id: instructorId },
    data: { isVerifiedInstructor: data.isVerifiedInstructor },
    select: {
      id: true,
      firstName: true,
      lastName: true,
      email: true,
      isVerifiedInstructor: true,
    },
  });
};

export const getPayments = async (params: {
  page?: number;
  limit?: number;
  status?: string;
  startDate?: string;
  endDate?: string;
}) => {
  const { page = 1, limit = 20, status, startDate, endDate } = params;
  const where: any = {};

  if (status) where.status = status;
  if (startDate || endDate) {
    where.paidAt = {};
    if (startDate) where.paidAt.gte = new Date(startDate);
    if (endDate) where.paidAt.lte = new Date(endDate);
  }

  const [data, total] = await Promise.all([
    prisma.payment.findMany({
      where,
      select: {
        id: true,
        amount: true,
        currency: true,
        status: true,
        provider: true,
        providerReference: true,
        paidAt: true,
        createdAt: true,
        user: { select: { id: true, firstName: true, lastName: true, email: true } },
        course: { select: { id: true, title: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.payment.count({ where }),
  ]);

  const totalRevenue = await prisma.payment.aggregate({
    where: { ...where, status: PaymentStatus.SUCCEEDED },
    _sum: { amount: true },
  });

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
    totalRevenue: totalRevenue._sum.amount ?? 0,
  };
};

export const getRecentActivities = async (limit: number = 20) => {
  const [recentUsers, recentPayments, recentEnrollments, recentReviews] = await Promise.all([
    prisma.user.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        role: true,
        createdAt: true,
      },
    }),
    prisma.payment.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      where: { status: PaymentStatus.SUCCEEDED },
      select: {
        id: true,
        amount: true,
        paidAt: true,
        createdAt: true,
        user: { select: { id: true, firstName: true, lastName: true } },
        course: { select: { id: true, title: true } },
      },
    }),
    prisma.enrollment.findMany({
      take: limit,
      orderBy: { enrolledAt: 'desc' },
      select: {
        id: true,
        enrolledAt: true,
        user: { select: { id: true, firstName: true, lastName: true } },
        course: { select: { id: true, title: true } },
      },
    }),
    prisma.review.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        rating: true,
        createdAt: true,
        user: { select: { id: true, firstName: true, lastName: true } },
        course: { select: { id: true, title: true } },
      },
    }),
  ]);

  const activities: Array<{
    id: string;
    type: string;
    description: string;
    createdAt: Date;
  }> = [];

  recentUsers.forEach((u) => {
    activities.push({
      id: `user-${u.id}`,
      type: 'user_registered',
      description: `${u.firstName} ${u.lastName} registered as ${u.role.toLowerCase()}`,
      createdAt: u.createdAt,
    });
  });

  recentPayments.forEach((p) => {
    activities.push({
      id: `payment-${p.id}`,
      type: 'payment_received',
      description: `$${p.amount} payment from ${p.user.firstName} ${p.user.lastName} for ${p.course.title}`,
      createdAt: p.paidAt || p.createdAt,
    });
  });

  recentEnrollments.forEach((e) => {
    activities.push({
      id: `enrollment-${e.id}`,
      type: 'enrollment',
      description: `${e.user.firstName} ${e.user.lastName} enrolled in ${e.course.title}`,
      createdAt: e.enrolledAt,
    });
  });

  recentReviews.forEach((r) => {
    activities.push({
      id: `review-${r.id}`,
      type: 'review_submitted',
      description: `${r.user.firstName} ${r.user.lastName} reviewed ${r.course.title} with ${r.rating} stars`,
      createdAt: r.createdAt,
    });
  });

  activities.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());

  return activities.slice(0, limit);
};

export const getDashboardOverview = async () => {
  const now = new Date();
  const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

  const [
    stats,
    pendingCourses,
    pendingInstructors,
    recentActivities,
    recentPayments,
  ] = await Promise.all([
    getStats(),
    prisma.course.count({ where: { status: CourseStatus.UNDER_REVIEW } }),
    prisma.user.count({ where: { role: 'INSTRUCTOR', isVerifiedInstructor: false, isActive: true } }),
    getRecentActivities(10),
    prisma.payment.findMany({
      where: {
        status: PaymentStatus.SUCCEEDED,
        paidAt: { gte: startOfMonth },
      },
      orderBy: { paidAt: 'desc' },
      take: 5,
      select: {
        amount: true,
        paidAt: true,
        user: { select: { firstName: true, lastName: true } },
        course: { select: { title: true } },
      },
    }),
  ]);

  return {
    ...stats,
    pendingReviews: pendingCourses,
    pendingInstructors,
    recentActivities,
    recentPayments,
  };
};

export const getNotifications = async (params: {
  page?: number;
  limit?: number;
  type?: string;
  isRead?: boolean;
}) => {
  const { page = 1, limit = 20, type, isRead } = params;
  const where: any = {};

  if (type) where.type = type;
  if (isRead !== undefined) where.isRead = isRead;

  const [data, total] = await Promise.all([
    prisma.notification.findMany({
      where,
      select: {
        id: true,
        type: true,
        title: true,
        body: true,
        data: true,
        isRead: true,
        createdAt: true,
        user: { select: { id: true, firstName: true, lastName: true, email: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.notification.count({ where }),
  ]);

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
};

export const sendBroadcastNotification = async (data: {
  type: NotificationType;
  title: string;
  body: string;
  role?: string;
  userIds?: string[];
}) => {
  let sentCount = 0;
  const BATCH_SIZE = 1000;

  if (data.userIds && data.userIds.length > 0) {
    const ids = data.userIds;
    for (let i = 0; i < ids.length; i += BATCH_SIZE) {
      const batch = ids.slice(i, i + BATCH_SIZE).map(userId => ({
        userId,
        type: data.type,
        title: data.title,
        body: data.body,
      }));
      await prisma.notification.createMany({ data: batch });
      sentCount += batch.length;
    }
  } else {
    const where = data.role ? { role: data.role as any, isActive: true } : { isActive: true };
    let skip = 0;
    let hasMore = true;

    while (hasMore) {
      const users = await prisma.user.findMany({
        where,
        select: { id: true },
        take: BATCH_SIZE,
        skip,
      });

      if (users.length === 0) break;

      const batch = users.map(u => ({
        userId: u.id,
        type: data.type,
        title: data.title,
        body: data.body,
      }));
      await prisma.notification.createMany({ data: batch });
      sentCount += batch.length;
      skip += BATCH_SIZE;
      hasMore = users.length === BATCH_SIZE;
    }
  }

  return { sentCount };
};

export const getPayouts = async (params: {
  page?: number;
  limit?: number;
  status?: string;
  instructorId?: string;
}) => {
  const { page = 1, limit = 20, status, instructorId } = params;
  const where: any = {};

  if (status) where.status = status;
  if (instructorId) where.instructorId = instructorId;

  const [data, total] = await Promise.all([
    prisma.payout.findMany({
      where,
      select: {
        id: true,
        amount: true,
        currency: true,
        status: true,
        providerReference: true,
        failureReason: true,
        processedAt: true,
        createdAt: true,
        instructor: {
          select: {
            id: true, firstName: true, lastName: true, email: true,
            payoutAccount: { select: { provider: true, details: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.payout.count({ where }),
  ]);

  const totalPending = await prisma.payout.aggregate({
    where: { status: PayoutStatus.PENDING },
    _sum: { amount: true },
  });

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
    totalPendingAmount: totalPending._sum.amount ?? 0,
  };
};

export const updatePayoutStatus = async (
  payoutId: string,
  data: { status: PayoutStatus; providerReference?: string; failureReason?: string }
) => {
  const updateData: Record<string, unknown> = { status: data.status };
  if (data.providerReference) updateData.providerReference = data.providerReference;
  if (data.failureReason) updateData.failureReason = data.failureReason;
  if (data.status === PayoutStatus.PAID || data.status === PayoutStatus.PROCESSING) {
    updateData.processedAt = new Date();
  }

  return prisma.payout.update({
    where: { id: payoutId },
    data: updateData,
    select: {
      id: true,
      amount: true,
      currency: true,
      status: true,
      providerReference: true,
      failureReason: true,
      processedAt: true,
    },
  });
};

export const getAllLiveClasses = async (params: {
  page?: number;
  limit?: number;
  status?: string;
  instructorId?: string;
  courseId?: string;
}) => {
  const { page = 1, limit = 20 } = params;
  const where: Record<string, unknown> = {};

  if (params.status) where.status = params.status;
  if (params.instructorId) where.instructorId = params.instructorId;
  if (params.courseId) where.courseId = params.courseId;

  const [data, total] = await Promise.all([
    prisma.liveClass.findMany({
      where,
      select: {
        id: true,
        title: true,
        description: true,
        roomName: true,
        scheduledAt: true,
        startedAt: true,
        endedAt: true,
        status: true,
        maxParticipants: true,
        createdAt: true,
        course: { select: { id: true, title: true } },
        instructor: { select: { id: true, firstName: true, lastName: true, email: true } },
        _count: { select: { participants: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
    }),
    prisma.liveClass.count({ where }),
  ]);

  return {
    data,
    total,
    page,
    limit,
    totalPages: Math.ceil(total / limit),
  };
};

export const getInstructorDetail = async (instructorId: string) => {
  const instructor = await prisma.user.findUnique({
    where: { id: instructorId, role: 'INSTRUCTOR' },
    select: {
      id: true,
      email: true,
      firstName: true,
      lastName: true,
      photo: true,
      bio: true,
      expertise: true,
      title: true,
      isVerifiedInstructor: true,
      isActive: true,
      totalCourses: true,
      totalStudents: true,
      totalRevenue: true,
      averageRating: true,
      createdAt: true,
      _count: { select: { courses: true, reviews: true, followers: true } },
    },
  });

  if (!instructor) return null;

  const courses = await prisma.course.findMany({
    where: { instructorId },
    select: {
      id: true,
      title: true,
      price: true,
      status: true,
      isPublished: true,
      isBestseller: true,
      isTrending: true,
      studentsCount: true,
      rating: true,
      level: true,
      thumbnail: true,
      createdAt: true,
      category: { select: { id: true, name: true } },
      _count: { select: { enrollments: true, lessons: true, reviews: true } },
    },
    orderBy: { createdAt: 'desc' },
  });

  return { ...instructor, courses };
};

export const getCourseAnalytics = async (courseId: string) => {
  const course = await prisma.course.findUnique({
    where: { id: courseId },
    select: {
      id: true,
      title: true,
      price: true,
      status: true,
      isPublished: true,
      rating: true,
      studentsCount: true,
      totalHours: true,
      level: true,
      language: true,
      createdAt: true,
      instructor: { select: { id: true, firstName: true, lastName: true } },
      category: { select: { id: true, name: true } },
      _count: { select: { enrollments: true, lessons: true, reviews: true, sections: true } },
    },
  });

  if (!course) return null;

  const [enrollmentsOverTime, revenueData, ratingDistribution, completedEnrollments] = await Promise.all([
    prisma.enrollment.findMany({
      where: { courseId },
      select: { enrolledAt: true },
      orderBy: { enrolledAt: 'asc' },
    }),
    prisma.payment.aggregate({
      where: { courseId, status: PaymentStatus.SUCCEEDED },
      _sum: { amount: true },
      _count: true,
    }),
    prisma.review.groupBy({
      by: ['rating'],
      where: { courseId },
      _count: true,
    }),
    course._count.enrollments > 0
      ? prisma.enrollment.count({ where: { courseId, isCompleted: true } })
      : Promise.resolve(0),
  ]);

  const monthlyEnrollments: Record<string, number> = {};
  enrollmentsOverTime.forEach((e) => {
    const key = e.enrolledAt.toISOString().slice(0, 7);
    monthlyEnrollments[key] = (monthlyEnrollments[key] || 0) + 1;
  });

  const ratings = Array.from({ length: 5 }, (_, i) => {
    const found = ratingDistribution.find((r) => r.rating === i + 1);
    return { rating: i + 1, count: found?._count ?? 0 };
  });

  return {
    ...course,
    totalRevenue: revenueData._sum.amount ?? 0,
    totalSales: revenueData._count,
    monthlyEnrollments: Object.entries(monthlyEnrollments).map(([month, count]) => ({ month, count })),
    ratingDistribution: ratings,
    completionRate: course._count.enrollments > 0
      ? (completedEnrollments as number) / course._count.enrollments * 100
      : 0,
  };
};

export const cleanupOldNotifications = async (days: number = 30) => {
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - days);

  const result = await prisma.notification.deleteMany({
    where: {
      isRead: true,
      createdAt: { lt: cutoff },
    },
  });

  return { deletedCount: result.count };
};
