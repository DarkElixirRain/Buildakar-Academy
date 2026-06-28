// backend/src/services/lesson.service.ts
import { PrismaClient } from '@prisma/client';
import { createStorageService, validateVideoFile } from './storageService';
import { StorageService, UploadOptions } from './storageService';

const prisma = new PrismaClient();

interface CreateLessonData {
  title: string;
  description?: string;
  videoUrl?: string;
  duration?: string;
  isPreview?: boolean;
  isFree?: boolean;
  order?: number;
  sectionId: string;
}

interface UpdateLessonData {
  title?: string;
  description?: string;
  videoUrl?: string;
  duration?: string;
  isPreview?: boolean;
  isFree?: boolean;
  order?: number;
}

interface ReorderLessonItem {
  id: string;
  order: number;
}

interface VideoUploadResult {
  videoUrl: string;
  fileId: string;
  fileName: string;
  mimeType: string;
  size: number;
}

export class LessonService {
  private storageService: StorageService;

  constructor(storageService?: StorageService) {
    this.storageService = storageService || createStorageService();
  }

  // Create a new lesson
  async createLesson(data: CreateLessonData, userId: string, userRole: any) {
    // Verify section exists and user owns the course
    const section = await prisma.section.findUnique({
      where: { id: data.sectionId },
      include: { course: true },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('Not authorized to add lessons to this section');
    }

    // Get the next order if not provided
    let order = data.order;
    if (order === undefined) {
      const lastLesson = await prisma.lesson.findFirst({
        where: { sectionId: data.sectionId },
        orderBy: { order: 'desc' },
      });
      order = (lastLesson?.order || 0) + 1;
    }

    const lesson = await prisma.lesson.create({
      data: {
        title: data.title,
        description: data.description,
        videoUrl: data.videoUrl,
        duration: data.duration,
        isPreview: data.isPreview || false,
        isFree: data.isFree || false,
        order,
        sectionId: data.sectionId,
        courseId: section.courseId,
      },
      include: {
        section: true,
      },
    });

    return lesson;
  }

  // Get lessons for a section
  async getLessonsBySection(sectionId: string) {
    const lessons = await prisma.lesson.findMany({
      where: { sectionId },
      orderBy: { order: 'asc' },
    });

    return lessons;
  }

  // Get lessons for a course (across all sections)
  async getLessonsByCourse(courseId: string) {
    const lessons = await prisma.lesson.findMany({
      where: { courseId },
      include: {
        section: {
          select: { id: true, title: true, order: true },
        },
      },
      orderBy: [
        { section: { order: 'asc' } },
        { order: 'asc' },
      ],
    });

    return lessons;
  }

  // Get lesson by ID
  async getLessonById(id: string) {
    const lesson = await prisma.lesson.findUnique({
      where: { id },
      include: {
        section: {
          include: {
            course: {
              select: { id: true, title: true, instructorId: true, status: true },
            },
          },
        },
      },
    });

    return lesson;
  }

  // Update lesson
  async updateLesson(id: string, data: UpdateLessonData, userId: string, userRole: any) {
    const lesson = await prisma.lesson.findUnique({
      where: { id },
      include: {
        section: {
          include: { course: true },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('Not authorized to update this lesson');
    }

    const updatedLesson = await prisma.lesson.update({
      where: { id },
      data,
      include: {
        section: true,
      },
    });

    return updatedLesson;
  }

  // Delete lesson
  async deleteLesson(id: string, userId: string, userRole: any) {
    const lesson = await prisma.lesson.findUnique({
      where: { id },
      include: {
        section: {
          include: { course: true },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('Not authorized to delete this lesson');
    }

    if (!lesson.sectionId) {
      throw new Error('Lesson has no section');
    }

    // Delete lesson
    await prisma.lesson.delete({
      where: { id },
    });

    // Reorder remaining lessons in the section
    await this.reorderAfterDelete(lesson.sectionId, lesson.order);

    return { success: true, message: 'Lesson deleted successfully' };
  }

  // Reorder lessons within a section
  async reorderLessons(sectionId: string, lessons: ReorderLessonItem[], userId: string, userRole: any) {
    const section = await prisma.section.findUnique({
      where: { id: sectionId },
      include: { course: true },
    });

    if (!section) {
      throw new Error('Section not found');
    }

    if (userRole !== 'ADMIN' && section.course.instructorId !== userId) {
      throw new Error('Not authorized to reorder lessons');
    }

    // Verify all lessons belong to this section
    const lessonIds = lessons.map(l => l.id);
    const existingLessons = await prisma.lesson.findMany({
      where: { id: { in: lessonIds }, sectionId },
    });

    if (existingLessons.length !== lessonIds.length) {
      throw new Error('One or more lessons not found or do not belong to this section');
    }

    // Update all lessons in a transaction
    await prisma.$transaction(
      lessons.map(lesson =>
        prisma.lesson.update({
          where: { id: lesson.id },
          data: { order: lesson.order },
        })
      )
    );

    return this.getLessonsBySection(sectionId);
  }

  // Upload video to storage and update lesson
  async uploadVideo(
    lessonId: string,
    fileBuffer: Buffer,
    fileName: string,
    mimeType: string,
    userId: string,
    userRole: any
  ): Promise<VideoUploadResult> {
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: { course: true },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('Not authorized to upload video for this lesson');
    }

    // Validate file
    const validation = validateVideoFile(mimeType, fileBuffer.length);
    if (!validation.valid) {
      throw new Error(validation.error);
    }

    // Upload to storage
    const uploadOptions: UploadOptions = {
      fileName,
      mimeType,
      buffer: fileBuffer,
      folder: `courses/${lesson.section.courseId}/lessons`,
    };

    const result = await this.storageService.uploadVideo(uploadOptions);

    // Update lesson with video URL
    await prisma.lesson.update({
      where: { id: lessonId },
      data: { videoUrl: result.url },
    });

    return {
      videoUrl: result.url,
      fileId: result.fileId,
      fileName: result.fileName,
      mimeType: result.mimeType,
      size: result.size,
    };
  }

  // Delete video from storage and update lesson
  async deleteVideo(lessonId: string, userId: string, userRole: any) {
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: { course: true },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
      throw new Error('Not authorized to delete video for this lesson');
    }

    if (!lesson.videoUrl) {
      throw new Error('No video to delete');
    }

    // Extract file ID from URL (Google Drive specific)
    const fileId = this.extractFileIdFromUrl(lesson.videoUrl);
    if (fileId) {
      await this.storageService.deleteFile(fileId);
    }

    // Update lesson to remove video URL
    await prisma.lesson.update({
      where: { id: lessonId },
      data: { videoUrl: null },
    });

    return { success: true, message: 'Video deleted successfully' };
  }

  // Helper: Reorder lessons after deletion
  private async reorderAfterDelete(sectionId: string, deletedOrder: number) {
    const lessons = await prisma.lesson.findMany({
      where: {
        sectionId,
        order: { gt: deletedOrder },
      },
      orderBy: { order: 'asc' },
    });

    await prisma.$transaction(
      lessons.map((lesson, index) =>
        prisma.lesson.update({
          where: { id: lesson.id },
          data: { order: deletedOrder + index },
        })
      )
    );
  }

  // Helper: Extract Google Drive file ID from URL
  private extractFileIdFromUrl(url: string): string | null {
    // Google Drive URL patterns:
    // https://drive.google.com/file/d/FILE_ID/view
    // https://drive.google.com/uc?id=FILE_ID
    // https://drive.google.com/open?id=FILE_ID
    
    const patterns = [
      /\/file\/d\/([a-zA-Z0-9_-]+)/,
      /[?&]id=([a-zA-Z0-9_-]+)/,
      /\/open\?id=([a-zA-Z0-9_-]+)/,
    ];

    for (const pattern of patterns) {
      const match = url.match(pattern);
      if (match && match[1]) {
        return match[1];
      }
    }

    return null;
  }

  // Get signed URL for video streaming
  async getVideoStreamUrl(lessonId: string, userId: string, userRole: any, expiresIn?: number): Promise<string> {
    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: { course: true },
        },
      },
    });

    if (!lesson) {
      throw new Error('Lesson not found');
    }

    if (!lesson.section) {
      throw new Error('Lesson section not found');
    }

    // For published courses, allow any enrolled user
    // For draft/under_review, only instructor/admin
    if (lesson.section.course.status !== 'PUBLISHED') {
      if (userRole !== 'ADMIN' && lesson.section.course.instructorId !== userId) {
        throw new Error('Not authorized to access this video');
      }
    }

    if (!lesson.videoUrl) {
      throw new Error('No video available for this lesson');
    }

    // Extract file ID and get signed URL
    const fileId = this.extractFileIdFromUrl(lesson.videoUrl);
    if (!fileId) {
      return lesson.videoUrl; // Return direct URL if can't extract ID
    }

    return this.storageService.getSignedUrl(fileId, expiresIn);
  }
}

export default new LessonService();