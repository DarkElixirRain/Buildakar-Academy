// backend/src/controllers/section.controller.ts
import { Request, Response, NextFunction } from 'express';
import sectionService from '../services/section.service';
import { schemas } from '../utils/validation';

export class SectionController {
  // Create a new section
  async createSection(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const data = schemas.createSection.parse(req.body);
      const courseId = req.params.courseId;

      const section = await sectionService.createSection({
        ...data,
        courseId,
      });

      res.status(201).json({
        success: true,
        message: 'Section created successfully',
        data: section,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get sections for a course
  async getSectionsByCourse(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = req.params;
      
      if (!courseId) {
        return res.status(400).json({
          success: false,
          message: 'Course ID is required',
        });
      }

      const sections = await sectionService.getSectionsByCourse(courseId);

      res.status(200).json({
        success: true,
        message: 'Sections retrieved successfully',
        data: sections,
      });
    } catch (error) {
      next(error);
    }
  }

  // Get section by ID
  async getSectionById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.sectionId.parse(req.params);

      const section = await sectionService.getSectionById(id);

      if (!section) {
        return res.status(404).json({
          success: false,
          message: 'Section not found',
        });
      }

      res.status(200).json({
        success: true,
        message: 'Section retrieved successfully',
        data: section,
      });
    } catch (error) {
      next(error);
    }
  }

  // Update section
  async updateSection(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.sectionId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const data = schemas.updateSection.parse(req.body);

      const section = await sectionService.updateSection(id, data, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Section updated successfully',
        data: section,
      });
    } catch (error) {
      next(error);
    }
  }

  // Delete section
  async deleteSection(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.sectionId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;

      const result = await sectionService.deleteSection(id, userId, userRole);

      res.status(200).json({
        success: true,
        message: result.message,
      });
    } catch (error) {
      next(error);
    }
  }

  // Reorder sections
  async reorderSections(req: Request, res: Response, next: NextFunction) {
    try {
      const { courseId } = req.params;
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const { sections } = schemas.reorderSections.parse(req.body);

      const result = await sectionService.reorderSections(courseId, sections, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Sections reordered successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }

  // Move single section
  async moveSection(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = schemas.sectionId.parse(req.params);
      const userId = req.user!.id;
      const userRole = req.user!.role;
      const { order } = req.body;

      if (typeof order !== 'number' || order < 1) {
        return res.status(400).json({
          success: false,
          message: 'Valid order number is required',
        });
      }

      const result = await sectionService.moveSection(id, order, userId, userRole);

      res.status(200).json({
        success: true,
        message: 'Section moved successfully',
        data: result,
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new SectionController();