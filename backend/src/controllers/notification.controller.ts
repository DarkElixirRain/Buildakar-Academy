import { Request, Response, NextFunction } from 'express';
import { deleteNotification, getUnreadCount, getUserNotification,markAllAsRead,markAsRead,removePushToken,savePushToken } from '../services/notification.service';

export async function getNotification(req:Request,res:Response,next:NextFunction){
     try {
      const userId = req.user!.id;
      const page = parseInt(req.query.page as string) || 1;
      const limit = parseInt(req.query.limit as string) || 20;
 
      const result = await getUserNotification(
        userId,
        page,
        limit
      );
 
      return res.status(200).json({
        success: true,
        message: 'Notifications retrieved successfully',
        data: result.data,
        meta: {
          total: result.total,
          unreadCount: result.unreadCount,
          page: result.page,
          limit: result.limit,
          totalPages: result.totalPages,
        },
      });
    } catch (error) {
      next(error);
    }
}

 export async function getUnreadCounts(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const count = await getUnreadCount(userId);
 
      return res.status(200).json({
        success: true,
        data: { count },
      });
    } catch (error) {
      next(error);
    }
  }

 export async function markasRead(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
 
      await markAsRead(id, userId);
 
      return res.status(200).json({
        success: true,
        message: 'Notification marked as read',
      });
    } catch (error) {
      next(error);
    }
  }

export   async function markallAsRead(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      await markAllAsRead(userId);
 
      return res.status(200).json({
        success: true,
        message: 'All notifications marked as read',
      });
    } catch (error) {
      next(error);
    }
  }

 export  async function deletenotification(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { id } = req.params;
 
      await deleteNotification(id, userId);
 
      return res.status(200).json({
        success: true,
        message: 'Notification deleted',
      });
    } catch (error) {
      next(error);
    }
  } 

 export async function savepushToken(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      const { pushToken } = req.body;
 
      if (!pushToken || typeof pushToken !== 'string') {
        return res.status(400).json({
          success: false,
          message: 'pushToken is required',
        });
      }
 
      await savePushToken(userId, pushToken);
 
      return res.status(200).json({
        success: true,
        message: 'Push token saved',
      });
    } catch (error) {
      next(error);
    }
  }

  export async function removepushToken(req: Request, res: Response, next: NextFunction) {
    try {
      const userId = req.user!.id;
      await removePushToken(userId);
 
      return res.status(200).json({
        success: true,
        message: 'Push token removed',
      });
    } catch (error) {
      next(error);
    }
  }
