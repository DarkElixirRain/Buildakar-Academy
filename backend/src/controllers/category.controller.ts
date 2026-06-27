// backend/src/controllers/category.controller.ts
import { Request, Response, NextFunction } from 'express';
import categoryService from '../services/category.services';

export class CategoryController {
  // Get all categories
  async getAllCategories(req: Request, res: Response, next: NextFunction) {
    try {
      const { includeCourses, isActive } = req.query;
      
      const categories = await categoryService.getAllCategories({
        isActive: isActive === 'true' ? true : isActive === 'false' ? false : undefined,
        includeCourses: includeCourses === 'true',
      });

      res.status(200).json({
        success: true,
        data: categories,
        message: 'Categories retrieved successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  // Get category by ID
  async getCategoryById(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { includeCourses } = req.query;

      const category = await categoryService.getCategoryById(
        id,
        includeCourses === 'true'
      );

      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Category not found',
        });
      }

      res.status(200).json({
        success: true,
        data: category,
        message: 'Category retrieved successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  // Get category by slug
  async getCategoryBySlug(req: Request, res: Response, next: NextFunction) {
    try {
      const { slug } = req.params;
      const { includeCourses } = req.query;

      const category = await categoryService.getCategoryBySlug(
        slug,
        includeCourses === 'true'
      );

      if (!category) {
        return res.status(404).json({
          success: false,
          message: 'Category not found',
        });
      }

      // Get courses with pagination and sorting
      const { limit = '10', offset = '0', sortBy = 'newest' } = req.query;
      
      const coursesResult = await categoryService.getCoursesByCategory(
        category.id,
        {
          limit: parseInt(limit as string, 10),
          offset: parseInt(offset as string, 10),
          sortBy: sortBy as 'popular' | 'rating' | 'newest',
        }
      );

      // Get category stats
      const stats = await categoryService.getCategoryStats(category.id);

      res.status(200).json({
        success: true,
        data: {
          ...category,
          stats,
          courses: coursesResult.courses,
          pagination: {
            total: coursesResult.totalCount,
            limit: coursesResult.limit,
            offset: coursesResult.offset,
            hasMore: coursesResult.hasMore,
          },
        },
        message: 'Category retrieved successfully',
      });
    } catch (error) {
      next(error);
    }
  }

  // Create category (Admin only)
  async createCategory(req: Request, res: Response, next: NextFunction) {
    try {
      const { name, description, icon, color, image } = req.body;
      const createdById = req.user?.id;

      if (!createdById) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
        });
      }

      if (!name) {
        return res.status(400).json({
          success: false,
          message: 'Category name is required',
        });
      }

      const category = await categoryService.createCategory({
        name,
        description,
        icon,
        color,
        image,
        createdById,
      });

      res.status(201).json({
        success: true,
        data: category,
        message: 'Category created successfully',
      });
    } catch (error: any) {
      if (error.code === 'P2002') {
        return res.status(409).json({
          success: false,
          message: 'Category with this name already exists',
        });
      }
      next(error);
    }
  }

  // Update category (Admin only)
  async updateCategory(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { name, description, icon, color, image, isActive } = req.body;

      const category = await categoryService.updateCategory(id, {
        name,
        description,
        icon,
        color,
        image,
        isActive,
      });

      res.status(200).json({
        success: true,
        data: category,
        message: 'Category updated successfully',
      });
    } catch (error: any) {
      if (error.code === 'P2025') {
        return res.status(404).json({
          success: false,
          message: 'Category not found',
        });
      }
      if (error.code === 'P2002') {
        return res.status(409).json({
          success: false,
          message: 'Category with this name already exists',
        });
      }
      next(error);
    }
  }

  // Delete category (Admin only)
  async deleteCategory(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      const { permanent } = req.query;

      let category;
      if (permanent === 'true') {
        category = await categoryService.hardDeleteCategory(id);
      } else {
        category = await categoryService.deleteCategory(id);
      }

      res.status(200).json({
        success: true,
        data: category,
        message: permanent === 'true' 
          ? 'Category permanently deleted' 
          : 'Category archived successfully',
      });
    } catch (error: any) {
      if (error.code === 'P2025') {
        return res.status(404).json({
          success: false,
          message: 'Category not found',
        });
      }
      next(error);
    }
  }

  // Get category stats
  async getCategoryStats(req: Request, res: Response, next: NextFunction) {
    try {
      const { id } = req.params;
      
      const stats = await categoryService.getCategoryStats(id);

      if (!stats) {
        return res.status(404).json({
          success: false,
          message: 'Category not found',
        });
      }

      res.status(200).json({
        success: true,
        data: stats,
        message: 'Category stats retrieved successfully',
      });
    } catch (error) {
      next(error);
    }
  }
}

export default new CategoryController();