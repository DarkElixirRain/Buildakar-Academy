// backend/src/services/instructor.service.ts

import { prisma } from '../lib/prisma';
import { AppError } from '../utils/AppError';
import { Prisma } from '@prisma/client';
import { notifyFollow } from './notification.service';

export interface InstructorFilters {
  search?: string;
  expertise?: string;
  limit?: number;
  offset?: number;
  sortBy?: 'popular' | 'rating' | 'newest' | 'courses';
  categoryId?: string;
}

export const instructorService = {
  // Get top instructors for homepage
  async getTopInstructors(limit: number = 10) {
    const instructors = await prisma.user.findMany({
      where: {
        role: 'INSTRUCTOR',
        isActive: true,
        isVerifiedInstructor: true,
        courses: {
          some: {
            status: 'PUBLISHED',
            isPublished: true,
          },
        },
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        photo: true,
        expertise: true,
        averageRating: true,
        totalStudents: true,
        totalCourses: true,
        isVerifiedInstructor: true,
        followers: {
          select: {
            followerId: true,
          },
        },
      },
      orderBy: [
        { totalStudents: 'desc' },
        { averageRating: 'desc' },
      ],
      take: limit,
    });

    return instructors.map(instructor => ({
      id: instructor.id,
      name: `${instructor.firstName} ${instructor.lastName}`,
      photo: instructor.photo || 'https://via.placeholder.com/150',
      expertise: instructor.expertise || 'Expert Instructor',
      rating: instructor.averageRating || 0,
      studentsCount: instructor.totalStudents,
      coursesCount: instructor.totalCourses,
      isVerified: instructor.isVerifiedInstructor,
      isFollowing: false,
      followerCount: instructor.followers.length,
    }));
  },

  // Get all instructors with filters
  async getInstructors(filters: InstructorFilters) {
    const {
      search,
      expertise,
      limit = 10,
      offset = 0,
      sortBy = 'popular',
      categoryId,
    } = filters;

    const where: Prisma.UserWhereInput = {
      role: 'INSTRUCTOR',
      isActive: true,
      isVerifiedInstructor: true,
      ...(search && {
        OR: [
          { firstName: { contains: search, mode: 'insensitive' } },
          { lastName: { contains: search, mode: 'insensitive' } },
          { expertise: { contains: search, mode: 'insensitive' } },
        ],
      }),
      ...(expertise && {
        expertise: { contains: expertise, mode: 'insensitive' },
      }),
      ...(categoryId && {
        courses: {
          some: {
            categoryId,
            status: 'PUBLISHED',
            isPublished: true,
          },
        },
      }),
    };

    const orderBy: Prisma.UserOrderByWithRelationInput = {};
    
    switch (sortBy) {
      case 'popular':
        orderBy.totalStudents = 'desc';
        break;
      case 'rating':
        orderBy.averageRating = 'desc';
        break;
      case 'newest':
        orderBy.createdAt = 'desc';
        break;
      case 'courses':
        orderBy.totalCourses = 'desc';
        break;
      default:
        orderBy.totalStudents = 'desc';
    }

    const [instructors, totalCount] = await Promise.all([
      prisma.user.findMany({
        where,
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          title: true,
          expertise: true,
          bio: true,
          averageRating: true,
          totalStudents: true,
          totalCourses: true,
          totalReviews: true,
          isVerifiedInstructor: true,
          followers: {
            select: {
              followerId: true,
            },
          },
          courses: {
            where: {
              status: 'PUBLISHED',
              isPublished: true,
            },
            select: {
              id: true,
              title: true,
              thumbnail: true,
              price: true,
              rating: true,
              studentsCount: true,
            },
            take: 3,
            orderBy: {
              studentsCount: 'desc',
            },
          },
          reviews: {
            where: {
              rating: { gte: 4 },
            },
            select: {
              id: true,
              rating: true,
              comment: true,
              createdAt: true,
              user: {
                select: {
                  firstName: true,
                  lastName: true,
                  photo: true,
                },
              },
            },
            take: 2,
            orderBy: {
              createdAt: 'desc',
            },
          },
        },
        orderBy,
        skip: offset,
        take: limit,
      }),
      prisma.user.count({ where }),
    ]);

    return {
      data: instructors.map(instructor => ({
        id: instructor.id,
        name: `${instructor.firstName} ${instructor.lastName}`,
        photo: instructor.photo || 'https://via.placeholder.com/150',
        expertise: instructor.expertise || '',
        rating: instructor.averageRating || 0,
        studentsCount: instructor.totalStudents,
        coursesCount: instructor.totalCourses,
        title: instructor.title || '',
        bio: instructor.bio || '',
        isVerified: instructor.isVerifiedInstructor,
        followerCount: instructor.followers.length,
        isFollowing: false,
        courses: instructor.courses,
        reviews: instructor.reviews,
      })),
      pagination: {
        total: totalCount,
        limit,
        offset,
        hasMore: offset + limit < totalCount,
      },
    };
  },

  // Get single instructor by ID
  async getInstructorById(instructorId: string, currentUserId?: string) {
    const instructor = await prisma.user.findUnique({
      where: {
        id: instructorId,
        role: 'INSTRUCTOR',
        isActive: true,
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        email: true,
        photo: true,
        title: true,
        expertise: true,
        bio: true,
        averageRating: true,
        totalStudents: true,
        totalCourses: true,
        totalRevenue: true,
        totalReviews: true,
        isVerifiedInstructor: true,
        createdAt: true,
        socialLinks: true,
        followers: {
          select: {
            followerId: true,
          },
        },
        courses: {
          where: {
            status: 'PUBLISHED',
            isPublished: true,
          },
          select: {
            id: true,
            title: true,
            description: true,
            thumbnail: true,
            price: true,
            originalPrice: true,
            level: true,
            rating: true,
            studentsCount: true,
            duration: true,
            totalHours: true,
            isBestseller: true,
            isTrending: true,
            createdAt: true,
            category: {
              select: {
                id: true,
                name: true,
                slug: true,
              },
            },
          },
          orderBy: {
            studentsCount: 'desc',
          },
        },
        reviews: {
          where: {
            rating: { gte: 3 },
          },
          select: {
            id: true,
            rating: true,
            comment: true,
            createdAt: true,
            user: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                photo: true,
              },
            },
          },
          orderBy: {
            createdAt: 'desc',
          },
          take: 10,
        },
      },
    });

    if (!instructor) {
      throw new AppError('Instructor not found', 404);
    }

    // Check if current user is following this instructor
    const isFollowing = currentUserId
      ? instructor.followers.some(f => f.followerId === currentUserId)
      : false;

    // Calculate category stats
    const courseCategories = await prisma.course.groupBy({
      by: ['categoryId'],
      where: {
        instructorId: instructorId,
        status: 'PUBLISHED',
        isPublished: true,
      },
      _count: true,
    });

    const categoryIds = courseCategories.map(c => c.categoryId);
    const categories = await prisma.category.findMany({
      where: {
        id: { in: categoryIds },
      },
      select: {
        id: true,
        name: true,
        slug: true,
      },
    });

    return {
      ...instructor,
      isFollowing,
      followerCount: instructor.followers.length,
      categories: categories.map(cat => ({
        ...cat,
        courseCount: courseCategories.find(cc => cc.categoryId === cat.id)?._count || 0,
      })),
    };
  },

  // Get instructor statistics for dashboard
  async getInstructorStats(instructorId: string) {
    const [
      courseCounts,
      overall,
      topCourses,
      totalReviews,
      totalEnrollments,
    ] = await Promise.all([
      // Count courses by status
      prisma.course.groupBy({
        by: ['status'],
        where: { instructorId },
        _count: true,
      }),
      // User-level stats
      prisma.user.findUnique({
        where: { id: instructorId },
        select: {
          totalRevenue: true,
          averageRating: true,
        },
      }),
      // Top courses
      prisma.course.findMany({
        where: {
          instructorId: instructorId,
        },
        select: {
          id: true,
          title: true,
          studentsCount: true,
          price: true,
        },
        orderBy: {
          studentsCount: 'desc',
        },
        take: 5,
      }),
      // Total reviews
      prisma.review.count({
        where: { course: { instructorId } },
      }),
      // Total students (enrollments)
      prisma.enrollment.count({
        where: { course: { instructorId } },
      }),
    ]);

    const totalCourses = courseCounts.reduce((sum, g) => sum + g._count, 0);

    return {
      totalStudents: totalEnrollments,
      totalCourses,
      totalRevenue: overall?.totalRevenue || 0,
      totalEarnings: overall?.totalRevenue || 0,
      averageRating: overall?.averageRating || 0,
      totalReviews,
      courseCounts: courseCounts.reduce((acc, g) => ({ ...acc, [g.status]: g._count }), {} as Record<string, number>),
      topCourses: topCourses.map(course => ({
        id: course.id,
        title: course.title,
        studentsCount: course.studentsCount,
        revenue: course.price * course.studentsCount,
      })),
    };
  },

  // ✅ NEW: Check follow status without toggling
  async checkFollowStatus(instructorId: string, userId: string): Promise<boolean> {
    try {
      // Check if the user is following the instructor
      const follow = await prisma.instructorFollow.findUnique({
        where: {
          followerId_instructorId: {
            followerId: userId,
            instructorId: instructorId,
          },
        },
      });
      return !!follow;
    } catch (error) {
      return false;
    }
  },

  // Follow/unfollow instructor
  async toggleFollow(instructorId: string, followerId: string) {
    if (instructorId === followerId) {
      throw new AppError('Cannot follow yourself', 400);
    }

    // Check if instructor exists and is active
    const instructor = await prisma.user.findUnique({
      where: {
        id: instructorId,
        role: 'INSTRUCTOR',
        isActive: true,
      },
    });

    if (!instructor) {
      throw new AppError('Instructor not found', 404);
    }

    const existingFollow = await prisma.instructorFollow.findUnique({
      where: {
        followerId_instructorId: {
          followerId,
          instructorId,
        },
      },
    });

    if (existingFollow) {
      // Unfollow
      await prisma.instructorFollow.delete({
        where: {
          followerId_instructorId: {
            followerId,
            instructorId,
          },
        },
      });
      return { following: false, message: 'Unfollowed successfully' };
    } else {
      // Follow
      await prisma.instructorFollow.create({
        data: {
          followerId,
          instructorId,
        },
      });

const follower = await prisma.user.findUnique({
  where: {
    id: followerId,
  },
  select: {
    firstName: true,
    lastName: true,
  },
});

      //notification
      await notifyFollow(instructorId,followerId,`${follower?.firstName} ${follower?.lastName}`)

      return { following: true, message: 'Followed successfully' };
    }
  },

  // Get instructor's followers
  async getFollowers(instructorId: string, limit: number = 20, offset: number = 0) {
    const [followers, total] = await Promise.all([
      prisma.instructorFollow.findMany({
        where: {
          instructorId,
        },
        select: {
          follower: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              photo: true,
            },
          },
          createdAt: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
        skip: offset,
        take: limit,
      }),
      prisma.instructorFollow.count({
        where: { instructorId },
      }),
    ]);

    return {
      data: followers.map(f => ({
        ...f.follower,
        name: `${f.follower.firstName} ${f.follower.lastName}`,
        followedAt: f.createdAt,
      })),
      pagination: {
        total,
        limit,
        offset,
        hasMore: offset + limit < total,
      },
    };
  },

  // Update instructor profile
  async updateInstructorProfile(instructorId: string, data: {
    title?: string;
    expertise?: string;
    bio?: string;
    photo?: string;
    socialLinks?: any;
  }) {
    const instructor = await prisma.user.update({
      where: {
        id: instructorId,
        role: 'INSTRUCTOR',
      },
      data: {
        title: data.title,
        expertise: data.expertise,
        bio: data.bio,
        photo: data.photo,
        socialLinks: data.socialLinks,
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        photo: true,
        title: true,
        expertise: true,
        bio: true,
        socialLinks: true,
        isVerifiedInstructor: true,
      },
    });

    return instructor;
  },

  // Search instructors
  async searchInstructors(query: string, limit: number = 10) {
    const instructors = await prisma.user.findMany({
      where: {
        role: 'INSTRUCTOR',
        isActive: true,
        isVerifiedInstructor: true,
        OR: [
          { firstName: { contains: query, mode: 'insensitive' } },
          { lastName: { contains: query, mode: 'insensitive' } },
          { expertise: { contains: query, mode: 'insensitive' } },
          { bio: { contains: query, mode: 'insensitive' } },
        ],
      },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        photo: true,
        expertise: true,
        averageRating: true,
        totalStudents: true,
        totalCourses: true,
        isVerifiedInstructor: true,
        followers: {
          select: {
            followerId: true,
          },
        },
      },
      orderBy: {
        totalStudents: 'desc',
      },
      take: limit,
    });

    return instructors.map(instructor => ({
      id: instructor.id,
      name: `${instructor.firstName} ${instructor.lastName}`,
      photo: instructor.photo || 'https://via.placeholder.com/150',
      expertise: instructor.expertise || 'Expert Instructor',
      rating: instructor.averageRating || 0,
      studentsCount: instructor.totalStudents,
      coursesCount: instructor.totalCourses,
      isVerified: instructor.isVerifiedInstructor,
      followerCount: instructor.followers.length,
    }));
  },

  // Get instructor's course analytics
  async getCourseAnalytics(instructorId: string, courseId?: string) {
    const where: Prisma.EnrollmentWhereInput = {
      course: {
        instructorId,
        ...(courseId && { id: courseId }),
        status: 'PUBLISHED',
      },
    };

    const [
      totalEnrollments,
      completedEnrollments,
      avgProgress,
    ] = await Promise.all([
      prisma.enrollment.count({ where }),
      prisma.enrollment.count({
        where: {
          ...where,
          isCompleted: true,
        },
      }),
      prisma.enrollment.aggregate({
        where,
        _avg: {
          progress: true,
        },
      }),
    ]);

    return {
      totalEnrollments,
      completedEnrollments,
      completionRate: totalEnrollments > 0 
        ? (completedEnrollments / totalEnrollments) * 100 
        : 0,
      averageProgress: avgProgress._avg.progress || 0,
    };
  },

  // ==================== NEW: Get Instructor's Courses ====================
  async getInstructorCourses(instructorId: string, filters: {
    status?: string;
    search?: string;
    limit?: number;
    offset?: number;
    sortBy?: 'newest' | 'oldest' | 'title' | 'rating' | 'students';
  }) {
    const {
      status,
      search,
      limit = 50,
      offset = 0,
      sortBy = 'newest',
    } = filters;

    const where: Prisma.CourseWhereInput = {
      instructorId,
      ...(status && { status: status as any }),
      ...(search && {
        OR: [
          { title: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
        ],
      }),
    };

    let orderBy: Prisma.CourseOrderByWithRelationInput = {};
    switch (sortBy) {
      case 'newest':
        orderBy = { createdAt: 'desc' };
        break;
      case 'oldest':
        orderBy = { createdAt: 'asc' };
        break;
      case 'title':
        orderBy = { title: 'asc' };
        break;
      case 'rating':
        orderBy = { rating: 'desc' };
        break;
      case 'students':
        orderBy = { studentsCount: 'desc' };
        break;
      default:
        orderBy = { createdAt: 'desc' };
    }

    const [courses, totalCount] = await Promise.all([
      prisma.course.findMany({
        where,
        include: {
          category: {
            select: {
              id: true,
              name: true,
              slug: true,
              icon: true,
              color: true,
            },
          },
          instructor: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              photo: true,
            },
          },
          _count: {
            select: {
              enrollments: true,
              reviews: true,
              lessons: true,
            },
          },
        },
        orderBy,
        skip: offset,
        take: limit,
      }),
      prisma.course.count({ where }),
    ]);

    // Format the response
    const formattedCourses = courses.map(course => ({
      ...course,
      studentsCount: course._count?.enrollments || 0,
      reviewsCount: course._count?.reviews || 0,
      lessonsCount: course._count?.lessons || 0,
    }));

    return {
      data: formattedCourses,
      pagination: {
        total: totalCount,
        limit,
        offset,
        hasMore: offset + limit < totalCount,
      },
    };
  },

  // ==================== Get Enrolled Students ====================
  async getEnrolledStudents(instructorId: string, filters: {
    search?: string;
    page?: number;
    limit?: number;
    sortBy?: 'newest' | 'oldest' | 'alphabetical';
  }) {
    const { search, page = 1, limit = 20, sortBy = 'newest' } = filters;

    const where: any = {
      course: { instructorId },
      ...(search && {
        user: {
          OR: [
            { firstName: { contains: search, mode: 'insensitive' } },
            { lastName: { contains: search, mode: 'insensitive' } },
          ],
        },
      }),
    };

    let orderBy: any;
    switch (sortBy) {
      case 'oldest':
        orderBy = { enrolledAt: 'asc' };
        break;
      case 'alphabetical':
        orderBy = { user: { firstName: 'asc' } };
        break;
      default:
        orderBy = { enrolledAt: 'desc' };
    }

    const [enrollments, total] = await Promise.all([
      prisma.enrollment.findMany({
        where,
        include: {
          user: { select: { id: true, firstName: true, lastName: true, email: true, photo: true } },
          course: { select: { id: true, title: true } },
        },
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.enrollment.count({ where }),
    ]);

    return {
      data: enrollments,
      pagination: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  },

  // ==================== Get Earnings ====================
  async getEarnings(instructorId: string, timeRange: string = 'all') {
    const where: any = { status: 'SUCCEEDED' as const, course: { instructorId } };

    if (timeRange !== 'all') {
      const now = new Date();
      let startDate: Date = new Date();
      if (timeRange === 'week') startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
      else if (timeRange === 'month') startDate = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);
      else if (timeRange === 'year') startDate = new Date(now.getTime() - 365 * 24 * 60 * 60 * 1000);
      where.createdAt = { gte: startDate };
    }

    const payments = await prisma.payment.findMany({
      where,
      select: { amount: true, createdAt: true, course: { select: { title: true } } },
      orderBy: { createdAt: 'desc' },
    });

    const totalEarnings = payments.reduce((sum, p) => sum + p.amount, 0);

    const totalPayouts = await prisma.payout.aggregate({
      where: { instructorId, status: 'PAID' as const },
      _sum: { amount: true },
    });

    const payoutSum = totalPayouts._sum.amount || 0;

    // Group by month for chart
    const monthlyMap: Record<string, number> = {};
    payments.forEach((p) => {
      const key = p.createdAt.toISOString().slice(0, 7); // YYYY-MM
      monthlyMap[key] = (monthlyMap[key] || 0) + p.amount;
    });

    const monthlyEarnings = Object.entries(monthlyMap)
      .map(([month, amount]) => ({ month, amount }))
      .sort((a, b) => a.month.localeCompare(b.month));

    return {
      totalEarnings,
      totalPayouts: payoutSum,
      balance: totalEarnings - payoutSum,
      recentTransactions: payments.slice(0, 20),
      monthlyEarnings,
    };
  },
};