import { Prisma } from '@prisma/client';

type PrismaTransaction = Prisma.TransactionClient;

/**
 * Recalculates and updates Course.rating based on the
 * average of all Review.rating rows for that course.
 * Must run inside a Prisma transaction.
 */
export async function recalculateCourseRating(
  tx: PrismaTransaction,
  courseId: string
): Promise<void> {
  const result = await tx.review.aggregate({
    where: { courseId },
    _avg: { rating: true },
    _count: { rating: true },
  });

  const avgRating = result._avg.rating ?? 0;

  await tx.course.update({
    where: { id: courseId },
    data: { rating: Math.round(avgRating * 10) / 10 }, // round to 1 decimal
  });
}

/**
 * Recalculates and updates instructor's averageRating and
 * totalReviews across all their courses.
 * Must run inside a Prisma transaction.
 */
export async function recalculateInstructorRating(
  tx: PrismaTransaction,
  instructorId: string
): Promise<void> {
  const result = await tx.review.aggregate({
    where: {
      course: { instructorId },
    },
    _avg: { rating: true },
    _count: { rating: true },
  });

  const avgRating = result._avg.rating ?? 0;
  const totalReviews = result._count.rating ?? 0;

  await tx.user.update({
    where: { id: instructorId },
    data: {
      averageRating: Math.round(avgRating * 10) / 10,
      totalReviews,
    },
  });
}