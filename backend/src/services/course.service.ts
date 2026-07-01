// backend/src/services/course.service.ts
import { PrismaClient, CourseStatus, Role, Level } from "@prisma/client";

const prisma = new PrismaClient();

interface CreateCourseData {
  title: string;
  description?: string;
  thumbnail?: string;
  price?: number;
  originalPrice?: number;
  level?: Level;
  language?: string;
  duration?: string;
  totalHours?: number;
  categoryId: string;
  instructorId: string;
}

interface UpdateCourseData {
  title?: string;
  description?: string;
  thumbnail?: string;
  price?: number;
  originalPrice?: number;
  level?: Level;
  language?: string;
  duration?: string;
  totalHours?: number;
  categoryId?: string;
  isBestseller?: boolean;
  isTrending?: boolean;
}

interface CourseFilters {
  instructorId?: string;
  categoryId?: string;
  status?: CourseStatus;
  isPublished?: boolean;
  search?: string;
  page?: number;
  limit?: number;
  sortBy?: "newest" | "oldest" | "title" | "updatedAt" | "rating" | "students";
}

interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasMore: boolean;
  };
}

export class CourseService {
  // Valid status transitions
  private static readonly validTransitions: Record<
    CourseStatus,
    CourseStatus[]
  > = {
    DRAFT: ["UNDER_REVIEW"],
    UNDER_REVIEW: ["PUBLISHED", "DRAFT"],
    PUBLISHED: ["DRAFT"], // Admin can unpublish
  };

  // Create a new course (instructor only)
  async createCourse(data: CreateCourseData) {
    // Verify category exists
    const category = await prisma.category.findUnique({
      where: { id: data.categoryId },
    });

    if (!category) {
      throw new Error("Category not found");
    }

    // Create course with DRAFT status
    const course = await prisma.course.create({
      data: {
        title: data.title,
        description: data.description,
        thumbnail: data.thumbnail,
        price: data.price || 0,
        originalPrice: data.originalPrice,
        level: data.level || Level.BEGINNER,
        language: data.language || "English",
        duration: data.duration,
        totalHours: data.totalHours,
        categoryId: data.categoryId,
        instructorId: data.instructorId,
        status: CourseStatus.DRAFT,
        isPublished: false,
      },
      include: {
        category: true,
        instructor: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
      },
    });

    return course;
  }

