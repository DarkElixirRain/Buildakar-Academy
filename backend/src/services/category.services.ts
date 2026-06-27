// backend/src/services/category.service.ts
import { PrismaClient } from '@prisma/client';
import slugify from 'slugify';

// Initialize Prisma Client with any type to bypass TypeScript issues
const prisma: any = new PrismaClient();

export class CategoryService {
  // Get all categories
  async getAllCategories(options?: {
    isActive?: boolean;
    includeCourses?: boolean;
  }) {
    const where: any = {};
    
    if (options?.isActive !== undefined) {
      where.isActive = options.isActive;
    }

    return prisma.category.findMany({
      where,
      include: {
        courses: options?.includeCourses ? {
          where: { isPublished: true },
          take: 10,
        } : false,
        _count: {
          select: { courses: true },
        },
      },
      orderBy: { name: 'asc' },
    });
  }

  // Get category by ID
  async getCategoryById(id: string, includeCourses: boolean = true) {
    return prisma.category.findUnique({
      where: { id },
      include: {
        courses: includeCourses ? {
          where: { isPublished: true },
          include: {
            instructor: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
        } : false,
        _count: {
          select: { courses: true },
        },
      },
    });
  }

  // Get category by slug
  async getCategoryBySlug(slug: string, includeCourses: boolean = true) {
    return prisma.category.findUnique({
      where: { slug },
      include: {
        courses: includeCourses ? {
          where: { isPublished: true },
          include: {
            instructor: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
              },
            },
          },
          orderBy: { createdAt: 'desc' },
        } : false,
        _count: {
          select: { courses: true },
        },
      },
    });
  }

  // Create category
  async createCategory(data: {
    name: string;
    description?: string;
    icon?: string;
    color?: string;
    image?: string;
    createdById: string;
  }) {
    const slug = slugify(data.name, { lower: true, strict: true });

    return prisma.category.create({
      data: {
        name: data.name,
        slug: slug,
        description: data.description,
        icon: data.icon,
        color: data.color,
        image: data.image,
        createdById: data.createdById,
      },
      include: {
        courses: true,
      },
    });
  }

  // Update category
  async updateCategory(id: string, data: {
    name?: string;
    description?: string;
    icon?: string;
    color?: string;
    image?: string;
    isActive?: boolean;
  }) {
    const updateData: any = { ...data };
    
    if (data.name) {
      updateData.slug = slugify(data.name, { lower: true, strict: true });
    }

    return prisma.category.update({
      where: { id },
      data: updateData,
      include: {
        courses: true,
      },
    });
  }

  // Delete category (soft delete)
  async deleteCategory(id: string) {
    return prisma.category.update({
      where: { id },
      data: { isActive: false },
    });
  }

  // Hard delete category
  async hardDeleteCategory(id: string) {
    return prisma.category.delete({
      where: { id },
    });
  }

  // Get courses by category
  async getCoursesByCategory(
    categoryId: string,
    options?: {
      limit?: number;
      offset?: number;
      sortBy?: 'popular' | 'rating' | 'newest';
    }
  ) {
    const { limit = 10, offset = 0, sortBy = 'newest' } = options || {};

    let orderBy: any = { createdAt: 'desc' };
    if (sortBy === 'popular') {
      orderBy = { studentsCount: 'desc' };
    } else if (sortBy === 'rating') {
      orderBy = { rating: 'desc' };
    }

    const courses = await prisma.course.findMany({
      where: {
        categoryId: categoryId,
        isPublished: true,
      },
      include: {
        instructor: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
        _count: {
          select: { enrollments: true },
        },
      },
      orderBy,
      take: limit,
      skip: offset,
    });

    const totalCount = await prisma.course.count({
      where: {
        categoryId: categoryId,
        isPublished: true,
      },
    });

    return {
      courses,
      totalCount,
      limit,
      offset,
      hasMore: offset + limit < totalCount,
    };
  }

  // Get category statistics
  async getCategoryStats(id: string) {
    const stats = await prisma.category.findUnique({
      where: { id },
      include: {
        _count: {
          select: { courses: true },
        },
        courses: {
          where: { isPublished: true },
          select: {
            studentsCount: true,
            rating: true,
          },
        },
      },
    });

    if (!stats) return null;

    // Fix: Add explicit types for reduce parameters
    const totalStudents = stats.courses.reduce(
      (sum: number, course: any) => sum + course.studentsCount,
      0
    );
    
    const averageRating = stats.courses.length > 0
      ? stats.courses.reduce((sum: number, course: any) => sum + course.rating, 0) / stats.courses.length
      : 0;

    return {
      totalCourses: stats._count.courses,
      totalStudents,
      averageRating: Number(averageRating.toFixed(1)),
    };
  }
}

export default new CategoryService();