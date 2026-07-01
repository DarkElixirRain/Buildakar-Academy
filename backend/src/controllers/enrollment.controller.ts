// controllers/enrollment.controller.ts
import { Request, Response, NextFunction } from "express";
import enrollmentService from "../services/enrollment.service";
import { schemas } from "../utils/validation";

export class EnrollmentController {
  async enroll(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = schemas.enrollParams.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role as import("@prisma/client").Role;

      const enrollment = await enrollmentService.enrollInCourse(courseId, userId, userRole);

      res.status(201).json({
        success: true,
        message: "Enrolled successfully",
        data: enrollment,
      });
    } catch (error) {
      next(error);
    }
  }

  async unenroll(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = schemas.enrollParams.parse(req.params);
      const userId = req.user!.id;

      const result = await enrollmentService.unenrollFromCourse(courseId, userId);

      res.status(200).json({ success: true, message: result.message });
    } catch (error) {
      next(error);
    }
  }

  async getStatus(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = schemas.enrollParams.parse(req.params);
      const userId = req.user!.id;

      const status = await enrollmentService.checkEnrollmentStatus(userId, courseId);

      res.status(200).json({
        success: true,
        message: "Enrollment status retrieved",
        data: status,
      });
    } catch (error) {
      next(error);
    }
  }

  async getMyEnrollments(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const filters = schemas.pagination.parse(req.query);
      const isCompleted =
        req.query.isCompleted !== undefined ? req.query.isCompleted === "true" : undefined;

      const result = await enrollmentService.getMyEnrollments(userId, {
        ...filters,
        isCompleted,
      });

      res.status(200).json({
        success: true,
        message: "Enrollments retrieved successfully",
        data: result.data,
        pagination: result.pagination,
      });
    } catch (error) {
      next(error);
    }
  }

  async getContinueLearning(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const limit = req.query.limit ? parseInt(req.query.limit as string) : 5;

      const data = await enrollmentService.getContinueLearning(userId, limit);

      res.status(200).json({
        success: true,
        message: "Continue learning list retrieved",
        data,
      });
    } catch (error) {
      next(error);
    }
  }

  async updateLessonProgress(req: Request, res: Response, next: NextFunction) {
    try {
      const { id: lessonId } = schemas.lessonId.parse(req.params);
      const { isCompleted } = schemas.updateLessonProgress.parse(req.body);
      const userId = req.user!.id;

      const enrollment = await enrollmentService.updateLessonProgress(
        userId,
        lessonId,
        isCompleted,
      );

      res.status(200).json({
        success: true,
        message: "Progress updated",
        data: enrollment,
      });
    } catch (error) {
      next(error);
    }
  }

  async getCourseProgress(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = schemas.enrollParams.parse(req.params);
      const userId = req.user!.id;

      const progress = await enrollmentService.getCourseProgress(userId, courseId);

      res.status(200).json({
        success: true,
        message: "Course progress retrieved",
        data: progress,
      });
    } catch (error) {
      next(error);
    }
  }
}

// ✅ Export the class (not an instance)
export default EnrollmentController;