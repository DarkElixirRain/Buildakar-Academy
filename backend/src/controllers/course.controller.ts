// backend/src/controllers/course.controller.ts
import { Request, Response, NextFunction } from 'express';
import courseService from '../services/course.service';
import { schemas } from '../utils/validation';

export class CourseController {
  // Create a new course (Instructor only)
  async createCourse(req: Request, res: Response, next: NextFunction) {
    try {
      const instructorId = req.user!.id;
      const data = schemas.createCourse.parse(req.body);

      const course = await courseService.createCourse({
        ...data,
        instructorId,
      });

      res.status(201).json({
        success: true,
        message: 'Course created successfully',
        data: course,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get all courses (with filters) - Instructor sees own, Admin sees all
  async getCourses(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const userRole = req.user!.role;
      
      const filters = schemas.pagination.parse(req.query);
      
      // Instructors can only see their own courses unless admin
      const instructorId = userRole === 'ADMIN' ? undefined : userId;

      const result = await courseService.getCourses({
        ...filters,
        instructorId,
        status: req.query.status as any,
        categoryId: req.query.categoryId as string,
        search: req.query.search as string,
      });

      res.status(200).json({
        success: true,
        message: 'Courses retrieved successfully',
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get single course by ID
  async getCourseById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.courseId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const course = await courseService.getCourseById(id);

      if (!course) {
        return res.status(404).json({
          success: false,
          message: 'Course not found',
        });
      }

      // Check access: instructors can only access their own, admins can access all
      // Students can only access published courses
      if (userRole === 'STUDENT') {
        if (course.status !== 'PUBLISHED') {
          return res.status(403).json({
            success: false,
            message: 'Course not available',
          });
        }
      } else if (userRole === 'INSTRUCTOR' && course.instructorId !== userId) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized to access this course',
        });
      }

      res.status(200).json({
        success: true,
        message: 'Course retrieved successfully',
        data: course,
      });
    } catch (error) {
      next(error);
    }
  }

  // Update course (Instructor owner or Admin)
  async updateCourse(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.courseId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role as import('@prisma/client').Role;
      const data = schemas.updateCourse.parse(req.body);

      const course = await courseService.updateCourse(id, data, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Course updated successfully',
        data: course,
      });
    } catch (error) {
      next(error);
    }
  }

  // Delete course (Instructor owner or Admin)
  async deleteCourse(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.courseId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role as import('@prisma/client').Role;

      const result = await courseService.deleteCourse(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  // Update course status (Instructor: DRAFT -> UNDER_REVIEW, Admin: any valid transition)
  async updateCourseStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.courseId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role as import('@prisma/client').Role;
      const { status } = schemas.updateCourseStatus.parse(req.body);

      const course = await courseService.updateCourseStatus(id, status, userId, userRole);

      res.status(200).json({
        success: true,
        message: `Course status updated to ${status}`,
        data: course,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get instructor stats
  async getInstructorStats(req: Request, res: Response, next: NextFunction) {
    try {
      const instructorId = req.user!.id;
      const stats = await courseService.getInstructorStats(instructorId);

      res.status(200).json({
        success: true,
        message: 'Instructor stats retrieved successfully',
        data: stats,
      });
    } catch (error) {
      next(error);
    }
  }

  // Duplicate course
  async duplicateCourse(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.courseId.parse(req.params);
      const instructorId = req.user!.id;

      const course = await courseService.duplicateCourse(id, instructorId);

      res.status(201).json({
        success: true,
        message: 'Course duplicated successfully',
        data: course,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get public courses (for students browsing)
  async getPublicCourses(req: Request, res: Response, next: NextFunction) {
    try {
      const filters = schemas.pagination.parse(req.query);
      
      const result = await courseService.getCourses({
        ...filters,
        status: 'PUBLISHED',
        isPublished: true,
        categoryId: req.query.categoryId as string,
        search: req.query.search as string,
        sortBy: req.query.sortBy as any,
      });

      res.status(200).json({
        success: true,
        message: 'Courses retrieved successfully',
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new CourseController();