  // Get courses with filters and pagination
  async getCourses(filters: CourseFilters = {}): Promise<PaginatedResult<any>> {
    const {
      instructorId,
      categoryId,
      status,
      isPublished,
      search,
      page = 1,
      limit = 10,
      sortBy = "newest",
    } = filters;

    const where: any = {};

    if (instructorId) where.instructorId = instructorId;
    if (categoryId) where.categoryId = categoryId;
    if (status) where.status = status;
    if (isPublished !== undefined) where.isPublished = isPublished;
    if (search) {
      where.OR = [
        { title: { contains: search, mode: "insensitive" } },
        { description: { contains: search, mode: "insensitive" } },
      ];
    }

    // Build orderBy
    let orderBy: any = { createdAt: "desc" };
    switch (sortBy) {
      case "oldest":
        orderBy = { createdAt: "asc" };
        break;
      case "title":
        orderBy = { title: "asc" };
        break;
      case "updatedAt":
        orderBy = { updatedAt: "desc" };
        break;
      case "rating":
        orderBy = { rating: "desc" };
        break;
      case "students":
        orderBy = { studentsCount: "desc" };
        break;
    }

    const [courses, total] = await Promise.all([
      prisma.course.findMany({
        where,
        include: {
          category: true,
          instructor: {
            select: { id: true, firstName: true, lastName: true, email: true },
          },
          sections: {
            include: {
              lessons: true,
            },
            orderBy: { order: "asc" },
          },
          _count: {
            select: { enrollments: true, lessons: true, reviews: true },
          },
        },
        orderBy,
        skip: (page - 1) * limit,
        take: limit,
      }),
      prisma.course.count({ where }),
    ]);

    return {
      data: courses,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasMore: page * limit < total,
      },
    };
  }

  // Get course by ID
  async getCourseById(id: string) {
    const course = await prisma.course.findUnique({
      where: { id },
      include: {
        category: true,
        instructor: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
        sections: {
          include: {
            lessons: {
              orderBy: { order: "asc" },
            },
          },
          orderBy: { order: "asc" },
        },
        _count: {
          select: { enrollments: true, lessons: true, reviews: true },
        },
      },
    });

    return course;
  }

  // backend/src/services/course.service.ts

  // Add this new method to the CourseService class
  async getPublishedCourses(filters: {
    page?: number;
    limit?: number;
    categoryId?: string;
    search?: string;
    sortBy?: string;
    level?: string;
  }) {
    const { page = 1, limit = 10, categoryId, search, sortBy, level } = filters;
    const skip = (page - 1) * limit;

    // Build where clause
    const where: any = {
      status: "PUBLISHED",
      isPublished: true,
    };

    if (categoryId) {
      where.categoryId = categoryId;
    }

    if (level) {
      where.level = level;
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: "insensitive" } },
        { description: { contains: search, mode: "insensitive" } },
      ];
    }

    // Build order by
    let orderBy: any = { createdAt: "desc" };
    if (sortBy === "rating") {
      orderBy = { rating: "desc" };
    } else if (sortBy === "popularity") {
      orderBy = { studentsCount: "desc" };
    } else if (sortBy === "newest") {
      orderBy = { createdAt: "desc" };
    } else if (sortBy === "priceLow") {
      orderBy = { price: "asc" };
    } else if (sortBy === "priceHigh") {
      orderBy = { price: "desc" };
    }

    // Get courses with relations
    const [data, total] = await Promise.all([
      prisma.course.findMany({
        where,
        include: {
          instructor: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              photo: true,
            },
          },
          category: {
            select: {
              id: true,
              name: true,
              slug: true,
              icon: true,
              color: true,
            },
          },
          _count: {
            select: {
              enrollments: true,
              reviews: true,
            },
          },
        },
        orderBy,
        skip,
        take: limit,
      }),
      prisma.course.count({ where }),
    ]);

    // Format response
    const formattedData = data.map((course: any) => ({
      ...course,
      studentsCount: course._count?.enrollments || 0,
      reviewCount: course._count?.reviews || 0,
    }));

    return {
      data: formattedData,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
        hasMore: page * limit < total,
      },
    };
  }

  // Update course
  async updateCourse(
    id: string,
    data: UpdateCourseData,
    userId: string,
    userRole: Role,
  ) {
    const course = await prisma.course.findUnique({
      where: { id },
    });

    if (!course) {
      throw new Error("Course not found");
    }

    // Check ownership (instructors can only update their own courses)
    if (userRole !== Role.ADMIN && course.instructorId !== userId) {
      throw new Error("Not authorized to update this course");
    }

    // If category is being updated, verify it exists
    if (data.categoryId) {
      const category = await prisma.category.findUnique({
        where: { id: data.categoryId },
      });
      if (!category) {
        throw new Error("Category not found");
      }
    }

    const updatedCourse = await prisma.course.update({
      where: { id },
      data,
      include: {
        category: true,
        instructor: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
      },
    });

    return updatedCourse;
  }

  // Delete course
  async deleteCourse(id: string, userId: string, userRole: Role) {
    const course = await prisma.course.findUnique({
      where: { id },
    });

    if (!course) {
      throw new Error("Course not found");
    }

    // Check ownership
    if (userRole !== Role.ADMIN && course.instructorId !== userId) {
      throw new Error("Not authorized to delete this course");
    }

    // Check if course has enrollments
    const enrollmentCount = await prisma.enrollment.count({
      where: { courseId: id },
    });

    if (enrollmentCount > 0) {
      throw new Error(
        "Cannot delete course with active enrollments. Archive instead.",
      );
    }

    await prisma.course.delete({
      where: { id },
    });

    return { success: true, message: "Course deleted successfully" };
  }

  // Update course status with validation
  async updateCourseStatus(
    id: string,
    newStatus: CourseStatus,
    userId: string,
    userRole: Role,
  ) {
    const course = await prisma.course.findUnique({
      where: { id },
    });

    if (!course) {
      throw new Error("Course not found");
    }

    // Check permissions
    const canSubmitForReview =
      userRole === Role.INSTRUCTOR && course.instructorId === userId;
    const canPublish = userRole === Role.ADMIN;

    // Validate transition
    const currentStatus = course.status;
    const allowedTransitions =
      CourseService.validTransitions[currentStatus] || [];

    // Instructors can only move DRAFT -> UNDER_REVIEW
    if (userRole === Role.INSTRUCTOR) {
      if (!canSubmitForReview) {
        throw new Error("Not authorized to update this course status");
      }
      if (
        currentStatus !== CourseStatus.DRAFT ||
        newStatus !== CourseStatus.UNDER_REVIEW
      ) {
        throw new Error("Instructors can only submit draft courses for review");
      }
    }

    // Admins can do any valid transition
    if (userRole === Role.ADMIN) {
      if (!allowedTransitions.includes(newStatus)) {
        throw new Error(
          `Invalid status transition from ${currentStatus} to ${newStatus}`,
        );
      }
    }

    // Additional validation for publishing
    if (newStatus === CourseStatus.PUBLISHED) {
      await this.validateCourseForPublishing(id);
    }

    const updatedCourse = await prisma.course.update({
      where: { id },
      data: {
        status: newStatus,
        isPublished: newStatus === CourseStatus.PUBLISHED,
      },
      include: {
        category: true,
        instructor: {
          select: { id: true, firstName: true, lastName: true, email: true },
        },
      },
    });

    return updatedCourse;
  }

  // Validate course has required content for publishing
  private async validateCourseForPublishing(courseId: string) {
    const course = await prisma.course.findUnique({
      where: { id: courseId },
      include: {
        sections: {
          include: {
            lessons: true,
          },
        },
      },
    });

    if (!course) {
      throw new Error("Course not found");
    }

    // Check if course has at least one section
    if (!course.sections || course.sections.length === 0) {
      throw new Error(
        "Course must have at least one section before publishing",
      );
    }

    // Check if at least one section has lessons
    const hasLessons = course.sections.some(
      (section) => section.lessons.length > 0,
    );
    if (!hasLessons) {
      throw new Error("Course must have at least one lesson before publishing");
    }

    // Check for required fields
    if (!course.title || !course.description) {
      throw new Error("Course must have a title and description");
    }

    if (!course.thumbnail) {
      throw new Error("Course must have a thumbnail before publishing");
    }

    if (!course.categoryId) {
      throw new Error("Course must have a category");
    }
  }

  // Get instructor's courses stats
  async getInstructorStats(instructorId: string) {
    const [
      totalCourses,
      publishedCourses,
      draftCourses,
      underReviewCourses,
      totalStudents,
    ] = await Promise.all([
      prisma.course.count({ where: { instructorId } }),
      prisma.course.count({
        where: { instructorId, status: CourseStatus.PUBLISHED },
      }),
      prisma.course.count({
        where: { instructorId, status: CourseStatus.DRAFT },
      }),
      prisma.course.count({
        where: { instructorId, status: CourseStatus.UNDER_REVIEW },
      }),
      prisma.enrollment.count({
        where: {
          course: { instructorId },
        },
      }),
    ]);

    return {
      totalCourses,
      publishedCourses,
      draftCourses,
      underReviewCourses,
      totalStudents,
      totalRevenue: 0,
      totalEarnings: 0,
    };
  }

  // Duplicate course (for creating similar courses)
  async duplicateCourse(id: string, instructorId: string) {
    const course = await prisma.course.findUnique({
      where: { id },
      include: {
        sections: {
          include: {
            lessons: true,
          },
        },
      },
    });

    if (!course) {
      throw new Error("Course not found");
    }

    if (course.instructorId !== instructorId) {
      throw new Error("Not authorized to duplicate this course");
    }

    // Create new course as draft
    const newCourse = await prisma.course.create({
      data: {
        title: `${course.title} (Copy)`,
        description: course.description,
        thumbnail: course.thumbnail,
        price: course.price,
        originalPrice: course.originalPrice,
        level: course.level,
        language: course.language,
        duration: course.duration,
        totalHours: course.totalHours,
        categoryId: course.categoryId,
        instructorId,
        status: CourseStatus.DRAFT,
        isPublished: false,
        isBestseller: false,
        isTrending: false,
      },
      include: {
        category: true,
      },
    });

    // Create sections and lessons
    for (const section of course.sections) {
      const newSection = await prisma.section.create({
        data: {
          title: section.title,
          description: section.description,
          order: section.order,
          courseId: newCourse.id,
        },
      });

      // Create lessons for this section
      for (const lesson of section.lessons) {
        await prisma.lesson.create({
          data: {
            title: lesson.title,
            description: lesson.description,
            videoUrl: lesson.videoUrl,
            duration: lesson.duration,
            order: lesson.order,
            isPreview: lesson.isPreview,
            isFree: lesson.isFree,
            sectionId: newSection.id,
            courseId: newCourse.id,
          },
        });
      }
    }

    // Fetch the complete course with sections and lessons
    const completeCourse = await prisma.course.findUnique({
      where: { id: newCourse.id },
      include: {
        category: true,
        sections: {
          include: { lessons: true },
        },
      },
    });

    return completeCourse!;
  }
}

export default new CourseService();
