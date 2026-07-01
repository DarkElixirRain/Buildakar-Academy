// backend/src/controllers/instructor.controller.ts
import { Request, Response, NextFunction } from 'express';
import { instructorService } from '../services/instructor.service';
import { schemas } from '../utils/validation';
import { AppError } from '../utils/AppError';

export const instructorController = {
  // Get top instructors for homepage
  async getTopInstructors(req: Request, res: Response, next: NextFunction) {
    try {
      const limit = parseInt(req.query.limit as string) || 10;
      const instructors = await instructorService.getTopInstructors(limit);

      // If user is authenticated, add follow status
      if (req.user?.id) {
        const userId = req.user.id;
        const instructorsWithFollow = await Promise.all(
          instructors.map(async (instructor) => {
            try {
              const result = await instructorService.toggleFollow(instructor.id, userId);
              return { ...instructor, isFollowing: result.following };
            } catch {
              return { ...instructor, isFollowing: false };
            }
          })
        );
        return res.status(200).json({
          success: true,
          message: 'Top instructors retrieved successfully',
          data: instructorsWithFollow,
        });
      }

      res.status(200).json({
        success: true,
        message: 'Top instructors retrieved successfully',
        data: instructors,
      });
    } catch (error) {
      next(error);
    }
  },

  // Get all instructors with filters
  async getInstructors(req: Request, res: Response, next: NextFunction) {
    try {
      const filters = schemas.getInstructors.parse(req.query);
      
      const result = await instructorService.getInstructors(filters);

      // If user is authenticated, add follow status
      if (req.user?.id) {
        const userId = req.user.id;
        const dataWithFollow = await Promise.all(
          result.data.map(async (instructor: any) => {
            try {
              const followResult = await instructorService.toggleFollow(instructor.id, userId);
              return { ...instructor, isFollowing: followResult.following };
            } catch {
              return { ...instructor, isFollowing: false };
            }
          })
        );
        return res.status(200).json({
          success: true,
          message: 'Instructors retrieved successfully',
          data: dataWithFollow,
          pagination: result.pagination,
        });
      }

      res.status(200).json({
        success: true,
        message: 'Instructors retrieved successfully',
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  },

  // Get instructor by ID
  async getInstructorById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const userId = req.user?.id;

      const instructor = await instructorService.getInstructorById(id, userId);

      res.status(200).json({
        success: true,
        message: 'Instructor retrieved successfully',
        data: instructor,
      });
    } catch (error) {
      next(error);
    }
  },

  // Get instructor stats (for instructor dashboard)
  async getInstructorStats(req: Request, res: Response, next: NextFunction) {
    try {
      const instructorId = req.user!.id;
      const stats = await instructorService.getInstructorStats(instructorId);

      res.status(200).json({
        success: true,
        message: 'Instructor stats retrieved successfully',
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  },

  // Follow/unfollow instructor
  async toggleFollow(req: Request, res: Response, next: NextFunction) {
    try {
      const { instructorId } = schemas.instructorId.parse(req.params);
      const userId = req.user!.id;

      const result = await instructorService.toggleFollow(instructorId, userId);

      res.status(200).json({
        success: true,
        message: result.message,
        data: {
          isFollowing: result.following,
        },
      });
    } catch (error) {
      next(error);
    }
  },

  // Get instructor's followers
  async getFollowers(req: Request, res: Response, next: NextFunction) {
    try {
      const { instructorId } = schemas.instructorId.parse(req.params);
      const limit = parseInt(req.query.limit as string) || 20;
      const offset = parseInt(req.query.offset as string) || 0;

      const result = await instructorService.getFollowers(instructorId, limit, offset);

      res.status(200).json({
        success: true,
        message: 'Followers retrieved successfully',
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  },

  // Update instructor profile
  async updateProfile(req: Request, res: Response, next: NextFunction) {
    try {
      const instructorId = req.user!.id;
      const data = schemas.updateInstructorProfile.parse(req.body);

      const instructor = await instructorService.updateInstructorProfile(
        instructorId,
        data
      );

      res.status(200).json({
        success: true,
        message: 'Profile updated successfully',
        data: instructor,
      });
    } catch (error) {
      next(error);
    }
  },

  // Search instructors
  async searchInstructors(req: Request, res: Response, next: NextFunction) {
    try {
      const { q, limit } = req.query;

      if (!q || typeof q !== 'string') {
        throw new AppError('Search query is required', 400);
      }

      const instructors = await instructorService.searchInstructors(
        q,
        limit ? parseInt(limit as string) : 10
      );

      res.status(200).json({
        success: true,
        message: 'Instructors searched successfully',
        data: instructors,
      });
    } catch (error) {
      next(error);
    }
  },

  // Get instructor's course analytics
  async getCourseAnalytics(req: Request, res: Response, next: NextFunction) {
    try {
      const instructorId = req.user!.id;
      const { courseId } = req.query;

      const analytics = await instructorService.getCourseAnalytics(
        instructorId,
        courseId as string
      );

      res.status(200).json({
        success: true,
        message: 'Course analytics retrieved successfully',
        data: analytics,
      });
    } catch (error) {
      next(error);
    }
  },
};