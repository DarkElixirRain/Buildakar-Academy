import type { Request,Response,NextFunction } from "express";
import { createReview, deleteReview, getCourseReviews, getMyReview, updateReview } from "../services/review.service";

export async function CreateReview(req:Request,res:Response,next:NextFunction) {
    try {
        const {rating,comment} = req.body
        const courseId = req.params.courseId;
        const userId = req.user!.id;

        if(!rating || rating <1 ){
            return res.status(401).json("Rating should be aleast 1")
        }
        if(!userId){
            return res.status(401).json("User is not authorized")
        }
        if(!courseId){
            return res.status(404).json("Course not found")
        }
        const createreview = await createReview(userId,courseId,rating,comment)

        if(!createReview){
        return res.status(401).json("Error while creating review")
        }

        return res.status(201).json({
        success: true,
        message: 'Review created successfully',
        data: createreview,
      });

        
    } catch (error) {
         next(error);
    }
}


export async function UpdateReview(req:Request,res:Response,next:NextFunction){
     try {
      const userId = req.user!.id;
      const { id } = req.params;
      const { rating, comment } = req.body;
 
      const review = await updateReview(
        id,
        userId,
        rating !== undefined ? Number(rating) : undefined,
        comment
      );
 
      return res.status(200).json({
        success: true,
        message: 'Review updated successfully',
        data: review,
      });
    } catch (error) {
      next(error);
    }
}

export async function DeleteReview(req: Request, res: Response, next: NextFunction) {
        try {
             const userId = req.user!.id;
      const userRole = req.user!.role;
      const { id } = req.params;
 
      await deleteReview(id, userId, userRole);
 
      return res.status(200).json({
        success: true,
        message: 'Review deleted successfully',
      });
        } catch (error) {
              next(error);
        }
}

export async function getCourseReview(req:Request,res:Response,next:NextFunction) {
     try {
      const { courseId } = req.params;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 10;
 
      const result = await getCourseReviews(
        courseId,
        page,
        limit
      );
 
      return res.status(200).json({
        success: true,
        message: 'Reviews retrieved successfully',
        data: result.data,
        meta: {
          total: result.total,
          page: result.page,
          limit: result.limit,
          totalPages: Math.ceil(result.total / result.limit),
          averageRating: result.averageRating,
          ratingBreakdown: result.ratingBreakdown,
        },
      });
    } catch (error) {
      next(error);
    }
}

export async function getMyReviews(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { courseId } = req.params;
 
      const review = await getMyReview(userId, courseId);
 
      return res.status(200).json({
        success: true,
        message: review ? 'Review found' : 'No review yet',
        data: review,
      });
    } catch (error) {
      next(error);
    }
  }
