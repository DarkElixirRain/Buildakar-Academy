// backend/src/services/instructor.service.ts
import { prisma } from '../lib/prisma';
import { AppError } from '../utils/errorHandler';
import { Prisma } from '@prisma/client';

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
    let isFollowing = false;
    if (currentUserId) {
      const follow = await prisma.instructorFollow.findUnique({
        where: {
          followerId_instructorId: {
            followerId: currentUserId,
            instructorId: instructorId,
          },
        },
      });
      isFollowing = !!follow;
    }

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
    const [overall, topCourses] = await Promise.all([
      // Overall stats
      prisma.user.findUnique({
        where: { id: instructorId },
        select: {
          totalStudents: true,
          totalCourses: true,
          totalRevenue: true,
          averageRating: true,
          totalReviews: true,
        },
      }),
      
      // Top courses
      prisma.course.findMany({
        where: {
          instructorId: instructorId,
          status: 'PUBLISHED',
          isPublished: true,
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
    ]);

    return {
      totalStudents: overall?.totalStudents || 0,
      totalCourses: overall?.totalCourses || 0,
      totalRevenue: overall?.totalRevenue || 0,
      averageRating: overall?.averageRating || 0,
      totalReviews: overall?.totalReviews || 0,
      topCourses: topCourses.map(course => ({
        id: course.id,
        title: course.title,
        studentsCount: course.studentsCount,
        revenue: course.price * course.studentsCount,
      })),
    };
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
};