// backend/src/middleware/ownership.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Check if user owns the course (for course-level operations)
export const checkCourseOwnership = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;
    const courseId = req.params.id || req.params.courseId;

    if (!courseId) {
      return res.status(400).json({
        success: false,
        message: 'Course ID is required',
      });
    }

    const course = await prisma.course.findUnique({
      where: { id: courseId },
      select: { instructorId: true, status: true },
    });

    if (!course) {
      return res.status(404).json({
        success: false,
        message: 'Course not found',
      });
    }

    // Admin can access all courses
    if (userRole === 'ADMIN') {
      return next();
    }

    // Instructor must own the course
    if (course.instructorId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this course',
      });
    }

    next();
  } catch (error) {
    console.error('Ownership check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error checking course ownership',
    });
  }
};

// Check if user owns the course for section operations
export const checkCourseOwnershipForSection = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;
    const courseId = req.params.courseId;

    if (!courseId) {
      return res.status(400).json({
        success: false,
        message: 'Course ID is required',
      });
    }

    const course = await prisma.course.findUnique({
      where: { id: courseId },
      select: { instructorId: true, status: true },
    });

    if (!course) {
      return res.status(404).json({
        success: false,
        message: 'Course not found',
      });
    }

    if (userRole === 'ADMIN') {
      return next();
    }

    if (course.instructorId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this course',
      });
    }

    next();
  } catch (error) {
    console.error('Ownership check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error checking course ownership',
    });
  }
};

// Check if user owns the section
export const checkSectionOwnership = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;
    const sectionId = req.params.id;

    if (!sectionId) {
      return res.status(400).json({
        success: false,
        message: 'Section ID is required',
      });
    }

    const section = await prisma.section.findUnique({
      where: { id: sectionId },
      include: { course: { select: { instructorId: true } } },
    });

    if (!section) {
      return res.status(404).json({
        success: false,
        message: 'Section not found',
      });
    }

    if (userRole === 'ADMIN') {
      return next();
    }

    if (section.course.instructorId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this section',
      });
    }

    next();
  } catch (error) {
    console.error('Section ownership check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error checking section ownership',
    });
  }
};

// Check if user owns the course that a lesson belongs to
export const checkCourseOwnershipForLesson = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;
    const sectionId = req.params.sectionId;

    if (!sectionId) {
      return res.status(400).json({
        success: false,
        message: 'Section ID is required',
      });
    }

    const section = await prisma.section.findUnique({
      where: { id: sectionId },
      include: { course: { select: { instructorId: true } } },
    });

    if (!section) {
      return res.status(404).json({
        success: false,
        message: 'Section not found',
      });
    }

    if (userRole === 'ADMIN') {
      return next();
    }

    if (section.course.instructorId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access lessons in this section',
      });
    }

    next();
  } catch (error) {
    console.error('Course ownership for lesson check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error checking course ownership',
    });
  }
};

// Check if user owns the lesson
export const checkLessonOwnership = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id;
    const userRole = req.user!.role;
    const lessonId = req.params.id;

    if (!lessonId) {
      return res.status(400).json({
        success: false,
        message: 'Lesson ID is required',
      });
    }

    const lesson = await prisma.lesson.findUnique({
      where: { id: lessonId },
      include: {
        section: {
          include: { course: { select: { instructorId: true } } },
        },
      },
    });

    if (!lesson) {
      return res.status(404).json({
        success: false,
        message: 'Lesson not found',
      });
    }

    if (!lesson.section || !lesson.section.course) {
      return res.status(404).json({
        success: false,
        message: 'Lesson section or course not found',
      });
    }

    if (userRole === 'ADMIN') {
      return next();
    }

    if (lesson.section.course.instructorId !== userId) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this lesson',
      });
    }

    next();
  } catch (error) {
    console.error('Lesson ownership check error:', error);
    return res.status(500).json({
      success: false,
      message: 'Error checking lesson ownership',
    });
  }
};

export default {
  checkCourseOwnership,
  checkCourseOwnershipForSection,
  checkSectionOwnership,
  checkCourseOwnershipForLesson,
  checkLessonOwnership,
};