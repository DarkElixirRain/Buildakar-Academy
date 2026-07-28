
import { CourseStatus, Role, Level } from "@prisma/client";
import { prisma } from '../lib/prisma';
import { createId } from '@paralleldrive/cuid2';
import {
  createAndSend,
  createAndSendBulk,
  notifyCoursePublished,
  notifyCourseApproved,
} from "./notification.service";

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
  private static readonly validTransitions: Record<CourseStatus, CourseStatus[]> = {
    PENDING_APPROVAL: ["DRAFT"],
    DRAFT: ["UNDER_REVIEW", "PUBLISHED"],
    UNDER_REVIEW: ["PUBLISHED", "DRAFT"],
    PUBLISHED: ["DRAFT"],
  };

  async createCourse(data: CreateCourseData) {
    const category = await prisma.category.findUnique({
      where: { id: data.categoryId },
    });

    if (!category) throw new Error("Category not found");

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
        status: CourseStatus.PENDING_APPROVAL,
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

    let orderBy: any = { createdAt: "desc" };
    switch (sortBy) {
      case "oldest": orderBy = { createdAt: "asc" }; break;
      case "title": orderBy = { title: "asc" }; break;
      case "updatedAt": orderBy = { updatedAt: "desc" }; break;
      case "rating": orderBy = { rating: "desc" }; break;
      case "students": orderBy = { studentsCount: "desc" }; break;
    }

    const [courses, total] = await Promise.all([
      prisma.course.findMany({
        where,
        include: {
          category: true,
          instructor: {
            select: { id: true, firstName: true, lastName: true, email: true },
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
            lessons: { orderBy: { order: "asc" } },
          },
          orderBy: { order: "asc" },
        },
        reviews: {
          take: 20,
          orderBy: { createdAt: "desc" },
          include: {
            user: {
              select: { id: true, firstName: true, lastName: true, photo: true },
            },
          },
        },
        _count: {
          select: { enrollments: true, lessons: true, reviews: true },
        },
      },
    });

    if (!course) return null;

    return {
      ...course,
      studentsCount: (course as any)._count?.enrollments || 0,
      reviewsCount: (course as any)._count?.reviews || 0,
    };
  }

  async getPublishedCourses(filters: {
    page?: number;
    limit?: number;
    categoryId?: string;
    instructorId?: string;
    search?: string;
    sortBy?: string;
    level?: string;
  }) {
    const { page = 1, limit = 10, categoryId, instructorId, search, sortBy, level } = filters;
    const skip = (page - 1) * limit;

    const where: any = {
      status: "PUBLISHED",
      isPublished: true,
    };

    if (categoryId) where.categoryId = categoryId;
    if (instructorId) where.instructorId = instructorId;
    if (level) where.level = level;
    if (search) {
      where.OR = [
        { title: { contains: search, mode: "insensitive" } },
        { description: { contains: search, mode: "insensitive" } },
      ];
    }

    let orderBy: any = { createdAt: "desc" };
    if (sortBy === "rating") orderBy = { rating: "desc" };
    else if (sortBy === "popularity") orderBy = { studentsCount: "desc" };
    else if (sortBy === "newest") orderBy = { createdAt: "desc" };
    else if (sortBy === "priceLow") orderBy = { price: "asc" };
    else if (sortBy === "priceHigh") orderBy = { price: "desc" };

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
            select: { enrollments: true, reviews: true },
          },
        },
        orderBy,
        skip,
        take: limit,
      }),
      prisma.course.count({ where }),
    ]);

    const formattedData = data.map((course: any) => ({
      ...course,
      studentsCount: course._count?.enrollments || 0,
      reviewsCount: course._count?.reviews || 0,
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

  async updateCourse(
    id: string,
    data: UpdateCourseData,
    userId: string,
    userRole: Role
  ) {
    const course = await prisma.course.findUnique({ where: { id } });

    if (!course) throw new Error("Course not found");

    if (userRole !== Role.ADMIN && course.instructorId !== userId) {
      throw new Error("Not authorized to update this course");
    }

    if (data.categoryId) {
      const category = await prisma.category.findUnique({
        where: { id: data.categoryId },
      });
      if (!category) throw new Error("Category not found");
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

  async deleteCourse(id: string, userId: string, userRole: Role) {
    const course = await prisma.course.findUnique({ where: { id } });

    if (!course) throw new Error("Course not found");

    if (userRole !== Role.ADMIN && course.instructorId !== userId) {
      throw new Error("Not authorized to delete this course");
    }

    const enrollmentCount = await prisma.enrollment.count({
      where: { courseId: id },
    });

    if (enrollmentCount > 0) {
      throw new Error(
        "Cannot delete course with active enrollments. Archive instead."
      );
    }

    await prisma.course.delete({ where: { id } });

    return { success: true, message: "Course deleted successfully" };
  }

  async updateCourseStatus(
    id: string,
    newStatus: CourseStatus,
    userId: string,
    userRole: Role
  ) {
    const course = await prisma.course.findUnique({ where: { id } });

    if (!course) throw new Error("Course not found");

    const canSubmitForReview =
      userRole === Role.INSTRUCTOR && course.instructorId === userId;

    const currentStatus = course.status;
    const allowedTransitions =
      CourseService.validTransitions[currentStatus] || [];

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

    if (userRole === Role.ADMIN) {
      if (!allowedTransitions.includes(newStatus)) {
        throw new Error(
          `Invalid status transition from ${currentStatus} to ${newStatus}`
        );
      }
    }

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

    // ── NOTIFICATIONS ─────────────────────────────────────────────

    // PENDING_APPROVAL → DRAFT: admin approved course for content creation
    if (
      currentStatus === CourseStatus.PENDING_APPROVAL &&
      newStatus === CourseStatus.DRAFT
    ) {
      createAndSend({
        userId: course.instructorId,
        type: 'COURSE_APPROVED' as any,
        title: '✅ Course Approved',
        body: `Your course "${course.title}" has been approved. You can now add sections and lessons.`,
        data: { courseId: course.id, type: 'COURSE_APPROVED' },
      }).catch(() => {});
    }

    // UNDER_REVIEW → PUBLISHED: admin approved
    if (
      currentStatus === CourseStatus.UNDER_REVIEW &&
      newStatus === CourseStatus.PUBLISHED
    ) {
      notifyCoursePublished(course.instructorId, course.title, course.id)
        .catch(() => {});

      notifyCourseApproved(course.instructorId, course.title, course.id, true)
        .catch(() => {});

      const enrolledUsers = await prisma.enrollment.findMany({
        where: { courseId: course.id },
        select: { userId: true },
      });

      if (enrolledUsers.length > 0) {
        createAndSendBulk(
          enrolledUsers.map((e) => e.userId),
          {
            type: "SYSTEM" as any,
            title: "📚 Course is now live!",
            body: `"${course.title}" has been published and is ready to learn.`,
            data: { courseId: course.id, type: "SYSTEM" },
          }
        ).catch(() => {});
      }
    }

    // UNDER_REVIEW → DRAFT: admin rejected
    if (
      currentStatus === CourseStatus.UNDER_REVIEW &&
      newStatus === CourseStatus.DRAFT
    ) {
      notifyCourseApproved(course.instructorId, course.title, course.id, false)
        .catch(() => {});
    }

    // PUBLISHED → DRAFT: admin unpublished
    if (
      currentStatus === CourseStatus.PUBLISHED &&
      newStatus === CourseStatus.DRAFT
    ) {
      createAndSend({
        userId: course.instructorId,
        type: "SYSTEM" as any,
        title: "⚠️ Course Unpublished",
        body: `Your course "${course.title}" has been unpublished by an admin.`,
        data: { courseId: course.id, type: "SYSTEM" },
      }).catch(() => {});
    }

    // ─────────────────────────────────────────────────────────────

    return updatedCourse;
  }

  private async validateCourseForPublishing(courseId: string) {
    const course = await prisma.course.findUnique({
      where: { id: courseId },
      include: {
        sections: {
          include: { lessons: true },
        },
      },
    });

    if (!course) throw new Error("Course not found");

    if (!course.sections || course.sections.length === 0) {
      throw new Error("Course must have at least one section before publishing");
    }

    const hasLessons = course.sections.some(
      (section) => section.lessons.length > 0
    );
    if (!hasLessons) {
      throw new Error("Course must have at least one lesson before publishing");
    }

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

  async getInstructorStats(instructorId: string) {
    const [
      totalCourses,
      publishedCourses,
      draftCourses,
      underReviewCourses,
      totalStudents,
    ] = await Promise.all([
      prisma.course.count({ where: { instructorId } }),
      prisma.course.count({ where: { instructorId, status: CourseStatus.PUBLISHED } }),
      prisma.course.count({ where: { instructorId, status: CourseStatus.DRAFT } }),
      prisma.course.count({ where: { instructorId, status: CourseStatus.UNDER_REVIEW } }),
      prisma.enrollment.count({ where: { course: { instructorId } } }),
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

  async duplicateCourse(id: string, instructorId: string) {
    const course = await prisma.course.findUnique({
      where: { id },
      include: {
        sections: {
          include: { lessons: true },
        },
      },
    });

    if (!course) throw new Error("Course not found");

    if (course.instructorId !== instructorId) {
      throw new Error("Not authorized to duplicate this course");
    }

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
      include: { category: true },
    });

    const sectionIdMap = new Map<string, string>();
    const sectionsData = course.sections.map(s => {
      const newId = createId();
      sectionIdMap.set(s.id, newId);
      return {
        id: newId,
        title: s.title,
        description: s.description,
        order: s.order,
        courseId: newCourse.id,
      };
    });

    const lessonsData = course.sections.flatMap(s => {
      const newSectionId = sectionIdMap.get(s.id)!;
      return s.lessons.map(l => ({
        id: createId(),
        title: l.title,
        description: l.description,
        videoUrl: l.videoUrl,
        duration: l.duration,
        order: l.order,
        isPreview: l.isPreview,
        isFree: l.isFree,
        sectionId: newSectionId,
        courseId: newCourse.id,
      }));
    });

    await prisma.$transaction([
      prisma.section.createMany({ data: sectionsData }),
      prisma.lesson.createMany({ data: lessonsData }),
    ]);

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