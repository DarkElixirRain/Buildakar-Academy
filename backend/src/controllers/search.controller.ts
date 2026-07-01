// backend/src/controllers/search.controller.ts
import { Request, Response, NextFunction } from "express";
import { PrismaClient, Prisma } from "@prisma/client";

const prisma = new PrismaClient();

export class SearchController {
  /**
   * Unified search - searches courses, instructors, and categories
   * GET /api/search?q=query&type=all&page=1&limit=20
   */
  async unifiedSearch(req: Request, res: Response, next: NextFunction) {
    try {
      const {
        q,
        type = 'all',
        page = 1,
        limit = 20,
        category,
        level,
        price,
        sortBy = 'relevance',
      } = req.query;

      const searchQuery = (q as string)?.trim() || '';
      const pageNum = parseInt(page as string) || 1;
      const limitNum = parseInt(limit as string) || 20;
      const skip = (pageNum - 1) * limitNum;

      // If no search query, return trending
      if (!searchQuery) {
        return this.getTrending(req, res, next);
      }

      const results: any = {
        courses: [],
        instructors: [],
        categories: [],
        meta: {
          query: searchQuery,
          totalResults: 0,
          type,
        },
      };

      // ============================================
      // SEARCH COURSES
      // ============================================
      if (type === 'all' || type === 'courses') {
        const courseWhere: any = {
          status: 'PUBLISHED',
          isPublished: true,
          OR: [
            { title: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
            { description: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
          ],
        };

        // Apply filters
        if (category) courseWhere.categoryId = category as string;
        if (level) courseWhere.level = level as string;
        if (price === 'free') courseWhere.price = 0;
        else if (price === 'paid') courseWhere.price = { gt: 0 };

        const courseOrderBy: any = {};
        switch (sortBy) {
          case 'rating': courseOrderBy.rating = 'desc'; break;
          case 'students': courseOrderBy.studentsCount = 'desc'; break;
          case 'newest': courseOrderBy.createdAt = 'desc'; break;
          case 'relevance': default: break;
        }

        const [courses, totalCourses] = await Promise.all([
          prisma.course.findMany({
            where: courseWhere,
            orderBy: courseOrderBy,
            take: type === 'all' ? 10 : limitNum,
            skip: type === 'all' ? 0 : skip,
            include: {
              instructor: {
                select: {
                  id: true,
                  firstName: true,
                  lastName: true,
                  photo: true,
                  expertise: true,
                },
              },
              category: {
                select: {
                  id: true,
                  name: true,
                  slug: true,
                  icon: true,
                  color: true,
                },
              },
              _count: {
                select: {
                  enrollments: true,
                  reviews: true,
                  lessons: true,
                },
              },
            },
          }),
          prisma.course.count({ where: courseWhere }),
        ]);

        results.courses = courses.map(c => ({
          ...c,
          type: 'course' as const,
        }));
        results.meta.totalResults += totalCourses;

        if (type === 'courses') {
          results.pagination = {
            page: pageNum,
            limit: limitNum,
            total: totalCourses,
            totalPages: Math.ceil(totalCourses / limitNum),
            hasMore: skip + courses.length < totalCourses,
          };
        }
      }

      // ============================================
      // SEARCH INSTRUCTORS
      // ============================================
      if (type === 'all' || type === 'instructors') {
        const instructorWhere: any = {
          role: 'INSTRUCTOR',
          isActive: true,
          OR: [
            { firstName: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
            { lastName: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
            { email: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
            { expertise: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
          ],
        };

        const [instructors, totalInstructors] = await Promise.all([
          prisma.user.findMany({
            where: instructorWhere,
            take: type === 'all' ? 5 : limitNum,
            skip: type === 'all' ? 0 : skip,
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              photo: true,
              expertise: true,
              bio: true,
              isVerifiedInstructor: true,
            },
          }),
          prisma.user.count({ where: instructorWhere }),
        ]);

        // Get course and follower counts
        const instructorIds = instructors.map(i => i.id);
        let instructorCounts: any = { courses: {}, followers: {} };

        if (instructorIds.length > 0) {
          const [courseCounts, followerCounts] = await Promise.all([
            prisma.course.groupBy({
              by: ['instructorId'],
              where: {
                instructorId: { in: instructorIds },
                status: 'PUBLISHED',
                isPublished: true,
              },
              _count: true,
            }),
            prisma.instructorFollow.groupBy({
              by: ['instructorId'],
              where: {
                instructorId: { in: instructorIds },
              },
              _count: true,
            }),
          ]);

          instructorCounts.courses = Object.fromEntries(
            courseCounts.map(c => [c.instructorId, c._count])
          );
          instructorCounts.followers = Object.fromEntries(
            followerCounts.map((f: any) => [f.instructorId, f._count])
          );
        }

        results.instructors = instructors.map(i => ({
          id: i.id,
          firstName: i.firstName,
          lastName: i.lastName,
          name: `${i.firstName} ${i.lastName}`,
          photo: i.photo || `https://ui-avatars.com/api/?name=${i.firstName}+${i.lastName}&size=150&background=4F46E5&color=fff`,
          expertise: i.expertise || 'Instructor',
          bio: i.bio,
          isVerified: i.isVerifiedInstructor || false,
          studentsCount: instructorCounts.followers[i.id] || 0,
          coursesCount: instructorCounts.courses[i.id] || 0,
          type: 'instructor' as const,
        }));
        results.meta.totalResults += totalInstructors;

        if (type === 'instructors') {
          results.pagination = {
            page: pageNum,
            limit: limitNum,
            total: totalInstructors,
            totalPages: Math.ceil(totalInstructors / limitNum),
            hasMore: skip + instructors.length < totalInstructors,
          };
        }
      }

      // ============================================
      // SEARCH CATEGORIES
      // ============================================
      if (type === 'all' || type === 'categories') {
        const categoryWhere: any = {
          OR: [
            { name: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
            { description: { contains: searchQuery, mode: 'insensitive' as Prisma.QueryMode } },
          ],
        };

        const [categories, totalCategories] = await Promise.all([
          prisma.category.findMany({
            where: categoryWhere,
            take: type === 'all' ? 5 : limitNum,
            skip: type === 'all' ? 0 : skip,
            include: {
              _count: {
                select: {
                  courses: {
                    where: {
                      status: 'PUBLISHED',
                      isPublished: true,
                    },
                  },
                },
              },
            },
          }),
          prisma.category.count({ where: categoryWhere }),
        ]);

        results.categories = categories.map(c => ({
          id: c.id,
          name: c.name,
          slug: c.slug,
          icon: c.icon || 'folder',
          color: c.color || '#7C3AED',
          description: c.description,
          courseCount: c._count.courses,
          type: 'category' as const,
        }));
        results.meta.totalResults += totalCategories;

        if (type === 'categories') {
          results.pagination = {
            page: pageNum,
            limit: limitNum,
            total: totalCategories,
            totalPages: Math.ceil(totalCategories / limitNum),
            hasMore: skip + categories.length < totalCategories,
          };
        }
      }

      res.status(200).json({
        success: true,
        message: "Search results retrieved successfully",
        data: results,
      });
    } catch (error) {
      console.error('❌ Search error:', error);
      next(error);
    }
  }

  /**
   * Get trending/popular items
   * GET /api/search/trending
   */
  async getTrending(req: Request, res: Response, next: NextFunction) {
    try {
      const [trendingCourses, topInstructors, popularCategories] = await Promise.all([
        // Trending courses
        prisma.course.findMany({
          where: {
            status: 'PUBLISHED',
            isPublished: true,
          },
          orderBy: [
            { studentsCount: 'desc' },
            { rating: 'desc' },
          ],
          take: 10,
          include: {
            instructor: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
                photo: true,
              },
            },
            category: {
              select: {
                id: true,
                name: true,
                slug: true,
                icon: true,
                color: true,
              },
            },
            _count: {
              select: {
                enrollments: true,
                reviews: true,
              },
            },
          },
        }),
        // Top instructors
        prisma.user.findMany({
          where: {
            role: 'INSTRUCTOR',
            isActive: true,
          },
          take: 5,
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photo: true,
            expertise: true,
            isVerifiedInstructor: true,
          },
        }),
        // Popular categories
        prisma.category.findMany({
          where: {
            courses: {
              some: {
                status: 'PUBLISHED',
                isPublished: true,
              },
            },
          },
          take: 5,
          include: {
            _count: {
              select: {
                courses: {
                  where: {
                    status: 'PUBLISHED',
                    isPublished: true,
                  },
                },
              },
            },
          },
        }),
      ]);

      // Get instructor counts
      const instructorIds = topInstructors.map(i => i.id);
      let instructorCounts: any = { courses: {}, followers: {} };

      if (instructorIds.length > 0) {
        const [courseCounts, followerCounts] = await Promise.all([
          prisma.course.groupBy({
            by: ['instructorId'],
            where: {
              instructorId: { in: instructorIds },
              status: 'PUBLISHED',
              isPublished: true,
            },
            _count: true,
          }),
          prisma.instructorFollow.groupBy({
            by: ['instructorId'],
            where: {
              instructorId: { in: instructorIds },
            },
            _count: true,
          }),
        ]);

        instructorCounts.courses = Object.fromEntries(
          courseCounts.map(c => [c.instructorId, c._count])
        );
        instructorCounts.followers = Object.fromEntries(
          followerCounts.map((f: any) => [f.instructorId, f._count])
        );
      }

      res.status(200).json({
        success: true,
        message: "Trending content retrieved",
        data: {
          trendingCourses: trendingCourses.map(c => ({
            ...c,
            type: 'course' as const,
          })),
          topInstructors: topInstructors.map(i => ({
            id: i.id,
            name: `${i.firstName} ${i.lastName}`,
            photo: i.photo || `https://ui-avatars.com/api/?name=${i.firstName}+${i.lastName}&size=150&background=4F46E5&color=fff`,
            expertise: i.expertise || 'Instructor',
            isVerified: i.isVerifiedInstructor || false,
            studentsCount: instructorCounts.followers[i.id] || 0,
            coursesCount: instructorCounts.courses[i.id] || 0,
            type: 'instructor' as const,
          })),
          popularCategories: popularCategories.map(c => ({
            ...c,
            type: 'category' as const,
          })),
        },
      });
    } catch (error) {
      console.error('❌ Trending error:', error);
      next(error);
    }
  }

  /**
   * Get search suggestions (autocomplete)
   * GET /api/search/suggestions?q=query
   */
  async getSuggestions(req: Request, res: Response, next: NextFunction) {
    try {
      const { q } = req.query;
      const query = (q as string)?.trim() || '';

      if (!query || query.length < 2) {
        return res.status(200).json({
          success: true,
          data: [],
        });
      }

      // Search courses (titles only for suggestions)
      const courses = await prisma.course.findMany({
        where: {
          status: 'PUBLISHED',
          isPublished: true,
          title: { contains: query, mode: 'insensitive' as Prisma.QueryMode },
        },
        select: {
          id: true,
          title: true,
          thumbnail: true,
          rating: true,
          studentsCount: true,
        },
        take: 5,
        orderBy: [
          { studentsCount: 'desc' },
          { rating: 'desc' },
        ],
      });

      // Search instructors
      const instructors = await prisma.user.findMany({
        where: {
          role: 'INSTRUCTOR',
          isActive: true,
          OR: [
            { firstName: { contains: query, mode: 'insensitive' as Prisma.QueryMode } },
            { lastName: { contains: query, mode: 'insensitive' as Prisma.QueryMode } },
          ],
        },
        select: {
          id: true,
          firstName: true,
          lastName: true,
          photo: true,
          expertise: true,
        },
        take: 3,
      });

      // Search categories
      const categories = await prisma.category.findMany({
        where: {
          name: { contains: query, mode: 'insensitive' as Prisma.QueryMode },
        },
        select: {
          id: true,
          name: true,
          slug: true,
          icon: true,
        },
        take: 3,
      });

      // Format suggestions
      const suggestions = [
        ...courses.map((c) => ({
          id: c.id,
          type: 'course' as const,
          title: c.title,
          subtitle: `${c.rating?.toFixed(1) || 0} ⭐ • ${c.studentsCount || 0} students`,
          image: c.thumbnail,
        })),
        ...instructors.map((i) => ({
          id: i.id,
          type: 'instructor' as const,
          title: `${i.firstName} ${i.lastName}`,
          subtitle: i.expertise || 'Instructor',
          image: i.photo || `https://ui-avatars.com/api/?name=${i.firstName}+${i.lastName}&size=150&background=4F46E5&color=fff`,
        })),
        ...categories.map((c) => ({
          id: c.id,
          type: 'category' as const,
          title: c.name,
          subtitle: 'Category',
          icon: c.icon,
        })),
      ];

      res.status(200).json({
        success: true,
        data: suggestions,
        query,
      });
    } catch (error) {
      console.error('❌ Suggestion error:', error);
      next(error);
    }
  }

  /**
   * Search by type (courses, instructors, categories)
   * GET /api/search/:type?q=query
   */
  async searchByType(req: Request, res: Response, next: NextFunction) {
    try {
      const { type } = req.params;
      req.query.type = type;
      return this.unifiedSearch(req, res, next);
    } catch (error) {
      console.error('❌ Search by type error:', error);
      next(error);
    }
  }

  /**
   * Get recent searches for user
   * GET /api/search/recent
   */
  async getRecentSearches(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return res.status(200).json({
          success: true,
          data: [],
        });
      }

      const recentSearches = await (prisma as any).recentSearch.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        take: 10,
        select: {
          query: true,
        },
      });

      res.status(200).json({
        success: true,
        data: recentSearches.map((r: { query: any; }) => r.query),
      });
    } catch (error) {
      console.error('❌ Recent searches error:', error);
      next(error);
    }
  }

  /**
   * Save a recent search
   * POST /api/search/recent
   */
  async saveRecentSearch(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id;
      const { query } = req.body;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
        });
      }

      if (!query || !query.trim()) {
        return res.status(400).json({
          success: false,
          message: 'Query is required',
        });
      }

      // Delete existing entry
      await (prisma as any).recentSearch.deleteMany({
        where: {
          userId,
          query: query.trim(),
        },
      });

      // Create new recent search
      const recentSearch = await (prisma as any).recentSearch.create({
        data: {
          userId,
          query: query.trim(),
        },
      });

      // Keep only last 10
      const count = await (prisma as any).recentSearch.count({
        where: { userId },
      });

      if (count > 10) {
        const toDelete = await (prisma as any).recentSearch.findMany({
          where: { userId },
          orderBy: { createdAt: 'asc' },
          take: count - 10,
          select: { id: true },
        });

        await (prisma as any).recentSearch.deleteMany({
          where: {
            id: { in: toDelete.map((r: { id: any; }) => r.id) },
          },
        });
      }

      res.status(201).json({
        success: true,
        message: 'Recent search saved',
        data: recentSearch,
      });
    } catch (error) {
      console.error('❌ Save recent search error:', error);
      next(error);
    }
  }

  /**
   * Clear all recent searches
   * DELETE /api/search/recent
   */
  async clearRecentSearches(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated',
        });
      }

      await (prisma as any).recentSearch.deleteMany({
        where: { userId },
      });

      res.status(200).json({
        success: true,
        message: 'Recent searches cleared',
      });
    } catch (error) {
      console.error('❌ Clear recent searches error:', error);
      next(error);
    }
  }
}