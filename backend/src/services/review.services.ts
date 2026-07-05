import { PrismaClient } from '@prisma/client';
import {
  recalculateCourseRating,
  recalculateInstructorRating,
} from '../utils/rating';
 
const prisma = new PrismaClient();
 
function createError(message: string, statusCode: number): Error {
  return Object.assign(new Error(message), { statusCode });
}

export interface ReviewWithUser {
  id: string;
  rating: number;
  comment: string | null;
  createdAt: Date;
  updatedAt: Date;
  userId: string;
  courseId: string;
  user: {
    id: string;
    firstName: string;
    lastName: string;
    photo: string | null;
  };
}
 
export interface RatingBreakdown {
  1: number;
  2: number;
  3: number;
  4: number;
  5: number;
}
 
export interface PaginatedReviews {
  data: ReviewWithUser[];
  total: number;
  page: number;
  limit: number;
  averageRating: number;
  ratingBreakdown: RatingBreakdown;
}

export async function createReview(userId:string,courseId:string,rating:number,comment?:string){
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
      throw createError('Rating must be an integer between 1 and 5', 400);
    }

const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });

    if (!enrollment) {
      throw createError(
        'You must be enrolled in this course to leave a review',
        403
      );
    }

    const existing = await prisma.review.findUnique({
      where: { userId_courseId: { userId, courseId } },
    });
 
    if (existing) {
      throw createError(
        'You have already reviewed this course',
        400
      );
    }

    const course = await prisma.course.findUnique({
      where: { id: courseId },
      select: { instructorId: true },
    });
 
    if (!course) {
      throw createError('Course not found', 404);
    }

    const review = await prisma.$transaction(async (tx) => {
      const created = await tx.review.create({
        data: { userId, courseId, rating, comment },
        include: {
          user: { select: { id: true, firstName: true, lastName: true, photo: true } },
        },
      });
 
      await recalculateCourseRating(tx, courseId);
      await recalculateInstructorRating(tx, course.instructorId);
 
      return created;
    });
 
    return review as ReviewWithUser;

}

export async function updateReview( reviewId: string,
    userId: string,
    rating?: number,
    comment?: string): Promise<ReviewWithUser>{

    if (rating !== undefined) {
      if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
        throw createError('Rating must be an integer between 1 and 5', 400);
      }
    }
    const review = await prisma.review.findUnique({
      where: { id: reviewId },
      include: { course: { select: { instructorId: true } } },
    });

     if (!review) throw createError('Review not found', 404);
    if (review.userId !== userId) throw createError('Forbidden', 403);

     const updated = await prisma.$transaction(async (tx) => {
      const result = await tx.review.update({
        where: { id: reviewId },
        data: {
          ...(rating !== undefined && { rating }),
          ...(comment !== undefined && { comment }),
        },
        include: {
          user: { select: { id: true, firstName: true, lastName: true, photo: true } },
        },
      });
       await recalculateCourseRating(tx, review.courseId);
      await recalculateInstructorRating(tx, review.course.instructorId);
 
      return result;
    });

        return updated as ReviewWithUser;
    }

export async function deleteReview( reviewId: string,
    userId: string,
    userRole: string) {
    const review = await prisma.review.findUnique({
      where: { id: reviewId },
      include: { course: { select: { instructorId: true } } },
    });
 
    if (!review) throw createError('Review not found', 404);
 
    if (review.userId !== userId && userRole !== 'ADMIN') {
      throw createError('Forbidden', 403);
    }
 
    await prisma.$transaction(async (tx) => {
      await tx.review.delete({ where: { id: reviewId } });
      await recalculateCourseRating(tx, review.courseId);
      await recalculateInstructorRating(tx, review.course.instructorId);
    });
 
    return { success: true };
}

export async function getCourseReviews(courseId: string,
    page: number = 1,
    limit: number = 10
  ): Promise<PaginatedReviews> {
    const skip = (page - 1) * limit;
 
    const [reviews, total, aggregate, breakdown] = await Promise.all([
      prisma.review.findMany({
        where: { courseId },
        include: {
          user: {
            select: { id: true, firstName: true, lastName: true, photo: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
 
      prisma.review.count({ where: { courseId } }),
 
      prisma.review.aggregate({
        where: { courseId },
        _avg: { rating: true },
      }),
 
      // Rating breakdown — count per star level
      prisma.review.groupBy({
        by: ['rating'],
        where: { courseId },
        _count: { rating: true },
      }),
    ]);
 
    // Build breakdown object { 1: 0, 2: 3, 3: 5, 4: 12, 5: 30 }
    const ratingBreakdown: RatingBreakdown = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    for (const row of breakdown) {
      ratingBreakdown[row.rating as keyof RatingBreakdown] = row._count.rating;
    }
 
    return {
      data: reviews as ReviewWithUser[],
      total,
      page,
      limit,
      averageRating: Math.round((aggregate._avg.rating ?? 0) * 10) / 10,
      ratingBreakdown,
    };
  }

export async  function  getMyReview(
    userId: string,
    courseId: string
  ): Promise<ReviewWithUser | null> {
    const review = await prisma.review.findUnique({
      where: { userId_courseId: { userId, courseId } },
      include: {
        user: {
          select: { id: true, firstName: true, lastName: true, photo: true },
        },
      },
    });
 
    return review as ReviewWithUser | null;
  }
 