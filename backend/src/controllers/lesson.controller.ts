// backend/src/controllers/lesson.controller.ts
import { Request, Response, NextFunction } from 'express';
import lessonService from '../services/lesson.service';
import { schemas } from '../utils/validation';
import { validateVideoFile } from '../services/storageService';

export class LessonController {
  // Create a new lesson
  async createLesson(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const data = schemas.createLesson.parse(req.body);
      const sectionId = req.params.sectionId;

      const lesson = await lessonService.createLesson({
        ...data,
        sectionId,
      }, userId, userRole);

      res.status(201).json({
        success: true,
        message: 'Lesson created successfully',
        data: lesson,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get lessons for a section
  async getLessonsBySection(req: Request, res: Response, next: NextFunction) {
    try {
      const { sectionId } = req.params;
      const lessons = await lessonService.getLessonsBySection(sectionId);

      res.status(200).json({
        success: true,
        message: 'Lessons retrieved successfully',
        data: lessons,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get lessons for a course
  async getLessonsByCourse(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = req.params;
      const lessons = await lessonService.getLessonsByCourse(courseId);

      res.status(200).json({
        success: true,
        message: 'Lessons retrieved successfully',
        data: lessons,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get lesson by ID
  async getLessonById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.lessonId.parse(req.params);
      const lesson = await lessonService.getLessonById(id);

      if (!lesson) {
        return res.status(404).json({
          success: false,
          message: 'Lesson not found',
        });
      }

      res.status(200).json({
        success: true,
        message: 'Lesson retrieved successfully',
        data: lesson,
      });
    } catch (error) {
      next(error);
    }
  }

  // Update lesson
  async updateLesson(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.lessonId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const data = schemas.updateLesson.parse(req.body);

      const lesson = await lessonService.updateLesson(id, data, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Lesson updated successfully',
        data: lesson,
      });
    } catch (error) {
      next(error);
    }
  }

  // Delete lesson
  async deleteLesson(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.lessonId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const result = await lessonService.deleteLesson(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  // Reorder lessons
  async reorderLessons(req: Request, res: Response, next: NextFunction) {
    try {
      const { sectionId } = req.params;
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const { lessons } = schemas.reorderLessons.parse(req.body);

      const result = await lessonService.reorderLessons(sectionId, lessons, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Lessons reordered successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  // ✅ UPLOAD VIDEO
  async uploadVideo(req: Request, res: Response, next: NextFunction) {
    try {
      console.log('[uploadVideo] Request received');
      console.log('[uploadVideo] Content-Type:', req.headers['content-type']);
      console.log('[uploadVideo] Params:', req.params);
      console.log('[uploadVideo] File exists:', !!req.file);

      const { id } = schemas.lessonId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;

      // Check if file exists
      if (!req.file) {
        console.log('[uploadVideo] No file in request');
        return res.status(400).json({
          success: false,
          message: 'No video file uploaded',
        });
      }

      console.log('[uploadVideo] File details:', {
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
        bufferLength: req.file.buffer?.length || 0,
      });

      const { buffer, originalname, mimetype, size } = req.file;

      // Validate file
      const validation = validateVideoFile(mimetype, size);
      if (!validation.valid) {
        console.log('[uploadVideo] Validation failed:', validation.error);
        return res.status(400).json({
          success: false,
          message: validation.error,
        });
      }

      console.log('[uploadVideo] Starting upload to Cloudinary...');
      const result = await lessonService.uploadVideo(
        id,
        buffer,
        originalname,
        mimetype,
        userId,
        userRole
      );

      console.log('[uploadVideo] Upload successful:', result.url);

      res.status(200).json({
        success: true,
        message: 'Video uploaded successfully',
        data: result,
      });
    } catch (error) {
      console.error('[uploadVideo] Error:', error);
      next(error);
    }
  }

  // ✅ DELETE VIDEO
  async deleteVideo(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.lessonId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const result = await lessonService.deleteVideo(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  // ✅ GET VIDEO STREAM URL
  async getVideoStreamUrl(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.lessonId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const expiresIn = req.query.expiresIn ? parseInt(req.query.expiresIn as string) : 3600;

      const url = await lessonService.getVideoStreamUrl(id, userId, userRole, expiresIn);

      res.status(200).json({
        success: true,
        message: 'Video stream URL generated',
        data: { url, expiresIn },
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new LessonController();