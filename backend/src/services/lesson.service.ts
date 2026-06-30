// backend/src/services/lesson.service.ts
import { PrismaClient } from '@prisma/client';
import { createStorageService } from './storageService';

const prisma = new PrismaClient();

export class LessonService {
  // Create a new lesson
  async createLesson(data: any, userId: string, userRole: string) {
    const { sectionId, title, description, order, isPreview, isFree } = data;

    // Get section with course
    const section = await prisma.section.findUnique({
      where: { id: sectionId },
      include: { course: true },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    // Check ownership
    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('You do not have permission to create lessons in this course');
    }

    // Get the highest order in the section
    const existingLessons = await prisma.lesson.findMany({
      where: { sectionId },
      orderBy: { order: 'desc' },
      take: 1,
    });

    const nextOrder = existingLessons.length > 0 ? existingLessons[0].order + 1 : 0;

    const lesson = await prisma.lesson.create({
      data: {
        title,
        description,
        order: order || nextOrder,
        isPreview: isPreview || false,
        isFree: isFree || false,
        courseId: section.courseId,
        sectionId,
      },
    });

    return lesson;
  }

  // Get lessons by section
  async getLessonsBySection(sectionId: string) {
    return prisma.lesson.findMany({
      where: { sectionId },
      orderBy: { order: 'asc' },
    });
  }

  // Get lessons by course
  async getLessonsByCourse(courseId: string) {
    return prisma.lesson.findMany({
      where: { courseId },
      orderBy: { order: 'asc' },
      include: {
        section: true,
      },
    });
  }

  // Get lesson by ID
  async getLessonById(id: string) {
    return prisma.lesson.findUnique({
      where: { id },
      include: {
        section: {
          include: {
            course: true,
          },
        },
      },
    });
  }

  // Update lesson
  async updateLesson(id: string, data: any, userId: string, userRole: string) {
    const lesson = await prisma.lesson.findUnique({
      where: { id },
      include: {
        section: {
          include: {
            course: true,
          },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    // ✅ Fixed null check
    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('You do not have permission to update this lesson');
    }

    return prisma.lesson.update({
      where: { id },
      data,
    });
  }

  // Delete lesson
  async deleteLesson(id: string, userId: string, userRole: string) {
    const lesson = await prisma.lesson.findUnique({
      where: { id },
      include: {
        section: {
          include: {
            course: true,
          },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    // ✅ Fixed null check
    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('You do not have permission to delete this lesson');
    }

    // Delete video from Cloudinary if exists
    if (lesson.videoPublicId) {
      try {
        const storageService = createStorageService();
        await storageService.deleteFile(lesson.videoPublicId);
      } catch (error) {
        console.error('Error deleting video from Cloudinary:', error);
      }
    }

    await prisma.lesson.delete({
      where: { id },
    });

    return { message: 'Lesson deleted successfully' };
  }

  // Reorder lessons
  async reorderLessons(sectionId: string, lessons: { id: string; order: number }[], userId: string, userRole: string) {
    const section = await prisma.section.findUnique({
      where: { id: sectionId },
      include: { course: true },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('You do not have permission to reorder lessons in this section');
    }

    const updates = lessons.map(({ id, order }) =>
      prisma.lesson.update({
        where: { id },
        data: { order },
      })
    );

    await prisma.$transaction(updates);

    return { message: 'Lessons reordered successfully' };
  }

  // ✅ UPLOAD VIDEO - Fixed with proper null checks
  async uploadVideo(
    lessonId: string,
    buffer: Buffer,
    fileName: string,
    mimeType: string,
    userId: string,
    userRole: string
  ) {
    // Check if lesson exists and user has permission
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: {
            course: {
              include: {
                instructor: true,
              },
            },
          },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    // ✅ Fixed null check for section
    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    // ✅ Fixed null check for course
    if (!lesson.section.course) {
      throw new Error('Course not found for this lesson');
    }

    // Check ownership
    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('You do not have permission to upload video for this lesson');
    }

    // Delete existing video if any
    if (lesson.videoPublicId) {
      try {
        const storageService = createStorageService();
        await storageService.deleteFile(lesson.videoPublicId);
      } catch (error) {
        console.error('Error deleting existing video:', error);
        // Continue with upload even if delete fails
      }
    }

    // Upload new video to Cloudinary
    const storageService = createStorageService();
    const result = await storageService.uploadVideo({
      fileName,
      mimeType,
      buffer,
      folder: `lessons/${lessonId}/videos`,
    });

    // Update lesson with video info
    const updatedLesson = await prisma.lesson.update({
      where: { id: lessonId },
      data: {
        videoUrl: result.url,
        videoPublicId: result.fileId,
        duration: result.duration || null,
        updatedAt: new Date(),
      },
    });

    return {
      url: result.url,
      fileId: result.fileId,
      fileName: result.fileName,
      mimeType: result.mimeType,
      size: result.size,
      lesson: updatedLesson,
    };
  }

  // ✅ DELETE VIDEO - Fixed with proper null checks
  async deleteVideo(lessonId: string, userId: string, userRole: string) {
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: {
            course: {
              include: {
                instructor: true,
              },
            },
          },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    // ✅ Fixed null check for section
    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    // ✅ Fixed null check for course
    if (!lesson.section.course) {
      throw new Error('Course not found for this lesson');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('You do not have permission to delete this video');
    }

    // Delete from Cloudinary
    if (lesson.videoPublicId) {
      const storageService = createStorageService();
      await storageService.deleteFile(lesson.videoPublicId);
    }

    // Update lesson
    await prisma.lesson.update({
      where: { id: lessonId },
      data: {
        videoUrl: null,
        videoPublicId: null,
        duration: null,
        updatedAt: new Date(),
      },
    });

    return { message: 'Video deleted successfully' };
  }

  // ✅ GET VIDEO STREAM URL - Fixed with proper null checks
  async getVideoStreamUrl(
    lessonId: string,
    userId: string,
    userRole: string,
    expiresIn: number = 3600
  ) {
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: {
            course: {
              include: {
                instructor: true,
                enrollments: {
                  where: { userId },
                },
              },
            },
          },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    // ✅ Fixed null check for section
    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    // ✅ Fixed null check for course
    if (!lesson.section.course) {
      throw new Error('Course not found for this lesson');
    }

    // Check if user has access (instructor, admin, or enrolled student)
    const isInstructor = lesson.section.course.instructorId === userId;
    const isAdmin = userRole === 'ADMIN';
    const isEnrolled = lesson.section.course.enrollments.length > 0;

    if (!isAdmin && !isInstructor && !isEnrolled) {
      throw new Error('You do not have permission to access this video');
    }

    if (!lesson.videoPublicId) {
      throw new Error('No video found for this lesson');
    }

    const storageService = createStorageService();
    return await storageService.getSignedUrl(lesson.videoPublicId, expiresIn);
  }
}

export default new LessonService();