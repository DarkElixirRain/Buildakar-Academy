import { PrismaClient, Role, CourseStatus } from "@prisma/client";

const prisma = new PrismaClient();

interface PaginationFilters {
  page?: number;
  limit?: number;
}

export class EnrollmentService {
  // Enroll the current user in a course
  async enrollInCourse(courseId: string, userId: string, userRole: Role) {
    const course = await prisma.course.findUnique({ where: { id: courseId } });

    if (!course) {
      throw new Error("Course not found");
    }

    if (course.status !== CourseStatus.PUBLISHED || !course.isPublished) {
      throw new Error("Course is not available for enrollment");
    }

    if (course.instructorId === userId) {
      throw new Error("Instructors cannot enroll in their own course");
    }

    const existing = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });

    if (existing) {
      throw new Error("Already enrolled in this course");
    }

    const [enrollment] = await prisma.$transaction([
      prisma.enrollment.create({
        data: { userId, courseId },
        include: {
          course: {
            select: { id: true, title: true, thumbnail: true, instructorId: true },
          },
        },
      }),
      prisma.course.update({
        where: { id: courseId },
        data: { studentsCount: { increment: 1 } },
      }),
      prisma.user.update({
        where: { id: course.instructorId },
        data: { totalStudents: { increment: 1 } },
      }),
    ]);

    return enrollment;
  }

  // Unenroll (hard delete — no DROPPED status in schema)
  async unenrollFromCourse(courseId: string, userId: string) {
    const enrollment = await this.getEnrollmentOrThrow(userId, courseId);

    await prisma.$transaction([
      prisma.lessonProgress.deleteMany({ where: { enrollmentId: enrollment.id } }),
      prisma.enrollment.delete({ where: { id: enrollment.id } }),
      prisma.course.update({
        where: { id: courseId },
        data: { studentsCount: { decrement: 1 } },
      }),
    ]);

    return { message: "Unenrolled successfully" };
  }

  async getEnrollmentOrThrow(userId: string, courseId: string) {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });
    if (!enrollment) {
      throw new Error("You are not enrolled in this course");
    }
    return enrollment;
  }

  async checkEnrollmentStatus(userId: string, courseId: string) {
    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });

    return {
      isEnrolled: !!enrollment,
      progress: enrollment?.progress ?? 0,
      isCompleted: enrollment?.isCompleted ?? false,
      enrolledAt: enrollment?.enrolledAt ?? null,
    };
  }

  // All courses the user is enrolled in
  async getMyEnrollments(userId: string, filters: PaginationFilters & { isCompleted?: boolean }) {
    const { page = 1, limit = 10, isCompleted } = filters;
    const where: any = { userId };
    if (isCompleted !== undefined) where.isCompleted = isCompleted;

    const [data, total] = await Promise.all([
      prisma.enrollment.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { enrolledAt: "desc" },
        include: {
          course: {
            select: {
              id: true,
              title: true,
              thumbnail: true,
              level: true,
              totalHours: true,
              instructor: {
                select: { id: true, firstName: true, lastName: true, photo: true },
              },
              _count: { select: { lessons: true } },
            },
          },
        },
      }),
      prisma.enrollment.count({ where }),
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

  // ✅ CONTINUE LEARNING — in-progress courses, most recently touched first,
  // with the exact lesson to resume from (derived from LessonProgress.watchedAt)
  async getContinueLearning(userId: string, limit = 5) {
    const enrollments = await prisma.enrollment.findMany({
      where: { userId, isCompleted: false },
      orderBy: { updatedAt: "desc" },
      take: limit,
      include: {
        course: {
          select: { id: true, title: true, thumbnail: true, totalHours: true },
        },
      },
    });

    const results = await Promise.all(
      enrollments.map(async (enrollment) => {
        // Most recently watched lesson for this enrollment
        const lastWatched = await prisma.lessonProgress.findFirst({
          where: { enrollmentId: enrollment.id },
          orderBy: { watchedAt: "desc" },
          include: {
            lesson: { select: { id: true, title: true, sectionId: true, order: true } },
          },
        });

        const resumeLesson = lastWatched
          ? lastWatched.lesson
          : await this.getFirstLesson(enrollment.courseId);

        return {
          enrollmentId: enrollment.id,
          course: enrollment.course,
          progress: enrollment.progress,
          resumeLesson, // null only if course genuinely has no lessons yet
        };
      }),
    );

    return results;
  }

  private async getFirstLesson(courseId: string) {
    const firstSection = await prisma.section.findFirst({
      where: { courseId },
      orderBy: { order: "asc" },
      include: {
        lessons: { orderBy: { order: "asc" }, take: 1 },
      },
    });
    return firstSection?.lessons[0] ?? null;
  }

  // Mark a lesson as accessed / completed and recompute enrollment progress
  async updateLessonProgress(userId: string, lessonId: string, isCompleted?: boolean) {
    const lesson = await prisma.lesson.findUnique({ where: { id: lessonId } });
    if (!lesson) {
      throw new Error("Lesson not found");
    }

    const enrollment = await this.getEnrollmentOrThrow(userId, lesson.courseId);

    await prisma.lessonProgress.upsert({
      where: { enrollmentId_lessonId: { enrollmentId: enrollment.id, lessonId } },
      update: {
        watchedAt: new Date(), // always bump "last touched" for continue-learning
        ...(isCompleted !== undefined && { isCompleted }),
      },
      create: {
        enrollmentId: enrollment.id,
        lessonId,
        isCompleted: isCompleted ?? false,
        watchedAt: new Date(),
      },
    });

    const totalLessons = await prisma.lesson.count({ where: { courseId: lesson.courseId } });
    const completedLessons = await prisma.lessonProgress.count({
      where: { enrollmentId: enrollment.id, isCompleted: true },
    });

    const progress = totalLessons > 0 ? Math.round((completedLessons / totalLessons) * 100) : 0;
    const courseCompleted = progress === 100;

    return prisma.enrollment.update({
      where: { id: enrollment.id },
      data: {
        progress,
        isCompleted: courseCompleted,
        completedAt: courseCompleted ? new Date() : null,
      },
    });
  }

  async getCourseProgress(userId: string, courseId: string) {
    const enrollment = await this.getEnrollmentOrThrow(userId, courseId);

    const lessonProgress = await prisma.lessonProgress.findMany({
      where: { enrollmentId: enrollment.id },
      select: { lessonId: true, isCompleted: true, watchedAt: true },
    });

    return {
      progress: enrollment.progress,
      isCompleted: enrollment.isCompleted,
      lessons: lessonProgress,
    };
  }
}

export default new EnrollmentService();